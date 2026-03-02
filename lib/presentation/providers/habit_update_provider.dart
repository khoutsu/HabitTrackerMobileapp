import 'package:flutter/material.dart';

class HabitUpdateProvider extends ChangeNotifier {
  int _updateCount = 0;
  int get updateCount => _updateCount;

  void notifyUpdated() {
    _updateCount++;
    notifyListeners();
  }
}
