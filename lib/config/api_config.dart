enum ApiMode {
  jsonServer,  // ใช้ JSON Server (Local)
  mangaDex,    // ใช้ MangaDex API (Online)
}

class ApiConfig {
  // เปลี่ยนตรงนี้เพื่อสลับ Mode
  static ApiMode currentMode = ApiMode.mangaDex;
  
  // JSON Server URL
  static const String jsonServerUrl = 'http://localhost:3000';
  
  // MangaDex URL (ไม่ต้องเปลี่ยน)
  static const String mangaDexUrl = 'https://api.mangadex.org';
  
  // ตรวจสอบว่าใช้ MangaDex หรือไม่
  static bool get useMangaDex => currentMode == ApiMode.mangaDex;
  
  // ตรวจสอบว่าใช้ JSON Server หรือไม่
  static bool get useJsonServer => currentMode == ApiMode.jsonServer;
  
  // สลับ Mode
  static void switchToMangaDex() {
    currentMode = ApiMode.mangaDex;
    print('✅ Switched to MangaDex API');
  }
  
  static void switchToJsonServer() {
    currentMode = ApiMode.jsonServer;
    print('✅ Switched to JSON Server');
  }
  
  // แสดงชื่อ Mode ปัจจุบัน
  static String get currentModeName {
    switch (currentMode) {
      case ApiMode.jsonServer:
        return 'JSON Server (Local)';
      case ApiMode.mangaDex:
        return 'MangaDex API (Online)';
    }
  }
}
