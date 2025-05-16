import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookModel {
  final String title;
  final String filePath;
  final String category;

  BookModel(
      {required this.title, required this.filePath, required this.category});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'filePath': filePath,
      'category': category,
    };
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'],
      filePath: json['filePath'],
      category: json['category'],
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String categoryName;
  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<BookModel> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getStringList('books') ?? [];

    final allBooks =
        booksJson.map((json) => BookModel.fromJson(jsonDecode(json))).toList();

    setState(() {
      // Filter books that belong to this category
      books = allBooks
          .where((book) =>
              book.category.toLowerCase() == widget.categoryName.toLowerCase())
          .toList();
      isLoading = false;
    });
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all existing books that don't belong to this category
    final booksJson = prefs.getStringList('books') ?? [];
    final otherBooks = booksJson
        .map((json) => BookModel.fromJson(jsonDecode(json)))
        .where((book) =>
            book.category.toLowerCase() != widget.categoryName.toLowerCase())
        .toList();

    // Combine with current category books
    final allBooks = [...otherBooks, ...books];

    // Save back to SharedPreferences
    await prefs.setStringList(
      'books',
      allBooks.map((book) => jsonEncode(book.toJson())).toList(),
    );
  }

  Future<void> _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'txt'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Copy file to app documents directory for permanent storage
        final appDir = await getApplicationDocumentsDirectory();
        final savedPath = '${appDir.path}/books/$fileName';

        // Create directory if it doesn't exist
        final bookDir = Directory('${appDir.path}/books');
        if (!await bookDir.exists()) {
          await bookDir.create(recursive: true);
        }

        // Copy the file
        await file.copy(savedPath);

        // Create book model and add to list
        final newBook = BookModel(
          title: fileName,
          filePath: savedPath,
          category: widget.categoryName,
        );

        setState(() {
          books.add(newBook);
        });

        await _saveBooks();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported: $fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing file: $e')),
      );
    }
  }

  void _deleteBook(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content:
            Text('Are you sure you want to delete "${books[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Remove file from storage
                final file = File(books[index].filePath);
                if (await file.exists()) {
                  await file.delete();
                }

                // Remove from list
                setState(() {
                  books.removeAt(index);
                });

                await _saveBooks();
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting book: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      backgroundColor: const Color(0xFF2D3F51),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No books in this category',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _importFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import Books'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      color: Colors.tealAccent.withOpacity(0.1),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(book.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Tap to open',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        leading:
                            const Icon(Icons.book, color: Colors.tealAccent),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white60),
                          onPressed: () => _deleteBook(index),
                        ),
                        onTap: () {
                          // Open book file (you'll need to implement a file reader or use a plugin)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening: ${book.title}')),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importFile,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
