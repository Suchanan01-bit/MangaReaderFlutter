import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/pages.dart';
import '../config/api_config.dart';
import 'manga_api_service.dart';
import 'mangadex_api_service.dart';

class UnifiedApiService {
  final MangaApiService _jsonServerApi = MangaApiService();
  final MangaDexApiService _mangaDexApi = MangaDexApiService();
  
  // ดึงมังงะล่าสุด
  Future<List<Manga>> fetchLatestManga({int page = 1}) async {
    if (ApiConfig.useMangaDex) {
      return await _mangaDexApi.fetchLatestManga(page: page);
    } else {
      return await _jsonServerApi.fetchLatestManga(page: page);
    }
  }
  
  // ดึงรายละเอียดมังงะ
  Future<Manga> fetchMangaDetail(String mangaId) async {
    if (ApiConfig.useMangaDex) {
      return await _mangaDexApi.fetchMangaDetail(mangaId);
    } else {
      return await _jsonServerApi.fetchMangaDetail(mangaId);
    }
  }
  
  // ดึง chapters
  Future<List<Chapter>> fetchChapters(String mangaId) async {
    if (ApiConfig.useMangaDex) {
      return await _mangaDexApi.fetchChapters(mangaId);
    } else {
      return await _jsonServerApi.fetchChapters(mangaId);
    }
  }
  
  // ดึงหน้ามังงะ
  Future<List<Pages>> fetchChapterPages(String chapterId) async {
    if (ApiConfig.useMangaDex) {
      return await _mangaDexApi.fetchChapterPages(chapterId);
    } else {
      return await _jsonServerApi.fetchChapterPages(chapterId);
    }
  }
  
  // ค้นหามังงะ
  Future<List<Manga>> searchManga(String query) async {
    if (ApiConfig.useMangaDex) {
      return await _mangaDexApi.searchManga(query);
    } else {
      return await _jsonServerApi.searchManga(query);
    }
  }
}