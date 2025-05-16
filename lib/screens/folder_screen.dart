import 'package:dummyproject/screens/folderscreens/author_screen.dart';
import 'package:dummyproject/screens/folderscreens/favorite_screen.dart';
import 'package:dummyproject/screens/folderscreens/file_screen.dart';
import 'package:dummyproject/screens/folderscreens/library_screen.dart';
import 'package:flutter/material.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> tabs = [
    const Tab(text: 'Library'),
    const Tab(text: 'Favorite'),
    const Tab(text: 'Author'),
    const Tab(text: 'File'),
  ];

  final List<Widget> tabViews = [
    const LibraryScreen(),
    const FavoriteScreen(),
    const AuthorScreen(),
    const FileScreen(
      categories: [],
      categoryName: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getTabBarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.blueGrey;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color getIndicatorColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  @override
  Widget build(BuildContext context) {
    final primaryColor = getPrimaryColor(context);
    getTabBarColor(context);
    final textColor = getTextColor(context);
    final indicatorColor = getIndicatorColor(context);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Folders',
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((tab) {
            return tab;
          }).toList(),
          indicatorColor: indicatorColor,
          labelColor: textColor,
          unselectedLabelColor: textColor.withOpacity(0.7),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabViews,
      ),
    );
  }
}
