import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/feature_button.dart';
import '../screens/today_screen.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
              Theme.of(context).scaffoldBackgroundColor,
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
        currentIndex: _currentTabIndex == 0 ? 0 : 1, // 현재 탭에 따라 인덱스 설정
        onTap: (index) {
          if (index == 1) {
            // My 페이지로 이동 - push로 이동하여 뒤로가기 가능하게
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPage()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.grey.shade700,
        unselectedItemColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
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
            activeIcon: Icon(Icons.person_outline),
            label: 'My',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      transform: Matrix4.translationValues(0, -4, 0),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFFCCCCFF)
                  : const Color(0xFF3D4B91),
              width: 3,
            ),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Theme.of(context).colorScheme.onBackground,
        unselectedLabelColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          _handleTabTap(index);
        },
        tabs: const [
          Tab(text: '오늘의 가이드'),
          Tab(text: '에피소드'),
          Tab(text: '시 낭독'),
          // Tab(text: '이달의 운세'),
          // Tab(text: '올해의 운세'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: const [
        TodayScreen(),
        DetailStoryScreen(),
        ReadingScreen(),
        // MonthScreen(),
        // YearScreen(),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AstroStar',
                  style: GoogleFonts.josefinSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    //fontStyle: FontStyle.italic,
                    height: 1.1,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFFCCCCFF)
                        : const Color(0xFF3D4B91), //0xFF1A3A8A
                    letterSpacing: -1,
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                border: Border.all(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3), width: 1),
              ),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onBackground,
                size: 18,
              ),
            ),
            tooltip: '환경설정',
          ),
        ],
      ),
    );
  }

  void _handleTabTap(int index) async {
    if (_sajuInfo == null) {
      return;
    }
    
    // todayFortune['study'] 값 출력
    print('=== todayFortune study 값 ===');
    print('study 값: ${_sajuInfo!.todayFortune['study']}');
    print('study 값 타입: ${_sajuInfo!.todayFortune['study'].runtimeType}');
    print('study 값이 null인가?: ${_sajuInfo!.todayFortune['study'] == null}');
    print('study 값이 빈 문자열인가?: ${_sajuInfo!.todayFortune['study'] == ''}');
    print('============================');
    
    print('=== monthFortune study 값 ===');
    print('study 값: ${_sajuInfo!.monthFortune['study']}');
    print('study 값 타입: ${_sajuInfo!.monthFortune['study'].runtimeType}');
    print('study 값이 null인가?: ${_sajuInfo!.monthFortune['study'] == null}');
    print('study 값이 빈 문자열인가?: ${_sajuInfo!.monthFortune['study'] == ''}');
    print('============================');
    // study 값 확인용 알림창
    //_showErrorDialog('study 값: ${_sajuInfo!.todayFortune['study']}');
    
    // study 값이 없으면 하드코딩으로 추가
    //if (_sajuInfo!.todayFortune['study'] == null || _sajuInfo!.todayFortune['study'].toString().isEmpty) {
      await SajuService.updateTodayFortune({
        'overall': '오늘은 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요. 나무가 아닌 숲을 바라보아야 하는 하루입니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 난관을 극복하고 원하는 바를 성취하려면 스스로를 믿고 적극적이고 결단력 있게 나아가야 합니다.',
        'love': '로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
        'health': '건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
        'study': '집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
        'wealth': '재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
        'luckyItem': '살구색, 모자, 남쪽, 7, 11, 맛집',
        'todayOutfit': '편안한 캐주얼 복장',
        'advice': '긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
        'overallScore': '70',
        'healthScore': '80',
        'loveScore': '50',
        'wealthScore': '60',
        'studyScore': '30',
      });
      
      // 업데이트된 SajuInfo 다시 로드
      await _loadSajuInfo();
    //}

  if (_sajuInfo!.monthFortune['study'] == null || _sajuInfo!.monthFortune['study'].toString().isEmpty) {
    await SajuService.updateMonthFortune({
      'overall': '이번달은 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요. 나무가 아닌 숲을 바라보아야 하는 하루입니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 난관을 극복하고 원하는 바를 성취하려면 스스로를 믿고 적극적이고 결단력 있게 나아가야 합니다.',
      'love': '이번달은 로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
      'health': '이번달은 건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
      'study': '이번달은 집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
      'wealth': '이번달은 재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
      'luckyItem': '이번달은 살구색, 모자, 남쪽, 7, 11, 맛집',
      'monthOutfit': '이번달은 편안한 캐주얼 복장',
      'advice': '이번달은 긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
    });
  }
  if (_sajuInfo!.yearFortune['study'] == null || _sajuInfo!.todayFortune['study'].toString().isEmpty) {
    await SajuService.updateYearFortune({
      'overall': '이번년도는 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요. 나무가 아닌 숲을 바라보아야 하는 하루입니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 목표를 향해 나아가는 데 있어 변덕스러운 마음이 일의 추진을 방해할 수 있습니다. 난관을 극복하고 원하는 바를 성취하려면 스스로를 믿고 적극적이고 결단력 있게 나아가야 합니다.',
      'love': '이번년도는 로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
      'health': '이번년도는 건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
      'study': '이번년도는 집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
      'wealth': '이번년도는 재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
      'luckyItem': '이번년도는 살구색, 모자, 남쪽, 7, 11, 맛집',
      'yearOutfit': '이번년도는 편안한 캐주얼 복장',
      'advice': '이번년도는 긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
    });
  }

    // 업데이트된 SajuInfo 다시 로드
    await _loadSajuInfo();

    final List<String> fortuneTypes = [
      '오늘의 가이드',
      '에피소드',
      '시 낭독',
      // '이달의 운세', 
      // '올해의 운세',
    ];
    
    final String selectedFortune = fortuneTypes[index];
    print('탭 클릭: $selectedFortune');
    print('index: $index');
    
    // 날짜 비교하여 서버 호출 여부 결정
    bool needServerCall = false;
    
    switch (index) {
      case 0: // 오늘의 운세
        needServerCall = _sajuInfo!.isTodayFortuneExpired;
        print('오늘의 운세 - 현재날짜: ${_sajuInfo!.currentTodayDate}, 저장된날짜: ${_sajuInfo!.todayFortune['lastFortuneDate']}');
        print('서버 호출 필요: $needServerCall');
        break;
      case 1: // 오늘의 이야기
        // 오늘의 이야기는 서버 호출이 필요하지 않음
        needServerCall = false;
        print('오늘의 이야기 - 서버 호출 불필요');
        break;
      case 2: // 오늘의 낭독시
        // 오늘의 낭독시는 서버 호출이 필요하지 않음
        needServerCall = false;
        print('오늘의 시 낭독 - 서버 호출 불필요');
        break;
      // case 1: // 이달의 운세
      //   needServerCall = _sajuInfo!.isMonthFortuneExpired;
      //   print('이달의 운세 - 현재달: ${_sajuInfo!.currentMonthDate}, 저장된달: ${_sajuInfo!.monthFortune['lastFortuneDate']}');
      //   print('서버 호출 필요: $needServerCall');
      //   break;
      // case 2: // 올해의 운세
      //   needServerCall = _sajuInfo!.isYearFortuneExpired;
      //   print('올해의 운세 - 현재년도: ${_sajuInfo!.currentYearDate}, 저장된년도: ${_sajuInfo!.yearFortune['lastFortuneDate']}');
      //   print('서버 호출 필요: $needServerCall');
      //   break;
    }
    
    if (!needServerCall) {
      print('저장된 운세 데이터가 최신이므로 서버 호출을 건너뜁니다.');
      return;
    }
    
    try {
      // API 호출
      final response = await SajuApiService.getSajuAnalysis(_sajuInfo!);
      
      if (response.success && response.data != null) {
        setState(() {
          _sajuAnalysis = response;
        });
        
        // 서버 응답을 해당 운세 데이터에 저장
        await _saveFortuneData(index, response);
              }
    } catch (e) {
      print('API 호출 중 오류: $e');
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
