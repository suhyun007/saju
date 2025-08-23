import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _enabledKey = 'notifications_enabled';
  static const String _userDisabledKey = 'notifications_user_disabled';
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(false);

  static Future<void> init() async {
    print('NotificationService: 초기화 시작');
    
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    // Ensure Android channel exists
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'test_channel',
      'Test Notifications',
      description: 'Channel for test notifications',
      importance: Importance.defaultImportance,
    ));

    // 저장된 알림 설정 로드 (처음 설치 시에는 켜짐으로 설정)
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_enabledKey);
      
      if (savedEnabled == null) {
        // 처음 설치된 경우 - 켜짐으로 설정
        await prefs.setBool(_enabledKey, true);
        enabledNotifier.value = true;
        print('NotificationService: 처음 설치 - 알림을 켜짐으로 설정');
      } else {
        // 기존 설정 로드
        enabledNotifier.value = savedEnabled;
        print('NotificationService: 저장된 알림 설정 로드: $savedEnabled');
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
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS permission check
      final perm = await Permission.notification.status;
      print('NotificationService: iOS 권한 상태: $perm');
      
      // iOS에서는 권한 상태를 정확히 확인
      return perm.isGranted;
    }
    return true;
  }

  // 실제 알림을 보내서 권한이 있는지 테스트
  static Future<bool> _testNotificationPermission() async {
    try {
      print('NotificationService: 실제 알림 테스트 시작');
      
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

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
    final permissionGranted = await hasPermission();
    if (!permissionGranted) {
      print('NotificationService: 권한이 없어서 알림을 보낼 수 없음');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
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
      
      if (savedEnabled == null) {
        // 처음 설치된 경우 - 켜짐으로 설정
        await prefs.setBool(_enabledKey, true);
        enabledNotifier.value = true;
        print('NotificationService: 처음 설치 - 알림을 켜짐으로 설정');
      } else {
        // 기존 설정 로드
        enabledNotifier.value = savedEnabled;
        print('NotificationService: 저장된 설정 로드: $savedEnabled');
      }
    } catch (e) {
      print('NotificationService: 설정 로드 실패: $e');
    }
  }

  // 설정으로 이동하는 함수
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // 권한 상태를 자세히 확인하는 함수
  static Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.notification.status;
  }

  // 앱이 포그라운드로 돌아왔을 때 호출할 함수
  static Future<void> onAppResumed() async {
    print('NotificationService: 앱이 포그라운드로 돌아옴 - 권한 상태 확인');
    await refreshPermissionStatus();
  }
}


