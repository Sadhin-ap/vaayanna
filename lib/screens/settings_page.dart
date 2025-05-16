// ignore_for_file: deprecated_member_use

import 'package:dummyproject/screens/about_page.dart';
import 'package:dummyproject/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedFontSize = 'Medium';
  bool _downloadOverWifiOnly = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            // ignore: duplicate_ignore
            // ignore: deprecated_member_use
            color: colorScheme.onBackground,
          ),
        ),
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSectionTitle('Reading Preferences', context),
          ListTile(
            leading: Icon(Icons.format_size, color: colorScheme.onBackground),
            title: Text(
              'Font Size',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            subtitle: Text(
              _selectedFontSize,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withOpacity(0.7), size: 18),
            onTap: () => _showFontSizeOptions(context),
          ),
          Divider(color: colorScheme.onBackground.withOpacity(0.24)),
          SwitchListTile(
            activeColor: colorScheme.primary,
            secondary: Icon(Icons.brightness_4, color: colorScheme.onSurface),
            title: Text(
              'Dark Mode',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            subtitle: Text(
              'Switch between light and dark theme',
              style:
                  TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
            ),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          Divider(color: colorScheme.onBackground.withOpacity(0.24)),
          _buildSectionTitle('Notifications', context),
          SwitchListTile(
            activeColor: colorScheme.primary,
            secondary:
                Icon(Icons.notifications, color: colorScheme.onBackground),
            title: Text(
              'Push Notifications',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            subtitle: Text(
              'Get notified about new books and features',
              style:
                  TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
            ),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          Divider(color: colorScheme.onBackground.withOpacity(0.24)),
          _buildSectionTitle('Download Options', context),
          SwitchListTile(
            activeColor: colorScheme.primary,
            secondary: Icon(Icons.wifi, color: colorScheme.onBackground),
            title: Text(
              'Download over WiFi only',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            subtitle: Text(
              'Save mobile data by downloading only on WiFi',
              style:
                  TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
            ),
            value: _downloadOverWifiOnly,
            onChanged: (value) => setState(() => _downloadOverWifiOnly = value),
          ),
          Divider(color: colorScheme.onBackground.withOpacity(0.24)),
          _buildSectionTitle('Account', context),
          ListTile(
            leading: Icon(Icons.person, color: colorScheme.onBackground),
            title: Text(
              'Manage Account',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: colorScheme.onBackground.withOpacity(0.7), size: 18),
            onTap: () {},
          ),
          Divider(color: colorScheme.onSurface.withOpacity(0.24)),
          ListTile(
            leading: Icon(Icons.lock, color: colorScheme.onBackground),
            title: Text(
              'Privacy Settings',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: colorScheme.onBackground.withOpacity(0.7), size: 18),
            onTap: () {},
          ),
          Divider(color: colorScheme.onBackground.withOpacity(0.24)),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.onBackground),
            title: Text(
              'About',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            subtitle: Text(
              'App information',
              style:
                  TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: colorScheme.onBackground.withOpacity(0.7), size: 18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onPressed: () => _showClearCacheDialog(context),
              child: const Text('Clear Cache'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFontSizeOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> fontSizes = ['Small', 'Medium', 'Large', 'Extra Large'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Select Font Size',
          style: TextStyle(color: colorScheme.onBackground),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: fontSizes
                .map((size) => ListTile(
                      title: Text(size,
                          style: TextStyle(color: colorScheme.onBackground)),
                      trailing: _selectedFontSize == size
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedFontSize = size);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Clear Cache',
          style: TextStyle(color: colorScheme.onBackground),
        ),
        content: Text(
          'This will clear all cached book data. This won\'t affect your saved books or reading progress.',
          style: TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancel', style: TextStyle(color: colorScheme.primary))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared'),
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
