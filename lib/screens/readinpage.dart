import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../data/models/book.dart';
import '../data/models/book_progress.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final Box<BookProgress> _progressBox;
  final PdfViewerController _pdfController = PdfViewerController();
  late BookProgress _currentProgress;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _progressBox = Hive.box<BookProgress>('bookProgressBox');
    _loadInitialProgress();
  }

  void _loadInitialProgress() {
    _currentProgress = _progressBox.get(
      widget.book.id,
      defaultValue: BookProgress(
        bookId: widget.book.id,
        pdfPath: widget.book.pdfPath,
        lastPage: 1,
        zoomLevel: 1.0,
        title: '',
      ),
    )!;
  }

  void _updateProgress(int page, [double zoom = 1.0]) {
    final newProgress = _currentProgress.copyWith(
      lastPage: page,
      zoomLevel: zoom,
    );
    _progressBox.put(widget.book.id, newProgress);
    setState(() => _currentProgress = newProgress);
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text('Failed to load PDF',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {
              _hasError = false;
              _isLoading = true;
            }),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: const Color(0xFF2D3F51),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _pdfController.zoomLevel += 0.2,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _pdfController.zoomLevel -= 0.2,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2D3F51),
      body: _hasError
          ? _buildErrorWidget()
          : Stack(
              children: [
                SfPdfViewer.asset(
                  widget.book.pdfPath,
                  controller: _pdfController,
                  onDocumentLoaded: (details) {
                    _pdfController.jumpToPage(_currentProgress.lastPage);
                    _pdfController.zoomLevel = _currentProgress.zoomLevel;
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onDocumentLoadFailed: (details) {
                    if (mounted) setState(() => _hasError = true);
                  },
                  onPageChanged: (details) {
                    _updateProgress(details.newPageNumber);
                  },
                  onZoomLevelChanged: (details) {
                    _updateProgress(
                        _currentProgress.lastPage, details as double);
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Page ${_currentProgress.lastPage}"),
        icon: const Icon(Icons.bookmark),
        onPressed: () => _pdfController.jumpToPage(_currentProgress.lastPage),
      ),
    );
  }
}
