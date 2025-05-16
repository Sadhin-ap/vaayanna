// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: colorScheme.onBackground,
          ),
        ),
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.onBackground.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.menu_book,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vaayana',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Vaayana is your personal digital library, giving you access to a wide range of books from different categories. Read on the go, track your progress, and discover new favorites.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorScheme.onBackground),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Features', context),
            const SizedBox(height: 10),
            _buildFeatureItem(
              Icons.book,
              'Wide Book Collection',
              'Access a diverse range of books across multiple genres',
              context,
            ),
            _buildFeatureItem(
              Icons.bookmark,
              'Progress Tracking',
              'Automatically saves your reading progress',
              context,
            ),
            _buildFeatureItem(
              Icons.category,
              'Categories',
              'Browse books by category for easy discovery',
              context,
            ),
            _buildFeatureItem(
              Icons.search,
              'Search',
              'Find your favorite books instantly',
              context,
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Developer', context),
            const SizedBox(height: 10),
            Text(
              'Developed by Sadhin',
              style: TextStyle(fontSize: 16, color: colorScheme.onBackground),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Support', context),
            const SizedBox(height: 10),
            _buildContactItem(
              Icons.email,
              'support@Vaayana.com',
              context,
            ),
            _buildContactItem(
              Icons.web,
              'www.Vaayana.com',
              context,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.description,
                      color: colorScheme.onBackground.withOpacity(0.7)),
                  label: Text('Terms of Service',
                      style: TextStyle(color: colorScheme.onBackground)),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: Icon(Icons.privacy_tip,
                      color: colorScheme.onBackground.withOpacity(0.7)),
                  label: Text('Privacy Policy',
                      style: TextStyle(color: colorScheme.onBackground)),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.onBackground, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String text,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: colorScheme.onBackground.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onBackground,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
