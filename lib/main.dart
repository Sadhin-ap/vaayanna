import 'dart:async';
import 'package:dummyproject/errorscreen.dart';
import 'package:dummyproject/loadingScreen.dart';
import 'package:dummyproject/services/theme_provider.dart';
import 'package:dummyproject/utilities/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dummyproject/screens/splashscreen.dart';
import 'package:dummyproject/data/models/book_progress.dart';
import 'package:provider/provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const RootWidget());
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error\n$stackTrace');
  });
}

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  AppState _appState = AppState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _initializeHive();
      if (mounted) setState(() => _appState = AppState.ready);
    } catch (e, st) {
      debugPrint('Initialization failed: $e\n$st');
      if (mounted) {
        setState(() {
          _appState = AppState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(
          BookProgressAdapter(),
        );
      }

      await Future.wait([
        Hive.openBox<String>('selectedFiles'),
        Hive.openBox<BookProgress>('bookProgressBox'),
      ]);
    } catch (e) {
      await _handleHiveError(e);
      rethrow;
    }
  }

  Future<void> _handleHiveError(dynamic error) async {
    try {
      await Hive.close();
    } catch (e) {
      debugPrint('Error closing Hive: $e');
    }
  }

  void _retryInitialization() {
    setState(() {
      _appState = AppState.loading;
      _errorMessage = null;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: _buildCurrentState(),
            // theme: _buildAppTheme(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_appState) {
      case AppState.loading:
        return const LoadingScreen();
      case AppState.ready:
        return const SplashScreen();
      case AppState.error:
        return ErrorScreen(
          errorMessage: _errorMessage,
          onRetry: _retryInitialization,
        );
    }
  }
}

enum AppState { loading, ready, error }
