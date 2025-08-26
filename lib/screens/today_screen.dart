import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 점수 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '75점',
                    style: GoogleFonts.notoSans(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '전반적으로 좋은 하루가 될 것입니다. 새로운 기회가 찾아올 수 있으니 주변을 잘 살펴보세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '사랑운',
              '로맨틱한 기운이 가득한 하루입니다. 소중한 사람과의 시간을 가져보세요.',
              Icons.favorite,
              Colors.pink,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '금전운',
              '재정적으로 안정적인 하루입니다. 투자나 큰 지출은 신중하게 결정하세요.',
              Icons.attach_money,
              Colors.green,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '건강운',
              '건강에 특별한 문제는 없지만, 적절한 운동과 휴식을 취하는 것이 좋겠습니다.',
              Icons.health_and_safety,
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '학업/직장운',
              '집중력이 높아지는 하루입니다. 중요한 업무나 공부에 집중하면 좋은 결과를 얻을 수 있습니다.',
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
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
