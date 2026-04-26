import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _navCount = 0;
  int _tab = 0;
  late TabController _tabController;
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _shopping = [];
  List<Map<String, dynamic>> _favMeals = [];
  bool _loading = true;
  Map<String, bool> _profile = {'pregnant': false, 'diabetic': false, 'heart': false, 'athlete': false, 'weight_loss': false};
  Map<String, bool> _dietary = {'halal': false, 'vegetarian': false, 'vegan': false, 'gluten_free': false};

  static const _cats = ['vegetables', 'fruits', 'proteins', 'grains', 'dairy', 'condiments', 'spices', 'other'];
  static const _catEmojis = {'vegetables': '🥦', 'fruits': '🍎', 'proteins': '🥩', 'grains': '🌾', 'dairy': '🥛', 'condiments': '🫙', 'spices': '🌶️', 'other': '📦'};

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
    );
    _banner!.load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { _interstitial = ad; },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _showInterstitialIfNeeded() {
    _navCount++;
    if (_navCount % 3 == 0 && _interstitial != null) {
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
    results.sort((a, b) {
      if (_profile['weight_loss'] == true) {
        final ac = (a['calories'] ?? 999) is int ? a['calories'] as int : int.tryParse(a['calories'].toString()) ?? 999;
        final bc = (b['calories'] ?? 999) is int ? b['calories'] as int : int.tryParse(b['calories'].toString()) ?? 999;
        return ac.compareTo(bc);
      }
      return (b['match_pct'] as int).compareTo(a['match_pct'] as int);
    });
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
    setState(() { _results = results; _tab = 1; _tabController.animateTo(1); });
  }

  Future<void> _addToShopping(Map<String, dynamic> meal) async {
    final req = _parseIngredients(meal['required_ingredients']);
    final missing = req.where((r) => !_selected.contains(r)).toList();
    for (final m in missing) {
      final ing = _allIngredients.firstWhere(
        (i) => i['id'].toString() == m.toString(),
        orElse: () => {'name_en': m, 'name_ar': m, 'name_fr': m},
      );
      await DatabaseHelper.addShoppingItem(LocalizationHelper.ingredientName(ing));
    }
    _shopping = await DatabaseHelper.getShoppingItems();
    setState(() { _tab = 2; _tabController.animateTo(2); });
  }

  Future<void> _toggleFavorite(int mealId) async {
    await DatabaseHelper.toggleFavorite(mealId);
    _favMeals = await DatabaseHelper.getFavoriteMeals();
    setState(() {});
  }

  Widget _buildIngredientTab() {
    final scheme = Theme.of(context).colorScheme;
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final cat in _cats) grouped[cat] = [];
    for (final i in _filtered) {
      final cat = i['category'] as String? ?? 'other';
      grouped[cat] ??= [];
      grouped[cat]!.add(i);
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _search,
          onChanged: _filterIngredients,
          decoration: InputDecoration(
            hintText: LocalizationHelper.t('search'),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),
      ),
      if (_selected.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Text('${_selected.length} ${LocalizationHelper.t('have')}', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: () => setState(() => _selected.clear()), child: Text(LocalizationHelper.t('clear_all'))),
          ]),
        ),
      Expanded(
        child: ListView(
          children: _cats.map((cat) {
            final items = grouped[cat] ?? [];
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(children: [
                  Text(_catEmojis[cat] ?? '📦', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(LocalizationHelper.t(cat), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                  final ing = items[idx];
                  final id = ing['id'].toString();
                  final sel = _selected.contains(id);
                  return GestureDetector(
                    onTap: () => setState(() { if (sel) _selected.remove(id); else _selected.add(id); }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel ? scheme.primaryContainer : scheme.surface,
                        border: Border.all(color: sel ? scheme.primary : Colors.grey.shade300, width: sel ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(ing['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationHelper.ingredientName(ing),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                        ),
                        if (sel) Icon(Icons.check_circle, size: 14, color: scheme.primary),
                      ]),
                    ),
                  );
                },
              ),
            ]);
          }).toList(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selected.isEmpty ? null : _findMeals,
            icon: const Icon(Icons.search),
            label: Text(LocalizationHelper.t('find_meals'), style: const TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ),
    ]);
  }

  Widget _buildResultsTab() {
    final scheme = Theme.of(context).colorScheme;
    if (_results.isEmpty) return Center(child: Text(LocalizationHelper.t('no_results'), style: const TextStyle(fontSize: 16)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      itemBuilder: (ctx, i) {
        final meal = _results[i];
        final pct = meal['match_pct'] as int;
        final isFav = _favMeals.any((f) => f['id'] == meal['id']);
        final warningsRaw = meal['warnings'];
        final warnings = warningsRaw is Map
            ? warningsRaw
            : warningsRaw is String && warningsRaw.isNotEmpty
                ? (jsonDecode(warningsRaw) as Map? ?? {})
                : <String, dynamic>{};
        final hasWarn = (_profile['pregnant'] == true && warnings['pregnant'] == true) ||
            (_profile['diabetic'] == true && warnings['diabetic'] == true) ||
            (_profile['heart'] == true && warnings['heart'] == true);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(meal['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(LocalizationHelper.mealName(meal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  •  ${meal['calories']} ${LocalizationHelper.t('calories')}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ])),
                IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                  onPressed: () => _toggleFavorite(meal['id'] as int),
                ),
              ]),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: Colors.grey.shade200,
                color: pct >= 80 ? Colors.green : pct >= 50 ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 4),
              Text(
                '${LocalizationHelper.t('match')}: $pct% (${meal['have']}/${meal['total']})',
                style: TextStyle(color: pct >= 80 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              ),
              if (hasWarn) ...[const SizedBox(height: 6), _buildWarning(warnings)],
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () { _showMealDetail(meal); _showInterstitialIfNeeded(); },
                  child: Text(LocalizationHelper.t('view_detail')),
                )),
                const SizedBox(width: 8),
                Expanded(child: FilledButton(
                  onPressed: () => _addToShopping(meal),
                  child: Text(LocalizationHelper.t('add_shopping')),
                )),
              ]),
            ]),
          ),
        );
      },
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
      child: Text(msgs.join('\n'), style: const TextStyle(fontSize: 12, color: Colors.deepOrange)),
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
                  Expanded(child: Text(LocalizationHelper.mealName(meal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                  IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null, size: 32),
                    onPressed: () async {
                      await _toggleFavorite(meal['id'] as int);
                      setS(() { isFav = _favMeals.any((f) => f['id'] == meal['id']); });
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                Text('${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  |  ${meal['calories']} kcal', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(LocalizationHelper.t('health_benefits'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(LocalizationHelper.healthBenefit(meal)),
                const Divider(height: 24),
                Text(LocalizationHelper.t('ingredients'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...req.map((r) {
                  final have = _selected.contains(r);
                  final ing = _allIngredients.firstWhere(
                    (i) => i['id'].toString() == r.toString(),
                    orElse: () => {'id': r, 'name_en': r, 'name_ar': r, 'name_fr': r, 'emoji': '🍽️'},
                  );
                  final altsRaw = ing['alternatives'];
                  final alts = altsRaw is List
                      ? altsRaw.map((e) => e.toString()).toList()
                      : altsRaw is String && altsRaw.isNotEmpty
                          ? altsRaw.split(',').map((e) => e.trim()).toList()
                          : <String>[];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Text(ing['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(LocalizationHelper.ingredientName(ing), style: TextStyle(fontWeight: FontWeight.bold, color: have ? Colors.green : Colors.red)),
                        if (!have && alts.isNotEmpty)
                          Text('${LocalizationHelper.t('alternatives')}: ${alts.join(', ')}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ])),
                      Icon(have ? Icons.check_circle : Icons.cancel, color: have ? Colors.green : Colors.red, size: 20),
                    ]),
                  );
                }),
                const Divider(height: 24),
                Text(LocalizationHelper.t('recipe'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(LocalizationHelper.recipeSteps(meal), style: const TextStyle(fontSize: 14, height: 1.6)),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildShoppingTab() {
    if (_shopping.isEmpty) return Center(child: Text(LocalizationHelper.t('no_shopping')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _shopping.length,
      itemBuilder: (ctx, i) {
        final item = _shopping[i];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: item['bought'] == 1,
              onChanged: (_) async {
                await DatabaseHelper.toggleShoppingBought(item['id'] as int, item['bought'] as int);
                _shopping = await DatabaseHelper.getShoppingItems();
                setState(() {});
              },
            ),
            title: Text(item['name'] ?? '', style: TextStyle(decoration: item['bought'] == 1 ? TextDecoration.lineThrough : null)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                _shopping = await DatabaseHelper.getShoppingItems();
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favMeals.isEmpty) return Center(child: Text(LocalizationHelper.t('no_favorites')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favMeals.length,
      itemBuilder: (ctx, i) {
        final meal = _favMeals[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Text(meal['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
            title: Text(LocalizationHelper.mealName(meal), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${meal['cuisine_flag'] ?? ''} ${meal['cuisine'] ?? ''}  •  ${meal['calories']} kcal'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await DatabaseHelper.toggleFavorite(meal['id'] as int);
                _favMeals = await DatabaseHelper.getFavoriteMeals();
                setState(() {});
              },
            ),
            onTap: () => _showMealDetail(meal),
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
        title: Text(LocalizationHelper.t('app_title'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
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
        bottom: TabBar(controller: _tabController, tabs: [
          Tab(icon: const Icon(Icons.kitchen), text: LocalizationHelper.t('ingredients')),
          Tab(icon: const Icon(Icons.restaurant_menu), text: LocalizationHelper.t('results')),
          Tab(icon: const Icon(Icons.shopping_cart), text: LocalizationHelper.t('shopping_list')),
          Tab(icon: const Icon(Icons.favorite), text: LocalizationHelper.t('favorites')),
        ]),
      ),
      body: Column(children: [
        Expanded(child: TabBarView(controller: _tabController, children: [
          _buildIngredientTab(),
          _buildResultsTab(),
          _buildShoppingTab(),
          _buildFavoritesTab(),
        ])),
        if (_banner != null) SizedBox(height: 50, child: AdWidget(ad: _banner!)),
      ]),
    );
  }
}
