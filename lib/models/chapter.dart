import 'pages.dart';

class Chapter {
  final String id;
  final double chapterNumber;
  final String title;
  final DateTime releaseDate;
  final List<Pages>? pages;
  final int? views;
  final bool? isRead;

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.releaseDate,
    this.pages,
    this.views,
    this.isRead,
  });

  // แปลง JSON เป็น Object
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      chapterNumber: (json['chapterNumber'] as num).toDouble(),
      title: json['title'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      pages: (json['pages'] as List<dynamic>?)
          ?.map((e) => Pages.fromJson(e as Map<String, dynamic>))
          .toList(),
      views: json['views'] as int?,
      isRead: json['isRead'] as bool?,
    );
  }

  // แปลง Object เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'title': title,
      'releaseDate': releaseDate.toIso8601String(),
      'pages': pages?.map((e) => e.toJson()).toList(),
      'views': views,
      'isRead': isRead,
    };
  }

  // สร้าง copy
  Chapter copyWith({
    String? id,
    double? chapterNumber,
    String? title,
    DateTime? releaseDate,
    List<Pages>? pages,
    int? views,
    bool? isRead,
  }) {
    return Chapter(
      id: id ?? this.id,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      pages: pages ?? this.pages,
      views: views ?? this.views,
      isRead: isRead ?? this.isRead,
    );
  }

  //เช็คว่ามีหน้าหรือไม่
  bool get hasPages => pages != null && pages!.isNotEmpty;

  // จำนวนหน้า
  int get pageCount => pages?.length ?? 0;
}
