class BookMetadata {
  final String filePath;
  final String title;
  final String author;
  final String category;

  BookMetadata({
    required this.filePath,
    required this.title,
    required this.author,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'title': title,
        'author': author,
        'category': category,
      };

  factory BookMetadata.fromJson(Map<String, dynamic> json) => BookMetadata(
        filePath: json['filePath'],
        title: json['title'],
        author: json['author'],
        category: json['category'],
      );

  factory BookMetadata.noMetadata(String filePath) => BookMetadata(
        filePath: filePath,
        title: 'Unknown',
        author: 'Unknown',
        category: 'Uncategorized',
      );
}
