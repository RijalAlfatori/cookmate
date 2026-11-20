# LAPORAN UJIAN TENGAH PRAKTIKUM (UTP)
## PRAKTIKUM MOBILE PROGRAMMING

---

### 1. IDENTITAS & INFO PROYEK

| Data | Keterangan |
| :--- | :--- |
| **Nama Mahasiswa** | [Nama Lengkap Mahasiswa / Rijal] |
| **NPM** | [Nomor Pokok Mahasiswa] |
| **Kelas / Praktikum** | [Kelas Praktikum Mobile Programming, Contoh: 5A / IF-A] |
| **Mata Kuliah** | Praktikum Mobile Programming |
| **Judul Aplikasi** | **CookMate** (Katalog Resep & Meal Planner Modern) |
| **Opsi Data Dipilih** | **Opsi 3 (Kombinasi Public REST API + Local Storage — Nilai Plus)** |
| **Platform / SDK** | Flutter SDK (Dart 3.x), Material 3 Design |
| **Link Repository GitHub** | [https://github.com/username/cookmate] *(isi link repo Anda)* |

---

### 2. DESKRIPSI APLIKASI

#### 2.1 Konsep Aplikasi
**CookMate** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna mengeksplorasi ribuan resep masakan dunia, merencanakan menu makanan sehat harian (*meal planner*), serta menyimpan resep favorit lengkap dengan catatan modifikasi resep pribadi secara *offline*. 

Aplikasi ini mengusung desain bertema kuliner hangat (*Warm Culinary Theme*) dengan warna utama *Deep Orange* (`#E65100`), tipografi modern *Plus Jakarta Sans*, dan menerapkan standar UI/UX kelas atas seperti *Hero transition*, *staggered grid animation*, skeleton *shimmer loading*, hingga dukungan otomatis untuk *Dark Mode*.

#### 2.2 Fitur-Fitur Utama
1. **Eksplorasi Resep Berbasis Kategori (Public API)**: Mengambil data kategori makanan dari TheMealDB (Beef, Chicken, Seafood, Pasta, Dessert, dll.) dan menyajikan resep dalam bentuk kartu visual 2 kolom yang responsif.
2. **Pencarian Cerdas & Real-time (Debounce 500ms)**: Pengguna dapat mencari resep masakan berdasarkan nama secara langsung tanpa membebani server/API secara berlebihan berkat mekanisme *debounce*.
3. **Detail Resep Komprehensif**:
   - Gambar *Hero animation* berukuran besar dengan *SliverAppBar parallax* dan tombol navigasi bernuansa *glass effect*.
   - Badge informasi asal negara (*Area*) dan kategori masakan.
   - Parsing otomatis daftar bahan masakan (*Ingredients*) beserta takarannya (*Measures*).
   - Panduan cara memasak langkah demi langkah bernomor (*Numbered Cooking Steps*) yang nyaman dibaca saat beraktivitas di dapur.
4. **Local Storage & Offline-First**:
   - Resep favorit dapat disimpan ke perangkat secara lokal menggunakan `SharedPreferences`.
   - Resep yang tersimpan dapat dibuka secara penuh (termasuk bahan dan langkah memasak) meskipun perangkat sedang tidak memiliki koneksi internet (*offline*).
5. **Catatan Masak Pribadi (*Personal Cooking Notes*)**:
   - Pengguna dapat menambahkan, membaca, dan mengubah catatan masak sendiri pada resep yang disimpan (contoh: *"Garam dikurangi setengah sendok teh, tambahkan 2 siung bawang putih"*). Catatan tersimpan persisten di penyimpanan lokal.
6. **Manajemen Favorit Interaktif**:
   - Fitur *Swipe-to-Dismiss* untuk menghapus resep favorit secara cepat.
   - Tombol hapus dengan dialog konfirmasi agar tidak terjadi ketidaksengajaan.
   - *Floating SnackBar* dengan aksi **"Urungkan" (Undo)** untuk mengembalikan resep yang baru saja terhapus.
7. **Meal Planner Harian (Fitur Nilai Tambah)**:
   - Kalender jadwal harian (Senin s.d. Minggu) untuk mengorganisir menu Sarapan, Makan Siang, dan Makan Malam beserta estimasi kalori dan tips gizi harian.

---

### 3. LIBRARY & STRUKTUR DATA

#### 3.1 Daftar Package / Dependencies (`pubspec.yaml`)
| Package | Versi | Fungsi dalam Aplikasi |
| :--- | :--- | :--- |
| `http` | `^1.2.2` | Menjalankan request HTTP (GET) asynchronous ke REST API TheMealDB untuk mengambil kategori, daftar resep, pencarian, dan detail resep. |
| `shared_preferences` | `^2.3.2` | Menyimpan daftar objek resep favorit beserta catatan modifikasi pribadi ke penyimpanan persisten lokal perangkat (format JSON string list). |
| `google_fonts` | `^6.2.1` | Mengintegrasikan tipografi profesional **Plus Jakarta Sans** untuk seluruh teks aplikasi secara konsisten. |
| `cupertino_icons` | `^1.0.8` | Menyediakan set ikon pendukung kompatibel iOS/Android. |

#### 3.2 Endpoint REST API (TheMealDB — Public API)
Aplikasi memanfaatkan base URL: `https://www.themealdb.com/api/json/v1/1/`

| No | Endpoint | Method | Fungsi |
| :---: | :--- | :---: | :--- |
| 1 | `/categories.php` | GET | Mengambil semua daftar kategori masakan beserta gambar thumbnail dan deskripsinya. |
| 2 | `/filter.php?c={category}` | GET | Mengambil daftar resep ringkas berdasarkan kategori terpilih (default: "Beef"). |
| 3 | `/search.php?s={query}` | GET | Melakukan pencarian resep masakan berdasarkan kata kunci nama makanan. |
| 4 | `/lookup.php?i={idMeal}` | GET | Mengambil detail lengkap satu resep berdasarkan ID unik (bahan 1-20, takaran, dan instruksi memasak). |

#### 3.3 Struktur Data JSON & Model Dart
TheMealDB menyediakan data masakan dengan format response seperti berikut:
```json
{
  "meals": [
    {
      "idMeal": "52772",
      "strMeal": "Teriyaki Chicken Casserole",
      "strCategory": "Chicken",
      "strArea": "Japanese",
      "strInstructions": "Preheat oven to 350° F. Spray a 9x13-inch baking dish...",
      "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
      "strTags": "Meat,Casserole",
      "strIngredient1": "soy sauce",
      "strIngredient2": "water",
      "strMeasure1": "3/4 cup",
      "strMeasure2": "1/2 cup"
    }
  ]
}
```

Struktur ini dipetakan ke dalam arsitektur model Dart di file `lib/models/meal_model.dart`:
- **`Meal`**: Berisi atribut `idMeal`, `strMeal`, `strMealThumb`, `strCategory`, `strArea`, `strInstructions`, `strTags`, `List<Ingredient> ingredients`, serta atribut lokal `personalNote`.
- **`Ingredient`**: Berisi pasangan `name` (nama bahan) dan `measure` (takaran porsi).
- **`MealCategory`**: Dipetakan di `lib/models/category_model.dart` untuk data kategori masakan.

#### 3.4 Skema Local Storage (`SharedPreferences`)
Data favorit disimpan dengan konfigurasi:
- **Storage Key**: `'saved_recipes'`
- **Data Type**: `List<String>` (koleksi string hasil `json.encode(meal.toJson())`)
- **Skema JSON Tersimpan di Storage**:
```json
{
  "idMeal": "52772",
  "strMeal": "Teriyaki Chicken Casserole",
  "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
  "strCategory": "Chicken",
  "strArea": "Japanese",
  "strInstructions": "Preheat oven to 350° F...",
  "ingredients": [
    {"name": "soy sauce", "measure": "3/4 cup"},
    {"name": "water", "measure": "1/2 cup"}
  ],
  "personalNote": "Gunakan kecap asin rendah natrium. Tambahkan sedikit wijen sangrai saat disajikan."
}
```

---

### 4. ALUR NAVIGASI & ARSITEKTUR HALAMAN

#### 4.1 Penjelasan Alur Navigasi
Aplikasi mengusung navigasi bertingkat yang bersih dan responsif:
1. **Navigasi Utama (`MainNavigation`)**: Menggunakan Material 3 `NavigationBar` di bagian bawah dengan 3 tab: **Jelajah** (Halaman 1), **Tersimpan** (Halaman 2), dan **Meal Planner** (Halaman 3). State antar tab dipertahankan secara utuh menggunakan `IndexedStack`.
2. **Navigasi ke Halaman Detail (`DetailScreen`)**: Saat pengguna menekan kartu resep dari halaman Jelajah maupun item dari halaman Tersimpan, aplikasi melakukan transisi halus menggunakan `FadeTransition` dan `Hero Animation` pada gambar resep sehingga perpindahan terasa organik dan tanpa patah (*seamless*).
3. **Aksi Offline & Sinkronisasi**: Jika resep dibuka dari tab Tersimpan, seluruh data instruksi dan bahan langsung di-load dari memori HP sehingga halaman detail dapat dibuka tanpa perlu jaringan internet sama sekali.

#### 4.2 Panduan Tangkapan Layar (Screenshot) untuk Laporan PDF
*(Saat memindahkan isi laporan ini ke Microsoft Word / Google Docs / Canva untuk dijadikan PDF, letakkan gambar screenshot aplikasi Anda di bagian-bagian berikut):*

- **Screenshot 1: Beranda / Eksplorasi Resep**
  - Tampilkan halaman utama dengan sapaan jam, search bar, chips kategori masakan, dan grid resep 2 kolom yang rapi.
- **Screenshot 2: State Loading & Pencarian**
  - Tampilkan animasi kerangka *Shimmer Skeleton Grid* saat aplikasi memuat data, serta hasil pencarian resep pada search bar.
- **Screenshot 3: Halaman Detail Resep**
  - Tampilkan bagian atas dengan gambar Hero berukuran besar, badge kategori/negara, daftar kartu bahan (*Ingredients*), dan langkah memasak bernomor.
- **Screenshot 4: Fitur Catatan Masak Pribadi**
  - Tampilkan form catatan masak pribadi pada resep yang tersimpan (mode teks yang sudah diisi catatan modifikasi resep).
- **Screenshot 5: Resep Tersimpan & Aksi Hapus (Undo)**
  - Tampilkan daftar resep favorit dengan thumbnail 80x80 rounded, preview catatan pribadi, serta feedback SnackBar saat menghapus/mengurungkan resep.
- **Screenshot 6: Halaman Meal Planner & Mode Gelap (Dark Mode)**
  - Tampilkan tab Meal Planner dengan kalender mingguan dan kartu menu harian, serta satu contoh tangkapan layar dalam tampilan Dark Mode.

---

### 5. PENJELASAN KODE UTAMA

#### 5.1 Integrasi REST API (`lib/services/api_service.dart`)
File ini menangani seluruh komunikasi jaringan ke server TheMealDB dengan timeout 15 detik dan penanganan error terpusat:

```dart
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Mengambil daftar kategori masakan
  Future<List<MealCategory>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/categories.php'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List categories = data['categories'] ?? [];
        return categories.map((c) => MealCategory.fromJson(c)).toList();
      }
      throw Exception('Gagal memuat kategori');
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }
  }

  // Mengambil detail lengkap resep berdasarkan idMeal
  Future<Meal?> getMealById(String idMeal) async {
    try {
      final uri = Uri.parse('$_baseUrl/lookup.php?i=$idMeal');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? meals = data['meals'];
        if (meals == null || meals.isEmpty) return null;
        return Meal.fromJson(meals[0]);
      }
      throw Exception('Gagal memuat detail resep');
    } catch (e) {
      throw Exception('Gagal memuat detail resep. Periksa koneksi internet.');
    }
  }
}
```
*Penjelasan*: Fungsi `getCategories()` dan `getMealById()` menggunakan `http.get` asynchronous. Response di-decode dengan `json.decode` lalu dipetakan ke objek Dart melalui factory constructor `.fromJson()`.

#### 5.2 Parsing Dinamis 20 Bahan & Takaran (`lib/models/meal_model.dart`)
API TheMealDB menyediakan pasangan bahan dan takaran secara terpisah dalam key `strIngredient1` s.d. `strIngredient20` dan `strMeasure1` s.d. `strMeasure20`. Algoritma di bawah memproses dan memfilter data tersebut secara dinamis:

```dart
factory Meal.fromJson(Map<String, dynamic> json) {
  final List<Ingredient> ingredientList = [];

  for (int i = 1; i <= 20; i++) {
    final ingredient = json['strIngredient$i']?.toString().trim() ?? '';
    final measure = json['strMeasure$i']?.toString().trim() ?? '';

    // Hanya masukkan bahan yang tidak null dan tidak kosong
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
    ingredients: ingredientList,
    personalNote: json['personalNote'],
  );
}
```
*Penjelasan*: Kode melakukan iterasi 1 hingga 20, membersihkan whitespace dengan `.trim()`, dan memastikan nilai non-empty dimasukkan ke `List<Ingredient>`, sehingga tampilan resep di layar terbebas dari nilai null atau baris kosong.

#### 5.3 Pengelolaan Local Storage (`lib/services/storage_service.dart`)
Menggunakan `SharedPreferences` untuk menyimpan dan memanipulasi data favorit secara offline:

```dart
class StorageService {
  static const String _savedRecipesKey = 'saved_recipes';

  // 1. Mengambil seluruh resep yang tersimpan di memori perangkat
  Future<List<Meal>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];
    return jsonList.map((jsonStr) => Meal.fromLocalJson(json.decode(jsonStr))).toList();
  }

  // 2. Menyimpan resep baru jika belum ada (mencegah duplikasi idMeal)
  Future<void> saveRecipe(Meal recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];
    final bool alreadySaved = jsonList.any((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['idMeal'] == recipe.idMeal;
    });

    if (!alreadySaved) {
      jsonList.add(json.encode(recipe.toJson()));
      await prefs.setStringList(_savedRecipesKey, jsonList);
    }
  }

  // 3. Menghapus resep berdasarkan idMeal
  Future<void> removeRecipe(String idMeal) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_savedRecipesKey) ?? [];
    jsonList.removeWhere((jsonStr) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['idMeal'] == idMeal;
    });
    await prefs.setStringList(_savedRecipesKey, jsonList);
  }

  // 4. Memperbarui catatan masak pribadi pengguna
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
}
```
*Penjelasan*: Seluruh data diserialisasi menjadi JSON String sebelum disimpan ke `SharedPreferences` menggunakan `json.encode` dan dide-serialisasi kembali dengan `json.decode` saat dibaca.

---

### 6. KENDALA & SOLUSI

Dalam proses perancangan dan implementasi aplikasi CookMate, terdapat beberapa tantangan teknis yang berhasil diatasi:

1. **Format Data Bahan API TheMealDB yang Terpisah (20 Keys)**:
   - *Kendala*: Struktur JSON API TheMealDB tidak menyediakan array objek untuk bahan masakan, melainkan 20 pasang key terpisah (`strIngredient1..20` dan `strMeasure1..20`), di mana banyak nilai bernilai string kosong `""` atau null.
   - *Solusi*: Dibuat algoritma pemrosesan cerdas di dalam factory constructor `Meal.fromJson()` yang melakukan iterasi dinamis, melakukan sanitasi teks (*trimming*), memvalidasi kelayakan data, dan mengelompokkannya ke dalam list `List<Ingredient>` yang rapi.

2. **Daftar Resep Berdasarkan Kategori Hanya Menyediakan Data Ringkas**:
   - *Kendala*: Endpoint `/filter.php?c={category}` hanya mengembalikan `idMeal`, `strMeal`, dan `strMealThumb` (tidak menyertakan langkah memasak dan daftar bahan).
   - *Solusi*: Diterapkan pola *Lazy Loading* & *State Fallback*. Saat kartu ditekan, `DetailScreen` langsung menampilkan gambar dan nama resep secara instan (didukung *Hero animation*), sementara instruksi lengkap dan bahan dimuat secara asynchronous di latar belakang melalui endpoint `/lookup.php?i={idMeal}`. Jika resep sudah pernah disimpan di Local Storage, data lokal lengkap langsung digunakan tanpa perlu request ulang ke API.

3. **Sinkronisasi Data Favorit dan Catatan Masak Antar-Halaman**:
   - *Kendala*: Ketika pengguna mengubah catatan pribadi atau menghapus bookmark di `DetailScreen`, halaman `SavedScreen` harus langsung ter-update tanpa harus me-restart aplikasi.
   - *Solusi*: Pemanggilan navigasi menggunakan `await Navigator.push()` yang diikuti dengan fungsi `_loadSavedMeals()` saat kembali dari halaman detail. Selain itu, ditambahkan `AutomaticKeepAliveClientMixin` pada state halaman agar posisi scroll dan state tidak hilang saat berpindah antar tab navigasi.

4. **Penanganan Kasus Layout Unbounded Height pada Scrollable Grid**:
   - *Kendala*: Penggunaan `GridView` di dalam `CustomScrollView` (seperti pada widget shimmer skeleton) sempat memicu error Flutter `Vertical viewport was given unbounded height` karena dua viewport saling bertumpuk.
   - *Solusi*: Dibuat komponen khusus `SliverShimmerGrid` menggunakan `SliverGrid` bawaan Flutter sehingga dapat berpadu secara mulus di dalam sliver architecture `CustomScrollView` tanpa memicu error rendering.

5. **Kualitas Kode dan Null Safety**:
   - *Kendala*: Terdapat deprecation warning seperti `withOpacity` dan `background` pada Flutter SDK versi terbaru.
   - *Solusi*: Seluruh kode diperbarui menggunakan API modern Flutter seperti `.withValues(alpha: ...)` dan penyesuaian Material 3 ColorScheme, menghasilkan **0 issue pada `flutter analyze`** dan lolos pengujian **`flutter test`**.

---

### 7. KESIMPULAN

Aplikasi **CookMate** berhasil dibangun dengan memenuhi seluruh ketentuan Ujian Tengah Praktikum (UTP) Mobile Programming:
- **Konsep Unik & Estetik**: Desain visual hangat bertema kuliner (*Deep Orange #E65100*), tipografi *Plus Jakarta Sans*, mikro-interaksi responsif, serta penambahan fitur Meal Planner.
- **Navigasi Terstruktur**: Terdiri dari minimal 3 halaman utama (Jelajah/Home, Detail Resep, dan Resep Tersimpan/Saved) yang saling terhubung dengan Material 3 NavigationBar.
- **Pengelolaan Data Terlengkap (Opsi 3 - Nilai Plus)**: Mengintegrasikan Public REST API TheMealDB dengan penanganan kondisi *loading* (shimmer), *error*, dan *empty state*, serta penyimpanan persisten *offline* menggunakan `SharedPreferences` lengkap dengan fitur catatan masak pribadi (*personal notes*).
- **Kualitas Teknis**: Struktur kode modular (models, services, screens, widgets, theme), bebas dari error null-safety, dan lolos uji analisis Flutter.
