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
import '../screens/myPage.dart';

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
            tooltip: '마이페이지',
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
          children: const [
            FeatureButton(
              icon: Icons.calendar_today,
              title: '사주 정보',
              subtitle: '생년월일시 입력',
              color: Color(0xFF8B4513),
            ),
          ],
        ),
      ],
    );
  }



}
