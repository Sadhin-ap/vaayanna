import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/book_progress.dart';

class DbFunctions {
  late Box<BookProgress> _progressBox;
  bool _isBoxOpen = false;

  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen('bookProgressBox')) {
        _progressBox = await Hive.openBox<BookProgress>('bookProgressBox');
      } else {
        _progressBox = Hive.box<BookProgress>('bookProgressBox');
      }
      _isBoxOpen = true;
    } catch (e) {
      debugPrint('Box initialization error: $e');
      _isBoxOpen = false;
    }
  }

  Future<BookProgress> getBookProgress(Book book) async {
    if (!_isBoxOpen) await initialize();

    if (_progressBox.containsKey(book.id)) {
      return _progressBox.get(book.id)!;
    } else {
      final newProgress = BookProgress(
        bookId: book.id,
        title: book.title,
        pdfPath: book.pdfPath,
        lastPage: 1,
        zoomLevel: 1.0,
        isFavorite: false,
      );
      await _progressBox.put(book.id, newProgress);
      return newProgress;
    }
  }

  Future<void> saveProgress(String bookId, int page, double zoom) async {
    if (!_isBoxOpen) return;

    try {
      final progress = _progressBox.get(bookId);
      if (progress != null) {
        final updated = progress.copyWith(
          lastPage: page,
          zoomLevel: zoom,
        );
        await _progressBox.put(bookId, updated);
      }
    } catch (e) {
      debugPrint('Save progress error: $e');
    }
  }

  Future<bool> toggleFavorite(String bookId, bool currentStatus) async {
    try {
      final progress = _progressBox.get(bookId);
      if (progress != null) {
        final updated = progress.copyWith(isFavorite: !currentStatus);
        await _progressBox.put(bookId, updated);
        return updated.isFavorite;
      }
      return currentStatus;
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      throw Exception('Failed to update favorite status');
    }
  }
}
