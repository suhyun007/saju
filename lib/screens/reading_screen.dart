import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/poetry_api_service.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';

class PoetryScreen extends StatefulWidget {
  final ValueNotifier<int>? activeTab;
  final int tabIndex;
  const PoetryScreen({super.key, this.activeTab, this.tabIndex = 1});

  @override
  State<PoetryScreen> createState() => _PoetryScreenState();
}

class _PoetryScreenState extends State<PoetryScreen> {
  bool _loading = false;
  String? _error;
  PoetryResult? _poem;
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
    if (_poem != null) return;
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab?.value != widget.tabIndex) return;
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; });
    try {
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        dev.log('Poetry load aborted: no saju info', name: 'PoetryScreen');
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      // 캐시 우선
      final bool expired = sajuInfo.isPoetryExpiredFor(lang);
      final String cachedContent = (sajuInfo.poetry['content'] ?? '').toString();
      // Debug: cache keys and comparison details
      final lastDate = (sajuInfo.poetry['lastPoetryDate'] ?? '').toString();
      final lastFp = (sajuInfo.poetry['lastRequestFingerprint'] ?? '').toString();
      final lastLang = (sajuInfo.poetry['lastLanguage'] ?? '').toString();
      final todayYmd = sajuInfo.currentTodayDate;
      final birthYmdDebug = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final expectedComposite = '$birthYmdDebug|${sajuInfo.gender}|${sajuInfo.loveStatus ?? ''}|$lastDate';
      dev.log('[Poetry cache check] today=$todayYmd lastDate=$lastDate lastFp=$lastFp expected=$expectedComposite lang=$lang lastLang=$lastLang expired=$expired', name: 'PoetryScreen');
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('바뀐 데이터 없음!! 서버 호출 안함!!', name: 'PoetryScreen');
        final cached = PoetryResult(
          title: (sajuInfo.poetry['title'] ?? '').toString(),
          content: cachedContent,
          summary: (sajuInfo.poetry['summary'] ?? '').toString(),
          tomorrowHint: (sajuInfo.poetry['tomorrowHint'] ?? '').toString(),
        );
        setState(() { _poem = cached; _loading = false; });
        return;
      }

      // 만료 시 호출 - 이때만 로딩 표시
      dev.log('바뀐 데이터 있음!! 서버 호출!!!', name: 'PoetryScreen');
      setState(() { _loading = true; });
      final res = await PoetryApiService.fetchPoetry(
        sajuInfo: sajuInfo,
        language: lang,
        forceNetwork: true,
      );
      // 저장
      sajuInfo.poetry['title'] = res.title;
      sajuInfo.poetry['content'] = res.content;
      sajuInfo.poetry['summary'] = res.summary;
      sajuInfo.poetry['tomorrowHint'] = res.tomorrowHint;
      sajuInfo.poetry['serverResponse'] = 'ok';
      final servedDate = (res.servedDate ?? '').replaceAll('-', '');
      sajuInfo.poetry['lastPoetryDate'] = servedDate.isNotEmpty ? servedDate : sajuInfo.currentTodayDate;
      // 조합 지문: YYYYMMDD|gender|loveStatus|servedDate(YYYYMMDD)
      final birthYmd = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final loveStatus = sajuInfo.loveStatus ?? '';
      final compositeFingerprint = '$birthYmd|${sajuInfo.gender}|$loveStatus|${sajuInfo.poetry['lastPoetryDate'] ?? ''}';
      sajuInfo.poetry['lastRequestFingerprint'] = compositeFingerprint;
      sajuInfo.poetry['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
      sajuInfo.poetry['lastLanguage'] = lang;
      await SajuService.saveSajuInfoContent(sajuInfo);
      setState(() { _poem = res; _loading = false; });
    } catch (e) {
      dev.log('Poetry load failed', name: 'PoetryScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _showShareOptions() {
    final text = _getShareText();
    final subject = '${AppLocalizations.of(context)?.poetryTitle ?? 'Poetry'} - ${_poem?.title ?? ''}';
    Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  String _getShareText() {
    if (_poem == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${_poem!.title}

    ${_poem!.content}

    ${_poem!.summary.isNotEmpty ? '${l10n.shareSummaryPrefix} ${_poem!.summary}' : ''}

    ${_poem!.tomorrowHint.isNotEmpty ? '${l10n.shareTomorrowPrefix} ${_poem!.tomorrowHint}' : ''}

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
            // Poetry UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: Color(0xFFB3B3FF),
                    size: 40,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.poetryTitle ?? '오늘의 시 낭독',
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
                    AppLocalizations.of(context)?.poetrySubtitle ?? '매일 당신에게 시 한 편을 지어드려요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.3 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 0),
            
            // Poetry 내용만 표시
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
    if (_poem == null) {
      return const SizedBox();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((_poem!.title).isNotEmpty)
            Center(
              child: SelectableText(
                '<${_poem!.title}>',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          if (_poem!.content.isNotEmpty)
            Center(
              child: SelectableText(
                _poem!.content,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  color: onText,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 15),
          if ((_poem!.summary).isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.summaryLabel}: ${_poem!.summary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          if ((_poem!.tomorrowHint).isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.shareTomorrowPoetryPrefix} ${_poem!.tomorrowHint}',
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
