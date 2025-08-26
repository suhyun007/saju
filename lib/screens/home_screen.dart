import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../widgets/feature_button.dart';
import '../screens/saju_input_screen.dart';
import '../screens/webview_screen.dart';
import '../screens/today_screen.dart';
import '../screens/month_screen.dart';
import '../screens/year_screen.dart';
// import '../widgets/kma_weather_chip.dart'; // 날씨 정보 주석처리
import '../services/daily_fortune_service.dart';
import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../services/auth_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../models/user_model.dart';
import '../screens/myPage.dart';
import '../screens/saju_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DailyFortune? _todayFortune;
  SajuInfo? _sajuInfo;
  SajuApiResponse? _sajuAnalysis;
  bool _isLoading = true;
  late final WebViewController _webController;
  bool _showWebView = false;
  UserModel? _currentUser;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadUserInfo();
    _loadSajuInfo();
    AuthService.addAuthStateListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    AuthService.removeAuthStateListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged(UserModel? user) {
    setState(() {
      _currentUser = user;
    });
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

  Future<void> _loadSajuInfo() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (mounted) {
        setState(() {
          _sajuInfo = sajuInfo;
        });
      }
    } catch (e) {
      print('출생 정보 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            
            // 탭바
            _buildTabBar(),
            
            // 메인 콘텐츠
            Expanded(
              child: _showWebView 
                ? _buildWebView()
                : _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWebView() {
    return WebViewWidget(controller: _webController);
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
              child: BottomNavigationBar(
          currentIndex: 0, // Home이 첫 번째이므로 0
          onTap: (index) {
            if (index == 1) {
              // My 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPage()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white.withOpacity(0.6),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'My',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicator: const BoxDecoration(
          color: Colors.transparent,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '오늘의 운세'),
          Tab(text: '이달의 운세'),
          Tab(text: '이번해 운세'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: const [
        TodayScreen(),
        MonthScreen(),
        YearScreen(),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 기능 버튼들
            _buildFeatureButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' AstroStar',
                  style: GoogleFonts.notoSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 출생 정보 이름 표시 (저장된 정보가 있으면 이름, 없으면 손님)
          Container(
            margin: const EdgeInsets.only(right: 0),
            child: Text(
              _sajuInfo != null && _sajuInfo!.name.isNotEmpty 
                ? '${_sajuInfo!.name}님' 
                : '손님',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyPage(),
                ),
              );
            },
            icon: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 18,
              ),
            ),
            tooltip: '환경설정',
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
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: [
            FeatureButton(
              icon: Icons.calendar_today,
              title: '출생 정보',
              subtitle: '생년월일시 입력',
              color: const Color(0xFF8B4513),
              onReturn: () {
                // 출생 정보 화면에서 돌아왔을 때 출생 정보 새로고침
                _loadSajuInfo();
              },
            ),
          ],
        ),
      ],
    );
  }



}
