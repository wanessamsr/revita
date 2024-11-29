import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {

  //Instância dela mesmo!
  static AppController instance = AppController();

  bool isDartTheme = false;
  changeTheme() {
    isDartTheme = !isDartTheme;
    notifyListeners();
  }
}

