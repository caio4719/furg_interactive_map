import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
part 'app_store.g.dart';

class AppStore = _AppStoreBase with _$AppStore;

class MyTheme {
  // * Creating both themmes
  static final ThemeData light = _buildLightTheme();
  static final ThemeData dark = _buildDarkTheme();

  // * Iniatilizing light theme
  static ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base;
  }

  // * Iniatilizing dark theme and changing ElevatedButtonThemeData to fallow the dark theme
  static ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
        ),
      ),
    );
  }
}

abstract class _AppStoreBase with Store {
  // * Before teh render _AppStorebase will run what is inside
  _AppStoreBase() {
    loadTheme();
  }

  // * Type of my current theme
  @observable
  ThemeData? themeType;

  // * bool of my current theme
  @computed
  bool get isDark => themeType?.brightness == Brightness.dark;

  // * function taht change themes and save in my local storage
  @action
  changeTheme() {
    if (isDark) {
      themeType = MyTheme.light;
    } else {
      themeType = MyTheme.dark;
    }
    saveThemePreferences();
  }

  // * function that saves my chose theme as True or False
  @action
  saveThemePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
  }

  // * function that fetche my the chose theme on my local sorage
  @action
  Future loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // await Future.delayed(Duration(seconds: 3));
    final isDark = prefs.getBool('isDark') ?? false;
    if (prefs.containsKey('isDark') && isDark) {
      themeType = MyTheme.dark;
    } else {
      themeType = MyTheme.light;
    }
  }
}