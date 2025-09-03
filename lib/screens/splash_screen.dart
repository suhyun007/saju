import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'saju_input_screen.dart';
import 'home_screen.dart';
import '../services/saju_service.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleStartButton() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 출생 정보 확인
      final sajuInfo = await SajuService.loadSajuInfo();
      
      if (mounted) {
        // 출생 정보가 있으면 HomeScreen으로, 없으면 입력 화면으로
        final targetScreen = sajuInfo != null 
            ? const HomeScreen() 
            : const SajuInputScreen();
        
        // 사주정보가 있으면 pushReplacement, 없으면 push 사용
        if (sajuInfo != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        }
      }
    } catch (e) {
      // 에러 발생 시 입력 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SajuInputScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/design/launch_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              // 앱 이름 (맨 위) - 제거됨
              // const SizedBox(height: 50),
              // Text(
              //   _appName,
              //   style: GoogleFonts.josefinSans(
              //     fontSize: 40,
              //     fontWeight: FontWeight.w300,
              //     color: const Color(0xFFE6F3FF),
              //     letterSpacing: 1,
              //     shadows: [
              //       Shadow(
              //         color: const Color(0xFF4A90E2).withOpacity(0.8),
              //         blurRadius: 15,
              //         offset: const Offset(2, 2),
              //       ),
              //       Shadow(
              //         color: const Color(0xFF9B59B6).withOpacity(0.6),
              //         blurRadius: 25,
              //         offset: const Offset(-2, -2),
              //       ),
              //       Shadow(
              //         color: Colors.white.withOpacity(0.4),
              //         blurRadius: 8,
              //         offset: const Offset(0, 0),
              //       ),
              //     ],
              //   ),
              // ),
              // 중간 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 앱 아이콘
                      Container(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/icons/zodiac_wheel_icon_512.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      // 고정 메시지 (로컬라이징 적용)
                      Text(
                        l10n?.splashSubtitle2 ?? 'LunaVerse creates fun literary content daily based on your information.',
                        style: TextStyle(
                          fontSize: l10n?.localeName == 'en' ? 20.0 : 19.0, // 영어일 때 20, 한국어일 때 19
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFFE6F3FF),
                          letterSpacing: 0.5,
                          height: 1.5,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 3,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      // 시작하기 버튼 (로컬라이징 적용)
                      Container(
                        width: 360,
                        height: 59,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5d7df4), // 채도 높은 파란색
                              Color(0xFF9961f6), // 채도 높은 보라색
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _handleStartButton,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          l10n?.splashButtonText ?? 'AI Content',
                                          style: const TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
