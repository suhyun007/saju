import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayFortune();
  }

  Future<void> _loadTodayFortune() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isTodayFortuneExpiredFor(locale);
      final String cachedContent = (sajuInfo.todayFortune['overall'] ?? '').toString();
      if (!expired && cachedContent.isNotEmpty) {
        final cached = _createTodayFortuneFromSajuInfo(sajuInfo);
        setState(() { _todayFortune = cached; _isLoading = false; });
        return;
      }

      // 만료 시에만 서버 호출
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
      sajuInfo.todayFortune['lastFortuneDate'] = DateTime.now().toIso8601String();
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
      setState(() { _todayFortune = todayFortune; _isLoading = false; });
    } catch (e) {
      dev.log('[GuideScreen] Guide load failed: $e');
      setState(() { _isLoading = false; });
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
        

        if (_todayFortune == null) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '출생 정보를 입력해주세요',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
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
              ],
            ),
          ),
        );
  }
}