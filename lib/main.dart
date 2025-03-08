import 'package:flutter/material.dart';
import 'package:march_yopta/main_screen.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShowCaseWidget(
        builder: (context) => Scaffold(
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.pinkAccent,
              child: const MainScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
