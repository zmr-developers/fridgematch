import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'helpers/localization_helper.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  // Initialize database FIRST - this seeds meals and ingredients
  await DatabaseHelper.database;

  final meals = await DatabaseHelper.getMeals();
final ings = await DatabaseHelper.getIngredients();
debugPrint('MEALS COUNT: ${meals.length}');
debugPrint('INGREDIENTS COUNT: ${ings.length}');
  
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final String lang = prefs.getString('app_language') ?? 'en';
  LocalizationHelper.currentLanguage = lang;
  runApp(FridgeMatchApp(showOnboarding: !seenOnboarding));
}

class FridgeMatchApp extends StatefulWidget {
  final bool showOnboarding;
  const FridgeMatchApp({super.key, required this.showOnboarding});
  static _FridgeMatchAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FridgeMatchAppState>();
  @override
  State<FridgeMatchApp> createState() => _FridgeMatchAppState();
}

class _FridgeMatchAppState extends State<FridgeMatchApp> {
  String _language = LocalizationHelper.currentLanguage;

  void setLanguage(String lang) {
    setState(() {
      _language = lang;
      LocalizationHelper.currentLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _language == 'ar';
    return MaterialApp(
      title: 'FridgeMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: widget.showOnboarding
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
