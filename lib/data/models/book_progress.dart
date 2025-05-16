import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'book_progress.g.dart';

@HiveType(typeId: 0)
class BookProgress extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String pdfPath;

  @HiveField(4)
  int lastPage;

  @HiveField(5)
  double zoomLevel;

  @HiveField(6)
  final DateTime addedAt;

  @HiveField(7)
  bool isFavorite;

  BookProgress({
    String? id,
    required this.bookId,
    required this.title,
    required this.pdfPath,
    this.lastPage = 1,
    this.zoomLevel = 1.0,
    DateTime? addedAt,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  get lastAccessed => null;

  BookProgress copyWith({
    String? id,
    String? bookId,
    String? title,
    String? pdfPath,
    int? lastPage,
    double? zoomLevel,
    DateTime? addedAt,
    bool? isFavorite,
  }) {
    return BookProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      pdfPath: pdfPath ?? this.pdfPath,
      lastPage: lastPage ?? this.lastPage,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      addedAt: addedAt ?? this.addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static empty() {}
}
