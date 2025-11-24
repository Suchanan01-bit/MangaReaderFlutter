import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manga.dart';
import 'manga_api_service.dart';

enum DataState { initial, loading, loaded, error }

class FavoritesProvider extends ChangeNotifier {
  // เก็บเฉพาะ ID ของมังงะที่ถูก Favorite
  List<String> _favoriteIds = [];
  // เก็บรายการมังงะฉบับเต็มเพื่อใช้แสดงบน FavoritesScreen
  List<Manga> _favorites = [];
  bool _isLoading = false;

  final MangaApiService _apiService = MangaApiService();

  List<Manga> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Constructor
  FavoritesProvider() {
    // 🛑 เริ่มต้นด้วยการโหลด ID ที่ถูกบันทึกไว้ และโหลดรายละเอียดมังงะ
    _loadFavoriteIdsFromStorage().then((_) {
      loadFavorites();
    });
  }

  // --- เมธอดภายในสำหรับจัดการ ID ---

  // 1. โหลด ID จาก SharedPreferences
  Future<void> _loadFavoriteIdsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favorites') ?? [];
    _logFavoritesCount('_loadFavoriteIdsFromStorage');
  }

  // 2. บันทึก ID ลง SharedPreferences
  Future<void> _saveFavoriteIdsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds);
  }
  
  // เพิ่มเมธอดช่วยพิมพ์จำนวน
  void _logFavoritesCount(String source) {
    debugPrint('[$source] จำนวน Favorite IDs = ${_favoriteIds.length}');
  }

  // --- เมธอดหลักสำหรับโหลดและแสดงผลบน FavoritesScreen ---

  /// โหลดรายการมังงะฉบับเต็ม (พร้อมรายละเอียด) เพื่อใช้แสดงผล
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favorites') ?? [];

    final List<Manga> favs = [];
    for (final mangaId in _favoriteIds) {
      try {
        final manga = await _apiService.fetchMangaDetail(mangaId);
        favs.add(manga);
      } catch (e, st) {
        debugPrint('error fetching detail for id=$mangaId: $e');
        debugPrint(st.toString());
        // ถ้าต้องการเก็บ log เพิ่มเติม สามารถเก็บลงไฟล์หรือส่งไป analytics ได้ที่นี่
      }
    }
    _favorites = favs;

    _logFavoritesCount('loadFavorites');

    _isLoading = false;
    notifyListeners();
  }

  // --- เมธอดหลักสำหรับจัดการสถานะ Favorite (ใช้ใน MangaDetailScreen) ---

  /// เปลี่ยนสถานะ Favorite ของมังงะ
  Future<void> toggleFavorite(String mangaId) async {
    if (_favoriteIds.contains(mangaId)) {
      _favoriteIds.remove(mangaId);
      _logFavoritesCount('toggleFavorite - removed');
      
      // 🛑 แก้ไข: ลบรายการออกจาก _favorites ทันที
      _favorites.removeWhere((m) => m.id == mangaId);

    } else {
      _favoriteIds.add(mangaId);
      _logFavoritesCount('toggleFavorite - added');
      
      // 🛑 OPTIONAL: ถ้าต้องการให้รายการ Favorite ปรากฏทันทีบน FavoritesScreen 
      //    (โดยไม่ต้องรอ loadFavorites()) 
      //    ให้เรียก API เพื่อโหลดรายละเอียดของมังงะที่เพิ่งเพิ่มเข้ามา
      try {
        final newManga = await _apiService.fetchMangaDetail(mangaId);
        _favorites.add(newManga);
      } catch (e) {
         debugPrint('Error fetching new favorite detail: $e');
      }
    }
    
    // บันทึก ID ลง Storage
    await _saveFavoriteIdsToStorage();
    
    // 🔑 สำคัญ: แจ้งเตือน FavoritesScreen ให้อัปเดตรายการทันที
    notifyListeners(); 
    
    // 🛑 ไม่จำเป็นต้องเรียก loadFavorites() อีกครั้งที่นี่
    //    เพราะเราอัปเดต _favorites (และ _favoriteIds) ด้วยตนเองแล้ว
  }

  /// ตรวจสอบสถานะ Favorite (ใช้ใน MangaDetailScreen)
  bool isFavorite(String mangaId) {
    // 🛑 สำคัญ: ต้องโหลด ID มาก่อนใช้เมธอดนี้
    return _favoriteIds.contains(mangaId);
  }
}