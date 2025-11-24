import 'package:flutter/material.dart';
import 'package:nekopost_clone/services/favorites_provider.dart' as fav;
import 'package:nekopost_clone/services/manga_detail_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/manga_detail_provider.dart' hide DataState;
import '../models/manga.dart';
import '../models/chapter.dart';
import 'reader_screen.dart';

class MangaDetailScreen extends StatelessWidget {
  final String mangaId;

  const MangaDetailScreen({
    super.key,
    required this.mangaId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MangaDetailProvider()..loadMangaDetail(mangaId),
      child: Consumer<MangaDetailProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: _buildBody(context, provider),
            floatingActionButton: provider.detailState == DataState.loaded &&
                    provider.mangaDetail != null
                ? _buildFAB(context, provider)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MangaDetailProvider provider) {
    switch (provider.detailState) {
      case DataState.initial:
      case DataState.loading:
        return const Center(child: CircularProgressIndicator());

      case DataState.error:
        return _buildErrorView(context, provider);

      case DataState.loaded:
        if (provider.mangaDetail == null) {
          return const Center(child: Text('ไม่พบข้อมูลมังงะ'));
        }
        return _buildContent(context, provider.mangaDetail!);
    }
  }

  Widget _buildErrorView(BuildContext context, MangaDetailProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text('ไม่สามารถโหลดรายละเอียดได้'),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? '',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('ลองใหม่'),
            onPressed: () => provider.loadMangaDetail(mangaId),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Manga manga) {
    return CustomScrollView(
      slivers: [
        // AppBar พร้อมรูปปก
        _buildSliverAppBar(context, manga),
        
        // ข้อมูลหลัก
        SliverToBoxAdapter(
          child: _buildMangaInfo(context, manga),
        ),
        
        // เรื่องย่อ
        SliverToBoxAdapter(
          child: _buildSummary(manga),
        ),
        
        // รายการตอน
        SliverToBoxAdapter(
          child: _buildChapterHeader(manga),
        ),
        
        _buildChapterList(context, manga),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Manga manga) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          manga.title,
          style: const TextStyle(
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
        background: CachedNetworkImage(
          imageUrl: manga.coverUrl,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.5),
          colorBlendMode: BlendMode.darken,
        ),
      ),
      actions: [
  Consumer<MangaDetailProvider>(
    builder: (context, provider, child) {
      final isFavorite = manga.isFavorite ?? false;
      return IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.white,
        ),
        onPressed: () async {
          // 1. เรียก toggleFavorite เพื่อเปลี่ยนสถานะและบันทึกข้อมูล
          await provider.toggleFavorite(context);
          
          // 2. เข้าถึง FavoritesProvider โดยไม่ให้ Widget นี้ฟัง (listen: false)
          //    และเรียกให้โหลดข้อมูลรายการโปรดใหม่ทันที
          //    เพื่อให้ FavoritesScreen อัปเดตเมื่อถูกนำทางกลับไป
          if (context.mounted) {
            Provider.of<fav.FavoritesProvider>(context, listen: false).loadFavorites();
          }
        },
      );
    },
  ),
],
    );
  }

  Widget _buildMangaInfo(BuildContext context, Manga manga) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อต้นฉบับ
          if (manga.originalTitle != null)
            Text(
              manga.originalTitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          
          const SizedBox(height: 12),
          
          // ข้อมูลย่อย
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.person, manga.creatorInfo),
              _buildInfoChip(Icons.book, '${manga.chapterCount} ตอน'),
              _buildInfoChip(
                Icons.radio_button_checked,
                manga.status,
                color: _getStatusColor(manga.status),
              ),
              _buildInfoChip(Icons.visibility, '${manga.views} views'),
              if (manga.rating != null)
                _buildInfoChip(
                  Icons.star,
                  manga.rating!.toStringAsFixed(1),
                  color: Colors.amber,
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // แนวเรื่อง
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: manga.genres
                .map((genre) => Chip(
                      label: Text(genre),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'hiatus':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSummary(Manga manga) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เรื่องย่อ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            manga.summary,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(Manga manga) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'รายการตอน',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${manga.chapterCount} ตอน',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(BuildContext context, Manga manga) {
    final chapters = manga.chapters ?? [];
    
    if (chapters.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('ยังไม่มีตอนที่อัปโหลด')),
        ),
      );
    }

    // เรียงตอนจากล่าสุดไปเก่าสุด
    final sortedChapters = List<Chapter>.from(chapters)
      ..sort((a, b) => b.chapterNumber.compareTo(a.chapterNumber));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final chapter = sortedChapters[index];
          return _buildChapterTile(context, manga, chapter);
        },
        childCount: sortedChapters.length,
      ),
    );
  }

  Widget _buildChapterTile(
    BuildContext context,
    Manga manga,
    Chapter chapter,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(chapter.chapterNumber.toStringAsFixed(0)),
      ),
      title: Text('ตอนที่ ${chapter.chapterNumber}: ${chapter.title}'),
      subtitle: Text(
        _formatChapterDate(chapter.releaseDate),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.isRead == true)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              mangaId: manga.id,
              chapterId: chapter.id,
              mangaTitle: manga.title,
              chapterTitle: chapter.title,
            ),
          ),
        );
      },
    );
  }

  String _formatChapterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildFAB(BuildContext context, MangaDetailProvider provider) {
    final latestChapter = provider.mangaDetail!.latestChapter;
    
    if (latestChapter == null) return const SizedBox();

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              mangaId: provider.mangaDetail!.id,
              chapterId: latestChapter.id,
              mangaTitle: provider.mangaDetail!.title,
              chapterTitle: latestChapter.title,
            ),
          ),
        );
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('อ่านตอนล่าสุด'),
    );
  }
}
