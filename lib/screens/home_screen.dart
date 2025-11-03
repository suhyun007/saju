import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'dart:async';
// import '../widgets/feature_button.dart';
import '../screens/favorite_screen.dart';
import '../screens/episode_screen.dart';
import '../screens/reading_screen.dart';
import '../services/saju_service.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../models/saju_info.dart';
import '../models/user_model.dart';
import '../screens/myPage.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 말풍선 본체 (둥근 사각형)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 20),
      const Radius.circular(20),
    );
    path.addRRect(rect);
    
    // 말풍선 꼬리 (아래쪽 중앙)
    final tailPath = Path();
    tailPath.moveTo(size.width * 0.5 - 10, size.height - 20);
    tailPath.lineTo(size.width * 0.5, size.height);
    tailPath.lineTo(size.width * 0.5 + 10, size.height - 20);
    tailPath.close();
    
    path.addPath(tailPath, Offset.zero);
    
    canvas.drawPath(path, paint);
    
    // 그림자 효과
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    final shadowPath = Path();
    shadowPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width, size.height - 18),
      const Radius.circular(20),
    ));
    
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {

  SajuInfo? _sajuInfo;
  // bool _isLoading = true; // 미사용
  late final WebViewController _webController;
  bool _showWebView = false;
  // UserModel? _currentUser; // 미사용
  late TabController _tabController;
  // subtitle animations removed
  int _currentTabIndex = 0;
  final ValueNotifier<int> _activeTab = ValueNotifier<int>(0);
  Timer? _autoAdCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadUserInfo();
    _loadSajuInfoAndAutoLoadFortune();
    AuthService.addAuthStateListener(_onAuthStateChanged);
    _startAutoAdCheck();
    // subtitle animation removed
  }

  void _startAutoAdCheck() {
    // 5분마다 4분 쿨다운 체크 및 자동 광고 표시 (쿨다운이 4분이므로 5분 간격으로 체크)
    _autoAdCheckTimer?.cancel();
    _autoAdCheckTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (mounted && context.mounted) {
        AdService.checkAndShowAutoInterstitial(context);
      }
    });
  }

  void _stopAutoAdCheck() {
    _autoAdCheckTimer?.cancel();
    _autoAdCheckTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 광고 체크
      if (mounted && context.mounted) {
        AdService.checkAndShowAutoInterstitial(context);
      }
      _startAutoAdCheck();
    } else if (state == AppLifecycleState.paused) {
      // 백그라운드로 가면 타이머 중지
      _stopAutoAdCheck();
    }
  }

  @override
  void dispose() {
    _stopAutoAdCheck();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    // subtitle controller removed
    AuthService.removeAuthStateListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged(UserModel? user) {}

  String _formatNameWithHonorific(String name) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ko': return '$name님'; // 한국어: 님
      case 'en': return name;     // 영어: 호칭 없음
      case 'zh': return name;  // 중국어: 호칭 없음
      case 'ja': return '$nameさん'; // 일본어: さん
      default: return '$name님';
    }
  }

  String _formatNameWithLengthLimit(String name) {
    if (name.length > 16) {
      return '${name.substring(0, 16)}...';
    }
    return _formatNameWithHonorific(name);
  }

  String _guestLabel() {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'ko':
        return '손님';
      case 'ja':
        return 'ゲスト';
      case 'zh':
        return '访客';
      default:
        return 'Guest';
    }
  }

  Future<void> _loadUserInfo() async {}

  // _loadSajuInfo 제거 (미사용)

  Future<void> _loadSajuInfoAndAutoLoadFortune() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (mounted) {
        setState(() {
          _sajuInfo = sajuInfo;
        });
        
        // 자동 탭 선택 제거 - 사용자가 직접 탭을 클릭할 때만 API 호출
      }
    } catch (e) {
      print('출생 정보 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark
                  ? 'assets/design/launch_bg.png' // 다크 모드
                  : 'assets/design/bg4.png',      // 라이트 모드
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            // subtitle removed
            
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
      ),
    );
  }

  // welcome subtitle removed

  Widget _buildWebView() {
    return WebViewWidget(controller: _webController);
  }

  // _buildBottomNavigationBar 제거됨 (AppBottomNavBar로 대체)

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
  
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.only(top: 6),
          transform: Matrix4.translationValues(0, -4, 0),
          child: Row(
            children: [
              // 즐겨찾기 탭 (index 0)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _handleTabTap(0),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.tabFavorites ?? '즐겨찾기',
                          style: GoogleFonts.notoSans(
                            fontSize: _currentTabIndex == 0 ? 18 : 17,
                            fontWeight: _currentTabIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                            color: _currentTabIndex == 0
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.1 : 0,
                          ),
                          strutStyle: StrutStyle(
                            fontSize: _currentTabIndex == 0 ? 18 : 17,
                            height: 1.0,
                            leading: 0.0,
                            forceStrutHeight: true,
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentTabIndex == 0)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFA09D91),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              // 시 낭독 탭 (index 1)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _handleTabTap(1),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.tabPoetry ?? '시 낭독',
                          style: GoogleFonts.notoSans(
                            fontSize: _currentTabIndex == 1 ? 18 : 17,
                            fontWeight: _currentTabIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                            color: _currentTabIndex == 1
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          strutStyle: StrutStyle(
                            fontSize: _currentTabIndex == 1 ? 18 : 17,
                            height: 1.0,
                            leading: 0.0,
                            forceStrutHeight: true,
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentTabIndex == 1)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFA09D91),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              // 에피소드 탭 (index 2)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _handleTabTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.tabEpisode ?? '에피소드',
                          style: GoogleFonts.notoSans(
                            fontSize: _currentTabIndex == 2 ? 18 : 17,
                            fontWeight: _currentTabIndex == 2 ? FontWeight.w600 : FontWeight.w500,
                            color: _currentTabIndex == 2
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          strutStyle: StrutStyle(
                            fontSize: _currentTabIndex == 2 ? 18 : 17,
                            height: 1.0,
                            leading: 0.0,
                            forceStrutHeight: true,
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentTabIndex == 2)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFA09D91),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FavoriteScreen(),
        PoetryScreen(activeTab: _activeTab, tabIndex: 1),
        EpisodeScreen(activeTab: _activeTab, tabIndex: 2),
        // MonthScreen(),
        // YearScreen(),
      ],
    );
  }

  // _buildMainContent 미사용 삭제

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20,20),
      child: Container(
        child: Row(
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text(
                          'LunaVerse',
                          style: GoogleFonts.josefinSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            //fontStyle: FontStyle.italic,
                            //height: 1,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFFCCCCFF)
                                : const Color(0xFF2A3A80), // 더 딥 네이비
                            letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.7 : -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 출생 정보 이름 표시 (저장된 정보가 있으면 이름, 없으면 로컬라이즈된 손님)
          Container(
            margin: const EdgeInsets.only(right: 0),
            child: Text(
              _sajuInfo != null && _sajuInfo!.name.isNotEmpty 
                ? _formatNameWithLengthLimit(_sajuInfo!.name)
                : _guestLabel(),
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _showAboutBottomSheet();
            },
            icon: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), width: 1),
              ),
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
            ),
            tooltip: 'About LunaVerse',
          ),
          Transform.translate(
            offset: const Offset(-10, 0),
            child: IconButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyPage(),
                  ),
                );
                // 마이페이지에서 돌아올 때 사용자 정보 새로고침
                _loadSajuInfoAndAutoLoadFortune();
              },
              icon: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), width: 1),
                ),
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 22,
                ),
              ),
              tooltip: '환경설정',
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showAboutBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            width: MediaQuery.of(context).size.width * 0.9,
            child: CustomPaint(
              painter: SpeechBubblePainter(),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF1a2139) // 더 진한 네이비
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.aboutLunaVerseTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.aboutLunaVerseContent,
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF06123C) // 다크모드: 진한 네이비
                            : Theme.of(context).colorScheme.primary, // 라이트모드: 기존 색상
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.confirmButton ?? 'Confirm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
  }

  void _handleTabTap(int index) async {
    // 탭 클릭 로그 기록
    String menuType = '';
    switch (index) {
      case 0:
        menuType = 'favorites'; // 즐겨찾기
        break;
      case 1:
        menuType = 'poetry'; // 시 낭독
        break;
      case 2:
        menuType = 'episode'; // 에피소드
        break;
    }
    AnalyticsService.logMenuClick(menuType);
    
    // 탭 컨트롤러 업데이트
    _tabController.animateTo(index);
    
    // 현재 탭 인덱스 업데이트
    setState(() {
      _currentTabIndex = index;
    });
    _activeTab.value = index; // 선택된 탭 알림
    // 탭 전환 시 전면 광고 시도 (2분 쿨다운 정책 적용)
    // 확률 기반으로 시도 (30%)
    const double probability = 0.30;
    if (Random().nextDouble() < probability) {
      AdService.maybeShowInterstitial(context);
    }
    
    // WebView 표시 여부 설정
    if (index == 0) {
      setState(() {
        _showWebView = false;
      });
      /*if (kDebugMode) {
        dev.log('Episode tab tapped', name: 'HomeScreen');
        dev.debugger(when: kDebugMode, message: 'Episode tab tapped');
      }*/
    } else if (index == 1) {
      setState(() {
        _showWebView = false;
      });
    } else if (index == 2) {
      setState(() {
        _showWebView = false;
      });
    }
  }

  // _showErrorDialog 제거 (미사용)

  // _buildFeatureButtons 제거 (미사용)



  // 미사용 함수 제거됨
}
