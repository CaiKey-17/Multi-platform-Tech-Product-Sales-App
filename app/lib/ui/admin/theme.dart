import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue[700],
    scaffoldBackgroundColor: Colors.grey[100],
    // textTheme: GoogleFonts.montserratTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
  );
}
