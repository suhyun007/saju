import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SajuApp());
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사주앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: GoogleFonts.notoSansKr().fontFamily,
        scaffoldBackgroundColor: const Color(0xFF2C1810),
      ),
      home: const HomeScreen(),
    );
  }
}