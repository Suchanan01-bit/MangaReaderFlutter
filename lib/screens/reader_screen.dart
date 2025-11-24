import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/reader_provider.dart';
import '../models/pages.dart' as manga_page;

class ReaderScreen extends StatelessWidget {
  final String mangaId;
  final String chapterId;
  final String mangaTitle;
  final String chapterTitle;

  const ReaderScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
    required this.mangaTitle,
    required this.chapterTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReaderProvider()..loadChapterPages(mangaId, chapterId),
      child: _ReaderView(
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        chapterTitle: chapterTitle,
        chapterId: chapterId,
      ),
    );
  }
}

class _ReaderView extends StatefulWidget {
  final String mangaId;
  final String mangaTitle;
  final String chapterTitle;
  final String chapterId;

  const _ReaderView({
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterTitle,
    required this.chapterId,
  });

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // ซ่อน status bar และ navigation bar เพื่อ immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // คืนค่า status bar และ navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _buildBody(context, provider),
              
              // AppBar ลอย
              if (provider.showUI && provider.readerState == DataState.loaded)
                _buildAppBar(context, provider),
              
              // ปุ่มนำทางด้านล่าง
              if (provider.showUI && provider.readerState == DataState.loaded)
                _buildBottomBar(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ReaderProvider provider) {
    switch (provider.readerState) {
      case DataState.initial:
      case DataState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case DataState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'ไม่สามารถโหลดหน้ามังงะได้',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? '',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
                onPressed: () => provider.loadChapterPages(widget.mangaId, widget.chapterId),
              ),
            ],
          ),
        );

      case DataState.loaded:
        if (provider.pages.isEmpty) {
          return const Center(
            child: Text(
              'ไม่มีหน้าในตอนนี้',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return _buildReader(context, provider);
    }
  }

  Widget _buildReader(BuildContext context, ReaderProvider provider) {
    return GestureDetector(
      onTap: () => provider.toggleUI(),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => provider.updateCurrentPage(index),
        itemCount: provider.pages.length,
        itemBuilder: (context, index) {
          final page = provider.pages[index];
          return _buildPage(page as manga_page.Pages, index + 1, provider.totalPages);
        },
      ),
    );
  }

  Widget _buildPage(manga_page.Pages page, int pageNum, int totalPages) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: page.imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.grey[900],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  'กำลังโหลดหน้า $pageNum/$totalPages',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'ไม่สามารถโหลดหน้า $pageNum',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ReaderProvider provider) {
    return AnimatedOpacity(
      opacity: provider.showUI ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mangaTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.chapterTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ReaderProvider provider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: provider.showUI ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  Row(
                    children: [
                      Text(
                        '${provider.currentPageIndex + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: provider.currentPageIndex.toDouble(),
                          min: 0,
                          max: (provider.totalPages - 1).toDouble(),
                          onChanged: (value) {
                            _pageController.jumpToPage(value.toInt());
                          },
                        ),
                      ),
                      Text(
                        '${provider.totalPages}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ปุ่มตอนก่อนหน้า
                      TextButton.icon(
                        onPressed: () {
                          // TODO: ไปตอนก่อนหน้า
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ฟีเจอร์กำลังพัฒนา'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        label: const Text(
                          'ตอนก่อน',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      
                      // แสดงเปอร์เซ็นต์
                      Text(
                        '${(provider.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // ปุ่มตอนถัดไป
                      TextButton.icon(
                        onPressed: () {
                          // TODO: ไปตอนถัดไป
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ฟีเจอร์กำลังพัฒนา'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        label: const Text(
                          'ตอนถัดไป',
                          style: TextStyle(color: Colors.white),
                        ),
                        iconAlignment: IconAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
