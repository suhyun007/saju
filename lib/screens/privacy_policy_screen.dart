import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),
            
            // 메인 콘텐츠
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)?.privacyPolicyTitle ?? '개인정보보호방침',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? [
            const Color(0xFF2C1810),
            const Color(0xFF4A2C1A),
            const Color(0xFF8B4513),
          ] : [
            Colors.grey.shade50,
            Colors.grey.shade100,
            Colors.grey.shade200,
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
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.amber,
                    size: 40,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicyHeader ?? '개인정보 처리방침',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // 통합 섹션
            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection1Title ?? '1. 수집하는 개인정보',
              AppLocalizations.of(context)?.privacyPolicySection1Content ?? '본 앱은 사용자의 생년월일을 입력받을 수 있습니다. 입력된 생년월일은 오직 개인 맞춤형 서비스(예: 운세/날씨 정보 제공 등)를 위해 앱 내에서만 사용되며, 서버(DB)나 외부에 저장되지 않습니다. 앱은 사용자의 푸시 알림 수신 여부 설정만 저장하며, 알림 발송을 위한 기기 토큰 외의 개인정보는 수집하지 않습니다.',
            ),
            
            const SizedBox(height: 0),
          
            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection2Title ?? '2. 개인정보의 이용 목적',
              AppLocalizations.of(context)?.privacyPolicySection2Content ?? '개인 맞춤형 서비스 제공, 소설/시/개인 가이드 문학 서비스 정보 제공, 푸시 알림 발송, 앱 기능 개선 및 서비스 품질 향상',
            ),

            const SizedBox(height: 0),

            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection3Title ?? '3. 개인정보의 보관 및 파기',
              AppLocalizations.of(context)?.privacyPolicySection3Content ?? '본 앱은 사용자의 개인정보(생년월일)를 별도로 저장하지 않으며, 앱 종료 시 데이터는 보관되지 않습니다. 푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.',
            ),

            const SizedBox(height: 0),

            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection4Title ?? '4. 개인정보 제3자 제공',
              AppLocalizations.of(context)?.privacyPolicySection4Content ?? '본 앱은 어떠한 개인정보도 제3자에게 제공하지 않습니다.',
            ),
            const SizedBox(height: 0),

            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection5Title ?? '5. 개인정보 보호',
              AppLocalizations.of(context)?.privacyPolicySection5Content ?? '본 앱은 개인정보를 서버에 저장하지 않으며, 기기 내에서만 처리하여 외부 유출 가능성을 최소화합니다.',
            ),
            const SizedBox(height: 0),

            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection6Title ?? '6. 이용자 권리',
              AppLocalizations.of(context)?.privacyPolicySection6Content ?? '사용자는 앱 내 설정을 통해 언제든 푸시 알림을 거부할 수 있습니다. 출생시간 입력은 선택 사항이며, 입력하지 않아도 앱 사용에 제한은 없습니다.',
            ),
            const SizedBox(height: 0),

            _buildSection(
              context,
              AppLocalizations.of(context)?.privacyPolicySection7Title ?? '7. 개인정보처리방침 변경 안내',
              AppLocalizations.of(context)?.privacyPolicySection7Content ?? '본 방침은 법령, 정책 또는 보안 기술의 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지 또는 업데이트를 통해 안내합니다.',
            ),
            // 하단 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicyFooter ?? '개인정보 보호를 위해 최선을 다하겠습니다.',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicyTeam ?? 'AstroStar Team',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
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

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            content,
            textAlign: TextAlign.left,
            style: GoogleFonts.notoSans(
              fontSize: 17,
              color: Theme.of(context).colorScheme.onBackground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
