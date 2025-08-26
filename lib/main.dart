import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 알림 권한 상태 확인
      NotificationService.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.brown,
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      scaffoldBackgroundColor: Colors.white,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.brown,
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF2C1810),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: '사주앱',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}