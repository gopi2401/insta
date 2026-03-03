import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insta/core/theme/app_theme.dart';

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
    return AppTheme.lightTheme();
  }

  ThemeData get darkTheme {
    return AppTheme.darkTheme();
  }
}

