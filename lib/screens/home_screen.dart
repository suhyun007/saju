import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../widgets/feature_button.dart';
import '../screens/saju_input_screen.dart';
import '../screens/webview_screen.dart';
import '../widgets/kma_weather_chip.dart';
import '../services/daily_fortune_service.dart';
import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../services/auth_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyFortune? _todayFortune;
  SajuInfo? _sajuInfo;
  SajuApiResponse? _sajuAnalysis;
  bool _isLoading = true;
  late final WebViewController _webController;
  bool _showWebView = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadTodayFortune();
    _initializeWebView();
    _loadUserInfo();
    AuthService.addAuthStateListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    AuthService.removeAuthStateListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged(UserModel? user) {
    setState(() {
      _currentUser = user;
    });
  }

  Widget _buildUserInitial() {
    return Center(
      child: Text(
        _currentUser!.displayName.isNotEmpty
            ? _currentUser!.displayName[0].toUpperCase()
            : 'U',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.amber,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }



  void _initializeWebView() async {
    try {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
        AndroidWebViewController.enableDebugging(true);
      }

      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            print('WebView 로딩 완료: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView 오류: ${error.description}');
          },
        ))
        ..addJavaScriptChannel(
          'flutter_inappwebview',
          onMessageReceived: (JavaScriptMessage message) {
            _handleWebViewMessage(message.message);
          },
        )
        ..loadFlutterAsset('web/home_screen.html');
    } catch (e) {
      print('WebView 초기화 오류: $e');
    }
  }

  void _handleWebViewMessage(String message) {
    switch (message) {
      case 'openSajuInfo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SajuInputScreen()),
        );
        break;
      case 'openFortuneAnalysis':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              title: '운세 분석',
              url: 'https://www.google.com',
            ),
          ),
        );
        break;
      case 'openLoveFortune':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              title: '연애운',
              url: 'https://www.naver.com',
            ),
          ),
        );
        break;
      case 'openCareerFortune':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              title: '직업운',
              url: 'https://www.daum.net',
            ),
          ),
        );
        break;
      case 'toggleWebView':
        setState(() {
          _showWebView = !_showWebView;
        });
        break;
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AuthService.getUserFromLocal();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('사용자 정보 로드 실패: $e');
    }
  }

  Future<void> _loadTodayFortune() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // 저장된 사주 정보 가져오기
      final sajuInfo = await SajuService.loadSajuInfo();
      
      // 사주 분석 데이터 가져오기 (실제 API 호출)
      SajuApiResponse? sajuAnalysis;
      if (sajuInfo != null) {
        try {
          sajuAnalysis = await SajuApiService.getSajuAnalysis(sajuInfo);
        } catch (e) {
          print('사주 분석 로드 실패: $e');
          // API 실패 시 더미 데이터로 폴백
          try {
            sajuAnalysis = await SajuApiService.getSimpleSajuAnalysis(sajuInfo);
          } catch (fallbackError) {
            print('더미 데이터 로드도 실패: $fallbackError');
          }
        }
      }
      
      // 오늘의 운세 가져오기 (API만 사용)
      final fortune = await DailyFortuneService.getTodayFortune(sajuInfo);
      
      if (mounted) {
        setState(() {
          _sajuInfo = sajuInfo;
          _sajuAnalysis = sajuAnalysis;
          _todayFortune = fortune;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('운세 API 호출 실패: $e');
      if (mounted) {
        setState(() {
          _todayFortune = null;
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF4A2C1A),
              Color(0xFF8B4513),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              
              // 메인 콘텐츠
              Expanded(
                child: _showWebView 
                  ? _buildWebView()
                  : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return WebViewWidget(controller: _webController);
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 오늘의 운세
          _buildTodayFortune(),
          
          const SizedBox(height: 30),
          
          // 기능 버튼들
          _buildFeatureButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/icons/Icon-192.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 실패: $error');
                  return const Icon(
                    Icons.water_drop,
                    color: Colors.green,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KmaWeatherChip(),
                const SizedBox(height: 8),
                Text(
                  '포춘수박',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_currentUser != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _currentUser!.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () async {
              try {
                if (_currentUser != null) {
                  // 로그인된 사용자가 있으면 로그아웃
                  await AuthService.signOut();
                  setState(() {
                    _currentUser = null;
                  });
                } else {
                  // 로그인되지 않았으면 Google 로그인
                  final user = await AuthService.signInWithGoogle();
                  if (user != null) {
                    setState(() {
                      _currentUser = user;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${user.displayName}님 환영합니다!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('로그인/로그아웃 오류: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('오류가 발생했습니다: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: _currentUser != null
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.2),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: _currentUser!.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              _currentUser!.photoURL!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildUserInitial();
                              },
                            ),
                          )
                        : _buildUserInitial(),
                  )
                : Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
            tooltip: _currentUser != null ? '로그아웃' : 'Google 로그인',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 서비스',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: const [
            FeatureButton(
              icon: Icons.calendar_today,
              title: '사주 정보',
              subtitle: '생년월일시 입력',
              color: Color(0xFF8B4513),
            ),
            FeatureButton(
              icon: Icons.psychology,
              title: '운세 분석',
              subtitle: '오늘의 운세',
              color: Color(0xFFDAA520),
            ),
            FeatureButton(
              icon: Icons.favorite,
              title: '연애운',
              subtitle: '사랑의 운세',
              color: Color(0xFFDC143C),
            ),
            FeatureButton(
              icon: Icons.work,
              title: '직업운',
              subtitle: '일과 재물운',
              color: Color(0xFF228B22),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayFortune() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 10),
              Text(
                '운세를 불러오는 중...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_todayFortune == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.amber, size: 24),
            const SizedBox(height: 10),
            Text(
              '불러올 수 없습니다.',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadTodayFortune,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '오늘의 운세',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_sajuInfo != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '개인화',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // 100점 만점 점수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Text(
              '${_todayFortune!.score}점 / 100점',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          // 운세 메시지 (주요 내용)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 운세',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _todayFortune!.message,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          if (_todayFortune!.advice.isNotEmpty) ...[
            const SizedBox(height: 12),
            // 조언 (추가 내용)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '오늘의 조언',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _todayFortune!.advice,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
          // 사주 분석 결과의 운세 내용 추가
          if (_sajuAnalysis?.data?.fortune != null && _sajuAnalysis!.data!.fortune!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '사주 분석 운세',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sajuAnalysis!.data!.fortune!,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _loadTodayFortune,
                icon: const Icon(Icons.refresh, color: Colors.amber, size: 20),
                tooltip: '새로고침',
              ),
                             Text(
                 '테스트 모드 - API 시뮬레이션',
                 style: GoogleFonts.notoSans(
                   fontSize: 12,
                   color: Colors.amber.withOpacity(0.7),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }


}
