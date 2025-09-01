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

class NotificationService {
  static const String _enabledKey = 'notifications_enabled';
  static const String _userDisabledKey = 'notifications_user_disabled';
  static const String _hourKey = 'notification_hour';
  static const String _minuteKey = 'notification_minute';
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(false);

  // 알림 제목 (세련된 톤으로 통일)
  static const String _dailyTitle = '별빛 소통';

  // 랜덤 바디 메시지 후보들
  static const List<String> _dailyBodyCandidates = [
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
    '오늘의 이야기 업데이트! 좋은 징조가 보여요',
    '마음이 가벼워지는 오늘의 조언',
    '행운 포인트가 깜빡! 확인해요',
    '오늘 더 반짝이도록, 설레임 ON',
    '하루의 흐름, 부드럽게 시작해요',
    '지금, 당신을 위한 한 줄 운세',
    '오늘의 길, 별이 살짝 비춰줘요',
    '스스로에게 건네는 작은 행운',
    '좋은 하루를 여는 열쇠, 여기요',
    '오늘의 기분 전환, 행복 한 컵',
    '오늘도 별이 당신 편이에요',
    '별빛이 이야기해주는 당신의 이야기를 들어보세요',
  ];

  static String _pickDailyBody() {
    final rand = Random();
    return _dailyBodyCandidates[rand.nextInt(_dailyBodyCandidates.length)];
  }

  static Future<void> init() async {
    print('NotificationService: 초기화 시작');
    
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    // Timezone init for scheduling (default to Asia/Seoul)
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Ensure Android channel exists
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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
      print('=== 앱 실행 시 알림 상태 ===');
      print('시스템 권한: $systemPermission');
      print('앱 내부 설정: $savedEnabled');
      print('==========================');
      
      if (savedEnabled == null) {
        // 처음 설치된 경우 - 시스템 권한에 따라 설정
        if (systemPermission) {
          await prefs.setBool(_enabledKey, true);
          enabledNotifier.value = true;
          print('NotificationService: 처음 설치 - 시스템 권한 있음, 알림을 켜짐으로 설정');
        } else {
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
          print('NotificationService: 처음 설치 - 시스템 권한 없음, 알림을 꺼짐으로 설정');
        }
      } else {
        // 기존 설정 로드 후 시스템 권한 확인
        if (savedEnabled && !systemPermission) {
          // 앱 내부는 켜져있지만 시스템 권한이 없는 경우 - 강제로 OFF
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
          print('NotificationService: 시스템 권한 없음으로 인해 앱 내부 설정을 OFF로 강제 변경');
        } else {
          // 정상적인 경우
          enabledNotifier.value = savedEnabled;
          print('NotificationService: 저장된 알림 설정 로드: $savedEnabled');
        }
      }
    } catch (e) {
      print('NotificationService: 설정 로드 실패: $e');
    }

