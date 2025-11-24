import 'package:dio/dio.dart';
import 'package:nekopost_clone/models/chapter.dart';
import '../models/manga.dart';
import '../models/pages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class JsonServerApi {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:3000';
  
  // Constructor
  JsonServerApi() {
    _dio.options.baseUrl = _baseUrl;
    // ... ตั้งค่า Dio อื่นๆ 
  }
  Future<List<Manga>> searchManga(String query) async {
    try {
        final response = await _dio.get(
            '/latest_manga', // หรือ endpoint ที่ถูกต้องสำหรับการค้นหา
            queryParameters: {'q': query},
        );
        
        if (response.statusCode == 200 && response.data != null) {
            return (response.data as List)
                .map((json) => Manga.fromJson(json))
                .toList();
        }
        return [];
    } catch (e) {
        print('❌ JsonServerApi Search failed: $e');
        throw Exception('Search API failed: $e');
    }
  }
}

class MangaApiService {
  final Dio _dio = Dio();

  // ⚠️ สำคัญ: เปลี่ยน URL นี้ให้ตรงกับที่คุณรัน API/JSON Server
  static const String _baseUrl = 'http://localhost:3000';
  final JsonServerApi _jsonServerApi = JsonServerApi();
  
  MangaApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  // 1. ดึงรายการมังงะล่าสุด (สำหรับหน้าแรก)
  Future<List<Manga>> fetchLatestManga({int page = 1, int limit = 20}) async {
    // ... (โค้ดเดิม)
    try {
      print('📚 Fetching latest manga (page: $page, limit: $limit)');

      final response = await _dio.get(
        '/latest_manga',
        queryParameters: {'_page': page, '_limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<Manga> mangaList = (response.data as List)
            .map((json) => Manga.fromJson(json))
            .toList();

        print('✅ Successfully fetched ${mangaList.length} manga');
        return mangaList;
      }

      print('⚠️ Invalid response: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching latest manga: $e');
      throw Exception('ไม่สามารถโหลดมังงะล่าสุดได้: $e');
    }
  }

  // 2. ดึงรายละเอียดมังงะ (สำหรับหน้า Detail) - แก้ไขการจัดการข้อมูล
  Future<Manga> fetchMangaDetail(String mangaId) async {
    try {
        // 1. เรียก API ของ MangaDex
        final response = await http.get(Uri.parse('https://api.mangadex.org/manga/$mangaId?includes[]=cover_art'));

        if (response.statusCode != 200) {
            throw Exception('MangaDex API returned status code ${response.statusCode}');
        }

        final data = jsonDecode(response.body);
        final mangaData = data['data'];

        if (mangaData == null) {
            throw Exception('Manga data not found for ID: $mangaId');
        }

        final attributes = mangaData['attributes'];

        final title = attributes['title']?['en'] ?? 'No Title';
        final summary = attributes['description']?['en'] ?? '';
        final status = attributes['status'] ?? '';

        // ❌ การจัดการวันที่: แปลง String เป็น DateTime
        final lastUpdatedString = attributes['updatedAt'];
        final DateTime lastUpdated = lastUpdatedString != null
            ? DateTime.tryParse(lastUpdatedString) ?? DateTime.now()
            : DateTime.now();

        // ดึง Cover Art
        final coverArt = mangaData['relationships']
            ?.firstWhere((rel) => rel['type'] == 'cover_art', orElse: () => null);

        final coverFileName = coverArt?['attributes']?['fileName'] ?? '';

        // ดึง Author/Creator (MangaDex API ใช้ relationships)
        final authorRel = mangaData['relationships']
            ?.firstWhere((rel) => rel['type'] == 'author', orElse: () => null);

        final author = authorRel?['attributes']?['name'] ?? 'Unknown Author';


        // ดึง Genres
        final genres = (attributes['tags'] as List? ?? [])
            .map((tag) => tag['attributes']?['name']?['en'] as String?)
            .where((name) => name != null)
            .cast<String>()
            .toList();

        // 💡 หมายเหตุ: ข้อมูล Chapters, CreatorInfo, Rating, ChapterCount, OriginalTitle
        //    และ Views ไม่ได้ถูกดึงโดยตรงจาก endpoint นี้ และต้องถูกจัดการในโมเดล Manga ให้เป็นค่าเริ่มต้น

        return Manga(
            id: mangaId,
            title: title,
            // ❌ เพิ่ม coverFileName เข้าไปใน constructor ของ Manga
            coverFileName: coverFileName,
            coverUrl: coverFileName.isNotEmpty
                ? 'https://uploads.mangadex.org/covers/$mangaId/$coverFileName.512.jpg'
                : '',
            summary: summary,
            // ❌ อัปเดต creatorInfo และ author
            creatorInfo: author,
            author: author,
            genres: genres,
            status: status,
            // ❌ แก้ไข: ส่งค่า DateTime เข้าไป
            lastUpdated: lastUpdated,
            views: 0,

            // 💡 สำคัญ: ค่าเหล่านี้จำเป็นสำหรับ Manga constructor แต่ไม่ได้ถูกดึงจาก endpoint นี้
            // ต้องแน่ใจว่า Manga constructor รับค่าเหล่านี้เป็น optional หรือมีค่าเริ่มต้น
            // และคุณอาจต้องเพิ่มการเรียก API อื่นเพื่อดึง Chapters/Rating/Views
            chapters: [],
            chapterCount: 0,
            rating: 0,
            originalTitle: '',
        );
    } catch (e) {
        print('❌ Error fetching Manga Detail for ID $mangaId: $e');
        // ส่ง Exception กลับไปเพื่อให้ FavoritesProvider/MangaDetailProvider จัดการสถานะ Error
        throw Exception('ไม่สามารถโหลดรายละเอียดมังงะได้: $e');
    }
  }

  // 3. ดึงรายการหน้าในตอน (สำหรับ Reader)
  Future<List<Pages>> fetchChapterPages(String chapterId) async {
    // ... (โค้ดเดิม)
    try {
      print('📄 Fetching pages for chapter: $chapterId');

      final response = await _dio.get('/chapter_pages');

      if (response.statusCode == 200 && response.data != null) {
        final List chapterList = response.data as List;

        final chapterData = chapterList.firstWhere(
          (item) => item['id'] == chapterId,
          orElse: () => null,
        );

        if (chapterData != null && chapterData['pages'] != null) {
          final pages = (chapterData['pages'] as List)
              .map((json) => Pages.fromJson(json))
              .toList();

          print('✅ Found ${pages.length} pages');
          return pages;
        }
      }

      print('⚠️ No pages found for chapter: $chapterId');
      return [];
    } catch (e) {
      print('❌ Error fetching chapter pages: $e');
      throw Exception('ไม่สามารถโหลดหน้ามังงะได้: $e');
    }
  }

  // ... (เมธอดอื่น ๆ เหมือนเดิม)

  // 7. ดึงแนวเรื่องทั้งหมด
  Future<List<String>> fetchAllGenres() async {
    // ... (โค้ดเดิม)
    try {
      print('🏷️ Fetching all genres...');

      final response = await _dio.get('/latest_manga');

      if (response.statusCode == 200 && response.data != null) {
        final allManga = (response.data as List)
            .map((json) => Manga.fromJson(json))
            .toList();

        // รวม genres ทั้งหมดและเอาเฉพาะที่ไม่ซ้ำ
        final Set<String> genresSet = {};
        for (var manga in allManga) {
          genresSet.addAll(manga.genres);
        }

        final genres = genresSet.toList()..sort();
        print('✅ Found ${genres.length} genres');
        return genres;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching genres: $e');
      return [];
    }
  }

  Future<Future<List<Chapter>>> fetchChapters(String mangaId) async {
    throw UnimplementedError('fetchChapters() has not been implemented yet.');
  }
  Future<List<Manga>> searchManga(String query) async {
    print('🔍 Searching manga via _jsonServerApi: "$query"');
    try {
        // 🔑 เรียกใช้เมธอด searchManga จาก Instance ของ JsonServerApi
        return await _jsonServerApi.searchManga(query);
    } catch (e) {
        print('❌ Error searching manga via _jsonServerApi: $e');
        throw Exception('ไม่สามารถค้นหามังงะได้: $e');
    }
 }
}
