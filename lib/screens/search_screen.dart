import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../data/models/book.dart';
import 'book_detail_screen.dart';
import 'package:dummyproject/screens/categories/classicfiction.dart';
import 'package:dummyproject/screens/categories/fiction.dart';
import 'package:dummyproject/screens/categories/non-fiction.dart';
import 'package:dummyproject/screens/categories/philosophy.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";
  List<String> recentSearches = ['Moby Dick', 'Dracula', 'Philosophy'];

  Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color getSearchBarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black26
          : Colors.grey[200]!;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> categories = [
    {
      'name': 'Classic Fiction',
      'image': 'assets/classicFiction/Moby Dick.jpg',
    },
    {
      'name': 'Fiction',
      'image': 'assets/fiction/Dracula (Bram Stoker) (Z-Library).webp',
    },
    {
      'name': 'Non-Fiction',
      'image':
          'assets/nonFiction/Machiavelli The Prince (Niccolo Machiavelli) (Z-Library).jpg',
    },
    {
      'name': 'Philosophy',
      'image':
          'assets/classicFiction/Blooms Modern Critical Interpretations -image.jpg',
    },
  ];

  // Map of category names to their respective screen builders
  final Map<String, Widget Function()> _screenBuilders = {
    'Classic Fiction': () => const Classicfiction(),
    'Fiction': () => const Fiction(),
    'Non-Fiction': () => const NonFiction(),
    'Philosophy': () => const Philosophy(),
  };

  List<Book> get filteredBooks {
    return query.isEmpty
        ? dummyBooks
        : dummyBooks.where((book) {
            return book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase());
          }).toList();
  }

  void setSearchQuery(String value) {
    setState(() {
      query = value;
      _searchController.text = value;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: getBackgroundColor(context),
        title: Text(
          "Search",
          style: TextStyle(color: getTextColor(context)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: getTextColor(context)),
                  decoration: InputDecoration(
                    hintText: "Search books...",
                    hintStyle: TextStyle(
                        color: getTextColor(context).withOpacity(0.7)),
                    prefixIcon:
                        Icon(Icons.search, color: getTextColor(context)),
                    filled: true,
                    fillColor: getSearchBarColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(top: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate directly to the specific category screen
                          final screenBuilder =
                              _screenBuilders[category['name']];
                          if (screenBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => screenBuilder(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      category['image'] ??
                                          'assets/classicFiction/Moby Dick.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category['name']!,
                                style: TextStyle(
                                  color: getTextColor(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (query.isEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        "Recent Searches",
                        style: TextStyle(
                          color: getTextColor(context),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: recentSearches.map((search) {
                          return ActionChip(
                            label: Text(
                              search,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[800]
                                    : Colors.blue[200],
                            onPressed: () => setSearchQuery(search),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = filteredBooks[index];
                    return ListTile(
                      title: Text(
                        book.title,
                        style: TextStyle(color: getTextColor(context)),
                      ),
                      subtitle: Text(
                        book.author,
                        style: TextStyle(
                            color: getTextColor(context).withOpacity(0.7)),
                      ),
                      onTap: () {
                        if (query.isNotEmpty &&
                            !recentSearches.contains(query)) {
                          setState(() {
                            recentSearches.insert(0, query);
                            if (recentSearches.length > 5) {
                              recentSearches.removeLast();
                            }
                          });
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              book: book,
                              alreadySelectedBooks: [],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredBooks.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
