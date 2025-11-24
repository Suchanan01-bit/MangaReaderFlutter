import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/manga.dart';

class MangaTile extends StatelessWidget {
  final Manga manga;
  final VoidCallback? onPressed;

  const MangaTile({
    super.key,
    required this.manga,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปปก
              _buildCover(),
              
              const SizedBox(width: 12),
              
              // ข้อมูล
              Expanded(
                child: _buildInfo(context),
              ),
              
              // ไอคอนลูกศร
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: CachedNetworkImage(
        imageUrl: manga.coverUrl,
        width: 70,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 70,
          height: 100,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 70,
          height: 100,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final latestChapter = manga.latestChapter;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ชื่อเรื่อง
        Text(
          manga.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // แนวเรื่อง
        Text(
          manga.genresDisplay,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // ตอนล่าสุด
        if (latestChapter != null)
          Row(
            children: [
              const Icon(
                Icons.update,
                size: 14,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ตอนที่ ${latestChapter.chapterNumber}: ${latestChapter.title}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 4),
        
        // วันที่อัปเดตและยอดดู
        Row(
          children: [
            Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              _formatDate(manga.lastUpdated),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.visibility, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              _formatViews(manga.views),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // จัดรูปแบบวันที่
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} สัปดาห์ที่แล้ว';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // จัดรูปแบบยอดดู
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }
}