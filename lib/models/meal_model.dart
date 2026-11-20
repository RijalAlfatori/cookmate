// Model utama untuk resep masakan dari TheMealDB API
// Mencakup data ringkas (dari filter) dan data lengkap (dari lookup/search)
class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strYoutube;
  final String? strTags;
  // Daftar bahan-bahan dan takaran (diparsing dari strIngredient1..20)
  final List<Ingredient> ingredients;
  // Catatan pribadi pengguna (disimpan di Local Storage)
  String? personalNote;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strYoutube,
    this.strTags,
    this.ingredients = const [],
    this.personalNote,
  });

  /// Factory constructor dari JSON API (data lengkap via lookup/search)
  factory Meal.fromJson(Map<String, dynamic> json) {
    final List<Ingredient> ingredientList = [];

    // Parsing bahan 1 sampai 20 dari JSON TheMealDB
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim() ?? '';
      final measure = json['strMeasure$i']?.toString().trim() ?? '';
      // Hanya tambahkan jika bahan tidak kosong/null
      if (ingredient.isNotEmpty && ingredient.toLowerCase() != 'null') {
        ingredientList.add(Ingredient(name: ingredient, measure: measure));
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strYoutube: json['strYoutube'],
      strTags: json['strTags'],
      ingredients: ingredientList,
      personalNote: json['personalNote'],
    );
  }

  /// Factory constructor dari data ringkas (filter by category)
  factory Meal.fromFilterJson(Map<String, dynamic> json) {
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
    );
  }

  /// Konversi ke JSON untuk disimpan ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strYoutube': strYoutube,
      'strTags': strTags,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'personalNote': personalNote,
    };
  }

  /// Factory dari JSON lokal (SharedPreferences)
  factory Meal.fromLocalJson(Map<String, dynamic> json) {
    final List<Ingredient> ingredientList = [];
    if (json['ingredients'] != null) {
      for (final item in json['ingredients']) {
        ingredientList.add(Ingredient.fromJson(item));
      }
    }
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strYoutube: json['strYoutube'],
      strTags: json['strTags'],
      ingredients: ingredientList,
      personalNote: json['personalNote'],
    );
  }

  /// Buat salinan Meal dengan field yang diperbarui
  Meal copyWith({String? personalNote}) {
    return Meal(
      idMeal: idMeal,
      strMeal: strMeal,
      strMealThumb: strMealThumb,
      strCategory: strCategory,
      strArea: strArea,
      strInstructions: strInstructions,
      strYoutube: strYoutube,
      strTags: strTags,
      ingredients: ingredients,
      personalNote: personalNote ?? this.personalNote,
    );
  }
}

/// Model untuk satu bahan beserta takarannya
class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      measure: json['measure'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'measure': measure};
}
