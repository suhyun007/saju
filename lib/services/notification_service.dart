import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Removed due to namespace issues
import '../l10n/app_localizations.dart';
import 'supabase_service.dart';

class NotificationService {
  static const String _enabledKey = 'notifications_enabled';
  static const String _userDisabledKey = 'notifications_user_disabled';
  static const String _hourKey = 'notification_hour';
  static const String _minuteKey = 'notification_minute';
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(false);
  
  // 로컬라이징을 위한 GlobalKey
  static GlobalKey<NavigatorState>? _navigatorKey;

  // 알림 제목 (로컬라이징)
  static String _getDailyTitle() {
    if (_navigatorKey?.currentContext != null) {
      final l10n = AppLocalizations.of(_navigatorKey!.currentContext!);
      return l10n?.notificationTitle ?? 'Moonlight Chat';
    }
    return 'Moonlight Chat'; // 폴백
  }

  // 푸시 메시지 (로컬라이징)
  static String _getPushPixMessage() {
    if (_navigatorKey?.currentContext != null) {
      final l10n = AppLocalizations.of(_navigatorKey!.currentContext!);
      return l10n?.pushPixMessage ?? 'Listen to your story told by moonlight';
    }
    return 'Listen to your story told by moonlight'; // 폴백
  }
  
  // GlobalKey 설정 함수
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // 랜덤 바디 메시지 후보들 (Supabase에서 가져오기)
  static Future<List<String>> _getDailyBodyCandidates() async {
    try {
      // Supabase에서 알림 메시지 조회
      final messages = await SupabaseService.getNotificationMessages();
      
      if (messages.isEmpty) {
        // 폴백: 기본 메시지
        return _getFallbackMessages();
      }
      
      // 현재 언어 설정에 따라 메시지 선택
      if (_navigatorKey?.currentContext != null) {
        final locale = Localizations.localeOf(_navigatorKey!.currentContext!);
        print('NotificationService: 현재 언어 코드: ${locale.languageCode}');
        
        // 모든 메시지를 하나의 배열로 합치기
        List<String> allMessages = [];
        for (var message in messages) {
          String? languageMessages;
          
          switch (locale.languageCode) {
            case 'ko':
              languageMessages = message['ko_msg'] as String?;
            case 'en':
              languageMessages = message['en_msg'] as String?;
            case 'ja':
              languageMessages = message['ja_msg'] as String?;
            case 'zh':
              languageMessages = message['zh_msg'] as String?;
            default:
              languageMessages = message['en_msg'] as String?;
          }
          
          if (languageMessages != null && languageMessages.isNotEmpty) {
            allMessages.addAll(SupabaseService.parseMessages(languageMessages));
          }
        }
        
        return allMessages.isNotEmpty ? allMessages : _getFallbackMessages();
      }
      
      return _getFallbackMessages();
    } catch (e) {
      return _getFallbackMessages();
    }
  }
  
  // 폴백 메시지 (오프라인 또는 오류 시)
  static List<String> _getFallbackMessages() {
    return [
      '기분 좋은 하루의 시작을 알려드릴게요',
      '오늘의 이야기, 잠깐 확인해볼까요?',
      '당신을 위한 작은 힌트가 도착했어요',
      '오늘 당신은 살짝 미소짓고 있어요',
      '별이 전하는 오늘의 메시지',
      '행운의 타이밍, 지금 체크하세요',
      '오늘 하루, 별자리 가이드 열렸어요',
      '하루를 여는 작은 영감 한 스푼',
      '오늘의 키워드, 지금 만나보세요',
      '당신의 오늘, 별이 응원해요',
    ];
  }

  static Future<String> _pickDailyBody() async {
    final rand = Random();
    final candidates = await _getDailyBodyCandidates();
    return candidates[rand.nextInt(candidates.length)];
  }

