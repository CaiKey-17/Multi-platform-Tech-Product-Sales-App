import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserPointsProvider extends ChangeNotifier {
  int _points = 0;

  int get points => _points;

  set points(int value) {
    _points = value;
    notifyListeners();
  }

  String get formattedPoints => NumberFormat("#,###", "de_DE").format(_points);

  Future<void> loadPointsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt('points') ?? 0;
    notifyListeners();
  }

  Future<void> updatePoints(int newPoints) async {
    _points = newPoints;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', newPoints);
    notifyListeners();
  }
}
