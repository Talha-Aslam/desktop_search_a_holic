import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Font size configuration
  double _fontSize = 13.0;
  double get fontSize => _fontSize;

  // Custom gradient colors that can be changed by user
  List<Color> _customGradientColors = [
    const Color(0xFF2196F3), // Default Blue
    const Color(0xFF49CEC3), // Default Teal
  ];

  // Light theme colors
  static const Color _lightPrimaryColor = Color(0xFF2196F3); // Blue
  static const Color _lightSecondaryColor = Color(0xFF49CEC3); // Teal
  static const Color _lightScaffoldBgColor = Color(0xFFEEF2F6);
  static const Color _lightCardBgColor = Colors.white;
  static const Color _lightTextColor = Color(0xFF212121);
  static const Color _lightIconColor = Color(0xFF616161);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF1976D2); // Dark Blue
  static const Color _darkSecondaryColor = Color(0xFF00897B); // Dark Teal
  static const Color _darkScaffoldBgColor = Color(0xFF121212);
  static const Color _darkCardBgColor = Color(0xFF1F1F1F);
  static const Color _darkTextColor = Color(0xFFEEEEEE);
  static const Color _darkIconColor = Color(0xFFBDBDBD);

  // Gradient colors
  List<Color> get gradientColors => _customGradientColors;

  // Primary Color getter for charts and other components
  Color get primaryColor =>
      _isDarkMode ? _darkPrimaryColor : _lightPrimaryColor;

  Color get scaffoldBackgroundColor =>
      _isDarkMode ? _darkScaffoldBgColor : _lightScaffoldBgColor;
  Color get cardBackgroundColor =>
      _isDarkMode ? _darkCardBgColor : _lightCardBgColor;
  Color get textColor => _isDarkMode ? _darkTextColor : _lightTextColor;
  Color get iconColor => _isDarkMode ? _darkIconColor : _lightIconColor;
  Color get borderColor =>
      _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

  // Text style helpers based on font size
  TextStyle get bodyTextStyle => TextStyle(
        fontSize: _fontSize,
        color: textColor,
      );

  TextStyle get bodyTextStyleBold => TextStyle(
        fontSize: _fontSize,
        color: textColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get titleTextStyle => TextStyle(
        fontSize: _fontSize + 2,
        color: textColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get subtitleTextStyle => TextStyle(
        fontSize: _fontSize - 1,
        color: textColor.withOpacity(0.7),
      );

  TextStyle get captionTextStyle => TextStyle(
        fontSize: _fontSize - 2,
        color: textColor.withOpacity(0.6),
      );

  TextStyle get largeTextStyle => TextStyle(
        fontSize: _fontSize + 4,
        color: textColor,
        fontWeight: FontWeight.bold,
      );

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    // Load font size and clamp it to the new range (10-17)
    double savedFontSize = prefs.getDouble('fontSize') ?? 13.0;
    _fontSize = savedFontSize.clamp(10.0, 17.0);

    // If the font size was clamped, save the new value
    if (savedFontSize != _fontSize) {
      await prefs.setDouble('fontSize', _fontSize);
    }

    // Load custom colors if they exist
    final primaryColorValue = prefs.getInt('primaryColor');
    final secondaryColorValue = prefs.getInt('secondaryColor');

    if (primaryColorValue != null && secondaryColorValue != null) {
      _customGradientColors = [
        Color(primaryColorValue),
        Color(secondaryColorValue),
      ];
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setGradientColors(List<Color> colors) async {
    if (colors.length >= 2) {
      _customGradientColors = colors.sublist(0, 2);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColor', _customGradientColors[0].value);
      await prefs.setInt('secondaryColor', _customGradientColors[1].value);

      notifyListeners();
    }
  }

  Future<void> setFontSize(double size) async {
    print('ThemeProvider: Setting font size to $size');
    // Clamp the font size to the valid range (10-17)
    _fontSize = size.clamp(10.0, 17.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    print('ThemeProvider: Font size saved and notifying listeners');
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  ThemeData get _lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _lightPrimaryColor,
      scaffoldBackgroundColor: _lightScaffoldBgColor,
      cardColor: _lightCardBgColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      colorScheme: ColorScheme.light(
        primary: _lightPrimaryColor,
        secondary: _lightSecondaryColor,
      ),
    );
  }

  ThemeData get _darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryColor,
      scaffoldBackgroundColor: _darkScaffoldBgColor,
      cardColor: _darkCardBgColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: _darkCardBgColor,
        labelStyle: const TextStyle(color: _darkTextColor),
      ),
      colorScheme: ColorScheme.dark(
        primary: _darkPrimaryColor,
        secondary: _darkSecondaryColor,
      ),
    );
  }
}
