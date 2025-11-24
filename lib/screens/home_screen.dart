import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manga_provider.dart';
import '../widgets/manga_tile.dart';
import 'manga_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // ตรวจสอบการ scroll เพื่อโหลดหน้าถัดไป
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // ใกล้ถึงจุดสุดท้ายแล้ว โหลดเพิ่ม
        context.read<MangaProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'มังงะอัปเดตล่าสุด',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              // ปุ่มรีเฟรช
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'รีเฟรชข้อมูล',
                onPressed: () {
                  provider.refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กำลังโหลดข้อมูลใหม่...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              // ปุ่มค้นหา
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'ค้นหา',
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: MangaSearchDelegate(provider),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(MangaProvider provider) {
    // แสดง Loading ครั้งแรก
    if (provider.latestMangaState == DataState.loading &&
        provider.latestManga.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลดมังงะล่าสุด...'),
          ],
        ),
      );
    }

    // แสดง Error
    if (provider.latestMangaState == DataState.error &&
        provider.latestManga.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'โหลดข้อมูลล้มเหลว',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                provider.errorMessage ?? 'เกิดข้อผิดพลาด',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่อีกครั้ง'),
              onPressed: () => provider.refresh(),
            ),
          ],
        ),
      );
    }

    // ไม่มีข้อมูล
    if (provider.latestManga.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ยังไม่มีมังงะที่อัปเดต',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // แสดงรายการมังงะ
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.latestManga.length +
            (provider.hasMore ? 1 : 0), // +1 สำหรับ loading indicator
        itemBuilder: (context, index) {
          // แสดง loading indicator ตอนโหลดเพิ่ม
          if (index == provider.latestManga.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final manga = provider.latestManga[index];
          return MangaTile(
            manga: manga,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaDetailScreen(mangaId: manga.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Search Delegate สำหรับค้นหา
class MangaSearchDelegate extends SearchDelegate<String> {
  final MangaProvider provider;

  MangaSearchDelegate(this.provider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          provider.clearSearch();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('กรุณาใส่คำค้นหา'));
    }

    provider.searchManga(query);

    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        if (provider.searchState == DataState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.searchState == DataState.error) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการค้นหา'));
        }

        if (provider.searchResults.isEmpty) {
          return Center(
            child: Text('ไม่พบผลลัพธ์สำหรับ "$query"'),
          );
        }

        return ListView.builder(
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final manga = provider.searchResults[index];
            return MangaTile(
              manga: manga,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaDetailScreen(mangaId: manga.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('พิมพ์เพื่อค้นหามังงะ'),
    );
  }
}