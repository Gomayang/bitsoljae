import 'package:bitsoljae/notice/notice_page.dart';
import 'package:bitsoljae/ui_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '빛솔재',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 48 * getScaleWidth(context),
          ),
          bodyMedium: TextStyle(
            fontSize: 32 * getScaleWidth(context),
            letterSpacing: -0.1 * getScaleWidth(context),
          ),
          bodySmall: TextStyle(
            fontSize: 24 * getScaleWidth(context),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800500),
        ),
        useMaterial3: true,
      ),
      home: const NoticePage(),
    );
  }
}
