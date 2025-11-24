import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_provider.dart';
import 'manga_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        // แสดงจำนวน object ใน favorites บน console
        print('จำนวนมังงะใน favorites: ${provider.favorites.length}');
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.favorites.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('รายการโปรด')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('ยังไม่มีมังงะที่บันทึกไว้',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text(
                    'กดไอคอนหัวใจที่หน้ารายละเอียดมังงะ\nเพื่อเพิ่มลงรายการโปรด',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('รายการโปรด'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'รีเฟรช',
                onPressed: () async {
                  await provider.loadFavorites();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('รีเฟรชรายการโปรดแล้ว')),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadFavorites,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final manga = provider.favorites[index];
                return Card(
                  child: ListTile(
                    leading: (manga.coverUrl != null && manga.coverUrl!.isNotEmpty)
                        ? Image.network(
                            manga.coverUrl!,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          )
                        : const Icon(Icons.image_not_supported, size: 50),
                    title: Text(manga.title),
                    subtitle: Text('ID: ${manga.id}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MangaDetailScreen(mangaId: manga.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}