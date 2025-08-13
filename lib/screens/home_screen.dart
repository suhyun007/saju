import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/saju_card.dart';
import '../widgets/feature_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              
              // 메인 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 환영 메시지
                      _buildWelcomeMessage(),
                      
                      const SizedBox(height: 30),
                      
                      // 사주 카드 섹션
                      _buildSajuCardSection(),
                      
                      const SizedBox(height: 30),
                      
                      // 기능 버튼들
                      _buildFeatureButtons(),
                      
                      const SizedBox(height: 30),
                      
                      // 오늘의 운세
                      _buildTodayFortune(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.amber,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사주 앱',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '전통 사주로 운명을 읽어보세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // 설정 메뉴
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '오늘의 운세를 확인해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '생년월일시를 입력하시면 정확한 사주를 분석해드립니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSajuCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 사주',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        const SajuCard(),
      ],
    );
  }

  Widget _buildFeatureButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 서비스',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: const [
            FeatureButton(
              icon: Icons.calendar_today,
              title: '사주 보기',
              subtitle: '생년월일시 입력',
              color: Color(0xFF8B4513),
            ),
            FeatureButton(
              icon: Icons.psychology,
              title: '운세 분석',
              subtitle: '오늘의 운세',
              color: Color(0xFFDAA520),
            ),
            FeatureButton(
              icon: Icons.favorite,
              title: '연애운',
              subtitle: '사랑의 운세',
              color: Color(0xFFDC143C),
            ),
            FeatureButton(
              icon: Icons.work,
              title: '직업운',
              subtitle: '일과 재물운',
              color: Color(0xFF228B22),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayFortune() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '오늘의 운세',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '오늘은 새로운 시작에 좋은 날입니다. 용기를 가지고 도전해보세요.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFortuneItem('행운의 색', '빨간색'),
              const SizedBox(width: 20),
              _buildFortuneItem('행운의 숫자', '7'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}
