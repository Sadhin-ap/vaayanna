import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/book_progress.dart';

class BookDatabase {
  Box<BookProgress>? _progressBox;
  bool _isBoxOpen = false;

  /// Getter for the progress box
  Box<BookProgress>? get progressBox => _progressBox;

  /// Getter for the box open status
  bool get isBoxOpen => _isBoxOpen;

  /// Initialize Hive for the application
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(BookProgressAdapter().typeId)) {
      Hive.registerAdapter(BookProgressAdapter());
    }

    // Register other adapters as needed
    // if (!Hive.isAdapterRegistered(BookAdapter().typeId)) {
    //   Hive.registerAdapter(BookAdapter());
    // }
  }

  /// Open the book progress box
  Future<void> openProgressBox() async {
    try {
      if (!Hive.isBoxOpen('bookProgressBox')) {
        _progressBox = await Hive.openBox<BookProgress>('bookProgressBox');
      } else {
        _progressBox = Hive.box<BookProgress>('bookProgressBox');
      }
      _isBoxOpen = true;
    } catch (e) {
      debugPrint('Error opening progress box: $e');
      _isBoxOpen = false;
    }
  }

  /// Close the book progress box
  Future<void> closeProgressBox() async {
    if (_isBoxOpen && _progressBox != null) {
      await _progressBox!.close();
      _isBoxOpen = false;
    }
  }

  /// Save book progress
  Future<void> saveBookProgress(Book book) async {
    if (!_isBoxOpen || _progressBox == null) {
      await openProgressBox();
    }

    if (_isBoxOpen && _progressBox != null) {
      try {
        // Check if progress already exists
        BookProgress? existingProgress = getBookProgress(book.id);

        if (existingProgress == null) {
          // Create new progress
          final newProgress = BookProgress(
            bookId: book.id,
            title: book.title,
            pdfPath: book.pdfPath,
          );

          await _progressBox!.add(newProgress);
        }
      } catch (e) {
        debugPrint('Error saving book progress: $e');
      }
    }
  }

  /// Get progress for a specific book
  BookProgress? getBookProgress(String bookId) {
    if (!_isBoxOpen || _progressBox == null) {
      return null;
    }

    try {
      return _progressBox!.values.firstWhere(
        (progress) => progress.bookId == bookId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update book progress
  Future<void> updateBookProgress(BookProgress progress) async {
    if (!_isBoxOpen || _progressBox == null) {
      await openProgressBox();
    }

    if (_isBoxOpen && _progressBox != null) {
      try {
        final index = _progressBox!.values.toList().indexWhere(
              (p) => p.bookId == progress.bookId,
            );

        if (index != -1) {
          await _progressBox!.putAt(index, progress);
        }
      } catch (e) {
        debugPrint('Error updating book progress: $e');
      }
    }
  }

  // /// Delete book progress
  // Future<void> deleteBookProgress(String bookId) async {
  //   if (!_isBoxOpen || _progressBox == null) {
  //     await openProgressBox();
  //   }

  //   if (_isBoxOpen && _progressBox != null) {
  //     try {
  //       final index = _progressBox!.values.toList().indexWhere(
  //             (p) => p.bookId == bookId,
  //           );

  //       if (index != -1) {
  //         await _progressBox!.deleteAt(index);
  //       }
  //     } catch (e) {
  //       debugPrint('Error deleting book progress: $e');
  //     }
  //   }
  // }

  /// Get all book progress records
  List<BookProgress> getAllBookProgress() {
    if (!_isBoxOpen || _progressBox == null) {
      return [];
    }

    return _progressBox!.values.toList();
  }

  /// Get recently read books (based on progress entries)
  List<BookProgress> getRecentlyReadBooks({int limit = 6}) {
    if (!_isBoxOpen || _progressBox == null) {
      return [];
    }

    final List<BookProgress> allProgress = _progressBox!.values.toList();

    // Sort by last access time if available, otherwise return as is
    // Note: You might want to add a lastAccessTime field to BookProgress

    if (allProgress.length > limit) {
      return allProgress.sublist(0, limit);
    }

    return allProgress;
  }
}

/// Example BookProgressAdapter (you'll need to implement this)
class BookProgressAdapter extends TypeAdapter<BookProgress> {
  @override
  final int typeId = 0; // Assign a unique type ID

  @override
  BookProgress read(BinaryReader reader) {
    // Implement reading from binary
    final bookId = reader.readString();
    final title = reader.readString();
    final pdfPath = reader.readString();
    // Read more fields as needed

    return BookProgress(
      bookId: bookId,
      title: title,
      pdfPath: pdfPath,
    );
  }

  @override
  void write(BinaryWriter writer, BookProgress obj) {
    // Implement writing to binary
    writer.writeString(obj.bookId);
    writer.writeString(obj.title);
    writer.writeString(obj.pdfPath);
    // Write more fields as needed
  }
}
