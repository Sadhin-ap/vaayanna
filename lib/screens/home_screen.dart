import 'package:dummyproject/components/home_screen_components.dart';
import 'package:dummyproject/data/functions/book_db.dart';
import 'package:dummyproject/screens/categories/classicfiction.dart';
import 'package:dummyproject/screens/categories/fiction.dart';
import 'package:dummyproject/screens/categories/non-fiction.dart';
import 'package:dummyproject/screens/categories/philosophy.dart';
import 'package:dummyproject/screens/settings_page.dart';
import 'package:flutter/material.dart';
import '../data/models/book.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> recentlyRead = [];
  late BookDatabase _bookDatabase;
  late HomeScreenComponents _components;

  // Theme-aware color getters
  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getAccentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue[100]!
          : Colors.blue[800]!;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

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

  final Map<String, Widget Function()> _screenBuilders = {
    'Classic Fiction': () => const Classicfiction(),
    'Fiction': () => const Fiction(),
    'Non-Fiction': () => const NonFiction(),
    'Philosophy': () => const Philosophy(),
  };

  @override
  void initState() {
    super.initState();
    _bookDatabase = BookDatabase();
    _initDatabase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initComponents();
  }

  Future<void> _initDatabase() async {
    await _bookDatabase.openProgressBox();
    if (mounted) {
      setState(() {
        _initComponents();
      });
    }
  }

  void _initComponents() {
    if (!_bookDatabase.isBoxOpen) {
      return;
    }

    _components = HomeScreenComponents(
      context: context,
      recentlyRead: recentlyRead,
      progressBox: _bookDatabase.progressBox!,
      isBoxOpen: _bookDatabase.isBoxOpen,
      accentColor: getAccentColor(context),
      categories: categories,
      screenBuilders: _screenBuilders,
      openBook: _openBook,
      getBookProgress: (bookId) {},
    );
  }

  void _bookOpened(Book book) {
    setState(() {
      recentlyRead.removeWhere((b) => b.pdfPath == book.pdfPath);
      recentlyRead.insert(0, book);
      if (recentlyRead.length > 6) {
        recentlyRead = recentlyRead.sublist(0, 6);
      }
    });
  }

  void _openBook(Book book) {
    _bookOpened(book);
    _bookDatabase.saveBookProgress(book);

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

  @override
  Widget build(BuildContext context) {
    final primaryColor = getPrimaryColor(context);
    final textColor = getTextColor(context);

    if (!_bookDatabase.isBoxOpen) {
      _initComponents();
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Vaayana',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 28, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!_bookDatabase.isBoxOpen) {
            await _initDatabase();
          }
          setState(() {});
          return Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _components.buildRecentlyReadSection(),
              const SizedBox(height: 8),
              _components.buildCategoriesSection(),
              const SizedBox(height: 8),
              _components.buildRandomPicksSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