  static Future<void> init() async {
    // Android Alarm Manager 초기화
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
    
    // 권한 상태 확인 (초기화 전에 확인)
    bool hasNotificationPermission = false;
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final status = await Permission.notification.status;
        hasNotificationPermission = status.isGranted;
      } catch (e) {
        hasNotificationPermission = false;
      }
    }
    
    // Android 초기화 설정
    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    
    // iOS 초기화 설정 - 권한이 이미 있으면 요청하지 않음
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: !hasNotificationPermission,
      requestBadgePermission: !hasNotificationPermission,
      requestSoundPermission: !hasNotificationPermission,
    );
    
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    
    // 초기화 + 알림 탭 콜백 설정
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 탭 시 처리
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Timezone init for scheduling (device local timezone)
    await _setupLocalTimezone();

    // Ensure Android channel exists
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'default_channel',
      '기본 알림',
      description: '앱의 기본 알림 채널입니다.',
      importance: Importance.max,
    ));
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'test_channel',
      'Test Notifications',
      description: 'Channel for test notifications',
      importance: Importance.defaultImportance,
    ));
    // Channel for fortune notifications
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'fortune_channel',
      'Fortune Notifications',
      description: 'Channel for daily fortune notifications',
      importance: Importance.max,
    ));
    

    // 저장된 알림 설정 로드 및 시스템 권한 확인
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_enabledKey);
      
      // 시스템 권한 확인
      final systemPermission = await hasPermission();
      
      if (savedEnabled == null) {
        // 처음 설치된 경우 - 권한 상태 확인 후 없을 때만 요청
        if (Platform.isAndroid) {
          // 이미 권한이 있는지 먼저 확인
          final currentStatus = await Permission.notification.status;
          print('NotificationService: init - Android 알림 권한 상태: $currentStatus');
          if (currentStatus.isGranted) {
            // 권한이 이미 있으면 요청하지 않음
            print('NotificationService: init - 알림 권한 이미 허용됨, 요청하지 않음');
            await prefs.setBool(_enabledKey, true);
            enabledNotifier.value = true;
          } else {
            // 권한이 없을 때만 요청
            print('NotificationService: init - 알림 권한 없음, 요청 시작');
            final granted = await Permission.notification.request();
            print('NotificationService: init - 알림 권한 요청 결과: $granted');
            
            if (granted.isGranted) {
              // 정확한 알람 권한 확인 및 요청 (Android 12+)
              try {
                final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
                if (!scheduleExactAlarmStatus.isGranted) {
                  await Permission.scheduleExactAlarm.request();
                }
              } catch (e) {
                // 권한 요청 실패 무시
              }
              
              await prefs.setBool(_enabledKey, true);
              enabledNotifier.value = true;
            } else {
              await prefs.setBool(_enabledKey, false);
              enabledNotifier.value = false;
            }
          }
        } else {
          // iOS는 시스템 권한에 따라 설정
          if (systemPermission) {
            await prefs.setBool(_enabledKey, true);
            enabledNotifier.value = true;
            print('NotificationService: 처음 설치 - 시스템 권한 있음, 알림을 켜짐으로 설정');
          } else {
            await prefs.setBool(_enabledKey, false);
            enabledNotifier.value = false;
            print('NotificationService: 처음 설치 - 시스템 권한 없음, 알림을 꺼짐으로 설정');
          }
        }
      } else {
        // 기존 설정 로드 후 시스템 권한 확인
        print('NotificationService: init - 저장된 알림 설정: $savedEnabled, 시스템 권한: $systemPermission');
        if (savedEnabled && !systemPermission) {
          // 앱 내부는 켜져있지만 시스템 권한이 없는 경우 - 강제로 OFF
          print('NotificationService: init - 앱 설정은 ON이지만 시스템 권한 없음, OFF로 변경');
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
        } else {
          // 권한이 있으면 설정값 그대로 사용
          print('NotificationService: init - 알림 설정 로드: $savedEnabled');
          enabledNotifier.value = savedEnabled;
        }
      }
    } catch (e) {
      // 설정 로드 실패 무시
    }
  }
  static Future<void> _setupLocalTimezone() async {
    try {
      tzdata.initializeTimeZones();
      
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final offsetHours = offset.inHours;
      
      String localTz;
      if (offsetHours == 9) {
        localTz = 'Asia/Seoul';
      } else if (offsetHours == -8) {
        localTz = 'America/Los_Angeles';
      } else if (offsetHours == -5) {
        localTz = 'America/New_York';
      } else if (offsetHours == 0) {
        localTz = 'Europe/London';
      } else if (offsetHours == 1) {
        localTz = 'Europe/Paris';
      } else if (offsetHours == 8) {
        localTz = 'Asia/Shanghai';
      } else if (offsetHours == -9) {
        localTz = 'America/Anchorage';
      } else if (offsetHours == -7) {
        localTz = 'America/Denver';
      } else if (offsetHours == -6) {
        localTz = 'America/Chicago';
      } else {
        localTz = 'UTC';
      }
      
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {
        // 시간대 설정 실패 무시
      }
    }
  }



  static Future<void> setEnabled(bool enable, {bool userAction = false}) async {
    enabledNotifier.value = enable;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enable);
      
      if (userAction && !enable) {
        await prefs.setBool(_userDisabledKey, true);
      } else if (userAction && enable) {
        await prefs.setBool(_userDisabledKey, false);
        
        // 알림을 ON으로 켤 때 Android 12+ 정확한 알람 권한 확인 및 요청
        if (Platform.isAndroid) {
          try {
            final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
            if (!scheduleExactAlarmStatus.isGranted) {
              // 권한 요청
              await Permission.scheduleExactAlarm.request();
              // 다시 확인
              final statusAfterRequest = await Permission.scheduleExactAlarm.status;
              if (!statusAfterRequest.isGranted) {
                // 권한이 없으면 알림 설정을 다시 OFF로 변경
                print('NotificationService: setEnabled - SCHEDULE_EXACT_ALARM 권한 없음 - 알림 설정을 OFF로 변경');
                enabledNotifier.value = false;
                await prefs.setBool(_enabledKey, false);
                return;
              }
            }
            // 권한이 있으면 알림 스케줄링
            await scheduleDailyFortuneNotification();
          } catch (e) {
            // 권한 확인 실패 시 알림 OFF
            print('NotificationService: setEnabled - SCHEDULE_EXACT_ALARM 권한 확인 실패 - 알림 설정을 OFF로 변경: $e');
            enabledNotifier.value = false;
            await prefs.setBool(_enabledKey, false);
          }
        }
      }
    } catch (e) {
      // 저장 실패 무시
    }
  }

  // 사용자가 수동으로 비활성화했는지 확인
  static Future<bool> isUserDisabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_userDisabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else {
      final status = await getPermissionStatus();
      return status.isGranted;
    }
  }

  // 설정에서 알림이 허용되어 있는지 확인 (앱 내부 설정과 무관)
  static Future<bool> isSystemNotificationEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else {
      final status = await getPermissionStatus();
      return status.isGranted;
    }
  }

  // iOS 설정에서 알림이 ON/OFF인지 확인하는 함수
  static Future<bool> isIOSNotificationEnabledInSettings() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final perm = await Permission.notification.status;
      return perm.isGranted;
    }
    return true;
  }

  // 실제 알림을 보내서 권한이 있는지 테스트 (알림 없이 권한만 확인)
  static Future<bool> _testNotificationPermission() async {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final perm = await Permission.notification.status;
        return perm.isGranted;
      }
      
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        9999,
        '권한 테스트',
        '알림 권한이 정상적으로 작동합니다.',
        details,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  // static Future<void> showTestNotification() async {
  //   try {
  //     const androidDetails = AndroidNotificationDetails(
  //       'test_channel',
  //       'Test Notifications',
  //       channelDescription: 'Channel for test notifications',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );
  //     const iosDetails = DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentSound: true,
  //       presentBadge: true,
  //     );
  //     const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  //     await _plugin.show(
  //       1001,
  //       '🔔 알림 테스트',
  //       '이것은 테스트 알림입니다.',
  //       details,
  //     );
  //   } catch (e) {
  //     // 테스트 알림 실패 무시
  //   }
  // }

  static Future<void> refreshPermissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_enabledKey);
      final systemPermission = await hasPermission();
      
      if (savedEnabled == null) {
        if (systemPermission) {
          await prefs.setBool(_enabledKey, true);
          enabledNotifier.value = true;
        } else {
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
        }
      } else {
        if (savedEnabled && !systemPermission) {
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
        } else {
          enabledNotifier.value = savedEnabled;
        }
      }
    } catch (e) {
      // 설정 로드 실패 무시
    }
  }

  // 설정으로 이동하는 함수
  static Future<void> navigateToAppSettings() async {
    try {
      if (Platform.isAndroid) {
        await openAppSettings();
      } else {
        const url = 'app-settings:';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      }
    } catch (e) {
      // 설정 화면 열기 실패 무시
    }
  }

  // 권한 상태를 자세히 확인하는 함수
  static Future<PermissionStatus> getPermissionStatus() async {
    // Prefer native UNUserNotificationCenter via MethodChannel on iOS
    if (Platform.isIOS || Platform.isMacOS) {
      const MethodChannel channel = MethodChannel('app.notificationStatus');
      try {
        final String status = await channel.invokeMethod('getAuthorizationStatus');
        // Map native statuses to PermissionStatus
        switch (status) {
          case 'authorized':
          case 'provisional':
          case 'ephemeral':
            return PermissionStatus.granted;
          case 'denied':
            return PermissionStatus.denied;
          case 'notDetermined':
            return PermissionStatus.denied;
          default:
            return await Permission.notification.status;
        }
      } catch (_) {
        return await Permission.notification.status;
      }
    }
    return await Permission.notification.status;
  }

  // iOS에서 더 정확한 권한 상태 확인 (실제 테스트 포함)
  static Future<Map<String, dynamic>> getDetailedPermissionStatus() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final perm = await Permission.notification.status;
      print('NotificationService: iOS 권한 상태 상세 확인: $perm');
      
      // 실제 알림 테스트로 권한 확인
      final canSendTest = await _testNotificationPermission();
      
      return {
        'permissionStatus': perm,
        'canSendNotification': canSendTest,
        'isGranted': perm.isGranted,
        'isDenied': perm.isDenied,
        'isPermanentlyDenied': perm.isPermanentlyDenied,
      };
    } else {
      final perm = await Permission.notification.status;
      return {
        'permissionStatus': perm,
        'canSendNotification': perm.isGranted,
        'isGranted': perm.isGranted,
        'isDenied': perm.isDenied,
        'isPermanentlyDenied': perm.isPermanentlyDenied,
      };
    }
  }

  // iOS에서 UNUserNotificationCenter를 직접 사용하여 권한 확인
  static Future<bool> checkIOSNotificationPermissionDirectly() async {
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final result = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return result ?? false;
        }
      } catch (e) {
        // 권한 확인 실패 무시
      }
    }
    return false;
  }

  static Future<bool> checkPermissionByTest() async {
    return await _testNotificationPermission();
  }

  static Future<void> onAppResumed() async {
    await _setupLocalTimezone();
    
    try {
      final systemEnabled = await isSystemNotificationEnabled();
      if (!systemEnabled) {
        await setEnabled(false, userAction: false);
        return;
      }
      
      // Android 12+ 정확한 알람 권한 확인
      if (Platform.isAndroid) {
        try {
          final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
          if (!scheduleExactAlarmStatus.isGranted) {
            // 권한이 없으면 알림 설정을 OFF로 변경
            print('NotificationService: onAppResumed - SCHEDULE_EXACT_ALARM 권한 없음 - 알림 설정을 OFF로 변경');
            await setEnabled(false, userAction: false);
          }
        } catch (e) {
          // 권한 확인 실패 무시
        }
      }
    } catch (e) {
      // 권한 확인 실패 무시
    }
  }

  static Future<Map<String, int>> getNotificationTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt(_hourKey) ?? 9;
      final minute = prefs.getInt(_minuteKey) ?? 0;
      return {'hour': hour, 'minute': minute};
    } catch (e) {
      return {'hour': 9, 'minute': 0};
    }
  }

  static Future<void> updateNotificationTime(int hour, int minute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_hourKey, hour);
      await prefs.setInt(_minuteKey, minute);
      
      if (enabledNotifier.value) {
        await scheduleDailyFortuneNotification();
      }
    } catch (e) {
      // 알림 시간 저장 실패 무시
    }
  }

  static Future<void> showFortuneNotification() async {
    if (!enabledNotifier.value) return;

    final androidDetails = AndroidNotificationDetails(
      'fortune_channel',
      'Fortune Notifications',
      channelDescription: 'Channel for daily fortune notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_push_icon', // 상단 작은 아이콘
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final body = await _pickDailyBody();
    await _plugin.show(
      1002,
      _getDailyTitle(),
      '$body\n${_getPushPixMessage()}',
      details,
    );
  }

  static Future<void> scheduleDailyFortuneNotification() async {
    // Android 12+ 정확한 알람 권한 확인
    if (Platform.isAndroid) {
      try {
        final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
        if (!scheduleExactAlarmStatus.isGranted) {
          // 권한 요청
          await Permission.scheduleExactAlarm.request();
          // 다시 확인
          final statusAfterRequest = await Permission.scheduleExactAlarm.status;
          if (!statusAfterRequest.isGranted) {
            // 권한이 없으면 알림 설정을 OFF로 변경
            print('NotificationService: SCHEDULE_EXACT_ALARM 권한 없음 - 알림 설정을 OFF로 변경');
            await setEnabled(false, userAction: false);
            return; // 스케줄링 중단
          }
        }
      } catch (e) {
        // 알람 권한 확인 실패 시 알림 설정 OFF
        print('NotificationService: SCHEDULE_EXACT_ALARM 권한 확인 실패 - 알림 설정을 OFF로 변경: $e');
        await setEnabled(false, userAction: false);
        return; // 스케줄링 중단
      }
    }
    
    // 스케줄 직전에 시간대 보장
    await _setupLocalTimezone();
    final time = await getNotificationTime();
    final hour = time['hour'] ?? 9;
    final minute = time['minute'] ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final body = await _pickDailyBody();
    
    final androidDetailsWithIcon = AndroidNotificationDetails(
      'fortune_channel',
      'Fortune Notifications',
      channelDescription: 'Channel for daily fortune notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_push_icon', // 상단 작은 아이콘
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    final detailsWithIcon = NotificationDetails(android: androidDetailsWithIcon, iOS: iosDetails);
    
    await _plugin.zonedSchedule(
      2001,
      _getDailyTitle(),
      '$body\n${_getPushPixMessage()}',
      scheduled,
      detailsWithIcon,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // 백그라운드 알림 탭 처리
  }
}


