import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier{

  bool _isDark = false;

  String? _wallpaperPath;

  bool get isDark => _isDark;

  String? get wallpaperPath => _wallpaperPath;

  late SharedPreferences storage;

  final darkTheme = ThemeData(

    primaryColor: Colors.black12,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black12,

  );

  final lightTheme = ThemeData(

    primaryColor: Colors.white,
    brightness: Brightness.light,
    primaryColorDark: Colors.white,

  );

  // changeTheme(){
  //
  //   _isDark = !isDark;
  //   storage.setBool("isDark", _isDark);
  //   notifyListeners();
  // }

  Future<void> changeTheme(bool isDarkMode) async {
    _isDark = isDarkMode;
    storage.setBool("isDark", _isDark);
    notifyListeners();
  }

  Future<void> setWallpaper(String path) async {
    _wallpaperPath = path;
    await storage.setString("wallpaperPath", path);
    notifyListeners();
  }

  init()async{

    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool("isDark")??false;

    _wallpaperPath = storage.getString("wallpaperPath");

    notifyListeners();

  }
}