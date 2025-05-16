import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/bookmetadata.dart';

class BookListItem extends StatelessWidget {
  final int index;
  final String jsonString;
  final Color secondaryColor;
  final Function(int, BookMetadata) onEdit;
  final Function(int, BookMetadata) onDelete;
  final Function(String) onOpenPdf;

  const BookListItem({
    Key? key,
    required this.index,
    required this.jsonString,
    required this.secondaryColor,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenPdf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BookMetadata bookData;
    try {
      final jsonData = jsonDecode(jsonString);
      bookData = BookMetadata.fromJson(jsonData);
    } catch (e) {
      bookData = BookMetadata.noMetadata(jsonString);
    }

    final fileName = bookData.filePath.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: secondaryColor.withOpacity(0.7),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          bookData.title != 'Unknown' ? bookData.title : fileName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Author: ${bookData.author}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Category: ${bookData.category}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              fileName,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.amber),
              onPressed: () => onEdit(index, bookData),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => onDelete(index, bookData),
            ),
          ],
        ),
        onTap: () => onOpenPdf(bookData.filePath),
      ),
    );
  }
}
