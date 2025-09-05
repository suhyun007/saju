import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';


class YearScreen extends StatefulWidget {
  const YearScreen({super.key});

  @override
  State<YearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  SajuInfo? _sajuInfo;
  YearFortune? _yearFortune;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadYearFortune();
  }

  Future<void> _loadYearFortune() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null) {
        setState(() {
          _sajuInfo = sajuInfo;
          _yearFortune = _createYearFortuneFromSajuInfo(sajuInfo);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('올해의 운세 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  YearFortune _createYearFortuneFromSajuInfo(SajuInfo sajuInfo) {
    return YearFortune(
      overall: sajuInfo.yearFortune['overall'] ?? '올해의 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요.',
      love: sajuInfo.yearFortune['love'] ?? '올해의는 로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
      health: sajuInfo.yearFortune['health'] ?? '올해의는 건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
      study: sajuInfo.yearFortune['study'] ?? '올해의는 집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
      wealth: sajuInfo.yearFortune['wealth'] ?? '올해의는 재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
      luckyItem: sajuInfo.yearFortune['luckyItem'] ?? '올해의는 살구색, 모자, 남쪽, 7, 11, 맛집',
      yearOutfit: sajuInfo.yearFortune['yearOutfit'] ?? '올해의는 편안한 캐주얼 복장',
      advice: sajuInfo.yearFortune['advice'] ?? '올해의는 긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
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
    final textColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
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
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

    if (_yearFortune == null) {
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
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 점수 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Text(
                    _truncateAtFirstPeriod(_yearFortune!.overall!),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: textColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // 올해의 운세 자세히 보기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/year-detail');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '올해의 운세 자세히 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 애정운
                  _buildFortuneSection(
                    '애정운',
                    _truncateAtSecondPeriod(_yearFortune!.love!),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 재물운
                  _buildFortuneSection(
                    '재물운',
                    _truncateAtSecondPeriod(_yearFortune!.wealth!),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 건강운
                  _buildFortuneSection(
                    '건강운',
                    _truncateAtSecondPeriod(_yearFortune!.health!),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 학업/직장운
                  _buildFortuneSection(
                    '학업/직장운',
                    _truncateAtSecondPeriod(_yearFortune!.study!),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 하단 안내
                  Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '운세는 참고용이며, 실제 삶의 결정은 본인의 판단에 따라 결정하세요.',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: textColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
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
