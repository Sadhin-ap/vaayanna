import 'package:dummyproject/data/models/book.dart';
import 'package:dummyproject/data/models/book_progress.dart';
import 'package:dummyproject/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

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

  Color getIconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black54;

  @override
  Widget build(BuildContext context) {
    final primaryColor = getPrimaryColor(context);
    final secondaryColor = getSecondaryColor(context);
    final textColor = getTextColor(context);
    final iconColor = getIconColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: () async {
              await Hive.box<BookProgress>('bookProgressBox').flush();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Favorites refreshed',
                      style: TextStyle(color: textColor)),
                  duration: const Duration(seconds: 1),
                  backgroundColor: secondaryColor,
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: primaryColor,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<BookProgress>('bookProgressBox').listenable(),
        builder: (context, Box<BookProgress> box, _) {
          final favorites = box.values.where((p) => p.isFavorite).toList()
            ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
          return favorites.isEmpty
              ? _buildEmptyState(context)
              : _buildFavoritesList(context, favorites);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textColor = getTextColor(context);
    final iconColor = textColor.withOpacity(0.5);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(
            'No Favorite Books',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your favorite books will appear here',
            style: TextStyle(color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
      BuildContext context, List<BookProgress> favorites) {
    final secondaryColor = getSecondaryColor(context);
    final textColor = getTextColor(context);

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final progress = favorites[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: secondaryColor,
          child: InkWell(
            onTap: () => _openBook(context, progress),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(Icons.book, size: 32, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last read: Page ${progress.lastPage}',
                          style: TextStyle(
                              fontSize: 14, color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Added: ${DateFormat('MMM d, yyyy').format(progress.addedAt)}',
                          style: TextStyle(
                              fontSize: 12, color: textColor.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      progress.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _toggleFavorite(context, progress),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, BookProgress progress) async {
    final box = Hive.box<BookProgress>('bookProgressBox');
    final updated = progress.copyWith(isFavorite: !progress.isFavorite);
    await box.put(progress.bookId, updated);
    await box.flush();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${progress.title} ${updated.isFavorite ? 'added to' : 'removed from'} favorites',
          style: TextStyle(color: getTextColor(context)),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: getSecondaryColor(context),
      ),
    );
  }

  void _openBook(BuildContext context, BookProgress progress) {
    final book = Book(
      id: progress.bookId,
      title: progress.title,
      pdfPath: progress.pdfPath,
      author: 'Unknown Author',
      coverPath: '',
      coverImage: '',
      categorie: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          book: book,
          alreadySelectedBooks: [],
        ),
      ),
    );
  }
}
