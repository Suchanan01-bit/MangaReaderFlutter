class Pages {
  final int pageNumber;
  final String imageUrl;
  final int? width;
  final int? height;

  Pages({
    required this.pageNumber,
    required this.imageUrl,
    this.width,
    this.height,
  });

  // แปลง JSON เป็น Object
  factory Pages.fromJson(Map<String, dynamic> json) {
    return Pages(
      pageNumber: json['pageNumber'] as int,
      imageUrl: json['imageUrl'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  // แปลง Object เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'imageUrl': imageUrl,
      'width': width,
      'height': height,
    };
  }

  // สร้าง copy พร้อมแก้ไขบางค่า
  Pages copyWith({
    int? pageNumber,
    String? imageUrl,
    int? width,
    int? height,
  }) {
    return Pages(
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
