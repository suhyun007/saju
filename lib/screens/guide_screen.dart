import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../models/saju_info.dart';
import '../l10n/app_localizations.dart';
import 'dart:developer' as dev;

class GuideScreen extends StatefulWidget {
  final ValueNotifier<int> activeTab;
  final int tabIndex;
  
  const GuideScreen({
    super.key,
    required this.activeTab,
    required this.tabIndex,
  });

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  SajuInfo? _sajuInfo;
  GuideResult? _guideResult;
  bool _loading = false;
  VoidCallback? _tabListener;

  @override
  void initState() {
    super.initState();
    _tabListener = () {
      if (widget.activeTab.value == widget.tabIndex) {
        _loadIfNeeded();
      }
    };
    widget.activeTab.addListener(_tabListener!);
    // 최초 선택된 탭과 일치하면 지연 호출
    if (widget.activeTab.value == widget.tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
    }
  }

  @override
  void dispose() {
    if (_tabListener != null) {
      widget.activeTab.removeListener(_tabListener!);
    }
    super.dispose();
  }

  void _loadIfNeeded() async {
    dev.log('[GuideScreen] _loadIfNeeded called - guideResult: $_guideResult, activeTab: ${widget.activeTab.value}, tabIndex: ${widget.tabIndex}');
    if (_loading) return;
    if (_guideResult != null) {
      dev.log('[GuideScreen] Already loaded, skipping');
      return;
    }
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab.value != widget.tabIndex) {
      dev.log('[GuideScreen] Different tab active, skipping');
      return;
    }
    
