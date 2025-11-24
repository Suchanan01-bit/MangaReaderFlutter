import 'package:dio/dio.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/pages.dart';

class MangaDexApiService {
  static const String baseUrl = 'https://api.mangadex.org';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // ดึงมังงะล่าสุด
  Future<List<Manga>> fetchLatestManga({int page = 1, int limit = 20}) async {
    try {
      final offset = (page - 1) * limit;
      
      final response = await _dio.get('/manga', queryParameters: {
        'limit': limit,
        'offset': offset,
        'order[updatedAt]': 'desc',
        'includes[]': ['cover_art', 'author'],
        'availableTranslatedLanguage[]': ['th', 'en'], // ภาษาไทยและอังกฤษ
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => _parseMangaFromMangaDex(json)).toList();
      } else {
        throw Exception('Failed to load manga: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ MangaDex Error: $e');
      throw Exception('Error fetching latest manga: $e');
    }
  }

  // ดึงรายละเอียดมังงะ
  Future<Manga> fetchMangaDetail(String mangaId) async {
    try {
      final response = await _dio.get(
        '/manga/$mangaId',
        queryParameters: {
          'includes[]': ['cover_art', 'author', 'artist'],
        },
      );

      if (response.statusCode == 200) {
        final mangaData = response.data['data'];
        
        // ดึง chapters
        final chapters = await fetchChapters(mangaId);
        
        return _parseMangaFromMangaDex(mangaData, chapters: chapters);
      } else {
        throw Exception('Failed to load manga detail');
      }
    } catch (e) {
      print('❌ MangaDex Detail Error: $e');
      throw Exception('Error fetching manga detail: $e');
    }
  }

  // ดึง chapters
  Future<List<Chapter>> fetchChapters(String mangaId) async {
    try {
      final response = await _dio.get('/manga/$mangaId/feed', queryParameters: {
        'limit': 100,
        'order[chapter]': 'desc',
        'translatedLanguage[]': ['th', 'en'],
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => _parseChapterFromMangaDex(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Chapters Error: $e');
      return [];
    }
  }

  // ดึงหน้ามังงะ (รูปภาพ)
  Future<List<Pages>> fetchChapterPages(String chapterId) async {
    try {
      // 1. ดึงข้อมูล chapter เพื่อหา baseUrl และ hash
      final response = await _dio.get('/at-home/server/$chapterId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load chapter data');
      }

      final baseUrlChapter = response.data['baseUrl'];
      final hash = response.data['chapter']['hash'];
      final data = response.data['chapter']['data'] as List<dynamic>;

      // 2. สร้าง URL สำหรับแต่ละหน้า
      final pages = <Pages>[];
      for (var i = 0; i < data.length; i++) {
        final filename = data[i] as String;
        final imageUrl = '$baseUrlChapter/data/$hash/$filename';
        
        // ✅ แก้ไข: Page ไม่มี field 'id'
        pages.add(Pages(
          pageNumber: i + 1,
          imageUrl: imageUrl,
        ));
      }

      return pages;
    } catch (e) {
      print('❌ Pages Error: $e');
      throw Exception('Error fetching chapter pages: $e');
    }
  }

  // ค้นหามังงะ
  Future<List<Manga>> searchManga(String query) async {
    try {
      final response = await _dio.get('/manga', queryParameters: {
        'title': query,
        'limit': 20,
        'includes[]': ['cover_art', 'author'],
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => _parseMangaFromMangaDex(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Search Error: $e');
      return [];
    }
  }

  // แปลงข้อมูล MangaDex เป็น Manga model
  Manga _parseMangaFromMangaDex(Map<String, dynamic> json, {List<Chapter>? chapters}) {
    final id = json['id'] as String;
    final attributes = json['attributes'] as Map<String, dynamic>;
    
    // ดึงชื่อ (ลองหาภาษาไทยก่อน ถ้าไม่มีใช้อังกฤษ)
    final title = (attributes['title'] as Map<String, dynamic>);
    final titleStr = title['th'] ?? title['en'] ?? title.values.first ?? 'Unknown';
    
    // ดึง description
    final description = (attributes['description'] as Map<String, dynamic>?);
    final descStr = description?['th'] ?? description?['en'] ?? 'ไม่มีคำอธิบาย';
    
    // ดึงแนว (tags)
    final tags = (attributes['tags'] as List?)
        ?.map((tag) => (tag['attributes']['name']['en'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList() ?? [];
    
    // ดึงรูปปก
    String coverUrl = 'https://via.placeholder.com/300x400?text=No+Cover';
    String coverFileName = '';
    final relationships = json['relationships'] as List?;
    if (relationships != null) {
      final coverArt = relationships.firstWhere(
        (rel) => rel['type'] == 'cover_art',
        orElse: () => null,
      );
      if (coverArt != null) {
        final fileName = coverArt['attributes']?['fileName'];
        if (fileName != null) {
          coverUrl = 'https://uploads.mangadex.org/covers/$id/$fileName';
          coverFileName = fileName;
        }
      }
    }

    // ✅ แก้ไข: ใช้ summary แทน description
    return Manga(
      id: id,
      title: titleStr,
      coverUrl: coverUrl,
      coverFileName: coverFileName,
      summary: descStr,  // ✅ เปลี่ยนจาก description เป็น summary
      author: 'MangaDex',
      genres: tags,
      status: 'Ongoing',
      views: 0,
      lastUpdated: DateTime.now(),
      chapters: chapters, creatorInfo: null, chapterCount: 0, 
    );
  }

  // แปลง MangaDex chapter เป็น Chapter model
  Chapter _parseChapterFromMangaDex(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final attributes = json['attributes'] as Map<String, dynamic>;
    
    // ดึงเลขตอน (อาจเป็น String หรือ Number)
    final chapterNumRaw = attributes['chapter'];
    final chapterNum = chapterNumRaw != null 
        ? (chapterNumRaw is num ? chapterNumRaw.toDouble() : double.tryParse(chapterNumRaw.toString()) ?? 0.0)
        : 0.0;
    
    final title = attributes['title'] ?? 'Chapter $chapterNum';
    
    // ✅ แก้ไข: ใช้ releaseDate แทน publishDate
    final publishAt = attributes['publishAt'] != null
        ? DateTime.parse(attributes['publishAt'])
        : DateTime.now();

    // ✅ แก้ไข: Chapter ไม่มี mangaId, volume, pages (int)
    return Chapter(
      id: id,
      chapterNumber: chapterNum,
      title: title,
      releaseDate: publishAt,  // ✅ เปลี่ยนจาก publishDate เป็น releaseDate
      // ไม่ส่ง pages (จะโหลดแยกตอนกดอ่าน)
    );
  }
}