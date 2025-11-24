# 🎯 Nekopost Clone - JSON Server Edition

แอปอ่านมังงะออนไลน์ สร้างด้วย **Flutter + JSON Server**

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![JSON Server](https://img.shields.io/badge/JSON_Server-0.17-green)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)

---

## ⚡ Quick Start (3 ขั้นตอน)

### 1️⃣ รัน JSON Server
```bash
cd nekopost_clone

# ติดตั้ง JSON Server (ครั้งแรก)
npm install

# รัน Server
npm start
```

**Server จะรันที่:** http://localhost:3000

### 2️⃣ ติดตั้ง Dependencies
```bash
# เปิด Terminal ใหม่
flutter pub get
```

### 3️⃣ รันแอป
```bash
flutter run
```

**เท่านี้เอง! ✅**

---

## 📋 สิ่งที่ต้องมี

### Software:
- ✅ **Flutter SDK** 3.0+ ([ดาวน์โหลด](https://flutter.dev/docs/get-started/install))
- ✅ **Node.js** ([ดาวน์โหลด](https://nodejs.org/))
- ✅ **Android Studio** หรือ **Xcode** (สำหรับ emulator)

---

## 🎯 Features

### ✨ ทำงานได้เต็มที่:
- ✅ **หน้าแรก** - แสดงมังงะล่าสุด + Infinite scroll
- ✅ **รายละเอียด** - ข้อมูลมังงะ + รายการตอน
- ✅ **อ่านมังงะ** - Viewer เต็มหน้าจอ + Pinch to zoom
- ✅ **ค้นหา** - ค้นหามังงะด้วยชื่อ
- ✅ **รายการโปรด** - บันทึกด้วย SharedPreferences (Local)
- ✅ **ประวัติ** - บันทึกหน้าที่อ่าน (Local)

### 💾 การจัดเก็บข้อมูล:
- 📊 **ข้อมูลมังงะ:** JSON Server (HTTP API)
- 💖 **Favorites:** SharedPreferences (Local)
- 📖 **History:** SharedPreferences (Local)

---

## 🗂️ โครงสร้างโปรเจกต์

```
nekopost_clone/
├── 📄 db.json                    ฐานข้อมูลมังงะ (JSON Server)
├── 📄 package.json               Config สำหรับ JSON Server
├── 📄 pubspec.yaml               Flutter dependencies
│
└── 📁 lib/
    ├── 📄 main.dart              Entry point
    │
    ├── 📁 models/                Data Models (3 ไฟล์)
    │   ├── manga.dart
    │   ├── chapter.dart
    │   └── page.dart
    │
    ├── 📁 screens/               หน้าจอ UI (7 ไฟล์)
    │   ├── main_app_screen.dart
    │   ├── home_screen.dart
    │   ├── manga_detail_screen.dart
    │   ├── reader_screen.dart
    │   ├── catalogue_screen.dart
    │   ├── favorites_screen.dart  (ใช้ SharedPreferences)
    │   └── more_screen.dart
    │
    ├── 📁 widgets/               Reusable Widgets (1 ไฟล์)
    │   └── manga_tile.dart
    │
    └── 📁 services/              Services (4 ไฟล์)
        ├── manga_api_service.dart  HTTP/Dio API
        ├── manga_provider.dart
        ├── manga_detail_provider.dart
        └── reader_provider.dart
```

---

## 🔧 วิธีการทำงาน

### JSON Server:
```
1. รัน npm start
2. Server รันที่ localhost:3000
3. Flutter เรียก HTTP API:
   - GET /manga          → รายการมังงะ
   - GET /manga/:id      → รายละเอียด
   - GET /chapters/:id   → ข้อมูลตอน
```

### Favorites & History:
```
1. ใช้ SharedPreferences
2. บันทึกในเครื่อง (Local)
3. ไม่ต้อง Server
4. เร็วกว่า Firebase
```

---

## 📡 JSON Server Endpoints

### Base URL:
```
http://localhost:3000
```

### Endpoints:
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/manga` | รายการมังงะทั้งหมด |
| GET | `/manga?_page=1&_limit=20` | Pagination |
| GET | `/manga?_sort=lastUpdated&_order=desc` | เรียงตามวันที่ |
| GET | `/manga?q=keyword` | ค้นหา |
| GET | `/manga/:id` | รายละเอียดมังงะ |
| GET | `/chapters?mangaId=:id` | Chapters ของมังงะ |
| GET | `/pages?chapterId=:id` | Pages ในตอน |

---

## 🐛 Troubleshooting

### ❌ "Connection refused" / "Failed to connect"

**สาเหตุ:** JSON Server ไม่ทำงาน

**วิธีแก้:**
```bash
# ตรวจสอบว่า Server รันอยู่
curl http://localhost:3000/manga

# ถ้ายังไม่รัน
cd nekopost_clone
npm start
```

---

### ❌ "npm: command not found"

**สาเหตุ:** ไม่มี Node.js

**วิธีแก้:**
1. ดาวน์โหลด Node.js จาก https://nodejs.org/
2. ติดตั้ง
3. Restart Terminal
4. รัน `npm install` อีกครั้ง

---

### ❌ Android: "CLEARTEXT communication not permitted"

**สาเหตุ:** Android 9+ ไม่อนุญาตให้ใช้ HTTP

**วิธีแก้:**

**ไฟล์: `android/app/src/main/AndroidManifest.xml`**
```xml
<application
    ...
    android:usesCleartextTraffic="true">
```

---

### ❌ iOS: "App Transport Security"

**สาเหตุ:** iOS ไม่อนุญาตให้ใช้ HTTP

**วิธีแก้:**

**ไฟล์: `ios/Runner/Info.plist`**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

### ❌ Favorites ไม่แสดง

**สาเหตุ:** ยังไม่ได้เพิ่มมังงะลงรายการโปรด

**วิธีแก้:**
1. ไปที่หน้ารายละเอียดมังงะ
2. กดไอคอนหัวใจ
3. กลับมาหน้า Favorites

---

## 💻 คำสั่งที่ใช้บ่อย

### JSON Server:
```bash
# รัน Server
npm start

# รัน Server (development mode)
npm run dev

# ดูข้อมูล
curl http://localhost:3000/manga

# เช็ค Server รันอยู่หรือไม่
curl http://localhost:3000
```

### Flutter:
```bash
# ติดตั้ง dependencies
flutter pub get

# Clean project
flutter clean

# รันแอป
flutter run

# Build APK
flutter build apk

# รันบน Chrome (Web)
flutter run -d chrome
```

---

## 🔄 เปรียบเทียบ JSON Server vs Firebase

| Feature | JSON Server | Firebase |
|---------|-------------|----------|
| **Setup** | ⚡ ง่ายมาก | 🔧 ปานกลาง |
| **ต้องรัน Server** | ✅ ต้อง | ❌ ไม่ต้อง |
| **Cloud-based** | ❌ | ✅ |
| **Real-time** | ❌ | ✅ |
| **Scalable** | ❌ จำกัด | ✅ Unlimited |
| **Favorites** | 💾 Local | ☁️ Cloud |
| **Auth** | ❌ | ✅ |
| **Production** | ❌ | ✅ |
| **ราคา** | ✅ ฟรี | ✅ ฟรี (มีจำกัด) |
| **เหมาะกับ** | พัฒนา/ทดสอบ | Production |

---

## 🎓 เหมาะสำหรับ

### ✅ JSON Server เหมาะกับ:
- 📚 เรียนรู้ Flutter
- 🧪 ทดสอบแอป
- 🎯 พัฒนาแบบเร็ว
- 💻 ทำงานแบบ Offline
- 🎓 โปรเจกต์จบ (ไม่ต้อง deploy)

### ⚠️ ไม่เหมาะกับ:
- ❌ Deploy Production
- ❌ ต้องการ Real-time
- ❌ Multi-user app
- ❌ ต้องการ Authentication

---

## 🚀 Upgrade เป็น Firebase

ถ้าอยากใช้ Firebase แทน:

1. ดาวน์โหลดเวอร์ชัน Firebase
2. ตั้งค่า Firebase Project
3. เปลี่ยนจาก MangaApiService → FirebaseService
4. Deploy ได้เลย!

---

## 📊 สถิติโปรเจกต์

| รายการ | จำนวน |
|--------|-------|
| ไฟล์ .dart | 21 ไฟล์ |
| บรรทัดโค้ด | ~3,000 บรรทัด |
| หน้าจอ | 7 หน้า |
| Models | 3 models |
| Services | 4 services |
| Dependencies | 8 packages |

---

## 📄 License

MIT License - ใช้งานได้อย่างอิสระ

---

## 🙏 Credits

- **Flutter Team** - Framework
- **JSON Server** - Mock REST API
- **Provider Package** - State Management
- **Picsum Photos** - ภาพ placeholder

---

<div align="center">

**⚡ Quick, Simple, and Easy! 🚀**

*สร้างด้วย ❤️ โดยใช้ Flutter + JSON Server*

---

**Version:** 1.0.0 (JSON Server Edition)  
**Last Updated:** 2025-01-22  
**Backend:** JSON Server  
**Storage:** SharedPreferences (Local)

</div>
