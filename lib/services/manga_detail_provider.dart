import 'package:flutter/material.dart';
import 'package:nekopost_clone/services/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manga.dart';
import 'unified_api_service.dart';

enum DataState { initial, loading, loaded, error }

class MangaDetailProvider with ChangeNotifier {
  final UnifiedApiService _apiService = UnifiedApiService();
  
  Manga? _mangaDetail;
  DataState _detailState = DataState.initial;
  String? _errorMessage;

  Manga? get mangaDetail => _mangaDetail;
  DataState get detailState => _detailState;
  String? get errorMessage => _errorMessage;

  // โหลดรายละเอียดมังงะ
  Future<void> loadMangaDetail(String mangaId) async {
    _detailState = DataState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _mangaDetail = await _apiService.fetchMangaDetail(mangaId);
      
      // เช็คว่าอยู่ใน Favorites หรือไม่ (จาก LocalStorage)
      final isFavorite = await _checkFavoriteStatus(mangaId);
      _mangaDetail = _mangaDetail!.copyWith(isFavorite: isFavorite);
      
      _detailState = DataState.loaded;
    } catch (e) {
      _detailState = DataState.error;
      _errorMessage = e.toString();
      _mangaDetail = null;
      print('❌ MangaDetailProvider Error: $e');
    }
    
    notifyListeners();
  }

  // Toggle Favorite (ใช้ SharedPreferences)
  Future<void> toggleFavorite(BuildContext context) async {
    if (_mangaDetail == null) return;
    
    // 1. เข้าถึง FavoritesProvider (ใช้ listen: false เพราะเราอยู่คนละ Provider)
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    // 2. เรียกให้ FavoritesProvider จัดการการสลับสถานะและบันทึกข้อมูล
    await favoritesProvider.toggleFavorite(_mangaDetail!.id);
    
    // 3. อัปเดตสถานะ isFavorite ในโมเดลของตัวเอง
    _mangaDetail = _mangaDetail!.copyWith(
        isFavorite: favoritesProvider.isFavorite(_mangaDetail!.id)
    );
    
    // 4. แจ้งเตือน MangaDetailScreen ให้อัปเดต UI (ปุ่มหัวใจ)
    notifyListeners(); 
}

  // เช็คสถานะ Favorite จาก SharedPreferences
  Future<bool> _checkFavoriteStatus(String mangaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      return favorites.contains(mangaId);
    } catch (e) {
      return false;
    }
  }

  // รีเซ็ตข้อมูล
  void reset() {
    _mangaDetail = null;
    _detailState = DataState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}