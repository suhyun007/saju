import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/saju_service.dart';
import '../services/friend_service.dart';
import '../models/saju_info.dart';
import '../models/friend_info.dart';
import '../utils/zodiac_utils.dart';
import 'saju_input_screen.dart';
import 'privacy_policy_screen.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with WidgetsBindingObserver {
  UserModel? _user;
  SajuInfo? _sajuInfo;
  FriendInfo? _friendInfo;
  String _selectedHour = '09';
  String _selectedMinute = '00';
  Timer? _permissionCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _user = AuthService.currentUser;
    _loadUser();
    _loadSajuInfo();
    _loadFriendInfo();
    _loadNotificationTime();
    AuthService.addAuthStateListener(_onAuthChanged);
    // 페이지 로드 시 시스템 알림 상태 확인 및 업데이트
    _checkAndUpdateNotificationStatus();
    
    // 주기 새로고침 제거: 포그라운드 복귀 시에만 동기화
  }

  @override
  void dispose() {
    _permissionCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    AuthService.removeAuthStateListener(_onAuthChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 알림 상태 새로고침
      print('=== MyPage: 앱이 포그라운드로 돌아옴 - 알림 상태 새로고침 ===');
      _checkAndUpdateNotificationStatus();
    }
  }

  // 시스템 알림 상태를 확인하고 앱 내부 설정을 업데이트
  Future<void> _checkAndUpdateNotificationStatus() async {
    try {
      print('=== MyPage: 시스템 알림 상태 확인 시작 ===');
      // 현재 앱 내부 설정 및 저장된 알림 시간 로그
      final currentEnabled = NotificationService.enabledNotifier.value;
      print('=== MyPage: 현재 앱 내부 알림 설정: $currentEnabled ===');
      final timeData = await NotificationService.getNotificationTime();
      print('=== MyPage: 저장된 알림 시간 ===');
      print('hour: ${timeData['hour']}, minute: ${timeData['minute']}');
      print('===========================');

      // 네이티브 권한 상태만 사용
      final status = await NotificationService.getPermissionStatus();
      print('=== MyPage: 네이티브 권한 상태: $status ===');

      if (status.isGranted) {
        print('=== MyPage: iOS 설정에서 알림 허용됨 - 현재 설정 유지 ===');
      } else {
        print('=== MyPage: iOS 설정에서 알림 거부됨 - 앱 내부 설정 OFF ===');
        await NotificationService.setEnabled(false, userAction: false);
        if (mounted) setState(() {});
        print('=== MyPage: 앱 내부 설정을 OFF로 변경 완료 ===');
      }
    } catch (e) {
      print('=== MyPage: 알림 상태 확인 오류: $e ===');
    }
  }

  void _onAuthChanged(UserModel? user) {
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadUser() async {
    final local = await AuthService.getUserFromLocal();
    if (!mounted) return;
    setState(() {
      _user = local ?? _user;
    });
  }

  Future<void> _loadSajuInfo() async {
    final sajuInfo = await SajuService.loadSajuInfo();
    if (!mounted) return;
    setState(() {
      _sajuInfo = sajuInfo;
    });
    print('=== 사주정보 로드 ===');
    print('사주정보: ${sajuInfo?.name}');
    print('별자리: ${sajuInfo?.zodiacSign}');
    print('==================');
  }

  Future<void> _loadFriendInfo() async {
    final friendInfo = await FriendService.loadFriendInfo();
    if (!mounted) return;
    setState(() {
      _friendInfo = friendInfo;
    });
    print('=== 친구정보 로드 ===');
    print('친구정보: ${friendInfo?.name}');
    print('별자리: ${friendInfo?.zodiacSign}');
    print('==================');
  }

  Future<void> _loadNotificationTime() async {
    final timeData = await NotificationService.getNotificationTime();
    // 진입 시 저장된 알림 시간 로깅
    print('=== MyPage: 저장된 알림 시간 ===');
    print('hour: ${timeData['hour']}, minute: ${timeData['minute']}');
    print('===========================');
    if (!mounted) return;
    setState(() {
      _selectedHour = timeData['hour']!.toString().padLeft(2, '0');
      _selectedMinute = timeData['minute']!.toString().padLeft(2, '0');
    });
  }

  Future<void> _signIn() async {
    final user = await AuthService.signInWithGoogle();
    if (!mounted) return;
    if (user != null) {
      setState(() {
        _user = user;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.displayName}님 환영합니다!')),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    setState(() {
      _user = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그아웃 되었습니다.')),
    );
  }

  String _themeSubtitle() {
    switch (ThemeService.currentMode) {
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
      case ThemeMode.system:
        return '시스템';
    }
  }

  void _showNotificationSheet() async {
    print('=== _showNotificationSheet 함수 호출됨 ===');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF2C1810).withOpacity(0.98) : Colors.white.withOpacity(0.98);
        final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
        final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: NotificationService.enabledNotifier,
            builder: (context, enabled, _) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        value: enabled,
                        activeColor: Colors.amber,
                        title: Text('알림 사용', style: GoogleFonts.notoSans(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          enabled ? '알림이 활성화되어 있습니다.' : '알림이 비활성화되어 있습니다.',
                          style: GoogleFonts.notoSans(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                        ),
                        secondary: Text(
                          enabled ? 'ON' : 'OFF',
                          style: GoogleFonts.notoSans(
                            color: enabled ? Colors.amber : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (value) async {
                          if (value) {
                            // ON 시도: 먼저 iOS 권한 상태 확인
                            print('=== 알림 ON 시도 ===');
                            final status = await NotificationService.getPermissionStatus();
                            print('=== iOS 권한 상태: $status ===');
                            if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('알림 권한 필요'),
                                    content: const Text('앱설정 > 알림에서 "알림 허용"을 켜주세요.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                                      TextButton(onPressed: () { Navigator.pop(context); NotificationService.navigateToAppSettings(); }, child: const Text('설정으로 이동')),
                                    ],
                                  ),
                                );
                              }
                              return; // 시스템 OFF → 내부 토글 변경 금지
                            }
                            // 권한 허용 → 내부 설정만 ON
                            await NotificationService.setEnabled(true, userAction: true);
                            setState(() {});
                            print('=== 시스템 허용: 내부 알림 ON 완료 ===');
                          } else {
                            // OFF로 바꾸는 경우 - 항상 가능
                            print('=== 알림 OFF 설정 ===');
                            await NotificationService.setEnabled(value, userAction: true);
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // 알림 시간 표시 (ON일 때만)
                      if (enabled)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Text(
                                '알림 시간: ',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                              ),
                              // 시간 선택 드롭다운
                              Container(
                                height: 32,
                                        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                child: DropdownButton<String>(
                                  value: _selectedHour,
                                  dropdownColor: isDark ? const Color(0xFF2C1810) : Colors.white,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                                  underline: Container(),
                                  items: List.generate(24, (index) {
                                    final hour = index.toString().padLeft(2, '0');
                                    return DropdownMenuItem<String>(
                                      value: hour,
                                      child: Text(hour),
                                    );
                                  }),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedHour = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Text(
                                ' : ',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                              ),
                              // 분 선택 드롭다운
                              Container(
                                height: 32,
                                        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                child: DropdownButton<String>(
                                  value: _selectedMinute,
                                  dropdownColor: isDark ? const Color(0xFF2C1810) : Colors.white,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                                  underline: Container(),
                                  items: List.generate(60, (index) {
                                    final minute = index.toString().padLeft(2, '0');
                                    return DropdownMenuItem<String>(
                                      value: minute,
                                      child: Text(minute),
                                    );
                                  }),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedMinute = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),
                      // 알림이 켜져있을 때만 확인 버튼 표시
                      if (enabled)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                              onPressed: () async {
                                // 알림 시간 저장
                                await NotificationService.updateNotificationTime(
                                  int.parse(_selectedHour),
                                  int.parse(_selectedMinute),
                                );
                                
                                // iOS 권한을 네이티브 기준으로 확인
                                final permissionStatus = await NotificationService.getPermissionStatus();
                                final appEnabled = NotificationService.enabledNotifier.value;

                                print('=== 알림 권한 상태 ===');
                                print('iOS 권한 상태: $permissionStatus');
                                print('앱 내부 설정: $appEnabled');
                                print('====================');

                                // 권한이 OFF면 설정 이동 안내
                                if (permissionStatus == PermissionStatus.denied ||
                                    permissionStatus == PermissionStatus.permanentlyDenied) {
                                  print('권한 요청 다이얼로그 표시 시도');
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('알림 권한 필요'),
                                        content: const Text('앱설정 > 알림에서 "알림 허용"을 켜주세요.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              print('취소 버튼 클릭됨');
                                              Navigator.pop(context);
                                            },
                                            child: const Text('취소'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              print('=== 설정으로 이동 버튼 클릭됨 ===');
                                              Navigator.pop(context);
                                              print('=== 다이얼로그 닫힘 ===');
                                              print('=== navigateToAppSettings 호출 시도 ===');
                                              NotificationService.navigateToAppSettings();
                                              print('=== navigateToAppSettings 호출 완료 ===');
                                            },
                                            child: const Text('설정으로 이동'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return;
                                }
                                
                                // 앱 내부 알림 설정이 꺼져있으면 알림을 보내지 않음
                                if (!appEnabled) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('알림이 비활성화되어 있습니다. 알림을 켜고 다시 시도해주세요.'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                
                                // 매일 알림 스케줄 등록
                                await NotificationService.scheduleDailyFortuneNotification();
                                print('=== 알림 스케줄 등록 완료 ===');

                                // 바텀 시트 닫기
                                Navigator.pop(context);
                                
                                // 성공 메시지 표시
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('알림 시간이 $_selectedHour:$_selectedMinute로 저장되었습니다.'),
                                      backgroundColor: Colors.amber,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('확인'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }



  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
        final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
        final textColor = isDark ? Colors.white : Colors.black;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '로그아웃 하시겠습니까?',
                style: GoogleFonts.notoSans(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '닫기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '로그아웃',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
        final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOptionTile('라이트', ThemeMode.light),
              _themeOptionTile('다크', ThemeMode.dark),
              _themeOptionTile('시스템', ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOptionTile(String label, ThemeMode mode) {
    final selected = ThemeService.currentMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final unselectedIconColor = isDark ? Colors.white54 : Colors.black54;
    
    return ListTile(
      onTap: () async {
        await ThemeService.setThemeMode(mode);
        if (!mounted) return;
        setState(() {});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('테마가 "$label"(으)로 변경되었습니다.')),
        );
      },
      title: Text(
        label,
        style: GoogleFonts.notoSans(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.amber)
          : Icon(Icons.circle_outlined, color: unselectedIconColor),
    );
  }

  Widget _buildAvatar({double size = 64}) {
    final radius = size / 2;
    if (_user?.photoURL != null && _user!.photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_user!.photoURL!),
        backgroundColor: Colors.white10,
      );
    }
    final hasName = _user?.displayName.isNotEmpty == true;
    final initial = hasName
        ? _user!.displayName[0].toUpperCase()
        : 'U';
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white12,
      child: Text(
        initial,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontSize: radius,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showProfileSheet() {
    if (_user == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
        final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
        final textColor = isDark ? Colors.white : Colors.black;
        final subtitleColor = isDark ? Colors.white70 : Colors.black54;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildAvatar(size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.displayName,
                          style: GoogleFonts.notoSans(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.email,
                          style: GoogleFonts.notoSans(color: subtitleColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow('로그인 제공자', (_user!.provider ?? 'unknown').toUpperCase()),
              _infoRow('사용자 ID', _user!.id),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final valueColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.notoSans(color: labelColor, fontSize: 12)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.notoSans(color: valueColor, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(top:20, left:20, right:20, bottom: 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      print('=== 마이페이지 뒤로가기 버튼 클릭됨 ===');
                      print('현재 context: $context');
                      print('Navigator.canPop: ${Navigator.canPop(context)}');
                      
                      // 단순히 뒤로가기
                      Navigator.pop(context);
                      print('=== Navigator.pop 호출 완료 ===');
                    },
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onBackground),
                  ),
                  const SizedBox(width: 0),
                  Text(
                    '마이페이지',
                    style: GoogleFonts.notoSans(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                  const SizedBox(height: 0),
                  _Section(
                    title: '관리',
                    children: [
                      _Tile(
                        icon: Icons.calendar_today,
                        title: _sajuInfo != null ? '${_sajuInfo!.name}님' : '사주정보',
                        subtitle: _sajuInfo != null
                            ? '${_sajuInfo!.yearText} ${_sajuInfo!.monthText} ${_sajuInfo!.dayText} ${_sajuInfo!.timeText}${_sajuInfo!.zodiacSign != null ? ' • ${_sajuInfo!.zodiacSign}' : ''}'
                            : '사주정보를 입력해 주세요',
                        zodiacSign: _sajuInfo?.zodiacSign,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SajuInputScreen(),
                            ),
                          ).then((_) {
                            _loadSajuInfo(); // 사주정보 화면에서 돌아올 때 새로고침
                          });
                        },
                      ),
                      _Tile(
                        icon: Icons.person,
                        title: _user == null ? '프로필' : (_user!.displayName ?? '사용자'),
                        subtitle: _user == null ? '구글에서 로그인' : (_user!.email ?? '이메일 없음'),
                        iconBackgroundColor: _user != null ? Colors.amber : null,
                        onTap: () {
                          if (_user == null) {
                            _signIn();
                          } else {
                            _showProfileSheet();
                          }
                        },
                      ),
                      if (_user != null)
                        _Tile(
                          icon: Icons.logout,
                          title: '로그아웃',
                          subtitle: '현재 계정에서 로그아웃',
                          onTap: () {
                            _showLogoutSheet();
                          },
                        ),
                      _SubSectionTitle('일반'),
                      _Tile(
                        icon: Icons.color_lens,
                        title: '테마',
                        subtitle: _themeSubtitle(),
                        onTap: _showThemePicker,
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: NotificationService.enabledNotifier,
                        builder: (context, enabled, _) {
                          return _Tile(
                            icon: Icons.notifications,
                            title: '알림',
                            subtitle: enabled ? 'ON' : 'OFF',
                            onTap: _showNotificationSheet,
                          );
                        },
                      ),
                      _SubSectionTitle('기타'),
                      _Tile(
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        subtitle: '개인정보보호방침',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final textColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
          const SizedBox(height: 0),
          ...children,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final String? zodiacSign;
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackgroundColor,
    this.zodiacSign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final iconBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final iconBorder = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final chevronColor = isDark ? Colors.white54 : Colors.black54;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBackgroundColor ?? iconBg,
                border: Border.all(color: iconBorder),
              ),
              child: zodiacSign != null
                  ? Builder(
                      builder: (context) {
                        final imagePath = ZodiacUtils.getZodiacImagePath(zodiacSign!);
                        print('=== 별자리 아이콘 로드 ===');
                        print('별자리: $zodiacSign');
                        print('이미지 경로: $imagePath');
                        print('========================');
                        return SvgPicture.asset(
                          imagePath,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                        );
                      },
                    )
                  : Icon(icon, color: textColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: chevronColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  final String title;
  const _SubSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 0),
      child:       Text(
        title,
        style: GoogleFonts.notoSans(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}


