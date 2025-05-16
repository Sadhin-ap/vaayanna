import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../data/models/book.dart';
import '../book_detail_screen.dart';

class CategoryBooksScreen extends StatelessWidget {
  final String category;
  const CategoryBooksScreen({super.key, required this.category});

  // For demo purposes, filter books by title containing the category name.
  List<Book> get categoryBooks {
    return dummyBooks
        .where(
            (book) => book.title.toLowerCase().contains(category.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: categoryBooks.length,
        itemBuilder: (context, index) {
          final book = categoryBooks[index];
          return ListTile(
            leading: Image.asset(
              book.coverImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(book.title),
            subtitle: Text(book.author),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                        book: book,
                        alreadySelectedBooks: [],
                      )),
            ),
          );
        },
      ),
    );
  }
}
