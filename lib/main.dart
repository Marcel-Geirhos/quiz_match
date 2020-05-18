import 'package:flutter/material.dart';
import 'package:quiz_match/userInterface/registerPage.dart';

void main() => runApp(
  MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: RegisterPage(),
  ),
);
