import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../services/saju_api_service.dart';

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
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF4A2C1A),
              Color(0xFF8B4513),
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

    if (_todayFortune == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF4A2C1A),
              Color(0xFF8B4513),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            '출생 정보를 먼저 입력해주세요.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C1810),
            Color(0xFF4A2C1A),
            Color(0xFF8B4513),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_todayFortune!.overallScore}점',
                    style: GoogleFonts.notoSans(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // RadarChart
                  SizedBox(
                    height: 200,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            dataEntries: [
                              RadarEntry(value: _todayFortune!.overallScore?.toDouble() ?? 0), // 총운
                              RadarEntry(value: _todayFortune!.loveScore?.toDouble() ?? 0), // 애정운
                              RadarEntry(value: _todayFortune!.wealthScore?.toDouble() ?? 0), // 재물운
                              RadarEntry(value: _todayFortune!.healthScore?.toDouble() ?? 0), // 건강운
                              RadarEntry(value: _todayFortune!.studyCore?.toDouble() ?? 0), // 학업/직장운
                            ],
                            fillColor: Color.fromARGB(255, 192, 118, 252).withOpacity(0.3), // 보라 계열 (슬레이트 블루)
                            borderColor: Colors.transparent,
                            borderWidth: 0,
                            entryRadius: 0,
                          ),
                          RadarDataSet(
                            dataEntries: [
                              RadarEntry(value: _todayFortune!.overallScore?.toDouble() ?? 0), // 총운
                              RadarEntry(value: _todayFortune!.loveScore?.toDouble() ?? 0), // 애정운
                              RadarEntry(value: _todayFortune!.wealthScore?.toDouble() ?? 0), // 재물운
                              RadarEntry(value: _todayFortune!.healthScore?.toDouble() ?? 0), // 건강운
                              RadarEntry(value: _todayFortune!.studyCore?.toDouble() ?? 0), // 학업/직장운
                            ],
                            fillColor: Color.fromARGB(255, 28, 158, 245).withOpacity(0.3), // 파랑 계열 (라벤더 퍼플)
                            borderColor: Colors.white,
                            borderWidth: 1,
                            entryRadius: 0,
                          ),
                        ],
                        //차트에 보이는 애정운..타이틀
                        titleTextStyle: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        titlePositionPercentageOffset: 0.03,
                        //radarBackgroundColor: Colors.blue,
                        tickCount: 1,
                        gridBorderData: const BorderSide(color: Colors.transparent),    // 그리드 선 숨김
                        tickBorderData: const BorderSide(color: Colors.transparent),  // 안쪽 선 숨김
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(color: Colors.transparent), //제일큰 원
                        radarBackgroundColor: Colors.transparent,  
                        ticksTextStyle: GoogleFonts.notoSans(
                          color: Colors.transparent,  // 숫자 숨김
                          fontSize: 0,               // 숫자 숨김
                        ),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return RadarChartTitle(text: '총운');
                            case 1:
                              return RadarChartTitle(text: '애정운');
                            case 2:
                              return RadarChartTitle(text: '재물운');
                            case 3:
                              return RadarChartTitle(text: '건강운');
                            case 4:
                              return RadarChartTitle(text: '학업\n직장운');  // 추가
                            default:
                              return const RadarChartTitle(text: '');
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _truncateAtFirstPeriod(_todayFortune!.overall!),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // 오늘의 운세 자세히 보기 버튼
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/today-detail');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '오늘의 운세 자세히 보기',
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
            
            _buildFortuneCard(
              '애정운',
              _truncateAtSecondPeriod(_todayFortune!.love!),
              Icons.favorite,
              Colors.pink,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '재물운',
              _truncateAtSecondPeriod(_todayFortune!.wealth!),
              Icons.attach_money,
              Colors.green,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '건강운',
              _truncateAtSecondPeriod(_todayFortune!.health!),
              Icons.health_and_safety,
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '학업/직장운',
              _truncateAtSecondPeriod(_todayFortune!.study!),
              Icons.work,
              Colors.purple,
            ),
            
            const SizedBox(height: 30),
            
            // 하단 안내
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '운세는 참고용이며, 실제 삶의 결정은 본인의 판단에 따라 결정하세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
