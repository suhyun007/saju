import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/myPage.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_service.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // iOS: ATT 권한을 우선 요청해 광고 초기화 전에 사용자 선택을 반영
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (_) {}

  // Initialize Google Mobile Ads (ATT 응답 이후 초기화)
  await MobileAds.instance.initialize();
  AdService.preloadInterstitial();
  AdService.preloadNative();
  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await ThemeService.init();
  await NotificationService.init();
  
  print('main.dart - Supabase 초기화 시작');
  await SupabaseService.initialize();
  print('main.dart - Supabase 초기화 완료');
  
  // 방문 로그는 splash_screen에서 기록됨
  
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    print('=== SajuApp initState 시작 ===');
    WidgetsBinding.instance.addObserver(this);
    
    // LanguageService 인스턴스 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _languageService = Provider.of<LanguageService>(context, listen: false);
      print('=== LanguageService 인스턴스 가져옴: ${_languageService.currentLocale.languageCode} ===');
      
      // NotificationService에 GlobalKey 설정
      NotificationService.setNavigatorKey(_navigatorKey);
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
      fontFamily: 'NotoSansKR',
      scaffoldBackgroundColor: Colors.white,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.brown,
      primaryColor: const Color(0xFF3366FF),
      fontFamily: 'NotoSansKR',
      scaffoldBackgroundColor: Colors.transparent,
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
          title: 'LunaVerse 앱',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
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
            '/settings': (context) => const MyPage(),
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}