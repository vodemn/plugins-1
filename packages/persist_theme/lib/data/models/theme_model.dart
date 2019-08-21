import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

//updated

enum ThemeType { light, dark, lightColor, darkColor }

class ThemeModel extends ChangeNotifier {
  ThemeModel({
    this.customLightTheme,
    this.customDarkTheme,
    this.customLightColorTheme,
    this.customDarkColorTheme,
    String key,
  }) : _storage = LocalStorage(key ?? "app_theme");

  final ThemeData customLightTheme,
      customDarkTheme,
      customDarkColorTheme,
      customLightColorTheme;

  int _accentColor = Colors.redAccent.value;
  bool _lightMode = false;
  bool _darkMode = false;
  int _primaryColor = Colors.blue.value;
  LocalStorage _storage;
  bool _lightColor = false;
  bool _darkColor = false;

  ThemeType get type {
    if (_darkMode ?? false) {
      if (_darkColor ?? false) return ThemeType.darkColor;
      return ThemeType.dark;
    }
    if (_lightMode ?? false) return ThemeType.lightColor;
    return ThemeType.light;
  }

  void changeDarkMode(bool value) {
    _darkMode = value;
    _storage.setItem("dark_mode", _darkMode);
    notifyListeners();
  }

  void changeDarkColor(bool value) {
    _darkColor = value;
    _storage.setItem("dark_color", _darkColor);
    notifyListeners();
  }

  void changeLightMode(bool value) {
    _lightMode = value;
    _storage.setItem("light_mode", _lightMode);
    notifyListeners();
  }

  void changeLightColor(bool value) {
    _lightColor = value;
    _storage.setItem("light_color", _lightColor);
    notifyListeners();
  }

  void changePrimaryColor(Color value) {
    _primaryColor = value.value;
    _storage.setItem("primary_color", _primaryColor);
    notifyListeners();
  }

  void changeAccentColor(Color value) {
    _accentColor = value.value;
    _storage.setItem("accent_color", _accentColor);
    notifyListeners();
  }

  ThemeData get theme {
    if (_storage == null) {
      init();
    }
    switch (type) {
      case ThemeType.light:
        return customLightTheme ??
            ThemeData.light().copyWith(
              primaryColor: primaryColor ?? Colors.white,
              accentColor: accentColor ?? Colors.redAccent,
            );
      case ThemeType.dark:
        return customDarkTheme ??
            ThemeData.dark().copyWith(
              accentColor: accentColor ?? null,
            );
      case ThemeType.darkColor:
        return customDarkColorTheme ??
            ThemeData.dark().copyWith(
              accentColor: accentColor ?? null,
            );
      case ThemeType.lightColor:
        return customLightColorTheme != null
            ? customLightColorTheme.copyWith(
                primaryColor: primaryColor ?? Colors.blue,
                accentColor: accentColor ?? Colors.redAccent,
              )
            : ThemeData.light().copyWith(
                primaryColor: primaryColor ?? Colors.blue,
                accentColor: accentColor ?? Colors.redAccent,
              );
      default:
        return customLightTheme ??
            ThemeData.light().copyWith(
              primaryColor: primaryColor ?? Colors.white,
              accentColor: accentColor ?? Colors.redAccent,
            );
    }
  }

  void checkPlatformBrightness(BuildContext context) {
    if (!darkMode &&
        MediaQuery.of(context).platformBrightness == Brightness.dark) {
      changeDarkMode(true);
    }
  }

  ThemeData get darkTheme {
    if (_storage == null) {
      init();
    }

    if (_darkColor ?? false) {
      return customDarkColorTheme ??
          ThemeData.dark().copyWith(
            primaryColorDark: primaryColor,
            accentColor: accentColor ?? null,
          );
    }
    return customDarkTheme ??
        ThemeData.dark().copyWith(
          accentColor: accentColor ?? null,
        );
  }

  Color get backgroundColor {
    if (darkMode ?? false) {
      if (darkColor ?? false) return Colors.black;
      return ThemeData.dark().scaffoldBackgroundColor;
    }
    if (customTheme ?? false) return primaryColor;
    return null;
  }

  Color get textColor {
    if (customTheme ?? false) return Colors.white;
    if (darkMode ?? false) return Colors.white;
    return Colors.black;
  }

  Color get textColorInvert {
    if (customTheme ?? false) return Colors.black;
    if (darkMode ?? false) return Colors.black;
    return Colors.white;
  }

  Future init() async {
    if (await _storage.ready) {
      _darkMode = _storage.getItem("dark_mode");
      _darkColor = _storage.getItem("dark_color");
      _lightMode = _storage.getItem("light_mode");
      _lightColor = _storage.getItem("light_color");
      _primaryColor = _storage.getItem("primary_color");
      _accentColor = _storage.getItem("accent_color");
      notifyListeners();
    } else {
      print("Error Loading Theme...");
    }
  }

  bool get darkMode =>
      _darkMode ?? (type == ThemeType.dark || type == ThemeType.darkColor);

  bool get darkColor => _darkColor ?? type == ThemeType.darkColor;

  bool get customTheme => _lightMode ?? type == ThemeType.lightColor;

  Color get primaryColor {
    if (_primaryColor == null) {
      return type == ThemeType.dark
          ? ThemeData.dark().primaryColor
          : ThemeData.light().primaryColor;
    }
    return Color(_primaryColor);
  }

  Color get accentColor {
    if (type == ThemeType.dark || type == ThemeType.darkColor) {
      return ThemeData.dark().accentColor;
    }

    if (_accentColor == null) {
      return ThemeData.light().accentColor;
    }

    if (_lightMode || _lightColor) {
      return Color(_accentColor);
    }

    return Colors.redAccent;
  }

  void reset() {
    _storage.clear();
    _darkMode = false;
    _darkColor = false;
    _lightMode = false;
    _lightColor = false;
    _primaryColor = Colors.blue.value;
    _accentColor = Colors.redAccent.value;
  }
}
