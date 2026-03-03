import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  late SharedPreferences _prefs;

  @override
  Future<ThemeService> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadThemePreference();
    return this;
  }

  void _loadThemePreference() {
    final savedTheme = _prefs.getBool('isDarkMode') ?? false;
    _isDarkMode.value = savedTheme;
  }

  /// Flip the saved boolean and then update both the
  /// stored preference and the visible theme.  When the app is
  /// wrapped in `AdaptiveTheme` we also need to drive that
  /// mechanism; previously we relied on `Get.changeTheme` which
  /// had no effect because `MaterialApp` was not a
  /// `GetMaterialApp`.
  ///
  /// A [BuildContext] is required so that we can look up the
  /// `AdaptiveTheme` instance and call its helpers.
  Future<void> toggleTheme(BuildContext context) async {
    _isDarkMode.toggle();
    await _prefs.setBool('isDarkMode', _isDarkMode.value);

    // update AdaptiveTheme so the change is visible and persisted
    if (_isDarkMode.value) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
        bodyLarge: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
      ),
    );
  }
}