import 'package:flutter/material.dart';

class AppTheme {
  static const String defaultTheme = 'blue';
  
  // Get theme based on theme name
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case 'blue':
        return ThemeData(
          primaryColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF2196F3),
            background: Colors.blue[50]!,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF424242),
            onSurface: const Color(0xFF424242),
            surfaceTint: Colors.white, // Explicitly disable surface tinting
          ),
          scaffoldBackgroundColor: Colors.blue[50],
          cardColor: Colors.white, // Ensure card color is white
          cardTheme: const CardTheme(
            color: Colors.white, // Explicitly set default card color
            surfaceTintColor: Colors.white, // Important for Material 3
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF424242)),
            bodyMedium: TextStyle(color: Color(0xFF424242)),
            titleLarge: TextStyle(color: Color(0xFF424242)),
            titleMedium: TextStyle(color: Color(0xFF424242)),
            titleSmall: TextStyle(color: Color(0xFF424242)),
          ),
          // Add bottom navigation bar theme with visible colors
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1565C0),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            selectedIconTheme: const IconThemeData(size: 24, color: Color(0xFF1565C0)),
            unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[600]),
            elevation: 8,
          ),
        );
      case 'green':
        return ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF4CAF50),
            background: Colors.green[50]!,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF424242),
            onSurface: const Color(0xFF424242),
          ),
          scaffoldBackgroundColor: Colors.green[50],
          cardColor: Colors.white,
          cardTheme: const CardTheme(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF424242)),
            bodyMedium: TextStyle(color: Color(0xFF424242)),
            titleLarge: TextStyle(color: Color(0xFF424242)),
            titleMedium: TextStyle(color: Color(0xFF424242)),
            titleSmall: TextStyle(color: Color(0xFF424242)),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            selectedIconTheme: const IconThemeData(size: 24, color: Color(0xFF2E7D32)),
            unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[600]),
            elevation: 8,
          ),
        );
      case 'purple':
        return ThemeData(
          primaryColor: const Color(0xFF6A1B9A),
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF6A1B9A),
            secondary: const Color(0xFF9C27B0),
            background: Colors.purple[50]!,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF424242),
            onSurface: const Color(0xFF424242),
          ),
          scaffoldBackgroundColor: Colors.purple[50],
          cardColor: Colors.white,
          cardTheme: const CardTheme(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6A1B9A),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF424242)),
            bodyMedium: TextStyle(color: Color(0xFF424242)),
            titleLarge: TextStyle(color: Color(0xFF424242)),
            titleMedium: TextStyle(color: Color(0xFF424242)),
            titleSmall: TextStyle(color: Color(0xFF424242)),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6A1B9A),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            selectedIconTheme: const IconThemeData(size: 24, color: Color(0xFF6A1B9A)),
            unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[600]),
            elevation: 8,
          ),
        );
      default:
        return ThemeData(
          primaryColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF2196F3),
            background: Colors.blue[50]!,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF424242),
            onSurface: const Color(0xFF424242),
            surfaceTint: Colors.white, // Explicitly disable surface tinting
          ),
          scaffoldBackgroundColor: Colors.blue[50],
          cardColor: Colors.white, // Ensure card color is white
          cardTheme: const CardTheme(
            color: Colors.white, // Explicitly set default card color
            surfaceTintColor: Colors.white, // Important for Material 3
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF424242)),
            bodyMedium: TextStyle(color: Color(0xFF424242)),
            titleLarge: TextStyle(color: Color(0xFF424242)),
            titleMedium: TextStyle(color: Color(0xFF424242)),
            titleSmall: TextStyle(color: Color(0xFF424242)),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1565C0),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            selectedIconTheme: const IconThemeData(size: 24, color: Color(0xFF1565C0)),
            unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[600]),
            elevation: 8,
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
