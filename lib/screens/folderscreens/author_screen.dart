import 'package:dummyproject/data/dummy_data.dart';
import 'package:dummyproject/data/models/book.dart';
import 'package:dummyproject/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthorScreen extends StatefulWidget {
  const AuthorScreen({super.key});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  final Map<String, List<Book>> _authorBooks = {};
  final List<String> _authors = [];
  String? _selectedAuthor;
  bool _isLoading = true;

  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B5166)
          : Colors.blueGrey;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color getAccentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.tealAccent
          : Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  void _loadAuthors() {
    setState(() => _isLoading = true);
    final List<Book> allBooks = [...dummyBooks];

    try {
      if (Hive.isBoxOpen('booksBox')) {
        final booksBox = Hive.box('booksBox');
        for (var i = 0; i < booksBox.length; i++) {
          final bookData = booksBox.getAt(i);
          if (bookData != null) {
            final book = Book(
              id: bookData['id'] ?? '${dummyBooks.length + i + 1}',
              title: bookData['title'] ?? 'Unknown',
              author: bookData['author'] ?? 'Unknown',
              categorie: bookData['category'] ?? 'Uncategorized',
              pdfPath: bookData['filePath'],
              coverImage: '',
              coverPath: '',
            );
            allBooks.add(book);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading books: \$e');
    }

    for (final book in allBooks) {
      if (book.author.isNotEmpty) {
        _authorBooks.putIfAbsent(book.author, () {
          _authors.add(book.author);
          return [];
        }).add(book);
      }
    }

    _authors.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    setState(() => _isLoading = false);
  }

  void _selectAuthor(String author) => setState(() => _selectedAuthor = author);
  void _clearSelection() => setState(() => _selectedAuthor = null);

  @override
  Widget build(BuildContext context) {
    final primary = getPrimaryColor(context);
    final text = getTextColor(context);
    final accent = getAccentColor(context);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: IconThemeData(color: text),
        title: Text(
          _selectedAuthor ?? 'Authors',
          style: TextStyle(color: text),
        ),
        leading: _selectedAuthor != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: text),
                onPressed: _clearSelection,
              )
            : null,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            )
          : _selectedAuthor == null
              ? _buildAuthorGrid(context)
              : _buildBookList(context, _selectedAuthor!),
    );
  }

  Widget _buildAuthorGrid(BuildContext context) {
    final accent = getSecondaryColor(context);
    final text = getTextColor(context);

    if (_authors.isEmpty) {
      return Center(
        child: Text(
          'No authors found',
          style: TextStyle(color: text, fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: _authors.length,
      itemBuilder: (context, i) {
        final author = _authors[i];
        final count = _authorBooks[author]?.length ?? 0;

        return GestureDetector(
          onTap: () => _selectAuthor(author),
          child: Container(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        author,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$count ${count == 1 ? 'book' : 'books'}',
                        style: TextStyle(
                            color: text.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      count.toString(),
                      style:
                          TextStyle(color: text, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookList(BuildContext context, String author) {
    final text = getTextColor(context);
    final accent = getAccentColor(context);
    final books = _authorBooks[author] ?? [];

    if (books.isEmpty) {
      return Center(
        child: Text('No books for this author',
            style: TextStyle(color: text, fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final book = books[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BookDetailScreen(book: book, alreadySelectedBooks: []),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: getSecondaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: book.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(book.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.book, color: text, size: 30)),
                      )
                    : Icon(Icons.book, color: text, size: 30),
              ),
              title: Text(book.title,
                  style: TextStyle(color: text, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('by ${book.author}',
                      style: TextStyle(
                          color: text.withOpacity(0.9),
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(book.categorie,
                      style: TextStyle(color: text.withOpacity(0.7))),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: accent),
            ),
          ),
        );
      },
    );
  }
}
