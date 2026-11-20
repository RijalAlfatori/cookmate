import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/category_model.dart';

/// Service untuk komunikasi dengan TheMealDB REST API
/// Base URL: https://www.themealdb.com/api/json/v1/1/
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // ─── Ambil semua kategori masakan ───────────────────────────────────────────
  /// Endpoint: /categories.php
  /// Mengembalikan list [MealCategory] dari API
  Future<List<MealCategory>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/categories.php'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List categories = data['categories'] ?? [];
        return categories.map((c) => MealCategory.fromJson(c)).toList();
      } else {
        throw Exception('Gagal memuat kategori (kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  // ─── Ambil daftar resep berdasarkan kategori ─────────────────────────────
  /// Endpoint: /filter.php?c={category}
  /// Mengembalikan list [Meal] ringkas (hanya idMeal, strMeal, strMealThumb)
  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final uri = Uri.parse('$_baseUrl/filter.php').replace(
        queryParameters: {'c': category},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List meals = data['meals'] ?? [];
        return meals.map((m) => Meal.fromFilterJson(m)).toList();
      } else {
        throw Exception('Gagal memuat resep (kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  // ─── Cari resep berdasarkan nama ─────────────────────────────────────────
  /// Endpoint: /search.php?s={query}
  /// Mengembalikan list [Meal] lengkap termasuk ingredients & instructions
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search.php').replace(
        queryParameters: {'s': query},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? meals = data['meals'];
        if (meals == null) return []; // Tidak ada hasil pencarian
        return meals.map((m) => Meal.fromJson(m)).toList();
      } else {
        throw Exception('Gagal mencari resep (kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  // ─── Ambil detail lengkap resep berdasarkan ID ───────────────────────────
  /// Endpoint: /lookup.php?i={idMeal}
  /// Mengembalikan satu [Meal] dengan data lengkap atau null jika tidak ditemukan
  Future<Meal?> getMealById(String idMeal) async {
    try {
      final uri = Uri.parse('$_baseUrl/lookup.php').replace(
        queryParameters: {'i': idMeal},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? meals = data['meals'];
        if (meals == null || meals.isEmpty) return null;
        return Meal.fromJson(meals[0]);
      } else {
        throw Exception('Gagal memuat detail resep (kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }
}
