import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = AuthService.currentUser;
    _loadUser();
    AuthService.addAuthStateListener(_onAuthChanged);
    // 페이지 로드 시 알림 권한 상태 새로고침
    NotificationService.refreshPermissionStatus();
  }

  @override
  void dispose() {
    AuthService.removeAuthStateListener(_onAuthChanged);
    super.dispose();
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810).withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: NotificationService.enabledNotifier,
            builder: (context, enabled, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: enabled,
                    activeColor: Colors.amber,
                    title: Text('알림 사용', style: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      enabled ? '알림이 활성화되어 있습니다.' : '알림이 비활성화되어 있습니다.',
                      style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12),
                    ),
                    onChanged: (value) async {
                      // 단순한 토글 - 권한 확인 없이 바로 설정 변경
                      await NotificationService.setEnabled(value, userAction: true);
                      setState(() {});
                      
                      if (value) {
                        // 켜짐으로 설정했을 때만 테스트 알림 보내기
                        await NotificationService.showTestNotification();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: enabled ? () => NotificationService.showTestNotification() : null,
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('테스트 알림 보내기'),
                        ),
                      ),
                    ],
                  ),
                ],
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
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810).withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '로그아웃 하시겠습니까?',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
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
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810).withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
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
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.amber)
          : const Icon(Icons.circle_outlined, color: Colors.white54),
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
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810).withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
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
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.email,
                          style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 13),
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
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF4A2C1A),
              Color(0xFF8B4513),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(top:20, left:20, right:20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '환경설정',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _Section(
                      title: '계정',
                      children: [
                        _Tile(
                          icon: Icons.person,
                          title: '프로필',
                          subtitle: _user == null ? '구글에서 로그인' : '로그인됨',
                          onTap: () {
                            if (_user == null) {
                              _signIn();
                            } else {
                              _showProfileSheet();
                            }
                          },
                        ),
                        // 로그인된 경우에만 로그아웃 표시
                        if (_user != null)
                          _Tile(
                            icon: Icons.logout,
                            title: '로그아웃',
                            subtitle: '현재 계정에서 로그아웃',
                            onTap: () {
                              _showLogoutSheet();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: '일반',
                      children: [
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
                              subtitle: enabled ? '켜짐' : '꺼짐',
                              onTap: _showNotificationSheet,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: '정보',
                      children: [
                        _Tile(
                          icon: Icons.info_outline,
                          title: '앱 정보',
                          subtitle: '버전, 약관, 오픈소스 라이선스',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
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
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}


