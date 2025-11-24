// ไฟล์: lib/screens/more_screen.dart
// หน้าอื่นๆ - การตั้งค่าและประวัติ

import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('อื่นๆ'),
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                SizedBox(height: 12),
                Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // History
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('ประวัติการอ่าน'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),
          
          // Downloads
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('มังงะที่ดาวน์โหลด'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),
          
          const Divider(),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('การตั้งค่า'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSettings(context),
          ),
          
          // Theme
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('ธีม'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),
          
          const Divider(),
          
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('เกี่ยวกับ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAbout(context),
          ),
          
          // Help
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('ช่วยเหลือ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('การตั้งค่า'),
        content: const Text('ฟีเจอร์การตั้งค่ากำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Nekopost Clone',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 60),
      children: [
        const Text('แอปอ่านมังงะออนไลน์'),
        const SizedBox(height: 8),
        const Text('สร้างด้วย Flutter'),
      ],
    );
  }
}