    // 캐시 먼저 확인
    final sajuInfo = await SajuService.loadSajuInfo();
    if (sajuInfo != null) {
      final locale = Localizations.localeOf(context).languageCode;
      final bool expired = sajuInfo.isTodayFortuneExpiredFor(locale);
      final String cachedContent = (sajuInfo.guide['overall'] ?? '').toString();
      
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('[GuideScreen] Cache found, using cached data');
        final cached = GuideResult(
          overall: (sajuInfo.guide['overall'] ?? '').toString(),
          love: (sajuInfo.guide['love'] ?? '').toString(),
          health: (sajuInfo.guide['health'] ?? '').toString(),
          study: (sajuInfo.guide['study'] ?? '').toString(),
          wealth: (sajuInfo.guide['wealth'] ?? '').toString(),
        );
        setState(() { _guideResult = cached; _loading = false; });
        return;
      }
    }
    
    dev.log('[GuideScreen] Starting load...');
    _loadTodayFortune();
  }

  Future<void> _loadTodayFortune() async {
    dev.log('[GuideScreen] _loadTodayFortune started');
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      dev.log('[GuideScreen] SajuInfo loaded: ${sajuInfo != null}');
      if (sajuInfo == null) {
        dev.log('[GuideScreen] No sajuInfo');
        setState(() {
          _guideResult = null; // 명시적으로 null 설정
        });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isTodayFortuneExpiredFor(locale);
      final String cachedContent = (sajuInfo.guide['overall'] ?? '').toString();
      
      dev.log('[GuideScreen] Cache check - expired: $expired, cachedContent length: ${cachedContent.length}');
      dev.log('[GuideScreen] Cache details - lastDate: ${sajuInfo.guide['lastFortuneDate']}, currentDate: ${sajuInfo.currentTodayDate}');
      dev.log('[GuideScreen] Cache details - lastFingerprint: ${sajuInfo.guide['lastRequestFingerprint']}, currentFingerprint: ${sajuInfo.currentRequestFingerprint}');
      dev.log('[GuideScreen] Cache details - lastLanguage: ${sajuInfo.guide['lastLanguage']}, currentLanguage: $locale');
      
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('[GuideScreen] Using cached data');
        final cached = GuideResult(
          overall: (sajuInfo.guide['overall'] ?? '').toString(),
          love: (sajuInfo.guide['love'] ?? '').toString(),
          health: (sajuInfo.guide['health'] ?? '').toString(),
          study: (sajuInfo.guide['study'] ?? '').toString(),
          wealth: (sajuInfo.guide['wealth'] ?? '').toString(),
        );
        setState(() { _guideResult = cached; _loading = false; });
        return;
      }
      // 만료 시에만 서버 호출 - 이때만 로딩 표시
      dev.log('[GuideScreen] Cache expired, calling server');
      dev.log('[GuideScreen] 🚨 API 호출 시도 - 과금 방지를 위해 주석 처리됨');
      setState(() { _loading = true; });

      // API 호출 주석 처리 (과금 방지)
      
      final result = await SajuApiService.fetchGuide(
        sajuInfo: sajuInfo,
        language: locale,
        forceNetwork: true,
      );
      

      await SajuService.saveSajuInfo(sajuInfo);
      setState(() { _guideResult = result; _loading = false; });
    } catch (e) {
      dev.log('[GuideScreen] Guide load failed: $e');
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_guideResult == null) {
          // 데이터 로드 시도 - API 호출 방지를 위해 주석 처리
          dev.log('[GuideScreen] _guideResult is null, showing message');
          // WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
          return const Center(child: Text('가이드 데이터가 없습니다.'));
        }

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
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 오늘의 가이드 헤더
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        size: 40,
                        color: const Color(0xFFB3B3FF),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppLocalizations.of(context)!.todayDetailTitle,
                        style: GoogleFonts.notoSans(
                          fontSize: 22,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        AppLocalizations.of(context)!.guideSubtitle,
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: textColor.withOpacity(0.9),
                          letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.3 : 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                // 빛과 희망
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/g5.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.lightAndHope,
                              style: GoogleFonts.notoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guideResult?.overall ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 성장과 집중
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/g2.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.growthAndFocus,
                              style: GoogleFonts.notoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guideResult?.study ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 풍요로움
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/g6.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.abundance,
                              style: GoogleFonts.notoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guideResult?.wealth ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 몸과 마음
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/g3.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.bodyAndMind,
                              style: GoogleFonts.notoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guideResult?.health ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 소중한 인연
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/g4.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.preciousRelationship,
                              style: GoogleFonts.notoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guideResult?.love ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                // 공유 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: _showShareOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A3A4A) : const Color(0xFFE8E8F5),
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_outward, size: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        const SizedBox(width: 3), // 간격을 2로 줄임
                          Text(
                            '공유',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
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

  void _showShareOptions() {
    final text = _getShareText();
    final subject = '오늘의 가이드';
    Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34, // 두 줄 텍스트를 위한 고정 높이
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
    );
  }

  String _getShareText() {
    if (_guideResult == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${l10n.todayDetailTitle}

    💕 ${l10n.preciousRelationship}: ${_guideResult!.love}

    💰 ${l10n.abundance}: ${_guideResult!.wealth}

    🧘 ${l10n.bodyAndMind}: ${_guideResult!.health}

    📚 ${l10n.growthAndFocus}: ${_guideResult!.study}

    ✨ ${l10n.lightAndHope}: ${_guideResult!.overall}

    ${l10n.shareAppPromotion}
    ''';
  }

  void _shareToGmail() {
    final text = _getShareText();
    final subject = '오늘의 가이드';
    
    // 디버깅을 위한 로그 추가
    dev.log('Gmail 공유 시도: $subject', name: 'GuideScreen');
    
    // 여러 방법을 순차적으로 시도
    _tryGmailMethods(subject, text);
  }

  Future<void> _tryGmailMethods(String subject, String text) async {
    // 시뮬레이터에서는 기본 공유 시트 사용
    if (kDebugMode) {
      dev.log('시뮬레이터 환경: 기본 공유 시트 사용', name: 'GuideScreen');
      await Share.share('Subject: $subject\n\n$text', subject: subject);
      return;
    }
    
    // 방법 1: Gmail 앱 직접 호출 (canLaunchUrl 우회)
    final gmailUri = Uri.parse('googlegmail://co?to=&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}');
    dev.log('Gmail URI 시도: $gmailUri', name: 'GuideScreen');
    
    try {
      dev.log('Gmail 앱 직접 실행 시도', name: 'GuideScreen');
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      dev.log('Gmail 앱 실행 성공', name: 'GuideScreen');
      return;
    } catch (e) {
      dev.log('Gmail 실행 실패: $e', name: 'GuideScreen');
    }
    
    // 방법 2: 기본 mailto (canLaunchUrl 우회)
    final mailtoUri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}');
    dev.log('Mailto URI 시도: $mailtoUri', name: 'GuideScreen');
    
    try {
      dev.log('Mailto 직접 실행 시도', name: 'GuideScreen');
      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      dev.log('Mailto 실행 성공', name: 'GuideScreen');
      return;
    } catch (e) {
      dev.log('Mailto 실행 실패: $e', name: 'GuideScreen');
    }
    
    // 방법 3: 기본 공유 기능
    dev.log('모든 방법 실패, 기본 공유 사용', name: 'GuideScreen');
    await Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  void _shareToFacebook() {
    final text = _getShareText();
    final uri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent('https://lunaverse.app')}&quote=${Uri.encodeComponent(text)}');
    _launchUrl(uri);
  }

  void _shareToFacebookMessage() {
    final text = _getShareText();
    final uri = Uri.parse('fb-messenger://share?link=${Uri.encodeComponent('https://lunaverse.app')}&app_id=YOUR_APP_ID');
    _launchUrl(uri);
  }

  void _shareToWhatsApp() {
    final text = _getShareText();
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    _launchUrl(uri);
  }

  void _shareToIMessage() {
    final text = _getShareText();
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    _launchUrl(uri);
  }

  void _shareToTelegram() {
    final text = _getShareText();
    final uri = Uri.parse('https://t.me/share/url?url=&text=${Uri.encodeComponent(text)}');
    _launchUrl(uri);
  }

  void _shareToKakaoTalk() {
    final text = _getShareText();
    // 카카오톡 앱 공유 URL
    final uri = Uri.parse('kakaotalk://sendurl?url=&text=${Uri.encodeComponent(text)}');
    _launchUrl(uri);
  }

  Future<void> _launchUrl(Uri uri) async {
    try {
      dev.log('URL 실행 시도: $uri', name: 'GuideScreen');
      
      // launchMode를 명시적으로 설정
      if (await canLaunchUrl(uri)) {
        dev.log('URL 실행 가능, 실행 중...', name: 'GuideScreen');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        dev.log('URL 실행 완료', name: 'GuideScreen');
      } else {
        dev.log('URL 실행 불가능, 기본 공유 기능 사용', name: 'GuideScreen');
        // URL을 열 수 없는 경우 기본 공유 기능 사용
        await Share.share(_getShareText());
      }
    } catch (e) {
      dev.log('URL 실행 오류: $e', name: 'GuideScreen');
      // 오류 발생 시 기본 공유 기능 사용
      await Share.share(_getShareText());
    }
  }

  Future<void> _launchUrlWithFallback(Uri primaryUri, Uri fallbackUri) async {
    try {
      // 먼저 Gmail 앱 시도
      if (await canLaunchUrl(primaryUri)) {
        await launchUrl(primaryUri);
      } else {
        // Gmail 앱이 없으면 기본 메일 앱 시도
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        } else {
          // 메일 앱도 없으면 기본 공유 기능 사용
          await Share.share(_getShareText());
        }
      }
    } catch (e) {
      // 오류 발생 시 기본 공유 기능 사용
      await Share.share(_getShareText());
    }
  }

  Future<void> _launchGmailWithMultipleFallbacks(List<Uri> gmailUris, Uri mailtoUri) async {
    try {
      // 여러 Gmail URL scheme 시도
      for (Uri gmailUri in gmailUris) {
        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri);
          return; // 성공하면 종료
        }
      }
      
      // Gmail 앱이 없으면 기본 메일 앱 시도
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        // 메일 앱도 없으면 기본 공유 기능 사용
        await Share.share(_getShareText());
      }
    } catch (e) {
      // 오류 발생 시 기본 공유 기능 사용
      await Share.share(_getShareText());
    }
  }

  void _copyToClipboard() {
    final text = _getShareText();
    Clipboard.setData(ClipboardData(text: text));
    
    // 복사 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.shareTextCopied,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}