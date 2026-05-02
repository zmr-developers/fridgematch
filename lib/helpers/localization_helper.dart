class LocalizationHelper {
  static String currentLanguage = 'en';
  static int _adCounter = 0;

  static int get adCounter => _adCounter;
  static void incrementAd() => _adCounter++;
  static bool shouldShowAd() => _adCounter % 3 == 0;

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'FridgeMatch', 'ar': 'فريدج ماتش', 'fr': 'FridgeMatch'},
    'select_language': {'en': 'Select Language', 'ar': 'اختر اللغة', 'fr': 'Choisir la Langue'},
    'welcome': {'en': 'Welcome to FridgeMatch', 'ar': 'مرحباً بك في فريدج ماتش', 'fr': 'Bienvenue sur FridgeMatch'},
    'welcome_sub': {'en': 'Your personal chef that knows your fridge', 'ar': 'طاهيك الشخصي الذي يعرف ثلاجتك', 'fr': 'Votre chef personnel qui connaît votre frigo'},
    'get_started': {'en': 'Get Started', 'ar': 'ابدأ الآن', 'fr': 'Commencer'},
    'skip': {'en': 'Skip', 'ar': 'تخطى', 'fr': 'Passer'},
    'home': {'en': 'Home', 'ar': 'الرئيسية', 'fr': 'Accueil'},
    'ingredients': {'en': 'Fridge', 'ar': 'الثلاجة', 'fr': 'Frigo'},
    'ingredients_detail': {'en': 'Ingredients', 'ar': 'المكونات', 'fr': 'Ingrédients'},
    'find_meals': {'en': 'Find Meals', 'ar': 'ابحث', 'fr': 'Chercher'},
    'results': {'en': 'Results', 'ar': 'النتائج', 'fr': 'Résultats'},
    'shopping': {'en': 'Shopping', 'ar': 'التسوق', 'fr': 'Courses'},
    'favorites': {'en': 'Favorites', 'ar': 'المفضلة', 'fr': 'Favoris'},
    'search': {'en': 'Search ingredients...', 'ar': 'ابحث عن مكونات...', 'fr': 'Rechercher des ingrédients...'},
    'vegetables': {'en': 'Vegetables', 'ar': 'خضروات', 'fr': 'Légumes'},
    'fruits': {'en': 'Fruits', 'ar': 'فواكه', 'fr': 'Fruits'},
    'proteins': {'en': 'Proteins', 'ar': 'بروتينات', 'fr': 'Protéines'},
    'grains': {'en': 'Grains', 'ar': 'حبوب', 'fr': 'Céréales'},
    'dairy': {'en': 'Dairy', 'ar': 'ألبان', 'fr': 'Laitier'},
    'condiments': {'en': 'Condiments', 'ar': 'توابل', 'fr': 'Condiments'},
    'spices': {'en': 'Spices', 'ar': 'بهارات', 'fr': 'Épices'},
    'other': {'en': 'Other', 'ar': 'أخرى', 'fr': 'Autre'},
    'match': {'en': 'Match', 'ar': 'تطابق', 'fr': 'Correspond.'},
    'calories': {'en': 'cal', 'ar': 'سعرة', 'fr': 'cal'},
    'recipe': {'en': 'Recipe', 'ar': 'الوصفة', 'fr': 'Recette'},
    'recipe_steps': {'en': 'How to Cook', 'ar': 'طريقة التحضير', 'fr': 'Comment Cuisiner'},
    'view_detail': {'en': 'View Recipe', 'ar': 'عرض الوصفة', 'fr': 'Voir Recette'},
    'missing': {'en': 'Missing', 'ar': 'مفقود', 'fr': 'Manquant'},
    'have': {'en': 'selected', 'ar': 'محدد', 'fr': 'sélectionné'},
    'add_shopping': {'en': 'Add Missing', 'ar': 'أضف الناقص', 'fr': 'Ajouter Manquants'},
    'shopping_list': {'en': 'Shopping', 'ar': 'التسوق', 'fr': 'Courses'},
    'clear_done': {'en': 'Clear Done', 'ar': 'مسح المشترى', 'fr': 'Effacer Achetés'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'fr': 'Paramètres'},
    'language': {'en': 'Language', 'ar': 'اللغة', 'fr': 'Langue'},
    'dietary': {'en': 'Dietary Filters', 'ar': 'فلاتر غذائية', 'fr': 'Filtres Alimentaires'},
    'halal': {'en': 'Halal', 'ar': 'حلال', 'fr': 'Halal'},
    'vegetarian': {'en': 'Vegetarian', 'ar': 'نباتي', 'fr': 'Végétarien'},
    'vegan': {'en': 'Vegan', 'ar': 'نباتي صارم', 'fr': 'Végétalien'},
    'gluten_free': {'en': 'Gluten Free', 'ar': 'خالي من الغلوتين', 'fr': 'Sans Gluten'},
    'lactose_free': {'en': 'Lactose Free', 'ar': 'خالي من اللاكتوز', 'fr': 'Sans Lactose'},
    'profile': {'en': 'Health Profile', 'ar': 'الملف الصحي', 'fr': 'Profil Santé'},
    'pregnant_warning': {'en': '⚠️ Pregnancy Warning: May contain ingredients to avoid during pregnancy', 'ar': '⚠️ تحذير للحامل: قد تحتوي على مكونات يجب تجنبها أثناء الحمل', 'fr': '⚠️ Avertissement Grossesse: Peut contenir des ingrédients à éviter'},
    'diabetic_warning': {'en': '⚠️ Diabetic Warning: High glycemic index, may spike blood sugar', 'ar': '⚠️ تحذير لمرضى السكري: مؤشر جلايسيمي مرتفع', 'fr': '⚠️ Avertissement Diabète: Indice glycémique élevé'},
    'heart_warning': {'en': '⚠️ Heart Warning: Contains high sodium or saturated fats', 'ar': '⚠️ تحذير للقلب: يحتوي على صوديوم عالٍ أو دهون مشبعة', 'fr': '⚠️ Avertissement Cardiaque: Contient sodium élevé ou graisses saturées'},
    'no_favorites': {'en': '❤️ No favorites yet\nTap the heart on any meal to save it', 'ar': '❤️ لا توجد مفضلة بعد\nاضغط على القلب لحفظ الوجبة', 'fr': '❤️ Pas encore de favoris\nAppuyez sur le cœur pour sauvegarder'},
    'no_shopping': {'en': '🛒 Shopping list is empty\nAdd missing ingredients from a meal', 'ar': '🛒 قائمة التسوق فارغة\nأضف المكونات الناقصة من وجبة', 'fr': '🛒 Liste vide\nAjoutez des ingrédients manquants'},
    'no_results': {'en': '🍽️ No meals found\nTry selecting more ingredients', 'ar': '🍽️ لا توجد وجبات\nجرب تحديد المزيد من المكونات', 'fr': '🍽️ Aucun repas trouvé\nSélectionnez plus d\'ingrédients'},
    'no_ingredients_selected': {'en': '🥗 Select ingredients you have\nThen tap Find Meals to get matches', 'ar': '🥗 حدد المكونات التي لديك\nثم اضغط على ابحث عن وجبات', 'fr': '🥗 Sélectionnez vos ingrédients\nPuis appuyez sur Chercher des Repas'},
    'remove': {'en': 'Remove', 'ar': 'إزالة', 'fr': 'Supprimer'},
    'bought': {'en': 'Bought', 'ar': 'تم الشراء', 'fr': 'Acheté'},
    'health_benefits': {'en': 'Health Benefits', 'ar': 'الفوائد الصحية', 'fr': 'Bienfaits pour la Santé'},
    'cuisine': {'en': 'Cuisine', 'ar': 'المطبخ', 'fr': 'Cuisine'},
    'alternatives': {'en': 'Alt', 'ar': 'بديل', 'fr': 'Alt'},
    'save': {'en': 'Save', 'ar': 'حفظ', 'fr': 'Enregistrer'},
    'saved': {'en': 'Settings saved!', 'ar': 'تم حفظ الإعدادات!', 'fr': 'Paramètres sauvegardés!'},
    'gender': {'en': 'Gender', 'ar': 'الجنس', 'fr': 'Genre'},
    'male': {'en': 'Male', 'ar': 'ذكر', 'fr': 'Homme'},
    'female': {'en': 'Female', 'ar': 'أنثى', 'fr': 'Femme'},
    'age_group': {'en': 'Age Group', 'ar': 'الفئة العمرية', 'fr': 'Groupe d\'Âge'},
    'health_conditions': {'en': 'Health Conditions', 'ar': 'الحالات الصحية', 'fr': 'Conditions de Santé'},
    'pregnant': {'en': 'Pregnant', 'ar': 'حامل', 'fr': 'Enceinte'},
    'diabetic': {'en': 'Diabetic', 'ar': 'مريض سكري', 'fr': 'Diabétique'},
    'heart_condition': {'en': 'Heart Condition', 'ar': 'مرض قلبي', 'fr': 'Maladie Cardiaque'},
    'athlete': {'en': 'Athlete', 'ar': 'رياضي', 'fr': 'Athlète'},
    'weight_loss': {'en': 'Weight Loss', 'ar': 'خسارة وزن', 'fr': 'Perte de Poids'},
    'clear_all': {'en': 'Clear All', 'ar': 'مسح الكل', 'fr': 'Tout Effacer'},
    'select_ingredients': {'en': 'Select ingredients you have', 'ar': 'حدد المكونات التي لديك', 'fr': 'Sélectionnez vos ingrédients'},
    'sort_by': {'en': 'Sort', 'ar': 'ترتيب', 'fr': 'Trier'},
    'sort_match': {'en': 'Best Match', 'ar': 'أفضل تطابق', 'fr': 'Meilleure Correspond.'},
    'sort_calories': {'en': 'Lowest Cal', 'ar': 'أقل سعرات', 'fr': 'Moins Cal.'},
    'all_cuisines': {'en': 'All', 'ar': 'الكل', 'fr': 'Tous'},
    'missing_added': {'en': 'Missing ingredients added to shopping list', 'ar': 'تمت إضافة المكونات الناقصة لقائمة التسوق', 'fr': 'Ingrédients manquants ajoutés à la liste'},
    'already_have_all': {'en': 'You already have all ingredients!', 'ar': 'لديك جميع المكونات بالفعل!', 'fr': 'Vous avez déjà tous les ingrédients!'},
  };

  static String t(String key) {
    return _strings[key]?[currentLanguage] ?? _strings[key]?['en'] ?? key;
  }

  static String mealName(Map<String, dynamic> meal) {
    if (currentLanguage == 'ar') return meal['name_ar'] ?? meal['name_en'] ?? '';
    if (currentLanguage == 'fr') return meal['name_fr'] ?? meal['name_en'] ?? '';
    return meal['name_en'] ?? '';
  }

  static String ingredientName(Map<String, dynamic> ing) {
    if (currentLanguage == 'ar') return ing['name_ar'] ?? ing['name_en'] ?? '';
    if (currentLanguage == 'fr') return ing['name_fr'] ?? ing['name_en'] ?? '';
    return ing['name_en'] ?? '';
  }

  static String healthBenefit(Map<String, dynamic> meal) {
    final hb = meal['health_benefits'];
    if (hb == null) return '';
    if (hb is Map) return hb[currentLanguage] ?? hb['en'] ?? '';
    return hb.toString();
  }

  static String recipeSteps(Map<String, dynamic> meal) {
    final rs = meal['recipe_steps'];
    if (rs == null) return '';
    if (rs is Map) return rs[currentLanguage] ?? rs['en'] ?? '';
    return rs.toString();
  }
}