import 'package:dummyproject/data/dummy_data.dart';
import 'package:dummyproject/data/models/book.dart';
import 'package:dummyproject/data/models/book_progress.dart';
import 'package:dummyproject/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Fiction extends StatefulWidget {
  const Fiction({super.key});

  @override
  State<Fiction> createState() => _NonFictionState();
}

class _NonFictionState extends State<Fiction> {
  late List<Book> nonFictionBooks;
  late Box<BookProgress> _progressBox;
  bool _isBoxOpen = false;

  @override
  void initState() {
    super.initState();
    _openProgressBox();

    // Filter only non-fiction books from dummyBooks
    nonFictionBooks =
        dummyBooks.where((book) => book.categorie == 'Fiction').toList();
  }

  Future<void> _openProgressBox() async {
    try {
      if (!Hive.isBoxOpen('bookProgressBox')) {
        _progressBox = await Hive.openBox<BookProgress>('bookProgressBox');
      } else {
        _progressBox = Hive.box<BookProgress>('bookProgressBox');
      }
      if (mounted) {
        setState(() {
          _isBoxOpen = true;
        });
      }
    } catch (e) {
      debugPrint('Error opening progress box: $e');
      if (mounted) {
        setState(() {
          _isBoxOpen = false;
        });
      }
    }
  }

  void _openBook(Book book) {
    // Check if we already have progress for this book
    BookProgress? existingProgress;

    if (_isBoxOpen) {
      existingProgress = _progressBox.values.firstWhere(
        (progress) => progress.bookId == book.id,
        orElse: () => BookProgress(
          bookId: book.id,
          title: book.title,
          pdfPath: book.pdfPath,
        ),
      );
    } else {
      // Create a new progress object if box isn't open
      existingProgress = BookProgress(
        bookId: book.id,
        title: book.title,
        pdfPath: book.pdfPath,
      );
    }

    // Make sure the progress is properly saved before navigating
    if (_isBoxOpen && !_progressBox.values.contains(existingProgress)) {
      _progressBox.add(existingProgress);
    }

    // Navigate to book detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BookDetailScreen(
                book: book,
                alreadySelectedBooks: [],
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fiction"),
        backgroundColor: const Color(0xFF2D3F51),
        foregroundColor: Colors.white,
      ),
      body: nonFictionBooks.isEmpty
          ? const Center(
              child: Text(
                "No Fiction books available",
                style: TextStyle(color: Colors.white),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: nonFictionBooks.length,
              itemBuilder: (context, index) {
                final book = nonFictionBooks[index];
                return _buildBookItem(book);
              },
            ),
      backgroundColor: const Color(0xFF2D3F51),
    );
  }

  Widget _buildBookItem(Book book) {
    return GestureDetector(
      onTap: () {
        _openBook(book);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  book.coverImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.book, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.categorie,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
