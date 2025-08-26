
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'myPage.dart';

class SajuNavigator extends StatefulWidget {
  const SajuNavigator({super.key});

  @override
  State<SajuNavigator> createState() => _SajuNavigatorState();
}

class _SajuNavigatorState extends State<SajuNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C1810).withOpacity(0.95),
              const Color(0xFF2C1810),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _currentIndex == 0 ? Colors.amber : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: _currentIndex == 0 ? Colors.amber : Colors.white.withOpacity(0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: _currentIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                          color: _currentIndex == 0 ? Colors.amber : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _currentIndex == 1 ? Colors.amber : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentIndex == 1 ? Icons.person : Icons.person_outline,
                        color: _currentIndex == 1 ? Colors.amber : Colors.white.withOpacity(0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'My',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: _currentIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                          color: _currentIndex == 1 ? Colors.amber : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
