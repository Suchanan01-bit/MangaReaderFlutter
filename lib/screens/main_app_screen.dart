import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'catalogue_screen.dart';
import 'favorites_screen.dart';
import 'more_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // รายการหน้าจอ
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),        // 0: หน้าแรก - มังงะล่าสุด
    CatalogueScreen(),   // 1: รายการ - ค้นหาและกรอง
    FavoritesScreen(),   // 2: โปรด - มังงะที่บันทึกไว้
    MoreScreen(),        // 3: อื่นๆ - การตั้งค่าและประวัติ
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แสดงหน้าจอตาม index ที่เลือก
      body: _screens[_selectedIndex],
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ล่าสุด',
            tooltip: 'มังงะอัปเดตล่าสุด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'รายการ',
            tooltip: 'ค้นหามังงะ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'โปรด',
            tooltip: 'มังงะที่บันทึกไว้',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.menu),
            label: 'อื่นๆ',
            tooltip: 'การตั้งค่า',
          ),
        ],
      ),
    );
  }
}
