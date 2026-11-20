import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

/// Service untuk menyimpan & mengelola resep favorit secara lokal
/// menggunakan SharedPreferences dengan format JSON string list
class StorageService {
  static const String _savedRecipesKey = 'saved_recipes';

  // ─── Ambil semua resep tersimpan ─────────────────────────────────────────
  /// Mengembalikan list [Meal] dari SharedPreferences
  /// Dapat diakses secara offline tanpa koneksi internet
  Future<List<Meal>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];
    return jsonList.map((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return Meal.fromLocalJson(jsonMap);
    }).toList();
  }

  // ─── Simpan resep ke Local Storage ───────────────────────────────────────
  /// Menyimpan [Meal] ke SharedPreferences jika belum tersimpan sebelumnya
  /// Menggunakan idMeal sebagai identifier unik
  Future<void> saveRecipe(Meal recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];

    // Cek apakah resep sudah tersimpan (hindari duplikat)
    final bool alreadySaved = jsonList.any((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['idMeal'] == recipe.idMeal;
    });

    if (!alreadySaved) {
      jsonList.add(json.encode(recipe.toJson()));
      await prefs.setStringList(_savedRecipesKey, jsonList);
    }
  }

  // ─── Hapus resep dari Local Storage ──────────────────────────────────────
  /// Menghapus resep berdasarkan [idMeal] dari SharedPreferences
  Future<void> removeRecipe(String idMeal) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];

    jsonList.removeWhere((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['idMeal'] == idMeal;
    });

    await prefs.setStringList(_savedRecipesKey, jsonList);
  }

  // ─── Update catatan pribadi resep ─────────────────────────────────────────
  /// Memperbarui field [personalNote] pada resep yang sudah tersimpan
  Future<void> updateNote(String idMeal, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];

    final updatedList = jsonList.map((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      if (jsonMap['idMeal'] == idMeal) {
        jsonMap['personalNote'] = note;
        return json.encode(jsonMap);
      }
      return jsonStr;
    }).toList();

    await prefs.setStringList(_savedRecipesKey, updatedList);
  }

  // ─── Cek apakah resep sudah tersimpan ────────────────────────────────────
  /// Mengembalikan true jika resep dengan [idMeal] sudah ada di Local Storage
  Future<bool> isRecipeSaved(String idMeal) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];

    return jsonList.any((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['idMeal'] == idMeal;
    });
  }
}
