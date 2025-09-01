import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/today_detail_screen.dart';
import 'screens/month_detail_screen.dart';
import 'screens/year_detail_screen.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  await NotificationService.init();
  runApp(const SajuApp());
}

class SajuApp extends StatefulWidget {
  const SajuApp({super.key});

  @override
  State<SajuApp> createState() => _SajuAppState();
}

class _SajuAppState extends State<SajuApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print('=== SajuApp initState 시작 ===');
    WidgetsBinding.instance.addObserver(this);
    print('=== WidgetsBindingObserver 등록 완료 ===');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('=== AppLifecycleState 변경: $state ===');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('=== 앱이 포그라운드로 돌아옴 ===');
        // 앱이 포그라운드로 돌아왔을 때 알림 권한 상태 확인
        NotificationService.onAppResumed();
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
        return MaterialApp(
          title: '사주앱',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/today-detail': (context) => const TodayDetailScreen(),
            '/month-detail': (context) => const MonthDetailScreen(),
            '/year-detail': (context) => const YearDetailScreen(),
          },
          // builder 제거: 테마의 scaffoldBackgroundColor 사용
        );
      },
    );
  }
}