    print('NotificationService: 앱 초기화 완료');
  }



  static Future<void> setEnabled(bool enable, {bool userAction = false}) async {
    print('NotificationService: 알림 설정 변경: $enable (사용자 액션: $userAction)');
    enabledNotifier.value = enable;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enable);
      
      // 사용자가 직접 끈 경우 기록
      if (userAction && !enable) {
        await prefs.setBool(_userDisabledKey, true);
        print('NotificationService: 사용자가 직접 비활성화함');
      } else if (userAction && enable) {
        await prefs.setBool(_userDisabledKey, false);
        print('NotificationService: 사용자가 직접 활성화함');
      }
      
      print('NotificationService: SharedPreferences에 저장됨: $enable');
    } catch (e) {
      print('NotificationService: SharedPreferences 저장 실패: $e');
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
      // Android 13+ requires POST_NOTIFICATIONS
      final status = await Permission.notification.status;
      print('NotificationService: Android 권한 상태: $status');
      return status.isGranted;
    } else {
      final status = await getPermissionStatus();
      print('NotificationService: iOS/macOS 권한 상태(네이티브): $status');
      return status.isGranted;
    }
  }

  // 설정에서 알림이 허용되어 있는지 확인 (앱 내부 설정과 무관)
  static Future<bool> isSystemNotificationEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      print('NotificationService: Android 시스템 알림 상태: $status');
      return status.isGranted;
    } else {
      final status = await getPermissionStatus();
      print('NotificationService: iOS/macOS 시스템 알림 상태(네이티브): $status');
      return status.isGranted;
    }
  }

  // iOS 설정에서 알림이 ON/OFF인지 확인하는 함수
  static Future<bool> isIOSNotificationEnabledInSettings() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final perm = await Permission.notification.status;
      print('NotificationService: iOS 설정에서 알림 상태 확인: $perm');
      
      // iOS 설정에서 알림이 ON인지 확인
      if (perm.isGranted) {
        print('NotificationService: iOS 설정에서 알림이 ON으로 설정됨');
        return true;
      } else if (perm.isDenied) {
        print('NotificationService: iOS 설정에서 알림이 OFF로 설정됨 (denied)');
        return false;
      } else if (perm.isPermanentlyDenied) {
        print('NotificationService: iOS 설정에서 알림이 OFF로 설정됨 (permanently denied)');
        return false;
      } else {
        print('NotificationService: iOS 설정에서 알림 상태를 알 수 없음: $perm');
        return false;
      }
    }
    return true; // Android는 기본적으로 true
  }

  // 실제 알림을 보내서 권한이 있는지 테스트 (알림 없이 권한만 확인)
  static Future<bool> _testNotificationPermission() async {
    try {
      print('NotificationService: 권한 확인 시작 (알림 없이)');
      
      // iOS에서는 permission_handler 결과만 사용
      if (Platform.isIOS || Platform.isMacOS) {
        final perm = await Permission.notification.status;
        print('NotificationService: iOS 권한 상태 확인: $perm');
        return perm.isGranted;
      }
      
      // Android에서는 기존 방식 사용
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        9999, // 다른 ID 사용
        '권한 테스트',
        '알림 권한이 정상적으로 작동합니다.',
        details,
      );
      
      print('NotificationService: 테스트 알림 전송 성공 - 권한 있음');
      return true;
    } catch (e) {
      print('NotificationService: 테스트 알림 전송 실패 - 권한 없음: $e');
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    print('NotificationService: 권한 요청 시작');
    final result = await Permission.notification.request();
    print('NotificationService: 권한 요청 결과: $result');
    return result.isGranted;
  }

  static Future<void> showTestNotification() async {
    print('NotificationService: 테스트 알림 시도');
    if (!enabledNotifier.value) {
      print('NotificationService: 알림이 비활성화되어 있음');
      return;
    }

    // iOS에서는 권한 확인을 우회하고 바로 알림 시도
    print('NotificationService: 권한 확인 우회하고 바로 알림 전송 시도');

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1001,
      '알림 테스트',
      '이것은 테스트 알림입니다.',
      details,
    );
    print('NotificationService: 테스트 알림 전송 완료');
  }

  // 저장된 알림 설정을 다시 로드
  static Future<void> refreshPermissionStatus() async {
    print('NotificationService: 저장된 설정 새로고침');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_enabledKey);
      
      // 시스템 권한 확인
      final systemPermission = await hasPermission();
      print('=== 앱 재개 시 알림 상태 ===');
      print('시스템 권한: $systemPermission');
      print('앱 내부 설정: $savedEnabled');
      print('==========================');
      
      if (savedEnabled == null) {
        // 처음 설치된 경우 - 시스템 권한에 따라 설정
        if (systemPermission) {
          await prefs.setBool(_enabledKey, true);
          enabledNotifier.value = true;
          print('NotificationService: 처음 설치 - 시스템 권한 있음, 알림을 켜짐으로 설정');
        } else {
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
          print('NotificationService: 처음 설치 - 시스템 권한 없음, 알림을 꺼짐으로 설정');
        }
      } else {
        // 기존 설정 로드 후 시스템 권한 확인
        if (savedEnabled && !systemPermission) {
          // 앱 내부는 켜져있지만 시스템 권한이 없는 경우 - 강제로 OFF
          await prefs.setBool(_enabledKey, false);
          enabledNotifier.value = false;
          print('NotificationService: 시스템 권한 없음으로 인해 앱 내부 설정을 OFF로 강제 변경');
        } else {
          // 정상적인 경우
          enabledNotifier.value = savedEnabled;
          print('NotificationService: 저장된 알림 설정 로드: $savedEnabled');
        }
      }
    } catch (e) {
      print('NotificationService: 설정 로드 실패: $e');
    }
  }

  // 설정으로 이동하는 함수
  static Future<void> navigateToAppSettings() async {
    if (Platform.isAndroid) {
      // Android에서는 시스템 설정으로 이동
      try {
        await openAppSettings();
        print('NotificationService: Android 앱 설정으로 이동 완료');
      } catch (e) {
        print('NotificationService: Android 앱 설정 이동 실패: $e');
        // fallback: 권한 요청
        try {
          await Permission.notification.request();
          print('NotificationService: fallback - 권한 요청');
        } catch (e2) {
          print('NotificationService: 권한 요청도 실패: $e2');
        }
      }
    } else {
      // iOS에서는 app-settings: URL 사용
      const url = 'app-settings:';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        print('NotificationService: iOS 앱 설정으로 이동 완료');
      } else {
        print('NotificationService: iOS 설정 화면을 열 수 없습니다.');
        // fallback: 권한 요청
        try {
          await Permission.notification.request();
          print('NotificationService: fallback - 권한 요청');
        } catch (e) {
          print('NotificationService: 권한 요청도 실패: $e');
        }
      }
    }
  }

  // 권한 상태를 자세히 확인하는 함수
  static Future<PermissionStatus> getPermissionStatus() async {
    // Prefer native UNUserNotificationCenter via MethodChannel on iOS
    if (Platform.isIOS || Platform.isMacOS) {
      final MethodChannel channel = const MethodChannel('app.notificationStatus');
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
        // flutter_local_notifications의 iOS 구현을 통해 직접 확인
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final result = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print('NotificationService: iOS 직접 권한 확인 결과: $result');
          return result ?? false;
        }
      } catch (e) {
        print('NotificationService: iOS 직접 권한 확인 실패: $e');
      }
    }
    return false;
  }

  // 실제 알림 테스트만으로 권한 확인 (가장 정확한 방법)
  static Future<bool> checkPermissionByTest() async {
    print('NotificationService: 실제 알림 테스트로 권한 확인 시작');
    return await _testNotificationPermission();
  }

  // 앱이 포그라운드로 돌아왔을 때 호출할 함수
  static Future<void> onAppResumed() async {
    print('NotificationService: 앱이 포그라운드로 돌아옴 - 권한 상태 확인');
    
    try {
      // 시스템에서 알림이 허용되어 있는지 확인
      final systemEnabled = await isSystemNotificationEnabled();
      print('NotificationService: 시스템 알림 허용 여부: $systemEnabled');
      
      if (!systemEnabled) {
        // 시스템에서 알림이 OFF된 경우 - 앱 내부 설정도 OFF로 변경
        print('NotificationService: 시스템에서 알림이 OFF됨 - 앱 내부 설정을 OFF로 변경');
        await setEnabled(false, userAction: false);
      } else {
        // 시스템에서 알림이 허용된 경우 - 현재 설정 유지
        print('NotificationService: 시스템에서 알림이 허용됨 - 현재 설정 유지');
      }
    } catch (e) {
      print('NotificationService: onAppResumed 오류: $e');
    }
  }

  // 알림 시간 가져오기
  static Future<Map<String, int>> getNotificationTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt(_hourKey) ?? 9;
      final minute = prefs.getInt(_minuteKey) ?? 0;
      return {'hour': hour, 'minute': minute};
    } catch (e) {
      print('NotificationService: 알림 시간 로드 실패: $e');
      return {'hour': 9, 'minute': 0};
    }
  }

  // 알림 시간 업데이트
  static Future<void> updateNotificationTime(int hour, int minute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_hourKey, hour);
      await prefs.setInt(_minuteKey, minute);
      print('NotificationService: 알림 시간 업데이트: $hour:$minute');
    } catch (e) {
      print('NotificationService: 알림 시간 저장 실패: $e');
    }
  }

  // 운세 알림 보내기
  static Future<void> showFortuneNotification() async {
    print('NotificationService: 운세 알림 시도');
    if (!enabledNotifier.value) {
      print('NotificationService: 알림이 비활성화되어 있음');
      return;
    }
    // 권한 확인 우회 (임시)
    print('NotificationService: 권한 확인 우회하고 바로 알림 전송 시도');

    const androidDetails = AndroidNotificationDetails(
      'fortune_channel',
      'Fortune Notifications',
      channelDescription: 'Channel for daily fortune notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1002,
      _dailyTitle,
      '${_pickDailyBody()}\n별빛이 이야기해주는 당신의 이야기를 들어보세요',
      details,
    );
    print('NotificationService: 운세 알림 전송 완료');
  }

  // 매일 지정 시간에 알림 스케줄
  static Future<void> scheduleDailyFortuneNotification() async {
    final time = await getNotificationTime();
    final hour = time['hour'] ?? 9;
    final minute = time['minute'] ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'fortune_channel',
      'Fortune Notifications',
      channelDescription: 'Channel for daily fortune notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      2001,
      _dailyTitle,
      '${_pickDailyBody()}\n별빛이 이야기해주는 당신의 이야기를 들어보세요',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('NotificationService: 스케줄 등록 완료 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
  }
}


