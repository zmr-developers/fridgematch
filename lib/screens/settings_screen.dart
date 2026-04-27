import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lang = 'en';
  Map<String, bool> _profile = {
    'pregnant': false, 'diabetic': false, 'heart': false,
    'athlete': false, 'weight_loss': false,
  };
  Map<String, bool> _dietary = {
    'halal': false, 'vegetarian': false, 'vegan': false, 'gluten_free': false,
  };
  String _gender = 'male';
  String _ageGroup = '18-30';
  bool _loading = true;

  final _langs = [
    {'code': 'en', 'flag': '🇬🇧', 'label': 'English', 'native': 'English'},
    {'code': 'ar', 'flag': '🇸🇦', 'label': 'Arabic', 'native': 'العربية'},
    {'code': 'fr', 'flag': '🇫🇷', 'label': 'French', 'native': 'Français'},
    {'code': 'es', 'flag': '🇪🇸', 'label': 'Spanish', 'native': 'Español'},
  ];
  final _ageGroups = ['<18', '18-30', '31-50', '51-65', '65+'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = prefs.getString('app_language') ?? 'en';
      _gender = prefs.getString('gender') ?? 'male';
      _ageGroup = prefs.getString('age_group') ?? '18-30';
      final profileStr = prefs.getString('health_profile');
      if (profileStr != null) _profile = Map<String, bool>.from(jsonDecode(profileStr));
      final dietStr = prefs.getString('dietary_filters');
      if (dietStr != null) _dietary = Map<String, bool>.from(jsonDecode(dietStr));
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _lang);
    await prefs.setString('gender', _gender);
    await prefs.setString('age_group', _ageGroup);
    await prefs.setString('health_profile', jsonEncode(_profile));
    await prefs.setString('dietary_filters', jsonEncode(_dietary));
    LocalizationHelper.currentLanguage = _lang;
    if (mounted) {
      FridgeMatchApp.of(context)?.setLanguage(_lang);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationHelper.t('saved')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _sectionTitle(String text, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(children: [
        Icon(icon, color: scheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: scheme.primary)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('settings'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              child: Text(LocalizationHelper.t('save')),
            ),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Language
        _sectionTitle(LocalizationHelper.t('language'), Icons.language),
        ..._langs.map((l) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() => _lang = l['code']!);
              LocalizationHelper.currentLanguage = l['code']!;
              FridgeMatchApp.of(context)?.setLanguage(l['code']!);
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _lang == l['code'] ? scheme.primaryContainer : scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _lang == l['code'] ? scheme.primary : scheme.outline,
                  width: _lang == l['code'] ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Text(l['flag']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l['native']!, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15,
                    color: _lang == l['code'] ? scheme.primary : null,
                  )),
                  Text(l['label']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
                const Spacer(),
                if (_lang == l['code']) Icon(Icons.check_circle, color: scheme.primary),
              ]),
            ),
          ),
        )),

        const Divider(height: 8),

        // Profile
        _sectionTitle(LocalizationHelper.t('profile'), Icons.person),

        // Gender
        Text(LocalizationHelper.t('gender'), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _gender = 'male'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _gender == 'male' ? scheme.primaryContainer : scheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gender == 'male' ? scheme.primary : scheme.outline,
                    width: _gender == 'male' ? 2 : 1),
              ),
              child: Center(child: Text('👨 ${LocalizationHelper.t('male')}',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: _gender == 'male' ? scheme.primary : null))),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _gender = 'female'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _gender == 'female' ? scheme.primaryContainer : scheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gender == 'female' ? scheme.primary : scheme.outline,
                    width: _gender == 'female' ? 2 : 1),
              ),
              child: Center(child: Text('👩 ${LocalizationHelper.t('female')}',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: _gender == 'female' ? scheme.primary : null))),
            ),
          )),
        ]),
        const SizedBox(height: 16),

        // Age group
        Text(LocalizationHelper.t('age_group'), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _ageGroups.map((a) => GestureDetector(
          onTap: () => setState(() => _ageGroup = a),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _ageGroup == a ? scheme.primaryContainer : scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ageGroup == a ? scheme.primary : scheme.outline,
                  width: _ageGroup == a ? 2 : 1),
            ),
            child: Text(a, style: TextStyle(
              color: _ageGroup == a ? scheme.primary : null,
              fontWeight: _ageGroup == a ? FontWeight.bold : FontWeight.normal,
            )),
          ),
        )).toList()),

        const Divider(height: 24),

        // Health conditions
        _sectionTitle(LocalizationHelper.t('health_conditions'), Icons.medical_services),
        ...(_profile.keys.map((k) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: (_profile[k] ?? false) ? scheme.primaryContainer.withOpacity(0.5) : scheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: (_profile[k] ?? false) ? scheme.primary : scheme.outline),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            title: Text(LocalizationHelper.t(k), style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (_profile[k] ?? false) ? scheme.primary : null,
            )),
            value: _profile[k] ?? false,
            onChanged: (v) => setState(() => _profile[k] = v),
          ),
        ))),

        const Divider(height: 16),

        // Dietary filters
        _sectionTitle(LocalizationHelper.t('dietary'), Icons.restaurant),
        ...(_dietary.keys.map((k) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: (_dietary[k] ?? false) ? scheme.primaryContainer.withOpacity(0.5) : scheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: (_dietary[k] ?? false) ? scheme.primary : scheme.outline),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            title: Text(LocalizationHelper.t(k), style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (_dietary[k] ?? false) ? scheme.primary : null,
            )),
            value: _dietary[k] ?? false,
            onChanged: (v) => setState(() => _dietary[k] = v),
          ),
        ))),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(LocalizationHelper.t('save'), style: const TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
