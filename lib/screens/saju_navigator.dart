import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'myPage.dart';

class SajuNavigator extends StatelessWidget {
  const SajuNavigator({
    super.key,
    required this.currentTabIndex,
    required this.onTap,
  });

  final int currentTabIndex; // 0: Episode, 1: Poetry, 2: Guide
  final ValueChanged<int> onTap; // 0: Home, 1: My

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5d7df4).withOpacity(0.6),
            const Color(0xFF9961f6).withOpacity(0.6),
          ],
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentTabIndex == 0 ? 0 : 1,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF1A1A1A).withOpacity(0.6),
        unselectedItemColor: const Color(0xFF1A1A1A).withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'My',
          ),
        ],
      ),
    );
  }
}
