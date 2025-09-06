// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '사주앱';

  @override
  String get birthInfoInput => '출생 정보 입력';

  @override
  String get friendInfoInput => '친구 정보 입력';

  @override
  String get name => '이름';

  @override
  String get nameHint => '이름을 입력해주세요';

  @override
  String get gender => '성별';

  @override
  String get female => '여성';

  @override
  String get male => '남성';

  @override
  String get nonBinary => '논바이너리';

  @override
  String get birthDate => '출생일자';

  @override
  String get birthDateHint => '생년월일을 선택해주세요';

  @override
  String get birthTime => '출생시간';

  @override
  String get birthTimeHint => '출생시간 선택';

  @override
  String get timeUnknown => '시간모름';

  @override
  String get birthRegion => '태어난 지역';

  @override
  String get searchRegion => '지역 검색하기';

  @override
  String get searchRegionAgain => '지역 다시 검색';

  @override
  String get loveStatus => '사랑에 대한 나의 상태';

  @override
  String get loveStatusHint => '상태를 선택해주세요';

  @override
  String get married => '결혼';

  @override
  String get inRelationship => '연애중';

  @override
  String get wantRelationship => '연애하고 싶음';

  @override
  String get noInterest => '관심없음';

  @override
  String get save => '저장';

  @override
  String get saveBirthInfo => '출생 정보 저장';

  @override
  String get saveFriendInfo => '친구 정보 저장';

  @override
  String get infoMessage => 'AI가 당신만의 이야기를\n풀어내려면 출생정보가 필요해요.';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get year => '년';

  @override
  String get month => '월';

  @override
  String get day => '일';

  @override
  String get hour => '시';

  @override
  String get minute => '분';

  @override
  String get zodiacSign => '띠';

  @override
  String get zodiacPeriod => '띠 기간';

  @override
  String get validationNameRequired => '이름을 입력해주세요.';

  @override
  String get validationGenderRequired => '성별을 선택해주세요.';

  @override
  String get validationBirthDateRequired => '생년월일을 선택해주세요.';

  @override
  String get validationBirthHourRequired => '출생 시를 선택해주세요.';

  @override
  String get validationBirthMinuteRequired => '출생 분을 선택해주세요.';

  @override
  String get validationRegionRequired => '출생 지역을 검색하고 선택해주세요.';

  @override
  String get validationStatusRequired => '상태를 선택해주세요.';

  @override
  String successBirthInfoSaved(Object zodiacSign) {
    return '출생 정보가 저장되었습니다! (띠: $zodiacSign)';
  }

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return '친구 정보가 저장되었습니다! (띠: $zodiacSign)';
  }

  @override
  String get errorBirthInfoSaveFailed => '출생 정보 저장에 실패했습니다.';

  @override
  String get errorFriendInfoSaveFailed => '친구 정보 저장에 실패했습니다.';

  @override
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 => 'LunaVerse가 당신의 기본정보를 바탕으로 짧은 이야기를 만들어드립니다.';

  @override
  String get splashSubtitle2 =>
      'LunaVerse가 당신의 정보를 바탕으로 매일 재미있는 문학 콘텐츠를 만들어드립니다.';

  @override
  String get splashSubtitle3 => '당신만의 운세 이야기를 AI가 들려드립니다.';

  @override
  String get splashSubtitle4 => '사주와 별자리를 통해 새로운 인사이트를 얻어보세요.';

  @override
  String get splashButtonText => 'AI 콘텐츠 시작';

  @override
  String myPageWelcome(String userName) {
    return '$userName님 환영합니다!';
  }

  @override
  String get myPageLogoutSuccess => '로그아웃 되었습니다.';

  @override
  String get myPageNotificationTitle => '알림 사용';

  @override
  String get myPageNotificationSubtitle => '매일 새로운 운세 이야기를 받아보세요';

  @override
  String get myPageNotificationStatus => '알림이 활성화되어 있습니다';

  @override
  String get myPageNotificationPermissionRequired => '알림 권한 필요';

  @override
  String get myPageNotificationPermissionTitle => '알림 권한 필요';

  @override
  String get myPageNotificationPermissionMessage =>
      '앱설정 > 알림에서 \"알림 허용\"을 켜주세요.';

  @override
  String get myPageNotificationPermissionCancel => '취소';

  @override
  String get myPageNotificationPermissionSettings => '설정으로 이동';

  @override
  String get myPageNotificationDisabledMessage =>
      '알림이 비활성화되어 있습니다. 알림을 켜고 다시 시도해주세요.';

  @override
  String myPageNotificationTimeSavedMessage(Object hour, Object minute) {
    return '알림 시간이 $hour:$minute로 저장되었습니다.';
  }

  @override
  String get myPageNotificationConfirmButton => '확인';

  @override
  String myPageThemeChanged(Object themeName) {
    return '테마가 \"$themeName\"(으)로 변경되었습니다.';
  }

  @override
  String get myPageProfile => '프로필';

  @override
  String get myPageSettings => '설정';

  @override
  String get myPageHelp => '도움말';

  @override
  String get myPageAbout => '정보';

  @override
  String get myPageLogout => '로그아웃';

  @override
  String get myPageDeleteAccount => '계정 삭제';

  @override
  String get myPagePrivacyPolicy => '개인정보보호방침';

  @override
  String get myPageTermsOfService => '이용약관';

  @override
  String get myPageVersion => '버전';

  @override
  String get myPageAppVersion => '앱 버전';

  @override
  String get myPageBuildNumber => '빌드 번호';

  @override
  String get myPageTitle => '마이페이지';

  @override
  String get loading => '로딩중...';

  @override
  String get todayDetailTitle => '오늘의 가이드';

  @override
  String get guideSubtitle => '오늘 하루를 위한 맞춤형 가이드를 받아보세요.';

  @override
  String get luckyItem => '행운의 아이템';

  @override
  String get todayOutfit => '오늘의 코디';

  @override
  String get overallFlow => '전체의 흐름';

  @override
  String get score => '점';

  @override
  String get privacyPolicyTitle => '개인정보보호방침';

  @override
  String get privacyPolicyHeader => '개인정보 처리방침';

  @override
  String get privacyPolicySection1Title => '1. 개인정보의 처리 목적';

  @override
  String get privacyPolicySection1Content =>
      'LunaVerse 앱은 다음의 목적을 위하여 개인정보를 처리하고 있으며, 이와 관련한 목적이 변경될 경우에는 개인정보보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.';

  @override
  String get privacyPolicySection1_1Title => '1.1 서비스 제공';

  @override
  String get privacyPolicySection1_1Content =>
      '• 에피소드, 시 낭독, 오늘의 가이드 등 문학 컨텐츠 제공\n• 사용자 맞춤형 콘텐츠 제공\n• 앱 기능 및 서비스 개선';

  @override
  String get privacyPolicySection1_2Title => '1.2 고객 지원';

  @override
  String get privacyPolicySection1_2Content =>
      '• 문의사항 응대 및 처리\n• 서비스 이용 관련 안내\n• 불만사항 처리 및 분쟁해결';

  @override
  String get privacyPolicySection2Title => '2. 개인정보 수집 및 처리';

  @override
  String get privacyPolicySection2Highlight => '개인정보를 수집하지 않습니다:';

  @override
  String get privacyPolicySection2Content =>
      '• 본 앱은 사용자의 생년월일, 성별, 출생지역 등을 입력받을 수 있지만 이를 서버나 외부에 저장하지 않습니다.\n• 입력된 정보는 오직 개인 맞춤형 서비스(에피소드, 시 낭독, 오늘의 가이드 제공 등)를 위해 앱 내에서만 사용됩니다.\n• 앱은 사용자의 푸시 알림 수신 여부 설정만 저장하며, 알림 발송을 위한 기기 토큰 외의 개인정보는 수집하지 않습니다.';

  @override
  String get privacyPolicySection2LocalTitle => '로컬 저장 정보:';

  @override
  String get privacyPolicySection2LocalContent =>
      '• 사용자가 입력한 출생 정보는 기기 내에서만 임시 저장되며, 앱 삭제 시 모든 데이터가 즉시 파기됩니다.\n• 푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.';

  @override
  String get privacyPolicySection3Title => '3. 개인정보의 보관 및 파기';

  @override
  String get privacyPolicySection3Content =>
      '본 앱은 사용자의 개인정보(생년월일)를 서버나 외부에 저장하지 않으며, 기기 내에서만 임시 저장됩니다. 앱을 삭제할 때까지 기기 내에서만 보관되며, 앱 삭제 시 모든 데이터가 즉시 파기됩니다. 푸시 알림을 위한 기기 식별 토큰은 사용자가 앱을 삭제하거나 알림 수신을 해제하면 즉시 파기됩니다.';

  @override
  String get privacyPolicySection3Highlight => '데이터 보관 정책:';

  @override
  String get privacyPolicySection3HighlightContent =>
      '• 개인정보를 서버에 저장하지 않음\n• 기기 내에서만 처리하여 외부 유출 가능성을 최소화\n• 앱 삭제 시 모든 데이터 즉시 파기';

  @override
  String get privacyPolicySection4Title => '4. 개인정보 제3자 제공';

  @override
  String get privacyPolicySection4Content => '본 앱은 어떠한 개인정보도 제3자에게 제공하지 않습니다.';

  @override
  String get privacyPolicySection4Highlight => '제3자 제공 금지:';

  @override
  String get privacyPolicySection4HighlightContent =>
      '• 개인정보를 서버에 저장하지 않으므로 제3자 제공이 불가능\n• 모든 데이터는 기기 내에서만 처리\n• 외부 서버나 데이터베이스에 개인정보 전송 없음';

  @override
  String get privacyPolicySection5Title => '5. 개인정보 보호';

  @override
  String get privacyPolicySection5Content =>
      '본 앱은 개인정보를 서버에 저장하지 않으며, 기기 내에서만 처리하여 외부 유출 가능성을 최소화합니다.';

  @override
  String get privacyPolicySection5Highlight => '보안 조치:';

  @override
  String get privacyPolicySection5HighlightContent =>
      '• 개인정보를 서버에 저장하지 않음\n• 기기 내에서만 처리하여 외부 유출 가능성 최소화\n• 앱 삭제 시 모든 데이터 즉시 파기';

  @override
  String get privacyPolicySection6Title => '6. 이용자 권리';

  @override
  String get privacyPolicySection6Content =>
      '사용자는 앱 내 설정을 통해 언제든 푸시 알림을 거부할 수 있습니다. 출생시간 입력은 선택 사항이며, 입력하지 않아도 앱 사용에 제한은 없습니다.';

  @override
  String get privacyPolicySection6Highlight => '이용자 권리:';

  @override
  String get privacyPolicySection6HighlightContent =>
      '• 푸시 알림 수신 거부 권리\n• 출생정보 입력 선택권\n• 앱 삭제를 통한 모든 데이터 삭제 권리';

  @override
  String get privacyPolicySection7Title => '7. 개인정보처리방침 변경 안내';

  @override
  String get privacyPolicySection7Content =>
      '본 방침은 법령, 정책 또는 보안 기술의 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지 또는 업데이트를 통해 안내합니다.';

  @override
  String get privacyPolicySection7Highlight => '변경 이력:';

  @override
  String get privacyPolicySection7HighlightContent =>
      '• 2025년 9월 1일: 최초 시행\n• 2025년 9월 1일: 개인정보 수집하지 않음으로 정책 변경';

  @override
  String get privacyPolicySection8Title => '8. 문의 및 연락처';

  @override
  String get privacyPolicySection8Contact => '개발팀 연락처';

  @override
  String get privacyPolicySection8ContactInfo =>
      '이름: subak lee\n직책: 개발자\n이메일: slee29709@gmail.com';

  @override
  String get privacyPolicySection8Content =>
      '개인정보 처리와 관련한 문의사항이 있으시면 위 연락처로 문의해 주시기 바랍니다.';

  @override
  String get privacyPolicyFooter => '개인정보 보호를 위해 최선을 다하겠습니다.';

  @override
  String get privacyPolicyTeam => 'LunaVerse Team';

  @override
  String get myPageManagement => '관리';

  @override
  String get myPageGeneral => '일반';

  @override
  String get myPageOther => '기타';

  @override
  String get myPageTheme => '테마';

  @override
  String get myPageAppInfo => '앱 정보';

  @override
  String get myPageNotificationTime => '알림 시간 ';

  @override
  String get myPageLoggedInWithGoogle => '구글에서 로그인';

  @override
  String get myPageUser => '사용자';

  @override
  String get myPageThemeLight => '라이트';

  @override
  String get myPageThemeDark => '다크';

  @override
  String get myPageThemeSystem => '시스템';

  @override
  String get am => '오전';

  @override
  String get pm => '오후';

  @override
  String get locationSearchTitle => '태어난 지역 검색';

  @override
  String get locationSearchHint => '지역/구/동을 입력하세요';

  @override
  String get locationSearchEmptyMessage => '지역명을 입력하여 검색하세요';

  @override
  String get selectedLocation => '선택된 위치';

  @override
  String get latitude => '위도';

  @override
  String get longitude => '경도';

  @override
  String get select => '선택';

  @override
  String get point => '점';

  @override
  String get overall => '전체';

  @override
  String get relationship => '인연';

  @override
  String get wealth => '풍요';

  @override
  String get mind => '마음';

  @override
  String get growth => '성장';

  @override
  String get tabTodayGuide => '가이드';

  @override
  String get tabEpisode => '에피소드';

  @override
  String get tabPoetry => '시 낭독';

  @override
  String get todayGuideDetailButton => '오늘의 가이드 자세히 보기';

  @override
  String get preciousRelationship => '소중한 인연';

  @override
  String get abundance => '풍요로움';

  @override
  String get bodyAndMind => '몸과 마음';

  @override
  String get growthAndFocus => '성장과 집중';

  @override
  String get todayStoryHint =>
      '오늘의 이야기는 별이 전해주는 작은 힌트일 뿐이에요.\n당신의 선택과 걸어가는 길은 오롯이 당신만의 것이에요.';

  @override
  String get episodeTitle => '오늘의 에피소드';

  @override
  String get episodeSubtitle => '매일 새로운 당신의 이야기를 만나보세요.';

  @override
  String get poetryTitle => '오늘의 시 낭독';

  @override
  String get poetrySubtitle => '매일 당신에게 시 한 편을 지어드려요.';

  @override
  String get lightAndHope => '빛과 희망';

  @override
  String get summaryLabel => '요약';

  @override
  String get shareTitle => '공유하기';

  @override
  String get shareTextCopy => '텍스트 복사';

  @override
  String get shareTextCopied => '텍스트가 클립보드에 복사되었습니다';

  @override
  String get shareSummaryPrefix => '💡 요약:';

  @override
  String get shareTomorrowPrefix => '🔮 내일의 에피소드 미리보기:';

  @override
  String get shareTomorrowPoetryPrefix => '🔮 내일의 시 미리보기:';

  @override
  String get shareAppPromotion => '✨ LunaVerse에서 매일 새로운 이야기를 만나보세요!';
}
