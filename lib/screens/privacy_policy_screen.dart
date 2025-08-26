import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),
            
            // 메인 콘텐츠
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            '개인정보보호방침',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
            // 제목
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
                    Icons.privacy_tip_outlined,
                    color: Colors.amber,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '개인정보 처리방침',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AstroStar 앱은 사용자의 개인정보 보호를 최우선으로 합니다.',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 섹션 1
            _buildSection(
              '1. 수집하는 개인정보',
              [
                '본 앱은 사용자의 생년월일을 입력받을 수 있습니다.',
                '입력된 생년월일은 오직 개인 맞춤형 서비스(예: 운세/날씨 정보 제공 등)를 위해 앱 내에서만 사용되며, 서버(DB)나 외부에 저장되지 않습니다.',
                '앱은 사용자의 푸시 알림 수신 여부 설정만 저장하며, 알림 발송을 위한 기기 토큰 외의 개인정보는 수집하지 않습니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 2
            _buildSection(
              '2. 개인정보의 이용 목적',
              [
                '사용자가 입력한 생년월일은 맞춤형 정보 제공을 위해 실시간으로만 활용됩니다.',
                '푸시 알림은 서비스 공지 및 사용자 맞춤형 알림 제공을 위해 사용됩니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 3
            _buildSection(
              '3. 개인정보의 보관 및 파기',
              [
                '본 앱은 사용자의 개인정보(생년월일)를 별도로 저장하지 않으며, 앱 종료 시 데이터는 보관되지 않습니다.',
                '푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 4
            _buildSection(
              '4. 개인정보 제3자 제공',
              [
                '본 앱은 어떠한 개인정보도 제3자에게 제공하지 않습니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 5
            _buildSection(
              '5. 개인정보 보호',
              [
                '본 앱은 개인정보를 서버에 저장하지 않으며, 기기 내에서만 처리하여 외부 유출 가능성을 최소화합니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 6
            _buildSection(
              '6. 이용자 권리',
              [
                '사용자는 앱 내 설정을 통해 언제든 푸시 알림을 거부할 수 있습니다.',
                '생년월일 입력은 선택 사항이며, 입력하지 않아도 앱 사용에 제한은 없습니다.',
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 섹션 7
            _buildSection(
              '7. 개인정보처리방침 변경 안내',
              [
                '본 방침은 법령, 정책 또는 보안 기술의 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지 또는 업데이트를 통해 안내합니다.',
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 하단 정보
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
                    Icons.security,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '개인정보 보호를 위해 최선을 다하겠습니다.',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AstroStar Team',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
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
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
