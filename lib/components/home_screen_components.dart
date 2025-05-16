import 'package:flutter/material.dart';
import '../data/models/book.dart';
import '../data/models/book_progress.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/dummy_data.dart';

class HomeScreenComponents {
  final BuildContext context;
  final List<Book> recentlyRead;
  final Box<BookProgress> progressBox;
  final bool isBoxOpen;
  final Color accentColor;
  // final Color textColor; // Commented out for theme adaptation
  final List<Map<String, String>> categories;
  final Map<String, Widget Function()> screenBuilders;
  final Function(Book) openBook;

  HomeScreenComponents({
    required this.context,
    required this.recentlyRead,
    required this.progressBox,
    required this.isBoxOpen,
    required this.accentColor,
    // required this.textColor, // Commented out for theme adaptation
    required this.categories,
    required this.screenBuilders,
    required this.openBook,
    required Function(dynamic bookId) getBookProgress,
  });

  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          // color: textColor, // Original code
          color: _textColor, // Updated to use theme-based color
        ),
      ),
    );
  }

  Widget buildRecentlyReadSection() {
    if (recentlyRead.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Recently Read'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: recentlyRead.map((book) {
              int lastPage = 1;
              if (isBoxOpen) {
                try {
                  final progress = progressBox.get(book.id);
                  if (progress != null) {
                    lastPage = progress.lastPage;
                  }
                } catch (e) {
                  debugPrint('Error getting book progress: $e');
                }
              }

              return GestureDetector(
                onTap: () => openBook(book),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(255, 34, 56, 88), // Original color
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                book.title,
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.white, // Original code
                                  color: _textColor,
                                  height: 1.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Page $lastPage',
                              style: TextStyle(
                                fontSize: 14,
                                // color: Colors.white, // Original code
                                color: _textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          book.coverImage,
                          width: 60,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////////////////////
  Widget buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Library Categories'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final screenBuilder = screenBuilders[category['name']];
              return GestureDetector(
                onTap: () {
                  if (screenBuilder != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screenBuilder()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('No screen found for ${category['name']}'),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 120,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(
                        category['image'] ??
                            'assets/classicFiction/Moby Dick.jpg',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildRandomPicksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Random Picks'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
            children: List.generate(dummyBooks.length, (index) {
              final book = dummyBooks[index];
              return GestureDetector(
                onTap: () => openBook(book),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(book.coverImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
