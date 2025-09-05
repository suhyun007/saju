import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/feature_button.dart';
import '../screens/guide_screen.dart';
import '../screens/detail_story_screen.dart';
import '../screens/reading_screen.dart';
// import '../screens/month_screen.dart'; // 주석처리
// import '../screens/year_screen.dart'; // 주석처리
// import '../widgets/kma_weather_chip.dart'; // 날씨 정보 주석처리

import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../services/auth_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../models/user_model.dart';
import '../screens/myPage.dart';
import '../l10n/app_localizations.dart';
import 'saju_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

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
    _loadSajuInfoAndAutoLoadFortune();
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

  String _formatNameWithHonorific(String name) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ko': return '$name님'; // 한국어: 님
      case 'en': return name;     // 영어: 호칭 없음
      case 'zh': return '$name';  // 중국어: 호칭 없음
      case 'ja': return '$nameさん'; // 일본어: さん
      default: return '$name님';
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

  Future<void> _loadSajuInfoAndAutoLoadFortune() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (mounted) {
        setState(() {
          _sajuInfo = sajuInfo;
        });
        
        // 사주 정보가 있으면 자동으로 오늘의 운세 로드
        if (sajuInfo != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleTabTap(0);
          });
        }
      }
    } catch (e) {
      print('출생 정보 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: isDark ? BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/design/launch_bg.png'),
            fit: BoxFit.cover,
          ),
        ) : null,
        child: SafeArea(
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
      ),
      /*bottomNavigationBar: SajuNavigator(
        currentTabIndex: _currentTabIndex,
        onTap: (index) {
          if (index == 0) {
            _handleTabTap(0);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPage()),
            );
          }
        },
      ),*/
    );
  }

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
              // 에피소드 탭
              Expanded(
                flex: 1, // 더 크게
                child: GestureDetector(
                  onTap: () => _handleTabTap(0),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.tabEpisode ?? '에피소드',
                          style: GoogleFonts.notoSans(
                            fontSize: _currentTabIndex == 0 ? 18 : 17,
                            fontWeight: _currentTabIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                            color: _currentTabIndex == 0
                                ? Theme.of(context).colorScheme.onBackground
                                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
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
                            margin: const EdgeInsets.only(top: 12),  // 에피소드 탭 라인바 위치 조정
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),  // 선택되지 않은 탭 라인바 위치 조정
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )

                      ],
                    ),
                  ),
                ),
              ),
              // 시 낭독 탭
              Expanded(
                flex: 1, // 더 크게
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
                                ? Theme.of(context).colorScheme.onBackground
                                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
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
                            margin: const EdgeInsets.only(top: 12),  // 시 낭독 탭 라인바 위치 조정
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),  // 선택되지 않은 탭 라인바 위치 조정
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )

                      ],
                    ),
                  ),
                ),
              ),
              // 오늘의 가이드 탭 (더 작게)
              Expanded(
                flex: 1, // 더 작게
                child: GestureDetector(
                  onTap: () => _handleTabTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.tabTodayGuide ?? '오늘의 가이드',
                          style: GoogleFonts.notoSans(
                            fontSize: _currentTabIndex == 2 ? 18 : 17,
                            fontWeight: _currentTabIndex == 2 ? FontWeight.w600 : FontWeight.w500,
                            color: _currentTabIndex == 2
                                ? Theme.of(context).colorScheme.onBackground
                                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.1 : 0,
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
                            margin: const EdgeInsets.only(top: 12),  // 가이드 탭 라인바 위치 조정
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 13),  // 선택되지 않은 탭 라인바 위치 조정
                            height: 1,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFCCCCCC),
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
      children: [
        const DetailStoryScreen(),
        const ReadingScreen(),
        const GuideScreen(),
        // MonthScreen(),
        // YearScreen(),
      ],
    );
  }

  Widget _buildMainContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: isDark ? null : BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20,20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 로고 이미지
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark 
                            ? 'assets/design/32b.png'
                            : 'assets/design/32.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text(
                          'LunaVerse',
                          style: GoogleFonts.josefinSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            //fontStyle: FontStyle.italic,
                            //height: 1,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFFCCCCFF)
                                : const Color(0xFF3D4B91), //0xFF1A3A8A
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
          // 출생 정보 이름 표시 (저장된 정보가 있으면 이름, 없으면 손님)
          Container(
            margin: const EdgeInsets.only(right: 0),
            child: Text(
              _sajuInfo != null && _sajuInfo!.name.isNotEmpty 
                ? _formatNameWithHonorific(_sajuInfo!.name)
                : '손님',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
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
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                border: Border.all(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3), width: 1),
              ),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onBackground,
                size: 22,
              ),
            ),
            tooltip: '환경설정',
          ),
        ],
      ),
    );
  }

  void _handleTabTap(int index) async {
    // 탭 컨트롤러 업데이트
    _tabController.animateTo(index);
    
    // 현재 탭 인덱스 업데이트
    setState(() {
      _currentTabIndex = index;
    });
    
    // WebView 표시 여부 설정
    if (index == 0) {
      setState(() {
        _showWebView = false;
      });
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            '오류',
            style: GoogleFonts.notoSans(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.notoSans(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: GoogleFonts.notoSans(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
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



  // 서버 응답을 해당 운세 데이터에 저장
  Future<void> _saveFortuneData(int index, SajuApiResponse response) async {
    try {
      Map<String, dynamic> fortuneData = {};
      
      // 서버 응답에서 운세 데이터 추출 (실제 API 응답 구조에 맞게 수정 필요)
      if (response.data != null && response.data!.todayFortune != null) {
        final todayFortune = response.data!.todayFortune!;
        fortuneData = {
          'overall': todayFortune.overall ?? '',
          'love': todayFortune.love ?? '',
          'health': todayFortune.health ?? '',
          'study': todayFortune.study ?? '',
          'wealth': todayFortune.wealth ?? '',
          'luckyItem': todayFortune.luckyItem ?? '',
          'todayOutfit': todayFortune.todayOutfit ?? '',
          'serverResponse': response.toJson().toString(),
        };
      }

      // 해당 운세 타입에 따라 저장
      bool success = false;
      switch (index) {
        case 0: // 오늘의 운세
          success = await SajuService.updateTodayFortune(fortuneData);
          break;
        case 1: // 오늘의 이야기
          // 오늘의 이야기는 데이터 저장이 필요하지 않음
          success = true;
          break;
        case 2: // 오늘의 낭독시
          // 오늘의 낭독시는 데이터 저장이 필요하지 않음
          success = true;
          break;
        // case 1: // 이달의 운세
        //   success = await SajuService.updateMonthFortune(fortuneData);
        //   break;
        // case 2: // 올해의 운세
        //   success = await SajuService.updateYearFortune(fortuneData);
        //   break;
      }

      if (success) {
        print('운세 데이터 저장 성공');
        // 저장된 데이터로 _sajuInfo 업데이트
        await _loadSajuInfo();
      } else {
        print('운세 데이터 저장 실패');
      }
    } catch (e) {
      print('운세 데이터 저장 중 오류: $e');
    }
  }
}
