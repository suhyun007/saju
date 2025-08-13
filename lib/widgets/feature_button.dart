import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/saju_view_screen.dart';
import '../screens/saju_input_screen.dart';
import '../models/saju_info.dart';
import '../services/saju_service.dart';

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 각 기능별 화면으로 이동
        _handleFeatureTap(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(BuildContext context) async {
    switch (title) {
      case '사주 보기':
        await _handleSajuView(context);
        break;
      case '운세 분석':
        _showSnackBar(context, '운세 분석 화면으로 이동합니다');
        break;
      case '연애운':
        _showSnackBar(context, '연애운 분석 화면으로 이동합니다');
        break;
      case '직업운':
        _showSnackBar(context, '직업운 분석 화면으로 이동합니다');
        break;
      default:
        _showSnackBar(context, '준비 중인 기능입니다');
    }
  }

  Future<void> _handleSajuView(BuildContext context) async {
    // 저장된 사주 정보가 있는지 확인
    final hasSajuInfo = await SajuService.hasSajuInfo();
    
    if (hasSajuInfo) {
      // 저장된 사주 정보가 있으면 사주 보기 화면으로 이동
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SajuViewScreen(sajuInfo: sajuInfo),
          ),
        );
      }
    } else {
      // 저장된 사주 정보가 없으면 사주 입력 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SajuInputScreen(),
        ),
      );
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
