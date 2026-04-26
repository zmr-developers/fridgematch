class LocalizationHelper {
  static String currentLanguage = 'en';

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'FridgeMatch', 'ar': 'فريدج ماتش', 'fr': 'FridgeMatch'},
    'select_language': {'en': 'Select Language', 'ar': 'اختر اللغة', 'fr': 'Choisir la Langue'},
    'welcome': {'en': 'Welcome to FridgeMatch', 'ar': 'مرحباً بك في فريدج ماتش', 'fr': 'Bienvenue sur FridgeMatch'},
    'welcome_sub': {'en': 'Your personal chef that knows your fridge', 'ar': 'طاهيك الشخصي الذي يعرف ثلاجتك', 'fr': 'Votre chef personnel qui connaît votre frigo'},
    'get_started': {'en': 'Get Started', 'ar': 'ابدأ الآن', 'fr': 'Commencer'},
    'skip': {'en': 'Skip', 'ar': 'تخطى', 'fr': 'Passer'},
    'home': {'en': 'Home', 'ar': 'الرئيسية', 'fr': 'Accueil'},
    'ingredients': {'en': 'My Ingredients', 'ar': 'مكوناتي', 'fr': 'Mes Ingrédients'},
    'find_meals': {'en': 'Find Meals', 'ar': 'ابحث عن وجبات', 'fr': 'Trouver des Repas'},
    'search': {'en': 'Search ingredients...', 'ar': 'ابحث عن مكونات...', 'fr': 'Rechercher des ingrédients...'},
    'vegetables': {'en': 'Vegetables', 'ar': 'خضروات', 'fr': 'Légumes'},
    'fruits': {'en': 'Fruits', 'ar': 'فواكه', 'fr': 'Fruits'},
    'proteins': {'en': 'Proteins', 'ar': 'بروتينات', 'fr': 'Protéines'},
    'grains': {'en': 'Grains', 'ar': 'حبوب', 'fr': 'Céréales'},
    'dairy': {'en': 'Dairy', 'ar': 'ألبان', 'fr': 'Laitier'},
    'condiments': {'en': 'Condiments', 'ar': 'توابل', 'fr': 'Condiments'},
    'spices': {'en': 'Spices', 'ar': 'بهارات', 'fr': 'Épices'},
    'other': {'en': 'Other', 'ar': 'أخرى', 'fr': 'Autre'},
    'match': {'en': 'Match', 'ar': 'تطابق', 'fr': 'Correspondance'},
    'calories': {'en': 'Calories', 'ar': 'سعرات', 'fr': 'Calories'},
    'recipe': {'en': 'View Recipe', 'ar': 'عرض الوصفة', 'fr': 'Voir la Recette'},
    'missing': {'en': 'Missing', 'ar': 'مفقود', 'fr': 'Manquant'},
    'have': {'en': 'You have', 'ar': 'لديك', 'fr': 'Vous avez'},
    'add_shopping': {'en': 'Add to Shopping List', 'ar': 'أضف لقائمة التسوق', 'fr': 'Ajouter à la liste'},
    'shopping_list': {'en': 'Shopping List', 'ar': 'قائمة التسوق', 'fr': 'Liste de Courses'},
    'favorites': {'en': 'Favorites', 'ar': 'المفضلة', 'fr': 'Favoris'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'fr': 'Paramètres'},
    'language': {'en': 'Language', 'ar': 'اللغة', 'fr': 'Langue'},
    'dietary': {'en': 'Dietary Filters', 'ar': 'فلاتر غذائية', 'fr': 'Filtres Alimentaires'},
    'halal': {'en': 'Halal', 'ar': 'حلال', 'fr': 'Halal'},
    'vegetarian': {'en': 'Vegetarian', 'ar': 'نباتي', 'fr': 'Végétarien'},
    'vegan': {'en': 'Vegan', 'ar': 'نباتي صارم', 'fr': 'Végétalien'},
    'gluten_free': {'en': 'Gluten Free', 'ar': 'خالي من الغلوتين', 'fr': 'Sans Gluten'},
    'lactose_free': {'en': 'Lactose Free', 'ar': 'خالي من اللاكتوز', 'fr': 'Sans Lactose'},
    'profile': {'en': 'Health Profile', 'ar': 'الملف الصحي', 'fr': 'Profil Santé'},
    'pregnant_warning': {'en': '⚠️ Pregnancy Warning: This meal may contain ingredients to avoid during pregnancy (FDA/CDC 2024)', 'ar': '⚠️ تحذير للحامل: قد تحتوي هذه الوجبة على مكونات يجب تجنبها أثناء الحمل', 'fr': '⚠️ Avertissement Grossesse: Ce repas peut contenir des ingrédients à éviter pendant la grossesse'},
    'diabetic_warning': {'en': '⚠️ Diabetic Warning: High glycemic index, may spike blood sugar (ADA 2024)', 'ar': '⚠️ تحذير لمرضى السكري: مؤشر جلايسيمي مرتفع قد يرفع السكر', 'fr': '⚠️ Avertissement Diabète: Indice glycémique élevé, peut augmenter la glycémie'},
    'heart_warning': {'en': '⚠️ Heart Warning: Contains high sodium or saturated fats', 'ar': '⚠️ تحذير للقلب: يحتوي على صوديوم عالٍ أو دهون مشبعة', 'fr': '⚠️ Avertissement Cardiaque: Contient sodium élevé ou graisses saturées'},
    'no_favorites': {'en': 'No favorites yet', 'ar': 'لا توجد مفضلة بعد', 'fr': 'Pas encore de favoris'},
    'no_shopping': {'en': 'Shopping list is empty', 'ar': 'قائمة التسوق فارغة', 'fr': 'La liste de courses est vide'},
    'remove': {'en': 'Remove', 'ar': 'إزالة', 'fr': 'Supprimer'},
    'bought': {'en': 'Bought', 'ar': 'تم الشراء', 'fr': 'Acheté'},
    'results': {'en': 'Meal Results', 'ar': 'نتائج الوجبات', 'fr': 'Résultats des Repas'},
    'no_results': {'en': 'No meals found. Select more ingredients.', 'ar': 'لا توجد وجبات. حدد مزيداً من المكونات.', 'fr': 'Aucun repas trouvé. Sélectionnez plus d\'ingrédients.'},
    'health_benefits': {'en': 'Health Benefits', 'ar': 'الفوائد الصحية', 'fr': 'Bienfaits pour la Santé'},
    'cuisine': {'en': 'Cuisine', 'ar': 'المطبخ', 'fr': 'Cuisine'},
    'alternatives': {'en': 'Alternatives', 'ar': 'بدائل', 'fr': 'Alternatives'},
    'save': {'en': 'Save', 'ar': 'حفظ', 'fr': 'Enregistrer'},
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
    if (hb is Map) {
      return hb[currentLanguage] ?? hb['en'] ?? '';
    }
    return hb.toString();
  }

  static String recipeSteps(Map<String, dynamic> meal) {
    final rs = meal['recipe_steps'];
    if (rs == null) return '';
    if (rs is Map) {
      return rs[currentLanguage] ?? rs['en'] ?? '';
    }
    return rs.toString();
  }
}
