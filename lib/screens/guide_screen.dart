import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/saju_service.dart';
import '../services/saju_api_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
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
  TodayFortune? _todayFortune;
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

  void _loadIfNeeded() {
    dev.log('[GuideScreen] _loadIfNeeded called - todayFortune: $_todayFortune, activeTab: ${widget.activeTab.value}, tabIndex: ${widget.tabIndex}');
    if (_loading) return;
    if (_todayFortune != null) {
      dev.log('[GuideScreen] Already loaded, skipping');
      return;
    }
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab.value != widget.tabIndex) {
      dev.log('[GuideScreen] Different tab active, skipping');
      return;
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
          _todayFortune = null; // 명시적으로 null 설정
        });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isTodayFortuneExpiredFor(locale);
      final String cachedContent = (sajuInfo.todayFortune['overall'] ?? '').toString();
      
      dev.log('[GuideScreen] Cache check - expired: $expired, cachedContent length: ${cachedContent.length}');
      dev.log('[GuideScreen] Cache details - lastDate: ${sajuInfo.todayFortune['lastFortuneDate']}, currentDate: ${sajuInfo.currentTodayDate}');
      dev.log('[GuideScreen] Cache details - lastFingerprint: ${sajuInfo.todayFortune['lastRequestFingerprint']}, currentFingerprint: ${sajuInfo.currentRequestFingerprint}');
      dev.log('[GuideScreen] Cache details - lastLanguage: ${sajuInfo.todayFortune['lastLanguage']}, currentLanguage: $locale');
      
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('[GuideScreen] Using cached data');
        final cached = _createTodayFortuneFromSajuInfo(sajuInfo);
        setState(() { _todayFortune = cached; _loading = false; });
        return;
      }

      // 만료 시에만 서버 호출 - 이때만 로딩 표시
      dev.log('[GuideScreen] Cache expired, calling server');
      setState(() { _loading = true; });
      final result = await SajuApiService.fetchGuide(
        sajuInfo: sajuInfo,
        language: locale,
        forceNetwork: true,
      );
      // 캐시에 저장 (날짜/지문/언어)
      sajuInfo.todayFortune['overall'] = result.overall;
      sajuInfo.todayFortune['love'] = result.love;
      sajuInfo.todayFortune['health'] = result.health;
      sajuInfo.todayFortune['study'] = result.study;
      sajuInfo.todayFortune['wealth'] = result.wealth;
      sajuInfo.todayFortune['lastFortuneDate'] = sajuInfo.currentTodayDate;
      sajuInfo.todayFortune['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
      sajuInfo.todayFortune['lastLanguage'] = locale;
      await SajuService.saveSajuInfo(sajuInfo);
      final todayFortune = TodayFortune(
        overall: result.overall,
        love: result.love,
        health: result.health,
        study: result.study,
        wealth: result.wealth,
      );
      setState(() { _todayFortune = todayFortune; _loading = false; });
    } catch (e) {
      dev.log('[GuideScreen] Guide load failed: $e');
      setState(() { _loading = false; });
    }
  }

  TodayFortune _createTodayFortuneFromSajuInfo(SajuInfo sajuInfo) {
    return TodayFortune(
      overall: sajuInfo.todayFortune['overall'] ?? '오늘은 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요.',
      love: sajuInfo.todayFortune['love'] ?? '로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
      health: sajuInfo.todayFortune['health'] ?? '건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
      study: sajuInfo.todayFortune['study'] ?? '집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
      wealth: sajuInfo.todayFortune['wealth'] ?? '재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
      luckyItem: sajuInfo.todayFortune['luckyItem'] ?? '살구색, 모자, 남쪽, 7, 11, 맛집',
      todayOutfit: sajuInfo.todayFortune['todayOutfit'] ?? '편안한 캐주얼 복장',
      advice: sajuInfo.todayFortune['advice'] ?? '긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
      overallScore: int.tryParse(sajuInfo.todayFortune['overallScore'] ?? '70'),
      healthScore: int.tryParse(sajuInfo.todayFortune['healthScore'] ?? '80'),
      loveScore: int.tryParse(sajuInfo.todayFortune['loveScore'] ?? '50'),
      wealthScore: int.tryParse(sajuInfo.todayFortune['wealthScore'] ?? '60'),
      studyCore: int.tryParse(sajuInfo.todayFortune['studyScore'] ?? '30'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
        

        
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_todayFortune == null) {
          // 에피소드 화면과 동일하게 빈 화면 반환
          return const SizedBox();
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
                              _todayFortune?.overall ?? '',
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
                              _todayFortune?.study ?? '',
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
                              _todayFortune?.wealth ?? '',
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
                              _todayFortune?.health ?? '',
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
                              _todayFortune?.love ?? '',
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
    if (_todayFortune == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${l10n.todayDetailTitle}

    💕 ${l10n.preciousRelationship}: ${_todayFortune!.love}

    💰 ${l10n.abundance}: ${_todayFortune!.wealth}

    🧘 ${l10n.bodyAndMind}: ${_todayFortune!.health}

    📚 ${l10n.growthAndFocus}: ${_todayFortune!.study}

    ✨ ${l10n.lightAndHope}: ${_todayFortune!.overall}

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