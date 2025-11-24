import 'package:flutter/material.dart';
import '../models/manga.dart';
import 'unified_api_service.dart';

enum DataState { initial, loading, loaded, loadingMore, error }

class MangaProvider with ChangeNotifier {
  final UnifiedApiService _apiService = UnifiedApiService();
  
  // Latest Manga (หน้าแรก)
  List<Manga> _latestManga = [];
  DataState _latestMangaState = DataState.initial;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Search Results
  List<Manga> _searchResults = [];
  DataState _searchState = DataState.initial;

  // Getters สำหรับ Latest Manga
  List<Manga> get latestManga => _latestManga;
  DataState get latestMangaState => _latestMangaState;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Getters สำหรับ Search
  List<Manga> get searchResults => _searchResults;
  DataState get searchState => _searchState;

  // Getters เดิม (สำหรับ backward compatibility)
  List<Manga> get mangaList => _latestManga;
  DataState get state => _latestMangaState;

  // Constructor - โหลดข้อมูลอัตโนมัติ
  MangaProvider() {
    loadManga();
  }

  // โหลดหน้าแรก
  Future<void> loadManga() async {
    _latestMangaState = DataState.loading;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      _latestManga = await _apiService.fetchLatestManga(page: _currentPage);
      _latestMangaState = DataState.loaded;
      _hasMore = _latestManga.length >= 20;
    } catch (e) {
      _latestMangaState = DataState.error;
      _errorMessage = e.toString();
      _latestManga = [];
      print('❌ MangaProvider Error: $e');
    }
    
    notifyListeners();
  }

  // โหลดหน้าถัดไป (Infinite Scroll)
  Future<void> loadMore() async {
    if (!_hasMore || _latestMangaState == DataState.loadingMore) return;

    _latestMangaState = DataState.loadingMore;
    notifyListeners();

    try {
      _currentPage++;
      final newManga = await _apiService.fetchLatestManga(page: _currentPage);
      
      if (newManga.isEmpty) {
        _hasMore = false;
      } else {
        _latestManga.addAll(newManga);
        _hasMore = newManga.length >= 20;
      }
      
      _latestMangaState = DataState.loaded;
    } catch (e) {
      _currentPage--;
      _latestMangaState = DataState.error;
      _errorMessage = e.toString();
      print('❌ LoadMore Error: $e');
    }
    
    notifyListeners();
  }

  // ค้นหามังงะ
  Future<void> searchManga(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _searchState = DataState.loading;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchManga(query);
      _searchState = DataState.loaded;
    } catch (e) {
      _searchState = DataState.error;
      _searchResults = [];
      print('❌ Search Error: $e');
    }
    
    notifyListeners();
  }

  // ล้างผลการค้นหา
  void clearSearch() {
    _searchResults = [];
    _searchState = DataState.initial;
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() async {
    await loadManga();
  }

  // รีเซ็ตข้อมูล
  void reset() {
    _latestManga = [];
    _latestMangaState = DataState.initial;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _searchResults = [];
    _searchState = DataState.initial;
    notifyListeners();
  }
}