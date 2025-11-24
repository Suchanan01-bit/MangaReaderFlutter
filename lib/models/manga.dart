import 'chapter.dart';

class Manga {
  final String id;
  final String title;
  final String? originalTitle;
  final String coverUrl;
  final String summary;
  final String author;
  final String? artist;
  final List<String> genres;
  final String status; // "Ongoing", "Completed", "Hiatus"
  final DateTime lastUpdated;
  final int views;
  final double? rating;
  final List<Chapter>? chapters;
  final bool? isFavorite;
  final String coverFileName;

  Manga({
    required this.id,
    required this.title,
    this.originalTitle,
    required this.coverUrl,
    required this.summary,
    required this.author,
    this.artist,
    required this.genres,
    required this.status,
    required this.lastUpdated,
    required this.views,
    this.rating,
    this.chapters,
    this.isFavorite,
     required this.coverFileName, required creatorInfo, required int chapterCount,
  });

  // แปลง JSON เป็น Object
  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as String,
      title: json['title'] as String,
      originalTitle: json['originalTitle'] as String?,
      coverUrl: json['coverUrl'] as String,
      summary: json['summary'] as String,
      author: json['author'] as String,
      artist: json['artist'] as String?,
      genres: List<String>.from(json['genres'] ?? []),
      status: json['status'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      views: json['views'] as int,
      rating: (json['rating'] as num?)?.toDouble(),
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool?,
      coverFileName: json['coverFileName'] as String, creatorInfo: null, chapterCount: 0,
    );
  }

  // แปลง Object เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalTitle': originalTitle,
      'coverUrl': coverUrl,
      'summary': summary,
      'author': author,
      'artist': artist,
      'genres': genres,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
      'views': views,
      'rating': rating,
      'chapters': chapters?.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  
  Manga copyWith({
    String? id,
    String? title,
    String? originalTitle,
    String? coverUrl,
    String? summary,
    String? author,
    String? artist,
    List<String>? genres,
    String? status,
    DateTime? lastUpdated,
    int? views,
    double? rating,
    List<Chapter>? chapters,
    bool? isFavorite,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      summary: summary ?? this.summary,
      author: author ?? this.author,
      artist: artist ?? this.artist,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      chapters: chapters ?? this.chapters,
      isFavorite: isFavorite ?? this.isFavorite,
      coverFileName: coverFileName, creatorInfo: null, chapterCount: 0,
    );
  }

  // ฟังก์ชันเสริม: หาตอนล่าสุด
  Chapter? get latestChapter {
    if (chapters == null || chapters!.isEmpty) return null;
    return chapters!.reduce(
      (a, b) => a.chapterNumber > b.chapterNumber ? a : b,
    );
  }

  // จำนวนตอนทั้งหมด
  int get chapterCount => chapters?.length ?? 0;

  // ชื่อแนว 
  String get genresDisplay => genres.join(', ');

  // ข้อมูลผู้สร้าง
  String get creatorInfo {
    if (artist != null && artist != author) {
      return '$author (เขียน), $artist (วาด)';
    }
    return author;
  }
}
