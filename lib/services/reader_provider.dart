import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pages.dart' ;
import 'unified_api_service.dart';

enum DataState { initial, loading, loaded, error }

class ReaderProvider with ChangeNotifier {
  final UnifiedApiService _apiService = UnifiedApiService();
  
  List<Pages> _pages = [];
  DataState _readerState = DataState.initial;
  String? _errorMessage;
  int _currentPageIndex = 0;
  bool _showUI = true;

  List<Pages> get pages => _pages;
  DataState get readerState => _readerState;
  String? get errorMessage => _errorMessage;
  int get currentPageIndex => _currentPageIndex;
  bool get showUI => _showUI;
  int get totalPages => _pages.length;
  
  // คำนวณเปอร์เซ็นต์ความคืบหน้า
  double get progress {
    if (_pages.isEmpty) return 0.0;
    return (_currentPageIndex + 1) / _pages.length;
  }

  // โหลดหน้ามังงะ
  Future<void> loadChapterPages(String mangaId, String chapterId) async {
    _readerState = DataState.loading;
    _errorMessage = null;
    _currentPageIndex = 0;
    notifyListeners();

    try {
      _pages = (await _apiService.fetchChapterPages(chapterId)).cast<Pages>();
      _readerState = DataState.loaded;
    } catch (e) {
      _readerState = DataState.error;
      _errorMessage = e.toString();
      _pages = [];
      print('❌ ReaderProvider Error: $e');
    }
    
    notifyListeners();
  }

  // บันทึกประวัติการอ่าน (ใช้ SharedPreferences)
  Future<void> saveProgress(String mangaId, String chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // บันทึก format: "mangaId:chapterId:pageNumber"
      final historyKey = 'history_${mangaId}_$chapterId';
      await prefs.setInt(historyKey, _currentPageIndex);
      
      // บันทึกลิสต์ history
      final historyList = prefs.getStringList('reading_history') ?? [];
      final historyEntry = '$mangaId:$chapterId';
      
      // ลบออกถ้ามีอยู่แล้ว (เพื่อเอาไปไว้บนสุด)
      historyList.remove(historyEntry);
      // เพิ่มไว้บนสุด
      historyList.insert(0, historyEntry);
      
      // เก็บแค่ 50 รายการล่าสุด
      if (historyList.length > 50) {
        historyList.removeRange(50, historyList.length);
      }
      
      await prefs.setStringList('reading_history', historyList);
      
      print('✅ Saved progress: $mangaId:$chapterId:$_currentPageIndex');
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  // อัปเดตหน้าปัจจุบัน
  void updateCurrentPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  // ไปหน้าถัดไป
  bool nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _currentPageIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ย้อนกลับหน้าก่อนหน้า
  bool previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Toggle แสดง/ซ่อน UI
  void toggleUI() {
    _showUI = !_showUI;
    notifyListeners();
  }

  // ตั้งค่าแสดง UI
  void setShowUI(bool show) {
    _showUI = show;
    notifyListeners();
  }

  // รีเซ็ตข้อมูล
  void reset() {
    _pages = [];
    _readerState = DataState.initial;
    _errorMessage = null;
    _currentPageIndex = 0;
    _showUI = true;
    notifyListeners();
  }
}