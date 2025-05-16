import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../data/models/book.dart';
import '../data/models/book_progress.dart';
import '../data/functions/db_functions.dart';
import '../components/pdf_viewer_components.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final List<Book> alreadySelectedBooks;

  const BookDetailScreen({
    Key? key,
    required this.book,
    required this.alreadySelectedBooks,
  }) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final DbFunctions _repo = DbFunctions();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  BookProgress? _progress;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  double _currentZoom = 1.0;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeReader();
  }

  Future<void> _initializeReader() async {
    try {
      await _repo.initialize();
      final progress = await _repo.getBookProgress(widget.book);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _currentPage = progress.lastPage;
            _currentZoom = progress.zoomLevel;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing reader: $e');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _progress = BookProgress(
              bookId: widget.book.id,
              title: widget.book.title,
              pdfPath: widget.book.pdfPath,
              lastPage: 1,
              zoomLevel: 1.0,
              isFavorite: false,
            );
            _isLoading = false;
          });
        }
      });
    }
  }

  void _toggleFavorite() async {
    if (_progress == null) return;

    try {
      final newStatus =
          await _repo.toggleFavorite(widget.book.id, _progress!.isFavorite);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(
              () => _progress = _progress!.copyWith(isFavorite: newStatus));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.book.title} '
                '${newStatus ? 'added to' : 'removed from'} favorites',
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update favorites')),
          );
        }
      });
    }
  }

  void _saveProgress() {
    if (_progress == null) return;
    try {
      _repo.saveProgress(widget.book.id, _currentPage, _currentZoom);
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _handleDocumentLoaded(PdfDocumentLoadedDetails details) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalPages = details.document.pages.count;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _currentPage > 0 && _currentPage <= _totalPages) {
            _pdfController.jumpToPage(_currentPage);
            _pdfController.zoomLevel = _currentZoom;
          }
        });
      }
    });
  }

  void _handleDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load book: ${details.error}')),
        );
      }
    });
  }

  void _handlePageChanged(PdfPageChangedDetails details) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _currentPage = details.newPageNumber);
        _saveProgress();
      }
    });
  }

  void _handleZoomLevelChanged(PdfZoomDetails details) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _currentZoom = details.newZoomLevel);
        _saveProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          if (_progress != null) ...[
            IconButton(
              icon: Icon(
                _progress!.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _progress!.isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
              tooltip: 'Toggle favorite',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
            ),
          ],
        ],
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              PdfViewerComponent(
                pdfPath: widget.book.pdfPath,
                pdfViewerKey: _pdfViewerKey,
                pdfController: _pdfController,
                onDocumentLoaded: _handleDocumentLoaded,
                onDocumentLoadFailed: _handleDocumentLoadFailed,
                onPageChanged: _handlePageChanged,
                onZoomLevelChanged: _handleZoomLevelChanged,
                isLoading: _isLoading,
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
      bottomNavigationBar: _isLoading || _progress == null
          ? null
          : PdfBottomBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPreviousPage: () {
                if (_pdfController.pageNumber > 1) {
                  _pdfController.previousPage();
                }
              },
              onNextPage: () {
                if (_pdfController.pageNumber < _totalPages) {
                  _pdfController.nextPage();
                }
              },
            ),
    );
  }

  void _showSettings() {
    if (_progress == null) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => PdfSettingsSheet(
        currentZoom: _currentZoom,
        currentPage: _currentPage,
        onZoomChanged: (value) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _currentZoom = value);
              _pdfController.zoomLevel = value;
              _saveProgress();
            }
          });
        },
        onPreviousPage: () {
          if (_pdfController.pageNumber > 1) {
            _pdfController.previousPage();
          }
        },
        onNextPage: () {
          if (_pdfController.pageNumber < _totalPages) {
            _pdfController.nextPage();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _saveProgress();
    _pdfController.dispose();
    super.dispose();
  }
}
