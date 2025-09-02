import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../l10n/app_localizations.dart';


class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
      if (sajuInfo != null) {
        setState(() {
          _sajuInfo = sajuInfo;
          _todayFortune = _createTodayFortuneFromSajuInfo(sajuInfo);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('오늘의 운세 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
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

  // 텍스트를 첫 번째 마침표까지만 자르는 메서드
  String _truncateAtFirstPeriod(String text) {
    final periodIndex = text.indexOf('.');
    if (periodIndex == -1) {
      return text; // 마침표가 없으면 전체 텍스트 반환
    }
    return text.substring(0, periodIndex + 1); // 마침표 포함해서 반환
  }

  // 텍스트를 두 번째 마침표까지만 자르고 ..을 붙이는 메서드
  String _truncateAtSecondPeriod(String text) {
    if (text.length <= 35) {
      return text; // 35자 이하면 그대로 반환
    }
    
    final firstPeriodIndex = text.indexOf('.');
    if (firstPeriodIndex == -1) {
      return text; // 마침표가 없으면 전체 텍스트 반환
    }
    
    final secondPeriodIndex = text.indexOf('.', firstPeriodIndex + 1);
    if (secondPeriodIndex == -1) {
      return text; // 두 번째 마침표가 없으면 전체 텍스트 반환
    }
    
    return '${text.substring(0, secondPeriodIndex + 1)}..'; // 두 번째 마침표까지 + ..
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    
    if (_isLoading) {
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
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

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
          child: Text(
            '출생 정보를 먼저 입력해주세요.',
            style: TextStyle(color: textColor, fontSize: 16),
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
        padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 점수 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    '${_todayFortune!.overallScore}${AppLocalizations.of(context)?.point ?? '점'}',
                    style: GoogleFonts.notoSans(
                      fontSize: Localizations.localeOf(context).languageCode == 'en' ? 39 : 40, // 영어일 때 -1 작게
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7A68B7), //0xFF5C4B8A   //0xFF7A68B7
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -1 : 0, // 영어일 때 글자 간격 -1
                    ),
                  ),
                  const SizedBox(height: 25),
                  // RadarChart
                  SizedBox(
                    height: 180,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            dataEntries: [
                              RadarEntry(value: _todayFortune!.overallScore?.toDouble() ?? 0), // 전체의 흐름
                              RadarEntry(value: _todayFortune!.loveScore?.toDouble() ?? 0), // 소중한 인연
                              RadarEntry(value: _todayFortune!.wealthScore?.toDouble() ?? 0), // 풍요로움
                              RadarEntry(value: _todayFortune!.healthScore?.toDouble() ?? 0), // 몸과 마음
                              RadarEntry(value: _todayFortune!.studyCore?.toDouble() ?? 0), // 성장과 집중
                            ],
                            fillColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFFB488FF).withOpacity(0.4) // 다크모드에서는 투명하게
                                : const Color(0xFF6E5DE7).withOpacity(0.5), // 라이트모드에서는 원래 색상
                            borderColor: Colors.transparent,
                            borderWidth: 0,
                            entryRadius: 0,
                          ),
                        ],
                        //차트에 보이는 소중한 인연..타이틀
                        titleTextStyle: GoogleFonts.notoSans(
                          color: textColor,
                          fontSize: Localizations.localeOf(context).languageCode == 'en' ? 15 : 16, // 영어일 때 -1 작게
                          fontWeight: FontWeight.w500,
                          letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -1 : 0, // 영어일 때 글자 간격 -1
                        ),
                        titlePositionPercentageOffset: 0.15,
                        //radarBackgroundColor: Colors.blue,
                        tickCount: 1,
                        gridBorderData: const BorderSide(color: Colors.transparent),    // 그리드 선 숨김
                        tickBorderData: const BorderSide(color: Colors.transparent),  // 안쪽 선 숨김
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(color: Colors.transparent), //제일큰 원
                        radarBackgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey.shade900
                            : const Color(0xEEE9E6FF).withOpacity(1), //  바탕색  
                        ticksTextStyle: GoogleFonts.notoSans(
                          color: Colors.transparent,  // 숫자 숨김
                          fontSize: 0,               // 숫자 숨김
                        ),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return RadarChartTitle(text: AppLocalizations.of(context)?.overall ?? '전체');
                            case 1:
                              return RadarChartTitle(text: AppLocalizations.of(context)?.relationship ?? '인연');
                            case 2:
                              return RadarChartTitle(text: AppLocalizations.of(context)?.wealth ?? '풍요');
                            case 3:
                              return RadarChartTitle(text: AppLocalizations.of(context)?.mind ?? '마음');
                            case 4:
                              return RadarChartTitle(text: AppLocalizations.of(context)?.growth ?? '성장');
                            default:
                              return const RadarChartTitle(text: '');
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _truncateAtFirstPeriod(_todayFortune!.overall!),
                                style: GoogleFonts.notoSans(
                                fontSize: 17,
                                color: textColor,
                                height: 1.4,
                              ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  
                  // 오늘의 운세 자세히 보기 버튼
                  Container(
                    width: double.infinity,
                    height: 53,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5d7df4), // 채도 높은 파란색
                          Color(0xFF9961f6), // 채도 높은 보라색
                          //Color(0xFF4A90E2), // 파란색
                          //Color(0xFF9B59B6), // 보라색
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/today-detail');
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)?.todayGuideDetailButton ?? '오늘의 가이드 자세히 보기',
                            style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 통합된 운세 박스
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 소중한 인연
                  _buildFortuneSection(
                    AppLocalizations.of(context)?.preciousRelationship ?? '소중한 인연',
                    _truncateAtSecondPeriod(_todayFortune!.love!),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 풍요로움
                  _buildFortuneSection(
                    AppLocalizations.of(context)?.abundance ?? '풍요로움',
                    _truncateAtSecondPeriod(_todayFortune!.wealth!),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 몸과 마음
                  _buildFortuneSection(
                    AppLocalizations.of(context)?.bodyAndMind ?? '몸과 마음',
                    _truncateAtSecondPeriod(_todayFortune!.health!),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 성장과 집중
                  _buildFortuneSection(
                    AppLocalizations.of(context)?.growthAndFocus ?? '성장과 집중',
                    _truncateAtSecondPeriod(_todayFortune!.study!),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 하단 안내
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (AppLocalizations.of(context)?.todayStoryHint ?? '오늘의 이야기는 별칭이 전해주는 작은 힌트일 뿐이에요. 당신의 선택과 걸어가는 길은 오롯이 당신만의 것이에요.').replaceAll('\n', ' '),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.left,
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

  Widget _buildFortuneSection(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.notoSans(
            fontSize: 17,
            color: textColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneCard(String title, String content, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
