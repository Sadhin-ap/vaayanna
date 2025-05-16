class Book {
  final String id;
  final String title;
  final String author;
  final String pdfPath;
  final String coverImage;
  final String categorie;
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.pdfPath,
    required this.coverImage,
    required this.categorie,
    required String coverPath,
  });
}
