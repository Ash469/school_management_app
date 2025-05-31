import 'package:flutter/material.dart';

class AppTheme {
  static const String defaultTheme = 'blue';
  
  // Get theme based on theme name
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case 'blue':
        return ThemeData(
          primaryColor: const Color(0xFF1565C0),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF2196F3),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            elevation: 0,
          ),
        );
      case 'green':
        return ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF4CAF50),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            elevation: 0,
          ),
        );
      case 'purple':
        return ThemeData(
          primaryColor: const Color(0xFF6A1B9A),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF6A1B9A),
            secondary: const Color(0xFF9C27B0),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6A1B9A),
            elevation: 0,
          ),
        );
      default:
        return ThemeData(
          primaryColor: const Color(0xFF1565C0),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF2196F3),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            elevation: 0,
          ),
        );
    }
  }
  
  // Get primary color based on theme name
  static Color getPrimaryColor(String themeName) {
    switch (themeName) {
      case 'blue':
        return const Color(0xFF1565C0);
      case 'green':
        return const Color(0xFF2E7D32);
      case 'purple':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF1565C0);
    }
  }
  
  // Get accent color based on theme name
  static Color getAccentColor(String themeName) {
    switch (themeName) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'purple':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF2196F3);
    }
  }
  
  // Get tertiary color based on theme name
  static Color getTertiaryColor(String themeName) {
    switch (themeName) {
      case 'blue':
        return const Color(0xFFFFA000);
      case 'green':
        return const Color(0xFFFF6F00);
      case 'purple':
        return const Color(0xFFFF4081);
      default:
        return const Color(0xFFFFA000);
    }
  }
  
  // Get gradient colors based on theme name
  static List<Color> getGradientColors(String themeName) {
    switch (themeName) {
      case 'blue':
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'green':
        return [const Color(0xFF2E7D32), const Color(0xFF81C784)];
      case 'purple':
        return [const Color(0xFF6A1B9A), const Color(0xFFBA68C8)];
      default:
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
  }
}
