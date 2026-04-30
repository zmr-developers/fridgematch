import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/localization_helper.dart';
import '../db/database_helper.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allIngredients = [];
  List<Map<String, dynamic>> _filtered = [];
  final Set<String> _selected = {};
  final TextEditingController _search = TextEditingController();
  BannerAd? _banner;
  InterstitialAd? _interstitial;
  int _tab = 0;
  late TabController _tabController;
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _baseResults = [];
  List<Map<String, dynamic>> _shopping = [];
  List<Map<String, dynamic>> _favMeals = [];
  bool _loading = true;
  String _sortBy = 'match';
  String _cuisineFilter = 'all';
  List<String> _availableCuisines = [];

  // FIX 1: Category filter for ingredient tab
  String _categoryFilter = 'all';

  Map<String, bool> _profile = {
    'pregnant': false, 'diabetic': false, 'heart': false,
    'athlete': false, 'weight_loss': false,
  };
  Map<String, bool> _dietary = {
    'halal': false, 'vegetarian': false, 'vegan': false, 'gluten_free': false,
  };

  static const _cats = ['vegetables', 'fruits', 'proteins', 'grains', 'dairy', 'condiments', 'spices', 'other'];
  static const _catEmojis = {
    'vegetables': '🥦', 'fruits': '🍎', 'proteins': '🥩', 'grains': '🌾',
    'dairy': '🥛', 'condiments': '🫙', 'spices': '🌶️', 'other': '📦',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() => _tab = _tabController.index));
    _loadBanner();
    _loadAll();
  }

  void _loadBanner() {
    _banner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _showInterstitialIfNeeded() {
    LocalizationHelper.incrementAd();
    if (LocalizationHelper.shouldShowAd() && _interstitial != null) {
      _interstitial!.show();
      _interstitial = null;
      _loadInterstitial();
    }
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'en';
    LocalizationHelper.currentLanguage = lang;
    _meals = await DatabaseHelper.getMeals();
    _allIngredients = await DatabaseHelper.getIngredients();
    _favMeals = await DatabaseHelper.getFavoriteMeals();
    _shopping = await DatabaseHelper.getShoppingItems();
    _filtered = List.from(_allIngredients);

    final cuisines = _meals
        .map((m) => m['cuisine'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cuisines.sort();
    _availableCuisines = cuisines;

    final profileStr = prefs.getString('health_profile');
    if (profileStr != null) _profile = Map<String, bool>.from(jsonDecode(profileStr));
    final dietStr = prefs.getString('dietary_filters');
    if (dietStr != null) _dietary = Map<String, bool>.from(jsonDecode(dietStr));
    setState(() => _loading = false);
    _loadInterstitial();
  }

  void _filterIngredients(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allIngredients)
          : _allIngredients.where((i) {
              final name = LocalizationHelper.ingredientName(i).toLowerCase();
              return name.contains(q.toLowerCase());
            }).toList();
      // Reset category filter when searching
      if (q.isNotEmpty) _categoryFilter = 'all';
    });
  }

  List<String> _parseIngredients(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  // FIX 2: Clear results when no ingredients selected
  void _clearResultsIfEmpty() {
    if (_selected.isEmpty) {
      setState(() {
        _results = [];
        _baseResults = [];
        _cuisineFilter = 'all';
        _sortBy = 'match';
      });
    }
  }

  void _findMeals() {
    _showInterstitialIfNeeded();
    List<Map<String, dynamic>> results = [];

    for (final meal in _meals) {
      final req = _parseIngredients(meal['required_ingredients']);
      if (req.isEmpty) continue;
      final have = req.where((r) => _selected.contains(r)).length;
      final pct = (have / req.length * 100).round();
      if (pct > 0) results.add({...meal, 'match_pct': pct, 'have': have, 'total': req.length});
    }

    // Dietary filter
    if (_dietary.values.any((v) => v)) {
      results = results.where((m) {
        final tagsRaw = m['dietary_tags'];
        final tags = tagsRaw is List
            ? tagsRaw.map((e) => e.toString()).toList()
            : tagsRaw is String
                ? tagsRaw.split(',').map((e) => e.trim()).toList()
                : <String>[];
        for (final f in _dietary.entries) {
          if (f.value && !tags.contains(f.key)) return false;
        }
        return true;
      }).toList();
    }

    _baseResults = List.from(results);
    _cuisineFilter = 'all';
    _applyFiltersToResults(baseResults: results);

    setState(() {
      _tab = 1;
      _tabController.animateTo(1);
    });
  }

  void _applyFiltersToResults({List<Map<String, dynamic>>? baseResults}) {
    final source = baseResults ?? List.from(_baseResults);
    if (source.isEmpty) return;

    int sortFn(Map a, Map b) {
      if (_sortBy == 'calories' || _profile['weight_loss'] == true) {
        final ac = (a['calories'] ?? 999) is int ? a['calories'] as int : int.tryParse(a['calories'].toString()) ?? 999;
        final bc = (b['calories'] ?? 999) is int ? b['calories'] as int : int.tryParse(b['calories'].toString()) ?? 999;
        return ac.compareTo(bc);
      }
      return (b['match_pct'] as int).compareTo(a['match_pct'] as int);
    }

    List<Map<String, dynamic>> sorted;
    if (_cuisineFilter == 'all') {
      sorted = List.from(source)..sort(sortFn);
    } else {
      final matching = source.where((m) => m['cuisine'] == _cuisineFilter).toList();
      final others = source.where((m) => m['cuisine'] != _cuisineFilter).toList();
      matching.sort(sortFn);
      others.sort(sortFn);
      sorted = [...matching, ...others];
    }

    setState(() => _results = sorted);
  }

  Future<void> _addMissingToShopping(Map<String, dynamic> meal) async {
    final req = _parseIngredients(meal['required_ingredients']);
    final missing = req.where((r) => !_selected.contains(r)).toList();

    if (missing.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocalizationHelper.t('already_have_all')),
          backgroundColor: Colors.green,
        ));
      }
      return;
    }

    for (final m in missing) {
      final ing = _allIngredients.firstWhere(
        (i) => i['id'].toString() == m.toString(),
        orElse: () => {'name_en': m, 'name_ar': m, 'name_fr': m, 'name_es': m},
      );
      await DatabaseHelper.addShoppingItem(LocalizationHelper.ingredientName(ing));
    }
    _shopping = await DatabaseHelper.getShoppingItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${missing.length} ${LocalizationHelper.t('missing_added')}'),
        backgroundColor: Colors.green,
      ));
    }

    setState(() {
      _tab = 2;
      _tabController.animateTo(2);
    });
  }

  Future<void> _toggleFavorite(int mealId) async {
    await DatabaseHelper.toggleFavorite(mealId);
    _favMeals = await DatabaseHelper.getFavoriteMeals();
    setState(() {});
  }

  String _getIngredientNameById(String id) {
    final ing = _allIngredients.firstWhere(
      (i) => i['id'].toString() == id,
      orElse: () => {'name_en': id, 'name_ar': id, 'name_fr': id},
    );
    return LocalizationHelper.ingredientName(ing);
  }

  // ─── INGREDIENT TAB WITH CATEGORY FILTER ──────────────────────
  Widget _buildIngredientTab() {
    final scheme = Theme.of(context).colorScheme;

    // Build grouped map
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final cat in _cats) grouped[cat] = [];
    for (final i in _filtered) {
      final cat = i['category'] as String? ?? 'other';
      grouped[cat] ??= [];
      grouped[cat]!.add(i);
    }

    // Determine which categories to show
    final catsToShow = _categoryFilter == 'all'
        ? _cats.where((c) => (grouped[c] ?? []).isNotEmpty).toList()
        : [_categoryFilter];

    return Column(children: [
      // Search bar
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: TextField(
          controller: _search,
          onChanged: _filterIngredients,
          decoration: InputDecoration(
            hintText: LocalizationHelper.t('search'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _search.clear();
                      _filterIngredients('');
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ),

      // FIX 1: Category filter chips
      SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _catChip('all', '🍽️', 'All'),
            ..._cats.map((cat) {
              final count = (grouped[cat] ?? []).length;
              if (count == 0) return const SizedBox.shrink();
              return _catChip(cat, _catEmojis[cat] ?? '📦', LocalizationHelper.t(cat));
            }),
          ],
        ),
      ),

      const SizedBox(height: 4),

      // Selected count + clear
      if (_selected.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(children: [
            Icon(Icons.check_circle, size: 16, color: scheme.primary),
            const SizedBox(width: 4),
            Text(
              '${_selected.length} ${LocalizationHelper.t('have')}',
              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() => _selected.clear());
                _clearResultsIfEmpty(); // FIX 2
              },
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(LocalizationHelper.t('clear_all'), style: const TextStyle(fontSize: 13)),
            ),
          ]),
        ),

      // Ingredient grid
      Expanded(
        child: ListView(
          children: catsToShow.map((cat) {
            final items = grouped[cat] ?? [];
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(children: [
                  Text(_catEmojis[cat] ?? '📦', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(LocalizationHelper.t(cat),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 8),
                  // Selected count in this category
                  Builder(builder: (_) {
                    final selCount = items.where((i) => _selected.contains(i['id'].toString())).length;
                    if (selCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$selCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    );
                  }),
                ]),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                  final ing = items[idx];
                  final id = ing['id'].toString();
                  final sel = _selected.contains(id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (sel) {
                          _selected.remove(id);
                        } else {
                          _selected.add(id);
                        }
                      });
                      // FIX 2: clear results if nothing selected
                      _clearResultsIfEmpty();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: sel ? scheme.primaryContainer : scheme.surface,
                        border: Border.all(
                          color: sel ? scheme.primary : Colors.grey.shade300,
                          width: sel ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(ing['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 3),
                        Text(
                          LocalizationHelper.ingredientName(ing),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (sel) Icon(Icons.check_circle, size: 12, color: scheme.primary),
                      ]),
                    ),
                  );
                },
              ),
            ]);
          }).toList(),
        ),
      ),

      // Find Meals button
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selected.isEmpty ? null : _findMeals,
            icon: const Icon(Icons.search),
            label: Text(
              _selected.isEmpty
                  ? LocalizationHelper.t('find_meals')
                  : '${LocalizationHelper.t('find_meals')} (${_selected.length})',
              style: const TextStyle(fontSize: 15),
            ),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(13)),
          ),
        ),
      ),
    ]);
  }

  // Category chip widget
  Widget _catChip(String value, String emoji, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _categoryFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _categoryFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : null,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildResultsTab() {
    final scheme = Theme.of(context).colorScheme;

    if (_results.isEmpty && _selected.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🥗', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              LocalizationHelper.t('no_ingredients_selected'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ]),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🍽️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(LocalizationHelper.t('no_results'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ]),
        ),
      );
    }

    final cuisineSplitIndex = _cuisineFilter != 'all'
        ? _results.indexWhere((m) => m['cuisine'] != _cuisineFilter)
        : -1;

    return Column(children: [
      // Sort + Cuisine filter bar
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              setState(() => _sortBy = _sortBy == 'match' ? 'calories' : 'match');
              _applyFiltersToResults();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.primary),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.sort, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  _sortBy == 'match'
                      ? LocalizationHelper.t('sort_match')
                      : LocalizationHelper.t('sort_calories'),
                  style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          _cuisineChip(LocalizationHelper.t('all_cuisines'), 'all'),
          ..._availableCuisines.map((c) => _cuisineChip(c, c)),
        ]),
      ),

      // Results count
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(children: [
          Text(
            '${_results.length} ${_results.length == 1 ? 'meal' : 'meals'}',
            style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.bold),
          ),
          if (_cuisineFilter != 'all') ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(10)),
              child: Text('$_cuisineFilter first',
                  style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        ]),
      ),

      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: _results.length + (cuisineSplitIndex > 0 ? 1 : 0),
          itemBuilder: (ctx, rawIndex) {
            if (cuisineSplitIndex > 0 && rawIndex == cuisineSplitIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Other cuisines',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ),
                  const Expanded(child: Divider()),
                ]),
              );
            }

            final i = cuisineSplitIndex > 0 && rawIndex > cuisineSplitIndex
                ? rawIndex - 1
                : rawIndex;

            final meal = _results[i];
            final pct = meal['match_pct'] as int;
            final isFav = _favMeals.any((f) => f['id'] == meal['id']);
            final warningsRaw = meal['warnings'];
            final warnings = warningsRaw is Map
                ? warningsRaw
                : warningsRaw is String && warningsRaw.isNotEmpty
                    ? (jsonDecode(warningsRaw) as Map? ?? {})
                    : <String, dynamic>{};
            final hasWarn =
                (_profile['pregnant'] == true && warnings['pregnant'] == true) ||
                (_profile['diabetic'] == true && warnings['diabetic'] == true) ||
                (_profile['heart'] == true && warnings['heart'] == true);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(meal['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(LocalizationHelper.mealName(meal),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        '${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  •  ${meal['calories']} ${LocalizationHelper.t('calories')}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ])),
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null, size: 22),
                      onPressed: () => _toggleFavorite(meal['id'] as int),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: pct >= 80 ? Colors.green : pct >= 50 ? Colors.orange : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${LocalizationHelper.t('match')}: $pct% (${meal['have']}/${meal['total']})',
                    style: TextStyle(
                      color: pct >= 80 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold, fontSize: 12,
                    ),
                  ),
                  if (hasWarn) ...[const SizedBox(height: 6), _buildWarning(warnings)],
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () {
                        _showMealDetail(meal);
                        _showInterstitialIfNeeded();
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                      child: Text(LocalizationHelper.t('view_detail'), style: const TextStyle(fontSize: 13)),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(
                      onPressed: () => _addMissingToShopping(meal),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                      child: Text(LocalizationHelper.t('add_shopping'), style: const TextStyle(fontSize: 13)),
                    )),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _cuisineChip(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _cuisineFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _cuisineFilter = value);
        _applyFiltersToResults();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? scheme.primary : scheme.outline),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : null,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  Widget _buildWarning(Map warnings) {
    final msgs = <String>[];
    if (_profile['pregnant'] == true && warnings['pregnant'] == true) msgs.add(LocalizationHelper.t('pregnant_warning'));
    if (_profile['diabetic'] == true && warnings['diabetic'] == true) msgs.add(LocalizationHelper.t('diabetic_warning'));
    if (_profile['heart'] == true && warnings['heart'] == true) msgs.add(LocalizationHelper.t('heart_warning'));
    if (msgs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(msgs.join('\n'), style: const TextStyle(fontSize: 11, color: Colors.deepOrange)),
    );
  }

  void _showMealDetail(Map<String, dynamic> meal) {
    _showInterstitialIfNeeded();
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        bool isFav = _favMeals.any((f) => f['id'] == meal['id']);
        return StatefulBuilder(builder: (ctx, setS) {
          final req = _parseIngredients(meal['required_ingredients']);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            builder: (_, ctrl) => ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                Row(children: [
                  Text(meal['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(child: Text(LocalizationHelper.mealName(meal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                  IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : null, size: 32),
                    onPressed: () async {
                      await _toggleFavorite(meal['id'] as int);
                      setS(() { isFav = _favMeals.any((f) => f['id'] == meal['id']); });
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                Text('${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  |  ${meal['calories']} kcal',
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(LocalizationHelper.t('health_benefits'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(LocalizationHelper.healthBenefit(meal)),
                const Divider(height: 24),
                Text(LocalizationHelper.t('ingredients_detail'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...req.map((r) {
                  final have = _selected.contains(r);
                  final ing = _allIngredients.firstWhere(
                    (i) => i['id'].toString() == r.toString(),
                    orElse: () => {'id': r, 'name_en': r, 'name_ar': r, 'name_fr': r, 'emoji': '🍽️'},
                  );
                  final altsRaw = ing['alternatives'];
                  final altIds = altsRaw is List
                      ? altsRaw.map((e) => e.toString()).toList()
                      : altsRaw is String && altsRaw.isNotEmpty
                          ? altsRaw.split(',').map((e) => e.trim()).toList()
                          : <String>[];
                  final altNames = altIds.map((id) => _getIngredientNameById(id)).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Text(ing['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(LocalizationHelper.ingredientName(ing),
                            style: TextStyle(fontWeight: FontWeight.bold,
                                color: have ? Colors.green : Colors.red)),
                        if (!have && altNames.isNotEmpty)
                          Text('${LocalizationHelper.t('alternatives')}: ${altNames.join(', ')}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ])),
                      Icon(have ? Icons.check_circle : Icons.cancel,
                          color: have ? Colors.green : Colors.red, size: 20),
                    ]),
                  );
                }),
                const Divider(height: 24),
                Text(LocalizationHelper.t('recipe_steps'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(LocalizationHelper.recipeSteps(meal),
                    style: const TextStyle(fontSize: 14, height: 1.6)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addMissingToShopping(meal);
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(LocalizationHelper.t('add_shopping')),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildShoppingTab() {
    final scheme = Theme.of(context).colorScheme;
    if (_shopping.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(LocalizationHelper.t('no_shopping'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
          ]),
        ),
      );
    }

    final bought = _shopping.where((i) => i['bought'] == 1).length;

    return Column(children: [
      if (bought > 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(
              onPressed: () async {
                for (final item in _shopping.where((i) => i['bought'] == 1)) {
                  await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                }
                _shopping = await DatabaseHelper.getShoppingItems();
                setState(() {});
              },
              icon: const Icon(Icons.done_all, size: 16),
              label: Text(LocalizationHelper.t('clear_done'), style: const TextStyle(fontSize: 13)),
            ),
          ]),
        ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _shopping.length,
          itemBuilder: (ctx, i) {
            final item = _shopping[i];
            final isBought = item['bought'] == 1;
            return Dismissible(
              key: Key('shop_${item['id']}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                _shopping = await DatabaseHelper.getShoppingItems();
                setState(() {});
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: isBought,
                    activeColor: scheme.primary,
                    onChanged: (_) async {
                      await DatabaseHelper.toggleShoppingBought(item['id'] as int, item['bought'] as int);
                      _shopping = await DatabaseHelper.getShoppingItems();
                      setState(() {});
                    },
                  ),
                  title: Text(item['name'] ?? '',
                      style: TextStyle(
                        decoration: isBought ? TextDecoration.lineThrough : null,
                        color: isBought ? Colors.grey : null,
                        fontWeight: isBought ? FontWeight.normal : FontWeight.bold,
                      )),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                      _shopping = await DatabaseHelper.getShoppingItems();
                      setState(() {});
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildFavoritesTab() {
    if (_favMeals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('❤️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(LocalizationHelper.t('no_favorites'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
          ]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favMeals.length,
      itemBuilder: (ctx, i) {
        final meal = _favMeals[i];
        return Dismissible(
          key: Key('fav_${meal['id']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            await DatabaseHelper.toggleFavorite(meal['id'] as int);
            _favMeals = await DatabaseHelper.getFavoriteMeals();
            setState(() {});
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Text(meal['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
              title: Text(LocalizationHelper.mealName(meal),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  •  ${meal['calories']} kcal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMealDetail(meal),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('app_title'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              _showInterstitialIfNeeded();
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              await _loadAll();
              setState(() {});
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(icon: const Icon(Icons.kitchen, size: 20), text: LocalizationHelper.t('ingredients')),
            Tab(icon: const Icon(Icons.restaurant_menu, size: 20), text: LocalizationHelper.t('results')),
            Tab(icon: const Icon(Icons.shopping_cart, size: 20), text: LocalizationHelper.t('shopping')),
            Tab(icon: const Icon(Icons.favorite, size: 20), text: LocalizationHelper.t('favorites')),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            _buildIngredientTab(),
            _buildResultsTab(),
            _buildShoppingTab(),
            _buildFavoritesTab(),
          ]),
        ),
        if (_banner != null)
          SafeArea(
            top: false,
            child: SizedBox(height: 50, child: AdWidget(ad: _banner!)),
          ),
      ]),
    );
  }
}
