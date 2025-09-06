import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
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
      // Debug: cache keys and comparison details
      final lastDate = (sajuInfo.episode['lastEpisodeDate'] ?? '').toString();
      final lastFp = (sajuInfo.episode['lastRequestFingerprint'] ?? '').toString();
      final lastLang = (sajuInfo.episode['lastLanguage'] ?? '').toString();
      final todayYmd = sajuInfo.currentTodayDate;
      final birthYmdDebug = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final expectedComposite = '$birthYmdDebug|${sajuInfo.gender}|${sajuInfo.loveStatus ?? ''}|$lastDate';
      dev.log('[Episode cache check] today=$todayYmd lastDate=$lastDate lastFp=$lastFp expected=$expectedComposite lang=$locale lastLang=$lastLang expired=$expired', name: 'EpisodeScreen');
      dev.log('[Episode] expired=$expired cachedLen=${cachedContent.length} today=$todayYmd lastDate=$lastDate fpOk=${lastFp==expectedComposite} langOk=${lastLang==locale}', name: 'EpisodeScreen');
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('바뀐 데이터 없음!! 서버 호출 안함!!', name: 'EpisodeScreen');
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
      dev.log('바뀐 데이터 있음!! 서버 호출!!!', name: 'EpisodeScreen');
      setState(() { _loading = true; });
      final result = await EpisodeApiService.fetchEpisode(
        sajuInfo: sajuInfo,
        language: locale,
        forceNetwork: true,
        needDummy: true,
      );
      // 캐시에 저장 (날짜/지문/언어)
      sajuInfo.episode['title'] = result.title;
      sajuInfo.episode['content'] = result.content;
      sajuInfo.episode['tomorrowSummary'] = result.tomorrowSummary;
      sajuInfo.episode['summary'] = result.summary;
      sajuInfo.episode['serverResponse'] = 'ok';
      // 서버 제공 servedDate 우선 사용, 없으면 디바이스 날짜 사용
      final servedDate = (result.servedDate ?? '').replaceAll('-', '');
      sajuInfo.episode['lastEpisodeDate'] = servedDate.isNotEmpty ? servedDate : sajuInfo.currentTodayDate;
      // 조합 지문: YYYYMMDD|gender|loveStatus|servedDate(YYYYMMDD)
      final birthYmd = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final loveStatus = sajuInfo.loveStatus ?? '';
      final compositeFingerprint = '$birthYmd|${sajuInfo.gender}|$loveStatus|${sajuInfo.episode['lastEpisodeDate'] ?? ''}';
      sajuInfo.episode['lastRequestFingerprint'] = compositeFingerprint;
      sajuInfo.episode['lastLanguage'] = locale;
      await SajuService.saveSajuInfoContent(sajuInfo);
      setState(() { _episode = result; _loading = false; });
    } catch (e) {
      dev.log('Episode load failed', name: 'EpisodeScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }
//_shareToDefault
  void _showShareOptions() {
    final text = _getShareText();
    final subject = '${AppLocalizations.of(context)?.episodeTitle ?? 'Episode'} - ${_episode?.title ?? ''}';
    Share.share('Subject: $subject\n\n$text', subject: subject);
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
              '${AppLocalizations.of(context)!.shareTomorrowPrefix} ${_episode!.tomorrowSummary}',
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
                      AppLocalizations.of(context)?.shareButton ?? '공유',
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


