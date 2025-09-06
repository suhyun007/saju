import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/episode_api_service.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';

class EpisodeScreen extends StatefulWidget {
  final ValueNotifier<int>? activeTab;
  final int tabIndex;
  const EpisodeScreen({super.key, this.activeTab, this.tabIndex = 0});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  EpisodeResult? _episode;
  bool _loading = false;
  String? _error;
  VoidCallback? _tabListener;

  @override
  void initState() {
    super.initState();
    _tabListener = () {
      if (widget.activeTab?.value == widget.tabIndex) {
        _loadIfNeeded();
      }
    };
    widget.activeTab?.addListener(_tabListener!);
    // 최초 선택된 탭과 일치하면 지연 호출
    if (widget.activeTab?.value == widget.tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
    }
  }

  @override
  void dispose() {
    if (_tabListener != null && widget.activeTab != null) {
      widget.activeTab!.removeListener(_tabListener!);
    }
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_loading) return;
    if (_episode != null) return;
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab?.value != widget.tabIndex) return;
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; });
    try {
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        dev.log('Episode load aborted: no saju info', name: 'EpisodeScreen');
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isEpisodeExpiredFor(locale);
      final String cachedContent = (sajuInfo.episode['content'] ?? '').toString();
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('Episode using cached data', name: 'EpisodeScreen');
        final cached = EpisodeResult(
          title: (sajuInfo.episode['title'] ?? '').toString(),
          content: cachedContent,
          contentLength: cachedContent.length,
          summary: (sajuInfo.episode['summary'] ?? '').toString(),
          tomorrowSummary: (sajuInfo.episode['tomorrowSummary'] ?? '').toString(),
        );
        setState(() { _episode = cached; _loading = false; });
        return;
      }

      // 만료 시에만 서버 호출 - 이때만 로딩 표시
      dev.log('Episode cache expired, calling server', name: 'EpisodeScreen');
      setState(() { _loading = true; });
      final result = await EpisodeApiService.fetchEpisode(
        sajuInfo: sajuInfo,
        language: locale,
        forceNetwork: true,
      );
      // 캐시에 저장 (날짜/지문/언어)
      sajuInfo.episode['title'] = result.title;
      sajuInfo.episode['content'] = result.content;
      sajuInfo.episode['tomorrowSummary'] = result.tomorrowSummary;
      sajuInfo.episode['summary'] = result.summary;
      sajuInfo.episode['serverResponse'] = 'ok';
      sajuInfo.episode['lastEpisodeDate'] = sajuInfo.currentTodayDate;
      sajuInfo.episode['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
      sajuInfo.episode['lastLanguage'] = locale;
      await SajuService.saveSajuInfo(sajuInfo);
      setState(() { _episode = result; _loading = false; });
    } catch (e) {
      dev.log('Episode load failed', name: 'EpisodeScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Text(
              AppLocalizations.of(context)!.shareTitle,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 한국어 사용자일 경우 카카오톡을 맨 앞에
                    if (Localizations.localeOf(context).languageCode == 'ko')
                      _buildShareOption(
                        icon: Icons.chat_bubble,
                        label: 'KakaoTalk',
                        onTap: () => _shareToKakaoTalk(),
                      ),
                    _buildShareOption(
                      icon: Icons.email,
                      label: 'Gmail',
                      onTap: () => _shareToGmail(),
                    ),
                    _buildShareOption(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onTap: () => _shareToFacebook(),
                    ),
                    _buildShareOption(
                      icon: Icons.message,
                      label: 'Facebook\nMessage',
                      onTap: () => _shareToFacebookMessage(),
                    ),
                    _buildShareOption(
                      icon: Icons.message,
                      label: 'Message',
                      onTap: () => _shareToIMessage(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 텍스트 복사 버튼
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.shareTextCopy,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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
    if (_episode == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${_episode!.title}

    ${_episode!.content}

    ${_episode!.summary.isNotEmpty ? '${l10n.shareSummaryPrefix} ${_episode!.summary}' : ''}

    ${_episode!.tomorrowSummary.isNotEmpty ? '${l10n.shareTomorrowPrefix} ${_episode!.tomorrowSummary}' : ''}

    ${l10n.shareAppPromotion}
    ''';
  }

  void _shareToGmail() {
    dev.log('=== _shareToGmail 메서드 호출됨 ===', name: 'EpisodeScreen');
    
    final text = _getShareText();
    final subject = '오늘의 에피소드 - ${_episode?.title ?? ''}';
    
    // 디버깅을 위한 로그 추가
    dev.log('Gmail 공유 시도: $subject', name: 'EpisodeScreen');
    
    // 여러 방법을 순차적으로 시도
    _tryGmailMethods(subject, text);
  }

  Future<void> _tryGmailMethods(String subject, String text) async {
    // 시뮬레이터에서는 기본 공유 시트 사용
    if (kDebugMode) {
      dev.log('시뮬레이터 환경: 기본 공유 시트 사용', name: 'EpisodeScreen');
      await Share.share('Subject: $subject\n\n$text', subject: subject);
      return;
    }
    
    // 방법 1: Gmail 앱 직접 호출 (canLaunchUrl 우회)
    final gmailUri = Uri.parse('googlegmail://co?to=&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}');
    dev.log('Gmail URI 시도: $gmailUri', name: 'EpisodeScreen');
    
    try {
      dev.log('Gmail 앱 직접 실행 시도', name: 'EpisodeScreen');
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      dev.log('Gmail 앱 실행 성공', name: 'EpisodeScreen');
      return;
    } catch (e) {
      dev.log('Gmail 실행 실패: $e', name: 'EpisodeScreen');
    }
    
    // 방법 2: 기본 mailto (canLaunchUrl 우회)
    final mailtoUri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}');
    dev.log('Mailto URI 시도: $mailtoUri', name: 'EpisodeScreen');
    
    try {
      dev.log('Mailto 직접 실행 시도', name: 'EpisodeScreen');
      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      dev.log('Mailto 실행 성공', name: 'EpisodeScreen');
      return;
    } catch (e) {
      dev.log('Mailto 실행 실패: $e', name: 'EpisodeScreen');
    }
    
    // 방법 3: 기본 공유 기능
    dev.log('모든 방법 실패, 기본 공유 사용', name: 'EpisodeScreen');
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
      dev.log('URL 실행 시도: $uri', name: 'EpisodeScreen');
      
      // launchMode를 명시적으로 설정
      if (await canLaunchUrl(uri)) {
        dev.log('URL 실행 가능, 실행 중...', name: 'EpisodeScreen');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        dev.log('URL 실행 완료', name: 'EpisodeScreen');
      } else {
        dev.log('URL 실행 불가능, 기본 공유 기능 사용', name: 'EpisodeScreen');
        // URL을 열 수 없는 경우 기본 공유 기능 사용
        await Share.share(_getShareText());
      }
    } catch (e) {
      dev.log('URL 실행 오류: $e', name: 'EpisodeScreen');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    color: Color(0xFFB3B3FF),
                    size: 40,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.episodeTitle ?? '오늘의 에피소드',
                    style: GoogleFonts.notoSans(
                      fontSize: 22,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    AppLocalizations.of(context)?.episodeSubtitle ?? '매일 새로운 당신의 이야기를 만나보세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // 이야기 내용 - 전체 화면에서 패딩 20 안에 들어가도록
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1) 
                      : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final onText = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error == 'no_saju') {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.infoMessage ?? '출생 정보를 먼저 저장해주세요.',
          style: GoogleFonts.notoSans(fontSize: 16, color: onText),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error', style: GoogleFonts.notoSans(fontSize: 18, color: onText, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.notoSans(fontSize: 14, color: onText.withOpacity(0.8))),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_episode == null) {
      return const SizedBox();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SelectableText(
              '<${_episode!.title}>',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: onText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            _episode!.content,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              color: onText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          if (_episode!.summary.isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.summaryLabel}: ${_episode!.summary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          if (_episode!.tomorrowSummary.isNotEmpty)
            SelectableText(
              '내일의 에피소드 미리보기 : ${_episode!.tomorrowSummary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 20),
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
    );
  }
}


