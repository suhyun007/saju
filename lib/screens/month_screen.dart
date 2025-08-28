import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../services/saju_api_service.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  SajuInfo? _sajuInfo;
  MonthFortune? _monthFortune;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthFortune();
  }

  Future<void> _loadMonthFortune() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null) {
        setState(() {
          _sajuInfo = sajuInfo;
          _monthFortune = _createMonthFortuneFromSajuInfo(sajuInfo);
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

  MonthFortune _createMonthFortuneFromSajuInfo(SajuInfo sajuInfo) {
    return MonthFortune(
      overall: sajuInfo.monthFortune['overall'] ?? '이번달 새로운 기회가 찾아올 수 있는 날입니다. 주변을 잘 살펴보세요.',
      love: sajuInfo.monthFortune['love'] ?? '이번달은 로맨틱한 기운이 가득한 날입니다. 소중한 사람과의 시간을 가져보세요.',
      health: sajuInfo.monthFortune['health'] ?? '이번달은 건강에 특별한 문제는 없을 것입니다. 적절한 운동을 해보세요.',
      study: sajuInfo.monthFortune['study'] ?? '이번달은 집중력이 높은 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
      wealth: sajuInfo.monthFortune['wealth'] ?? '이번달은 재정적으로 안정적인 하루가 될 것입니다. 투자나 큰지출은 신중하게 결정하세요.',
      luckyItem: sajuInfo.monthFortune['luckyItem'] ?? '이번달은 살구색, 모자, 남쪽, 7, 11, 맛집',
      monthOutfit: sajuInfo.monthFortune['monthOutfit'] ?? '이번달은 편안한 캐주얼 복장',
      advice: sajuInfo.monthFortune['advice'] ?? '이번달은 긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
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

    if (_monthFortune == null) {
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
                    _truncateAtFirstPeriod(_monthFortune!.overall!),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // 이번달 운세 자세히 보기 버튼
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/month-detail');
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
                        '이번달 운세 자세히 보기',
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
              _truncateAtSecondPeriod(_monthFortune!.love!),
              Icons.favorite,
              Colors.pink,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '재물운',
              _truncateAtSecondPeriod(_monthFortune!.wealth!),
              Icons.attach_money,
              Colors.green,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '건강운',
              _truncateAtSecondPeriod(_monthFortune!.health!),
              Icons.health_and_safety,
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '학업/직장운',
              _truncateAtSecondPeriod(_monthFortune!.study!),
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
