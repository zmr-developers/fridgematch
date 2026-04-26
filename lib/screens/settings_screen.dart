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
  Map<String, bool> _profile = {'pregnant': false, 'diabetic': false, 'heart': false, 'athlete': false, 'weight_loss': false};
  Map<String, bool> _dietary = {'halal': false, 'vegetarian': false, 'vegan': false, 'gluten_free': false};
  String _gender = 'male';
  String _ageGroup = '18-30';
  bool _loading = true;

  final _langs = [{'code': 'en', 'flag': '🇬🇧', 'label': 'English'}, {'code': 'ar', 'flag': '🇸🇦', 'label': 'العربية'}, {'code': 'fr', 'flag': '🇫🇷', 'label': 'Français'}];
  final _ageGroups = ['<18', '18-30', '31-50', '51-65', '65+'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en';
    _gender = prefs.getString('gender') ?? 'male';
    _ageGroup = prefs.getString('age_group') ?? '18-30';
    final profileStr = prefs.getString('health_profile');
    if (profileStr != null) _profile = Map<String, bool>.from(jsonDecode(profileStr));
    final dietStr = prefs.getString('dietary_filters');
    if (dietStr != null) _dietary = Map<String, bool>.from(jsonDecode(dietStr));
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _lang);
    await prefs.setString('gender', _gender);
    await prefs.setString('age_group', _ageGroup);
    await prefs.setString('health_profile', jsonEncode(_profile));
    await prefs.setString('dietary_filters', jsonEncode(_dietary));
    LocalizationHelper.currentLanguage = _lang;
    FridgeMatchApp.of(context)?.setLanguage(_lang);
    if (mounted) Navigator.pop(context);
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('settings'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [FilledButton(onPressed: _save, child: Text(LocalizationHelper.t('save')))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sectionTitle(LocalizationHelper.t('language')),
        Row(children: _langs.map((l) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(
          label: Text('${l['flag']} ${l['label']}', style: const TextStyle(fontSize: 12)),
          selected: _lang == l['code'],
          onSelected: (_) => setState(() { _lang = l['code']!; LocalizationHelper.currentLanguage = _lang; FridgeMatchApp.of(context)?.setLanguage(_lang); }),
        )))).toList()),
        _sectionTitle(LocalizationHelper.t('profile')),
        Row(children: [
          Text(LocalizationHelper.t('gender')),
          const SizedBox(width: 16),
          ChoiceChip(label: Text(LocalizationHelper.t('male')), selected: _gender == 'male', onSelected: (_) => setState(() => _gender = 'male')),
          const SizedBox(width: 8),
          ChoiceChip(label: Text(LocalizationHelper.t('female')), selected: _gender == 'female', onSelected: (_) => setState(() => _gender = 'female')),
        ]),
        const SizedBox(height: 12),
        Text(LocalizationHelper.t('age_group')),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _ageGroups.map((a) => ChoiceChip(label: Text(a), selected: _ageGroup == a, onSelected: (_) => setState(() => _ageGroup = a))).toList()),
        _sectionTitle(LocalizationHelper.t('health_conditions')),
        ...(_profile.keys.map((k) => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(LocalizationHelper.t(k)),
          value: _profile[k] ?? false,
          onChanged: (v) => setState(() => _profile[k] = v),
        ))),
        _sectionTitle(LocalizationHelper.t('dietary')),
        ...(_dietary.keys.map((k) => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(LocalizationHelper.t(k)),
          value: _dietary[k] ?? false,
          onChanged: (v) => setState(() => _dietary[k] = v),
        ))),
      ]),
    );
  }
}
