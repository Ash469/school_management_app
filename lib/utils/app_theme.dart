import 'package:flutter/material.dart';

class AppTheme {
  static const String defaultTheme = 'blue';
  static const String defaultBrightness = 'light';
  
  // Get theme based on theme name and brightness
  static ThemeData getTheme(String themeName, {String brightness = 'light'}) {
    final bool isDark = brightness == 'dark';
    
    switch (themeName) {
      case 'blue':
        return _buildBlueTheme(isDark);
      case 'green':
        return _buildGreenTheme(isDark);
      case 'purple':
        return _buildPurpleTheme(isDark);
      default:
        return _buildBlueTheme(isDark);
    }
  }
  
  // Build blue theme (light/dark)
  static ThemeData _buildBlueTheme(bool isDark) {
    if (isDark) {
      return ThemeData(
        primaryColor: const Color(0xFF1565C0),
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF64B5F6),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
          surfaceTint: Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          surfaceTintColor: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF42A5F5),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          selectedIconTheme: IconThemeData(size: 24, color: Color(0xFF42A5F5)),
          unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
          elevation: 8,
        ),
      );
    } else {
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
          surfaceTint: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.blue[50],
        cardColor: Colors.white,
        cardTheme: const CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.white,
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
  
  // Build green theme (light/dark)
  static ThemeData _buildGreenTheme(bool isDark) {
    if (isDark) {
      return ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF81C784),
          secondary: Color(0xFF4CAF50),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          surfaceTintColor: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF81C784),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          selectedIconTheme: IconThemeData(size: 24, color: Color(0xFF81C784)),
          unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
          elevation: 8,
        ),
      );
    } else {
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
    }
  }
  
  // Build purple theme (light/dark)
  static ThemeData _buildPurpleTheme(bool isDark) {
    if (isDark) {
      return ThemeData(
        primaryColor: const Color(0xFF6A1B9A),
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBA68C8),
          secondary: Color(0xFF9C27B0),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          surfaceTintColor: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFFBA68C8),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          selectedIconTheme: IconThemeData(size: 24, color: Color(0xFFBA68C8)),
          unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
          elevation: 8,
        ),
      );
    } else {
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
    }
  }
  
  // Get primary color based on theme name and brightness
  static Color getPrimaryColor(String themeName, {String brightness = 'light'}) {
    final bool isDark = brightness == 'dark';
    
    switch (themeName) {
      case 'blue':
        return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
      case 'green':
        return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      case 'purple':
        return isDark ? const Color(0xFFBA68C8) : const Color(0xFF6A1B9A);
      default:
        return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
    }
  }
  
  // Get accent color based on theme name and brightness
  static Color getAccentColor(String themeName, {String brightness = 'light'}) {
    final bool isDark = brightness == 'dark';
    
    switch (themeName) {
      case 'blue':
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3);
      case 'green':
        return isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);
      case 'purple':
        return isDark ? const Color(0xFF9C27B0) : const Color(0xFF9C27B0);
      default:
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3);
    }
  }
  
  // Get tertiary color based on theme name and brightness
  static Color getTertiaryColor(String themeName, {String brightness = 'light'}) {
    final bool isDark = brightness == 'dark';
    
    switch (themeName) {
      case 'blue':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFFA000);
      case 'green':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF6F00);
      case 'purple':
        return isDark ? const Color(0xFFFF80AB) : const Color(0xFFFF4081);
      default:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFFA000);
    }
  }
  
  // Get gradient colors based on theme name and brightness
  static List<Color> getGradientColors(String themeName, {String brightness = 'light'}) {
    final bool isDark = brightness == 'dark';
    
    switch (themeName) {
      case 'blue':
        return isDark 
          ? [const Color(0xFF1E1E1E), const Color(0xFF42A5F5)]
          : [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'green':
        return isDark 
          ? [const Color(0xFF1E1E1E), const Color(0xFF81C784)]
          : [const Color(0xFF2E7D32), const Color(0xFF81C784)];
      case 'purple':
        return isDark 
          ? [const Color(0xFF1E1E1E), const Color(0xFFBA68C8)]
          : [const Color(0xFF6A1B9A), const Color(0xFFBA68C8)];
      default:
        return isDark 
          ? [const Color(0xFF1E1E1E), const Color(0xFF42A5F5)]
          : [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
  }
}
