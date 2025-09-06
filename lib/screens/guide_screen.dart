import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/saju_api_service.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';

class GuideScreen extends StatefulWidget {
  final ValueNotifier<int>? activeTab;
  final int tabIndex;
  const GuideScreen({super.key, this.activeTab, this.tabIndex = 2});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  GuideResult? _guide;
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
    if (_tabListener != null) {
      widget.activeTab!.removeListener(_tabListener!);
    }
    super.dispose();
  }

  void _loadIfNeeded() async {
    if (_loading) return;
    if (_guide != null) return;
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab?.value != widget.tabIndex) return;
    // 최초 진입/탭 리스너 중복 호출 방지
    setState(() { _loading = true; });
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; });
    try {
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        dev.log('Guide load aborted: no saju info', name: 'GuideScreen');
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isTodayFortuneExpiredFor(locale);
      final String cachedContent = (sajuInfo.guide['overall'] ?? '').toString();
      // Debug: cache keys and comparison details
      final lastDate = (sajuInfo.guide['lastFortuneDate'] ?? '').toString();
      final lastFp = (sajuInfo.guide['lastRequestFingerprint'] ?? '').toString();
      final lastLang = (sajuInfo.guide['lastLanguage'] ?? '').toString();
      final todayYmd = sajuInfo.currentTodayDate;
      final birthYmdDebug = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final expectedComposite = '$birthYmdDebug|${sajuInfo.gender}|${sajuInfo.loveStatus ?? ''}|$lastDate';
      dev.log('[Guide cache check] today=$todayYmd lastDate=$lastDate lastFp=$lastFp expected=$expectedComposite lang=$locale lastLang=$lastLang expired=$expired', name: 'GuideScreen');
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('바뀐 데이터 없음!! 서버 호출 안함!!', name: 'GuideScreen');
        final cached = GuideResult(
          overall: (sajuInfo.guide['overall'] ?? '').toString(),
          love: (sajuInfo.guide['love'] ?? '').toString(),
          health: (sajuInfo.guide['health'] ?? '').toString(),
          study: (sajuInfo.guide['study'] ?? '').toString(),
          wealth: (sajuInfo.guide['wealth'] ?? '').toString(),
        );
        setState(() { _guide = cached; _loading = false; });
        return;
      }
      // 만료 시에만 서버 호출 - 이때만 로딩 표시
      dev.log('바뀐 데이터 있음!! 서버 호출!!!', name: 'GuideScreen');
      // 이미 _loadIfNeeded에서 _loading=true로 설정됨
      final result = await SajuApiService.fetchGuide(
        sajuInfo: sajuInfo,
        language: locale,
        forceNetwork: true,
        needDummy: true,
      );
      // 캐시에 저장(날짜/지문/언어)
      sajuInfo.guide['overall'] = result.overall;
      sajuInfo.guide['love'] = result.love;
      sajuInfo.guide['health'] = result.health;
      sajuInfo.guide['study'] = result.study;
      sajuInfo.guide['wealth'] = result.wealth;
      sajuInfo.guide['serverResponse'] = 'ok';
      var servedDate = (result.servedDate ?? '').replaceAll('-', '');
      if (servedDate.isEmpty) servedDate = todayYmd;
      // 타임존 오차 등으로 과거 날짜가 오면 오늘 날짜로 보정
      if (servedDate.compareTo(todayYmd) < 0) servedDate = todayYmd;
      sajuInfo.guide['lastFortuneDate'] = servedDate;
      // 조합 지문: YYYYMMDD|gender|loveStatus|servedDate(YYYYMMDD)
      final birthYmd = '${sajuInfo.birthDate.year.toString().padLeft(4, '0')}'
          '${sajuInfo.birthDate.month.toString().padLeft(2, '0')}'
          '${sajuInfo.birthDate.day.toString().padLeft(2, '0')}';
      final loveStatus = sajuInfo.loveStatus ?? '';
      final compositeFingerprint = '$birthYmd|${sajuInfo.gender}|$loveStatus|${sajuInfo.guide['lastFortuneDate'] ?? ''}';
      sajuInfo.guide['lastRequestFingerprint'] = compositeFingerprint;
      sajuInfo.guide['lastLanguage'] = locale;
      await SajuService.saveSajuInfoContent(sajuInfo);
      setState(() { _guide = result; _loading = false; });
      dev.log('[GuideScreen] saved cache: date=' + (sajuInfo.guide['lastFortuneDate'] ?? '') + ' fp=' + (sajuInfo.guide['lastRequestFingerprint'] ?? '') + ' lang=' + (sajuInfo.guide['lastLanguage'] ?? '') + ' servedRaw=' + (result.servedDate ?? 'null'));
    } catch (e) {
      dev.log('Guide load failed', name: 'GuideScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _showShareOptions() {
    final text = _getShareText();
    final subject = "${AppLocalizations.of(context)?.todayDetailTitle ?? "Today's Guide"}";
    Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  String _getShareText() {
    if (_guide == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${l10n.todayDetailTitle}

    💕 ${l10n.preciousRelationship}: ${_guide!.love}

    💰 ${l10n.abundance}: ${_guide!.wealth}

    🧘 ${l10n.bodyAndMind}: ${_guide!.health}

    📚 ${l10n.growthAndFocus}: ${_guide!.study}

    ✨ ${l10n.lightAndHope}: ${_guide!.overall}

    ${l10n.shareAppPromotion}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_guide == null) {
          // 데이터 로드 시도 - API 호출 방지를 위해 주석 처리
          dev.log('[GuideScreen] _guide is null, showing message');
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
                              _guide?.overall ?? '',
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
                              _guide?.study ?? '',
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
                              _guide?.wealth ?? '',
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
                              _guide?.health ?? '',
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
                              _guide?.love ?? '',
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
          ),
        );
  }
}