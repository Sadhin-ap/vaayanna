import 'package:dummyproject/widgets/category_list.dart';
import 'package:flutter/material.dart';
import 'package:dummyproject/screens/categories/classicfiction.dart';
import 'package:dummyproject/screens/categories/fiction.dart';
import 'package:dummyproject/screens/categories/non-fiction.dart';
import 'package:dummyproject/screens/categories/philosophy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> categories = [
    {
      'name': 'Classic Fiction',
      'page': const Classicfiction(),
      'isDefault': true
    },
    {'name': 'Fiction', 'page': const Fiction(), 'isDefault': true},
    {'name': 'Non-Fiction', 'page': const NonFiction(), 'isDefault': true},
    {'name': 'Philosophy', 'page': const Philosophy(), 'isDefault': true},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Theme-aware color getters
  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getSurfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B5166)
          : Colors.grey.shade200;

  Color getOutlineColor(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color getAccentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.tealAccent
          : Colors.blueAccent;

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getStringList('customCategories') ?? [];

    if (customJson.isNotEmpty) {
      final custom =
          customJson.map((j) => jsonDecode(j) as Map<String, dynamic>).toList();
      setState(() {
        categories = [
          ...categories.where((cat) => cat['isDefault'] == true),
          ...custom.map((cat) => {
                'name': cat['name'],
                'page': CategoryPage(categoryName: cat['name']),
                'isDefault': false,
              }),
        ];
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = categories
        .where((c) => c['isDefault'] != true)
        .map((c) => jsonEncode({'name': c['name']}))
        .toList();
    await prefs.setStringList('customCategories', custom);
  }

  void _addCategory() {
    String newCategory = '';
    final accent = getAccentColor(context);
    final text = getTextColor(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text('Add New Category', style: TextStyle(color: text)),
        content: TextField(
          onChanged: (v) => newCategory = v,
          style: TextStyle(color: text),
          decoration: InputDecoration(
            hintText: 'Enter category name',
            hintStyle: TextStyle(color: text.withOpacity(0.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: accent)),
          ),
          TextButton(
            onPressed: () {
              if (newCategory.isNotEmpty) {
                final exists = categories.any((c) =>
                    c['name'].toLowerCase() == newCategory.toLowerCase());
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'A category with this name already exists'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else {
                  setState(() {
                    categories.add({
                      'name': newCategory,
                      'page': CategoryPage(categoryName: newCategory),
                      'isDefault': false,
                    });
                  });
                  _saveCategories();
                }
              }
              Navigator.pop(context);
            },
            child: Text('Add', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    final cat = categories[index];
    final text = getTextColor(context);
    if (cat['isDefault'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Default categories cannot be deleted'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text('Delete Category', style: TextStyle(color: text)),
        content: Text(
          'Are you sure you want to delete "${cat['name']}"?',
          style: TextStyle(color: text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: getAccentColor(context))),
          ),
          TextButton(
            onPressed: () {
              setState(() => categories.removeAt(index));
              _saveCategories();
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = getPrimaryColor(context);
    final surface = getSurfaceColor(context);
    final outline = getOutlineColor(context);
    final text = getTextColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: text),
      ),
      backgroundColor: primary,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 4 / 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => cat['page']),
            ),
            onLongPress: () => _deleteCategory(i),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outline),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat['name'],
                      style: TextStyle(color: text, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 20),
                    if (cat['isDefault'] != true)
                      IconButton(
                        icon: Icon(Icons.delete, color: text.withOpacity(0.6)),
                        onPressed: () => _deleteCategory(i),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: getAccentColor(context),
        foregroundColor: getTextColor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
