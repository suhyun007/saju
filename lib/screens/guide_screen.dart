import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../l10n/app_localizations.dart';


class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

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
            // 가이드 UI (아이콘, 타이틀, 설명글)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 가이드 아이콘
                  Icon(
                    Icons.tips_and_updates,
                    size: 40,
                    color: const Color(0xFFB3B3FF),
                  ),
                  const SizedBox(height: 8),
                  // 가이드 타이틀
                  Text(
                    'Today\'s Guide',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  // 가이드 설명글
                  Text(
                    'Get personalized guidance for your day ahead.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      color: textColor.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
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
                  // 오늘의 가이드 자세히 보기 버튼 (박스 위쪽에 배치)
                  Container(
                    width: double.infinity,
                    height: 53,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5d7df4),
                          Color(0xFF9961f6),
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
                  
                  const SizedBox(height: 30),
                  
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
