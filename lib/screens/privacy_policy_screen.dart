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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            AppLocalizations.of(context)?.privacyPolicyTitle ?? '개인정보보호방침',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.amber,
                    size: 40,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicyHeader ?? '개인정보 처리방침',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 모든 내용을 하나의 박스에 통합
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1Title ?? '1. 개인정보의 처리 목적',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1Content ?? 'LunaVerse 앱은 다음의 목적을 위하여 개인정보를 처리하고 있으며, 이와 관련한 목적이 변경될 경우에는 개인정보보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 7),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1_1Title ?? '1.1 서비스 제공',
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1_1Content ?? '• 에피소드, 시 낭독, 오늘의 가이드 등 문학 컨텐츠 제공\n• 사용자 맞춤형 콘텐츠 제공\n• 앱 기능 및 서비스 개선',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 3),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1_2Title ?? '1.2 고객 지원',
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection1_2Content ?? '• 문의사항 응대 및 처리\n• 서비스 이용 관련 안내\n• 불만사항 처리 및 분쟁해결',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection2Title ?? '2. 개인정보 수집 및 처리',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection2Highlight ?? '개인정보를 수집하지 않습니다:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection2Content ?? '• 본 앱은 사용자의 생년월일, 성별, 출생지역 등을 입력받을 수 있지만 이를 서버나 외부에 저장하지 않습니다.\n• 입력된 정보는 오직 개인 맞춤형 서비스(에피소드, 시 낭독, 오늘의 가이드 제공 등)를 위해 앱 내에서만 사용됩니다.\n• 앱은 사용자의 푸시 알림 수신 여부 설정만 저장하며, 알림 발송을 위한 기기 토큰 외의 개인정보는 수집하지 않습니다.',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection2LocalTitle ?? '로컬 저장 정보:',
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection2LocalContent ?? '• 사용자가 입력한 출생 정보는 기기 내에서만 임시 저장되며, 앱 삭제 시 모든 데이터가 즉시 파기됩니다.\n• 푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection3Title ?? '3. 개인정보의 보관 및 파기',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection3Content ?? '본 앱은 사용자의 개인정보(생년월일)를 서버나 외부에 저장하지 않으며, 기기 내에서만 임시 저장됩니다. 앱을 삭제할 때까지 기기 내에서만 보관되며, 앱 삭제 시 모든 데이터가 즉시 파기됩니다. 푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection3Highlight ?? '데이터 보관 정책:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection3HighlightContent ?? '• 개인정보를 서버에 저장하지 않음\n• 기기 내에서만 처리하여 외부 유출 가능성을 최소화\n• 앱 삭제 시 모든 데이터 즉시 파기',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection4Title ?? '4. 개인정보 제3자 제공',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection4Content ?? '본 앱은 어떠한 개인정보도 제3자에게 제공하지 않습니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection4Highlight ?? '제3자 제공 금지:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection4HighlightContent ?? '• 개인정보를 서버에 저장하지 않으므로 제3자 제공이 불가능\n• 모든 데이터는 기기 내에서만 처리\n• 외부 서버나 데이터베이스에 개인정보 전송 없음',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection5Title ?? '5. 개인정보 보호',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection5Content ?? '본 앱은 개인정보를 서버에 저장하지 않으며, 기기 내에서만 처리하여 외부 유출 가능성을 최소화합니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection5Highlight ?? '보안 조치:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection5HighlightContent ?? '• 개인정보를 서버에 저장하지 않음\n• 기기 내에서만 처리하여 외부 유출 가능성 최소화\n• 앱 삭제 시 모든 데이터 즉시 파기',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection6Title ?? '6. 이용자 권리',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection6Content ?? '사용자는 앱 내 설정을 통해 언제든 푸시 알림을 거부할 수 있습니다. 출생시간 입력은 선택 사항이며, 입력하지 않아도 앱 사용에 제한은 없습니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection6Highlight ?? '이용자 권리:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection6HighlightContent ?? '• 푸시 알림 수신 거부 권리\n• 출생정보 입력 선택권\n• 앱 삭제를 통한 모든 데이터 삭제 권리',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection7Title ?? '7. 개인정보처리방침 변경 안내',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection7Content ?? '본 방침은 법령, 정책 또는 보안 기술의 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지 또는 업데이트를 통해 안내합니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection7Highlight ?? '변경 이력:',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection7HighlightContent ?? '• 2025년 9월 1일: 최초 시행\n• 2025년 9월 1일: 개인정보 수집하지 않음으로 정책 변경',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection8Title ?? '8. 문의 및 연락처',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.green[700]! : Colors.green[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection8Contact ?? '개발팀 연락처',
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)?.privacyPolicySection8ContactInfo ?? '이름: subak lee\n직책: 개발자\n이메일: slee29709@gmail.com',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    AppLocalizations.of(context)?.privacyPolicySection8Content ?? '개인정보 처리와 관련한 문의사항이 있으시면 위 연락처로 문의해 주시기 바랍니다.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // 하단 정보를 메인 박스 안에 추가
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)?.privacyPolicyFooter ?? '개인정보 보호를 위해 최선을 다하겠습니다.',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 3),
                  
                  Center(
                    child: Text(
                      AppLocalizations.of(context)?.privacyPolicyTeam ?? 'LunaVerse Team',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
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
}