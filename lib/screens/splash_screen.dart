import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'auth_wrapper.dart';
import 'saju_input_screen.dart';
import 'home_screen.dart';
import '../services/saju_service.dart';
import '../services/splash_text_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  String _appName = 'AstroStar';
  String _subtitle = '별자리의 신비로움을 통해 운세를 알아보세요';
  String _buttonText = '시작하기';
  Timer? _subtitleTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadSplashTexts();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadSplashTexts() async {
    await SplashTextService.loadSplashTexts();
    if (mounted) {
      setState(() {
        _appName = SplashTextService.getAppName();
        _subtitle = SplashTextService.getSubtitle();
        _buttonText = SplashTextService.getButtonText();
      });
      
      // 10초마다 subtitle 변경 (더 천천히)
      _subtitleTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
        if (mounted && !_isLoading) {
          setState(() {
            _subtitle = SplashTextService.getSubtitle();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subtitleTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleStartButton() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 출생 정보 확인
      final sajuInfo = await SajuService.loadSajuInfo();
      
      if (mounted) {
        // 출생 정보가 있으면 홈 화면으로, 없으면 입력 화면으로
        final targetScreen = sajuInfo != null 
            ? const HomeScreen() 
            : const SajuInputScreen();
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 입력 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SajuInputScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/design/pattern_starry_1024_optimized.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // 앱 이름 (맨 위)
                      const SizedBox(height: 200),
                      Text(
                        _appName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 54,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFF5E6D3),
                          letterSpacing: 4,
                          
                        ),
                      ),
                      // 중간 영역
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 앱 아이콘
                              Container(
                                width: 200,
                                height: 200,
                                child: ClipRRect(
                                  //borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    'assets/icons/zodiac_wheel_icon_256.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // 고정 메시지
                              Text(
                                '오늘 밤하늘의 별은 \n어떤 이야기를 전해줄까요?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFd6c2a5),
                                  letterSpacing: 0.5,
                                  height: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 3,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // 부제목
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  _subtitle,
                                  key: ValueKey(_subtitle),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFd6c2a5),
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 5,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 40),
                              // 시작하기 버튼
                              Container(
                                width: 350,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4C430),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    //borderRadius: BorderRadius.circular(15),
                                    onTap: _isLoading ? null : _handleStartButton,
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 26,
                                              height: 26,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _buttonText,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                letterSpacing: 1,
                                              ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
