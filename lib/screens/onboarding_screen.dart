import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedLang = 'en';

  final _langs = [
    {'code': 'en', 'label': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'ar', 'label': 'Arabic', 'flag': '🇸🇦', 'native': 'العربية'},
    {'code': 'fr', 'label': 'French', 'flag': '🇫🇷', 'native': 'Français'},
  ];

  Future<void> _proceed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLang);
    await prefs.setBool('seen_onboarding', true);
    LocalizationHelper.currentLanguage = _selectedLang;
    FridgeMatchApp.of(context)?.setLanguage(_selectedLang);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text('🍽️', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('FridgeMatch', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary)),
              const SizedBox(height: 8),
              Text('Your personal chef that knows your fridge', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.primary)),
              const SizedBox(height: 48),
              Text(LocalizationHelper.t('select_language'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ...(_langs.map((lang) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedLang = lang['code']!);
                    LocalizationHelper.currentLanguage = lang['code']!;
                    FridgeMatchApp.of(context)?.setLanguage(lang['code']!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedLang == lang['code'] ? scheme.primaryContainer : scheme.surface,
                      border: Border.all(color: _selectedLang == lang['code'] ? scheme.primary : scheme.primary.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang['native']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(lang['label']!, style: TextStyle(color: scheme.primary)),
                          ],
                        ),
                        const Spacer(),
                        if (_selectedLang == lang['code']) Icon(Icons.check_circle, color: scheme.primary),
                      ],
                    ),
                  ),
                ),
              ))),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _proceed,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(LocalizationHelper.t('get_started'), style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
