import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/today_detail_screen.dart';
import 'screens/month_detail_screen.dart';
import 'screens/year_detail_screen.dart';
import 'screens/myPage.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  await NotificationService.init();
  
  final languageService = LanguageService();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => languageService,
      child: const SajuApp(),
    ),
  );
}

class SajuApp extends StatefulWidget {
  const SajuApp({super.key});

  @override
  State<SajuApp> createState() => _SajuAppState();
}

class _SajuAppState extends State<SajuApp> with WidgetsBindingObserver {
  late LanguageService _languageService;
  
  @override
  void initState() {
    super.initState();
    print('=== SajuApp initState 시작 ===');
    WidgetsBinding.instance.addObserver(this);
    
    // LanguageService 인스턴스 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _languageService = Provider.of<LanguageService>(context, listen: false);
      print('=== LanguageService 인스턴스 가져옴: ${_languageService.currentLocale.languageCode} ===');
    });
    
    print('=== WidgetsBindingObserver 등록 완료 ===');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('=== AppLifecycleState 변경: $state ===');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('=== 앱이 포그라운드로 돌아옴 ===');
        // 앱이 포그라운드로 돌아왔을 때 알림 권한 상태 확인
        NotificationService.onAppResumed();
        
        // 시스템 언어 변경 감지 및 자동 업데이트
        final languageService = Provider.of<LanguageService>(context, listen: false);
        await languageService.checkAndUpdateSystemLanguage();
        break;
      case AppLifecycleState.inactive:
        print('=== 앱이 비활성화됨 ===');
        break;
      case AppLifecycleState.paused:
        print('=== 앱이 백그라운드로 이동됨 ===');
        break;
      case AppLifecycleState.detached:
        print('=== 앱이 완전히 종료됨 ===');
        break;
      case AppLifecycleState.hidden:
        print('=== 앱이 숨겨짐 ===');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.brown,
      primaryColor: const Color(0xFF3366FF),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      scaffoldBackgroundColor: Colors.white,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.brown,
      primaryColor: const Color(0xFF3366FF),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      scaffoldBackgroundColor: Colors.black,
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, mode, _) {
        print('=== MaterialApp 빌드 ===');
        print('현재 테마 모드: $mode');
        
        // LanguageService를 직접 사용
        final languageService = Provider.of<LanguageService>(context, listen: true);
        print('=== MaterialApp 빌드 - 현재 로케일: ${languageService.currentLocale.languageCode} ===');
        print('=== 지원하는 로케일: ${LanguageService.supportedLocales.map((l) => l.languageCode).join(', ')} ===');
        print('=== AppLocalizations.delegate: ${AppLocalizations.delegate} ===');
        
        return MaterialApp(
          title: '사주앱',
          debugShowCheckedModeBanner: false,
          locale: languageService.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/today-detail': (context) => const TodayDetailScreen(),
            '/month-detail': (context) => const MonthDetailScreen(),
            '/year-detail': (context) => const YearDetailScreen(),
            '/settings': (context) => const MyPage(),
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}