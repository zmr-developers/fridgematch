class LocalizationHelper {
  static String currentLanguage = 'en';
  static int _adCounter = 0;

  static int get adCounter => _adCounter;
  static void incrementAd() => _adCounter++;
  static bool shouldShowAd() => _adCounter % 3 == 0;

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'FridgeMatch', 'ar': 'فريدج ماتش', 'fr': 'FridgeMatch', 'es': 'FridgeMatch'},
    'select_language': {'en': 'Select Language', 'ar': 'اختر اللغة', 'fr': 'Choisir la Langue', 'es': 'Seleccionar Idioma'},
    'welcome': {'en': 'Welcome to FridgeMatch', 'ar': 'مرحباً بك في فريدج ماتش', 'fr': 'Bienvenue sur FridgeMatch', 'es': 'Bienvenido a FridgeMatch'},
    'welcome_sub': {'en': 'Your personal chef that knows your fridge', 'ar': 'طاهيك الشخصي الذي يعرف ثلاجتك', 'fr': 'Votre chef personnel qui connaît votre frigo', 'es': 'Tu chef personal que conoce tu nevera'},
    'get_started': {'en': 'Get Started', 'ar': 'ابدأ الآن', 'fr': 'Commencer', 'es': 'Comenzar'},
    'skip': {'en': 'Skip', 'ar': 'تخطى', 'fr': 'Passer', 'es': 'Omitir'},
    'home': {'en': 'Home', 'ar': 'الرئيسية', 'fr': 'Accueil', 'es': 'Inicio'},
    'ingredients': {'en': 'Fridge', 'ar': 'الثلاجة', 'fr': 'Frigo', 'es': 'Nevera'},
    'ingredients_detail': {'en': 'Ingredients', 'ar': 'المكونات', 'fr': 'Ingrédients', 'es': 'Ingredientes'},
    'find_meals': {'en': 'Find Meals', 'ar': 'ابحث', 'fr': 'Chercher', 'es': 'Buscar'},
    'results': {'en': 'Results', 'ar': 'النتائج', 'fr': 'Résultats', 'es': 'Resultados'},
    'shopping': {'en': 'Shopping', 'ar': 'التسوق', 'fr': 'Courses', 'es': 'Compras'},
    'favorites': {'en': 'Favorites', 'ar': 'المفضلة', 'fr': 'Favoris', 'es': 'Favoritos'},
    'search': {'en': 'Search ingredients...', 'ar': 'ابحث عن مكونات...', 'fr': 'Rechercher des ingrédients...', 'es': 'Buscar ingredientes...'},
    'vegetables': {'en': 'Vegetables', 'ar': 'خضروات', 'fr': 'Légumes', 'es': 'Verduras'},
    'fruits': {'en': 'Fruits', 'ar': 'فواكه', 'fr': 'Fruits', 'es': 'Frutas'},
    'proteins': {'en': 'Proteins', 'ar': 'بروتينات', 'fr': 'Protéines', 'es': 'Proteínas'},
    'grains': {'en': 'Grains', 'ar': 'حبوب', 'fr': 'Céréales', 'es': 'Cereales'},
    'dairy': {'en': 'Dairy', 'ar': 'ألبان', 'fr': 'Laitier', 'es': 'Lácteos'},
    'condiments': {'en': 'Condiments', 'ar': 'توابل', 'fr': 'Condiments', 'es': 'Condimentos'},
    'spices': {'en': 'Spices', 'ar': 'بهارات', 'fr': 'Épices', 'es': 'Especias'},
    'other': {'en': 'Other', 'ar': 'أخرى', 'fr': 'Autre', 'es': 'Otros'},
    'match': {'en': 'Match', 'ar': 'تطابق', 'fr': 'Correspond.', 'es': 'Coincid.'},
    'calories': {'en': 'cal', 'ar': 'سعرة', 'fr': 'cal', 'es': 'cal'},
    'recipe': {'en': 'Recipe', 'ar': 'الوصفة', 'fr': 'Recette', 'es': 'Receta'},
    'recipe_steps': {'en': 'How to Cook', 'ar': 'طريقة التحضير', 'fr': 'Comment Cuisiner', 'es': 'Cómo Cocinar'},
    'view_detail': {'en': 'View Recipe', 'ar': 'عرض الوصفة', 'fr': 'Voir Recette', 'es': 'Ver Receta'},
    'missing': {'en': 'Missing', 'ar': 'مفقود', 'fr': 'Manquant', 'es': 'Faltante'},
    'have': {'en': 'selected', 'ar': 'محدد', 'fr': 'sélectionné', 'es': 'seleccionado'},
    'add_shopping': {'en': 'Add Missing', 'ar': 'أضف الناقص', 'fr': 'Ajouter Manquants', 'es': 'Agregar Faltantes'},
    'shopping_list': {'en': 'Shopping', 'ar': 'التسوق', 'fr': 'Courses', 'es': 'Compras'},
    'clear_done': {'en': 'Clear Done', 'ar': 'مسح المشترى', 'fr': 'Effacer Achetés', 'es': 'Limpiar Comprados'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'fr': 'Paramètres', 'es': 'Ajustes'},
    'language': {'en': 'Language', 'ar': 'اللغة', 'fr': 'Langue', 'es': 'Idioma'},
    'dietary': {'en': 'Dietary Filters', 'ar': 'فلاتر غذائية', 'fr': 'Filtres Alimentaires', 'es': 'Filtros Dietéticos'},
    'halal': {'en': 'Halal', 'ar': 'حلال', 'fr': 'Halal', 'es': 'Halal'},
    'vegetarian': {'en': 'Vegetarian', 'ar': 'نباتي', 'fr': 'Végétarien', 'es': 'Vegetariano'},
    'vegan': {'en': 'Vegan', 'ar': 'نباتي صارم', 'fr': 'Végétalien', 'es': 'Vegano'},
    'gluten_free': {'en': 'Gluten Free', 'ar': 'خالي من الغلوتين', 'fr': 'Sans Gluten', 'es': 'Sin Gluten'},
    'lactose_free': {'en': 'Lactose Free', 'ar': 'خالي من اللاكتوز', 'fr': 'Sans Lactose', 'es': 'Sin Lactosa'},
    'profile': {'en': 'Health Profile', 'ar': 'الملف الصحي', 'fr': 'Profil Santé', 'es': 'Perfil de Salud'},
    'pregnant_warning': {'en': '⚠️ Pregnancy Warning: May contain ingredients to avoid during pregnancy', 'ar': '⚠️ تحذير للحامل: قد تحتوي على مكونات يجب تجنبها أثناء الحمل', 'fr': '⚠️ Avertissement Grossesse: Peut contenir des ingrédients à éviter', 'es': '⚠️ Advertencia Embarazo: Puede contener ingredientes a evitar'},
    'diabetic_warning': {'en': '⚠️ Diabetic Warning: High glycemic index, may spike blood sugar', 'ar': '⚠️ تحذير لمرضى السكري: مؤشر جلايسيمي مرتفع', 'fr': '⚠️ Avertissement Diabète: Indice glycémique élevé', 'es': '⚠️ Advertencia Diabético: Índice glucémico alto'},
    'heart_warning': {'en': '⚠️ Heart Warning: Contains high sodium or saturated fats', 'ar': '⚠️ تحذير للقلب: يحتوي على صوديوم عالٍ أو دهون مشبعة', 'fr': '⚠️ Avertissement Cardiaque: Contient sodium élevé ou graisses saturées', 'es': '⚠️ Advertencia Cardíaca: Contiene sodio alto o grasas saturadas'},
    'no_favorites': {'en': '❤️ No favorites yet\nTap the heart on any meal to save it', 'ar': '❤️ لا توجد مفضلة بعد\nاضغط على القلب لحفظ الوجبة', 'fr': '❤️ Pas encore de favoris\nAppuyez sur le cœur pour sauvegarder', 'es': '❤️ Sin favoritos aún\nToca el corazón para guardar'},
    'no_shopping': {'en': '🛒 Shopping list is empty\nAdd missing ingredients from a meal', 'ar': '🛒 قائمة التسوق فارغة\nأضف المكونات الناقصة من وجبة', 'fr': '🛒 Liste vide\nAjoutez des ingrédients manquants', 'es': '🛒 Lista vacía\nAgrega ingredientes faltantes'},
    'no_results': {'en': '🍽️ No meals found\nTry selecting more ingredients', 'ar': '🍽️ لا توجد وجبات\nجرب تحديد المزيد من المكونات', 'fr': '🍽️ Aucun repas trouvé\nSélectionnez plus d\'ingrédients', 'es': '🍽️ No se encontraron comidas\nIntenta seleccionar más ingredientes'},
    'no_ingredients_selected': {'en': '🥗 Select ingredients you have\nThen tap Find Meals to get matches', 'ar': '🥗 حدد المكونات التي لديك\nثم اضغط على ابحث عن وجبات', 'fr': '🥗 Sélectionnez vos ingrédients\nPuis appuyez sur Chercher des Repas', 'es': '🥗 Selecciona los ingredientes que tienes\nLuego toca Buscar Comidas'},
    'remove': {'en': 'Remove', 'ar': 'إزالة', 'fr': 'Supprimer', 'es': 'Eliminar'},
    'bought': {'en': 'Bought', 'ar': 'تم الشراء', 'fr': 'Acheté', 'es': 'Comprado'},
    'health_benefits': {'en': 'Health Benefits', 'ar': 'الفوائد الصحية', 'fr': 'Bienfaits pour la Santé', 'es': 'Beneficios para la Salud'},
    'cuisine': {'en': 'Cuisine', 'ar': 'المطبخ', 'fr': 'Cuisine', 'es': 'Cocina'},
    'alternatives': {'en': 'Alt', 'ar': 'بديل', 'fr': 'Alt', 'es': 'Alt'},
    'save': {'en': 'Save', 'ar': 'حفظ', 'fr': 'Enregistrer', 'es': 'Guardar'},
    'saved': {'en': 'Settings saved!', 'ar': 'تم حفظ الإعدادات!', 'fr': 'Paramètres sauvegardés!', 'es': '¡Configuración guardada!'},
    'gender': {'en': 'Gender', 'ar': 'الجنس', 'fr': 'Genre', 'es': 'Género'},
    'male': {'en': 'Male', 'ar': 'ذكر', 'fr': 'Homme', 'es': 'Hombre'},
    'female': {'en': 'Female', 'ar': 'أنثى', 'fr': 'Femme', 'es': 'Mujer'},
    'age_group': {'en': 'Age Group', 'ar': 'الفئة العمرية', 'fr': 'Groupe d\'Âge', 'es': 'Grupo de Edad'},
    'health_conditions': {'en': 'Health Conditions', 'ar': 'الحالات الصحية', 'fr': 'Conditions de Santé', 'es': 'Condiciones de Salud'},
    'pregnant': {'en': 'Pregnant', 'ar': 'حامل', 'fr': 'Enceinte', 'es': 'Embarazada'},
    'diabetic': {'en': 'Diabetic', 'ar': 'مريض سكري', 'fr': 'Diabétique', 'es': 'Diabético'},
    'heart_condition': {'en': 'Heart Condition', 'ar': 'مرض قلبي', 'fr': 'Maladie Cardiaque', 'es': 'Enfermedad Cardíaca'},
    'athlete': {'en': 'Athlete', 'ar': 'رياضي', 'fr': 'Athlète', 'es': 'Atleta'},
    'weight_loss': {'en': 'Weight Loss', 'ar': 'خسارة وزن', 'fr': 'Perte de Poids', 'es': 'Pérdida de Peso'},
    'clear_all': {'en': 'Clear All', 'ar': 'مسح الكل', 'fr': 'Tout Effacer', 'es': 'Limpiar Todo'},
    'select_ingredients': {'en': 'Select ingredients you have', 'ar': 'حدد المكونات التي لديك', 'fr': 'Sélectionnez vos ingrédients', 'es': 'Selecciona tus ingredientes'},
    'sort_by': {'en': 'Sort', 'ar': 'ترتيب', 'fr': 'Trier', 'es': 'Ordenar'},
    'sort_match': {'en': 'Best Match', 'ar': 'أفضل تطابق', 'fr': 'Meilleure Correspond.', 'es': 'Mejor Coincidencia'},
    'sort_calories': {'en': 'Lowest Cal', 'ar': 'أقل سعرات', 'fr': 'Moins Cal.', 'es': 'Menos Calorías'},
    'all_cuisines': {'en': 'All', 'ar': 'الكل', 'fr': 'Tous', 'es': 'Todos'},
    'missing_added': {'en': 'Missing ingredients added to shopping list', 'ar': 'تمت إضافة المكونات الناقصة لقائمة التسوق', 'fr': 'Ingrédients manquants ajoutés à la liste', 'es': 'Ingredientes faltantes agregados a la lista'},
    'already_have_all': {'en': 'You already have all ingredients!', 'ar': 'لديك جميع المكونات بالفعل!', 'fr': 'Vous avez déjà tous les ingrédients!', 'es': '¡Ya tienes todos los ingredientes!'},
  };

  static String t(String key) {
    return _strings[key]?[currentLanguage] ?? _strings[key]?['en'] ?? key;
  }

  static String mealName(Map<String, dynamic> meal) {
    if (currentLanguage == 'ar') return meal['name_ar'] ?? meal['name_en'] ?? '';
    if (currentLanguage == 'fr') return meal['name_fr'] ?? meal['name_en'] ?? '';
    if (currentLanguage == 'es') return meal['name_es'] ?? meal['name_en'] ?? '';
    return meal['name_en'] ?? '';
  }

  static String ingredientName(Map<String, dynamic> ing) {
    if (currentLanguage == 'ar') return ing['name_ar'] ?? ing['name_en'] ?? '';
    if (currentLanguage == 'fr') return ing['name_fr'] ?? ing['name_en'] ?? '';
    if (currentLanguage == 'es') return ing['name_es'] ?? ing['name_en'] ?? '';
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
