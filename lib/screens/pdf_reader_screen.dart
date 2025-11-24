// ไฟล์: lib/screens/pdf_reader_screen.dart
// หน้าสำหรับอ่าน PDF

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFReaderScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFReaderScreen({
    super.key,
    required this.pdfUrl,
    this.title = 'PDF Reader',
  });

  @override
  State<PDFReaderScreen> createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPDF();
  }

  // ดาวน์โหลด PDF และบันทึกลง Local
  Future<void> _downloadAndLoadPDF() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ดาวน์โหลด PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

      // บันทึกลง Local Storage
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_manga.pdf');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      });
      print('❌ PDF Download Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
            ),
            if (_totalPages > 0)
              Text(
                'หน้า ${_currentPage + 1}/$_totalPages',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          if (!_isLoading && _localPath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _downloadAndLoadPDF,
              tooltip: 'โหลดใหม่',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // แสดง Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลด PDF...'),
          ],
        ),
      );
    }

    // แสดง Error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndLoadPDF,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }

    // แสดง PDF
    if (_localPath != null) {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            _totalPages = pages ?? 0;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Error: $error';
          });
        },
        onPageError: (page, error) {
          print('❌ Page $page Error: $error');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          // สามารถเก็บ controller ไว้ใช้งานได้
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        },
      );
    }

    return const Center(
      child: Text('ไม่พบไฟล์ PDF'),
    );
  }

  @override
  void dispose() {
    // ลบไฟล์ชั่วคราว
    if (_localPath != null) {
      try {
        File(_localPath!).delete();
      } catch (e) {
        print('Error deleting temp file: $e');
      }
    }
    super.dispose();
  }
}
