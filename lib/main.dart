import 'package:flutter/material.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/pages/catalog_page.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';

void main() {
  runApp(const ShopLiteApp());
}

class ShopLiteApp extends StatefulWidget {
  const ShopLiteApp({super.key});

  @override
  State<ShopLiteApp> createState() => _ShopLiteAppState();
}

class _ShopLiteAppState extends State<ShopLiteApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: CatalogPage(onThemeToggle: _toggleTheme),
      routes: {
        AppConstants.catalogRoute: (context) => CatalogPage(onThemeToggle: _toggleTheme),
      },
    );
  }
}