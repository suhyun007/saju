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
import '../services/auth_service.dart';
import '../models/saju_info.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyFortune? _todayFortune;
  SajuInfo? _sajuInfo;
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
      
      // 오늘의 운세 가져오기 (API만 사용)
      final fortune = await DailyFortuneService.getTodayFortune(sajuInfo);
      
      if (mounted) {
        setState(() {
          _sajuInfo = sajuInfo;
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
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.amber,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수박 사주',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const KmaWeatherChip(),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showWebView = !_showWebView;
              });
            },
            icon: Icon(
              _showWebView ? Icons.apps : Icons.web,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              // 설정에서 사주 정보 입력 화면으로 이동
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SajuInputScreen()),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
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
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: _currentUser!.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                    child: _currentUser!.photoURL == null
                        ? Text(
                            _currentUser!.displayName.isNotEmpty
                                ? _currentUser!.displayName[0]
                                : 'U',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          )
                        : null,
                  )
                : const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 32,
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
          Text(
            '${_todayFortune!.score}점 / 100점',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _todayFortune!.message,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_todayFortune!.advice.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _todayFortune!.advice,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.amber.withOpacity(0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
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
