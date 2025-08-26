import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key});

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
            // 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.amber,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '이달의 운세',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이번 달의 운세를 확인해보세요',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 월간 운세 카드들
            _buildFortuneCard(
              '월간 전체운',
              '이번 달은 새로운 시작에 좋은 시기입니다. 계획했던 일들을 실행에 옮기기에 적절한 달이 될 것입니다.',
              Icons.star,
              Colors.amber,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '월간 사랑운',
              '로맨틱한 만남이나 기존 관계의 발전이 기대되는 달입니다. 소통을 중시하세요.',
              Icons.favorite,
              Colors.pink,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '월간 금전운',
              '재정적으로 안정적인 한 달이 될 것입니다. 새로운 수입원이나 투자 기회가 찾아올 수 있습니다.',
              Icons.attach_money,
              Colors.green,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '월간 건강운',
              '건강 관리에 신경 쓰는 것이 좋겠습니다. 규칙적인 운동과 식습관을 유지하세요.',
              Icons.health_and_safety,
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '월간 학업/직장운',
              '업무나 학업에서 좋은 성과를 거둘 수 있는 달입니다. 새로운 프로젝트나 학습에 도전해보세요.',
              Icons.work,
              Colors.purple,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '월간 인연운',
              '새로운 인연이나 기존 관계의 발전이 기대됩니다. 네트워킹 활동에 적극적으로 참여하세요.',
              Icons.people,
              Colors.orange,
            ),
            
            const SizedBox(height: 30),
            
            // 월간 조언
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이번 달 조언',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '새로운 시작과 변화의 시기입니다. 과감하게 도전하고, 주변 사람들과의 소통을 중시하세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
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
