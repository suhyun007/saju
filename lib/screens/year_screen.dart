import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YearScreen extends StatelessWidget {
  const YearScreen({super.key});

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
                    Icons.calendar_today,
                    color: Colors.amber,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '이번해 운세',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '올해의 운세를 확인해보세요',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 연간 운세 카드들
            _buildFortuneCard(
              '연간 전체운',
              '올해는 변화와 성장의 해가 될 것입니다. 새로운 도전과 기회가 많이 찾아올 것이니 준비를 잘 하세요.',
              Icons.star,
              Colors.amber,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 사랑운',
              '로맨틱한 관계에서 중요한 발전이 있을 수 있는 해입니다. 진정한 사랑을 찾거나 기존 관계가 더욱 깊어질 수 있습니다.',
              Icons.favorite,
              Colors.pink,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 금전운',
              '재정적으로 안정적이고 성장하는 한 해가 될 것입니다. 새로운 수입원이나 투자 기회를 잘 활용하세요.',
              Icons.attach_money,
              Colors.green,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 건강운',
              '건강 관리에 더욱 신경 쓰는 것이 좋겠습니다. 규칙적인 운동과 건강한 생활습관을 유지하세요.',
              Icons.health_and_safety,
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 학업/직장운',
              '업무나 학업에서 큰 성과를 거둘 수 있는 해입니다. 새로운 프로젝트나 학습에 적극적으로 도전하세요.',
              Icons.work,
              Colors.purple,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 인연운',
              '새로운 인연이나 기존 관계의 발전이 기대됩니다. 네트워킹 활동에 적극적으로 참여하세요.',
              Icons.people,
              Colors.orange,
            ),
            
            const SizedBox(height: 20),
            
            _buildFortuneCard(
              '연간 여행운',
              '새로운 곳을 여행하거나 새로운 경험을 할 수 있는 기회가 많을 것입니다. 여행 계획을 세워보세요.',
              Icons.flight,
              Colors.cyan,
            ),
            
            const SizedBox(height: 30),
            
            // 연간 조언
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
                    '올해 조언',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '변화와 성장의 해입니다. 새로운 도전을 두려워하지 말고, 주변 사람들과의 관계를 소중히 하세요.',
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
