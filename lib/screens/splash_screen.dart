import 'package:flutter/material.dart';
import 'dart:async';
import 'saju_input_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../services/analytics_service.dart';
import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../models/saju_info.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool? _isReturningUser; // 서버 로그 기반 기존 사용자 여부
  late final AnimationController _subtitleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final Animation<double> _subtitleFade =
      CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut);
  late final Animation<Offset> _subtitleSlide = Tween<Offset>(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut));
  Timer? _subtitleTimer;

  @override
  void initState() {
    super.initState();
    
    _initSplash();
  }

  Future<void> _initSplash() async {
    // saju_info의 핵심 필드가 모두 비어있으면 신규, 아니면 기존 사용자로 간주
    final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
    bool isAllEmpty(String? v) => v == null || v.trim().isEmpty;
    final bool returning = !(
      sajuInfo == null ||
      (isAllEmpty(sajuInfo.name) &&
       isAllEmpty(sajuInfo.gender) &&
       isAllEmpty(sajuInfo.tone) &&
       isAllEmpty(sajuInfo.world) &&
       isAllEmpty(sajuInfo.era) &&
       isAllEmpty(sajuInfo.ageGroup))
    );
    if (mounted) {
      setState(() {
        _isReturningUser = returning;
      });
      _subtitleCtrl.forward();
      _subtitleTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
        if (!mounted) return;
        _subtitleCtrl.forward(from: 0);
      });
    }
    
    // 방문 로그 기록 (서버가 geo로 nation 계산)
    try {
      final localeLang = AppLocalizations.of(context)?.localeName ?? 'en';
      await SajuApiService.logVisit(language: localeLang);
    } catch (_) {}
    // 하루 1회 방문 로그 기록 (분기 결정 후 기록하여 첫 방문이 기존으로 오인되지 않도록)
    AnalyticsService.logFirstVisit();
    // 즉시 스플래시 화면 진입 로그 기록 (menu_click_logs)
    AnalyticsService.logMenuClick('splash');
    
    // 익명 로그인 테스트
    _testAnonymousLogin();
  }

  void _testAnonymousLogin() async {
    try {
      print('splash_screen - 익명 로그인 테스트 시작');
      final response = await SupabaseService.client.auth.signInAnonymously();
      if (response.user != null) {
        print('splash_screen - 익명 로그인 성공: ${response.user!.id}');
      } else {
        print('splash_screen - 익명 로그인 실패: 사용자 정보 없음');
      }
    } catch (e) {
      print('splash_screen - 익명 로그인 실패: $e');
    }
  }

  Future<void> _handleStartButton() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 온라인 체크
      final online = await _isOnline();
      if (!online) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              title: Text(l10n.offlineTitle),
              content: Text(l10n.offlineMessage),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.offlineClose),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (await _isOnline()) {
                      _handleStartButton();
                    }
                  },
                  child: Text(l10n.offlineRetry),
                ),
              ],
            ),
          );
        }
        return;
      }

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

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return false;
    try {
      final resp = await http
          .get(Uri.parse('https://saju-server-j9ti.vercel.app/api/poetry'))
          .timeout(const Duration(seconds: 3));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final double androidIconSize = (shortestSide * 0.5).clamp(140.0, 200.0).toDouble();
    final double iconSize = isAndroid ? androidIconSize : 200.0;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/design/bg6.png'),
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
                  padding: EdgeInsets.only(top: isAndroid ? 10 : 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height:0),
                      // 고정 메시지 (로컬라이징 적용) + 애니메이션
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: FadeTransition(
                          opacity: _subtitleFade,
                          child: SlideTransition(
                            position: _subtitleSlide,
                            child: Text(
                              (_isReturningUser == true)
                                  ? (l10n?.existPlashSubtitle ?? 'Welcome back. Your story continues.')
                                  : (l10n?.splashSubtitle2 ?? 'Ready to begin?\nAdd a few optional details to personalize your experience. You can skip anytime.'),
                              style: TextStyle(
                                fontSize: l10n?.localeName == 'en' ? 19.0 : 19.0, // 영어일 때 20, 한국어일 때 19
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF333333),
                                letterSpacing: 0.5,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // 시작하기 버튼 (로컬라이징 적용)
                      Container(
                        width: 320,
                        height: 50,
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
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          l10n?.splashButtonText ?? 'AI Content',
                                          style: const TextStyle(
                                            fontSize: 20,
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
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            builder: (ctx) {
                              return FractionallySizedBox(
                                heightFactor: 0.58,
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (l10n?.sampleStoryHeader ?? 'Try a Sample Story'),
                                          style: TextStyle(
                                            color: Color(0xFF4E4E4E),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(height: 14),
                                        Text(
                                          l10n?.sampleStoryP1 ?? 'When you opened your window this morning, the world felt strangely quiet, as if waiting for you. The sky carried a pale shade of blue, and in that stillness, you sensed something tender unfolding.',
                                          style: TextStyle(
                                            color: Color(0xFF585858),
                                            fontSize: 17,
                                            height: 1.7,
                                          ),
                                        ),
                                        SizedBox(height: 14),
                                        Text(
                                          l10n?.sampleStoryP2 ?? 'Walking down the street, you noticed small details—sunlight caught in the branches, a stranger smiling for no reason...',
                                          style: TextStyle(
                                            color: Color(0xFF585858),
                                            fontSize: 17,
                                            height: 1.7,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Container(
                                            width: 330,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF5d7df4),
                                                  Color(0xFF9961f6),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(ctx);
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => const SajuInputScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.auto_awesome,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        l10n?.makeMyStoryButton ?? 'Set Up Character',
                                                        style: const TextStyle(
                                                          fontSize: 19,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              );
                              
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 0), // underline gap
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF333333), width: 0.8),
                                ),
                              ),
                              child: Text(
                                l10n?.sampleStory ?? 'Try a Sample Story', 
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
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
