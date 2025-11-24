import 'package:flutter/material.dart';
import 'package:nekopost_clone/services/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'services/manga_provider.dart';
import 'screens/main_app_screen.dart';

void main() {
  runApp(const NekopostCloneApp());
}

class NekopostCloneApp extends StatelessWidget {
  const NekopostCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider หลักสำหรับ Home Screen
        ChangeNotifierProvider(
          create: (_) => MangaProvider(),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Nekopost Clone - JSON Server',
        debugShowCheckedModeBanner: false,
        
        // Theme
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            elevation: 2,
            centerTitle: false,
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          
          // Card Theme
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
          ),
          
          // ใช้ Material 3
          useMaterial3: true,
        ),
        
        // Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        
        // เลือก theme mode
        themeMode: ThemeMode.system,
        
        // หน้าแรก
        home: const MainAppScreen(),
      ),
    );
  }
}
