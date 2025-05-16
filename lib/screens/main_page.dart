import 'package:dummyproject/screens/folder_screen.dart';
import 'package:dummyproject/screens/home_screen.dart';
import 'package:dummyproject/screens/search_screen.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const FolderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B5166)
          : const Color.fromARGB(255, 255, 255, 255);

  Color getAccentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.tealAccent
          : Colors.blueAccent;

  Color getIconSelectedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.tealAccent
          : Colors.blueAccent;

  Color getIconUnselectedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]!
          : Colors.grey;

  @override
  Widget build(BuildContext context) {
    final primaryColor = getPrimaryColor(context);
    final secondaryColor = getSecondaryColor(context);
    final accentColor = getAccentColor(context);
    final selectedIconColor = getIconSelectedColor(context);
    final unselectedIconColor = getIconUnselectedColor(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedIconColor,
          unselectedItemColor: unselectedIconColor,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            shadows: [
              Shadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          selectedIconTheme: IconThemeData(
            size: 28,
            color: selectedIconColor,
          ),
          unselectedIconTheme: IconThemeData(
            size: 24,
            color: unselectedIconColor,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_rounded, 0, selectedIconColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.search_rounded, 1, selectedIconColor),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.folder_rounded, 2, selectedIconColor),
              label: 'Folders',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, Color selectedColor) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? selectedColor : getIconUnselectedColor(context),
      ),
    );
  }
}
