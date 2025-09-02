// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Saju App';

  @override
  String get birthInfoInput => 'Birth Information Input';

  @override
  String get friendInfoInput => 'Friend Information Input';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Please enter your name';

  @override
  String get gender => 'Gender';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get nonBinary => 'N-binary';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthDateHint => 'Please select your birth date';

  @override
  String get birthTime => 'Birth Time';

  @override
  String get birthTimeHint => 'Please select your birth time';

  @override
  String get timeUnknown => 'Time Unknown';

  @override
  String get birthRegion => 'Birth Region';

  @override
  String get searchRegion => 'Search Region';

  @override
  String get searchRegionAgain => 'Search Region Again';

  @override
  String get loveStatus => 'My Love Status';

  @override
  String get loveStatusHint => 'Please select your status';

  @override
  String get married => 'Married';

  @override
  String get inRelationship => 'In a Relationship';

  @override
  String get wantRelationship => 'Want a Relationship';

  @override
  String get noInterest => 'No Interest';

  @override
  String get save => 'Save';

  @override
  String get saveBirthInfo => 'Save Birth Information';

  @override
  String get saveFriendInfo => 'Save Friend Information';

  @override
  String get infoMessage =>
      'AI needs your birth information to tell your unique story.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get hour => 'Hour';

  @override
  String get minute => 'Minute';

  @override
  String get zodiacSign => 'Zodiac Sign';

  @override
  String get zodiacPeriod => 'Zodiac Period';

  @override
  String get validationNameRequired => 'Please enter your name.';

  @override
  String get validationGenderRequired => 'Please select your gender.';

  @override
  String get validationBirthDateRequired => 'Please select your birth date.';

  @override
  String get validationBirthHourRequired => 'Please select your birth hour.';

  @override
  String get validationBirthMinuteRequired =>
      'Please select your birth minute.';

  @override
  String get validationRegionRequired =>
      'Please search and select your birth region.';

  @override
  String get validationStatusRequired => 'Please select your status.';

  @override
  String successBirthInfoSaved(Object zodiacSign) {
    return 'Birth information has been saved! (Zodiac: $zodiacSign)';
  }

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return 'Friend information has been saved! (Zodiac: $zodiacSign)';
  }

  @override
  String get errorBirthInfoSaveFailed => 'Failed to save birth information.';

  @override
  String get errorFriendInfoSaveFailed => 'Failed to save friend information.';

  @override
  String get splashAppName => 'AstroStar';

  @override
  String get splashSubtitle1 =>
      'AstroStar creates short stories based on your basic information.';

  @override
  String get splashSubtitle2 =>
      'AstroStar creates fun literary content\ndaily based on your information.';

  @override
  String get splashSubtitle3 => 'AI tells your unique fortune story.';

  @override
  String get splashSubtitle4 =>
      'Gain new insights through Saju and zodiac signs.';

  @override
  String get splashButtonText => 'Start AI Content';

  @override
  String myPageWelcome(String userName) {
    return 'Welcome, $userName!';
  }

  @override
  String get myPageLogoutSuccess => 'You have been logged out.';

  @override
  String get myPageNotificationTitle => 'Notifications';

  @override
  String get myPageNotificationSubtitle => 'Receive daily fortune stories';

  @override
  String get myPageNotificationStatus => 'Notifications are enabled';

  @override
  String get myPageNotificationPermissionRequired =>
      'Notification Permission Required';

  @override
  String get myPageNotificationPermissionTitle =>
      'Notification Permission Required';

  @override
  String get myPageNotificationPermissionMessage =>
      'Please enable \"Allow Notifications\" in App Settings > Notifications.';

  @override
  String get myPageNotificationPermissionCancel => 'Cancel';

  @override
  String get myPageNotificationPermissionSettings => 'Go to Settings';

  @override
  String get myPageNotificationDisabledMessage =>
      'Notifications are disabled. Please enable notifications and try again.';

  @override
  String myPageNotificationTimeSavedMessage(Object hour, Object minute) {
    return 'Notification time has been saved to $hour:$minute.';
  }

  @override
  String get myPageNotificationConfirmButton => 'Confirm';

  @override
  String myPageThemeChanged(Object themeName) {
    return 'Theme has been changed to \"$themeName\".';
  }

  @override
  String get myPageProfile => 'Profile';

  @override
  String get myPageSettings => 'Settings';

  @override
  String get myPageHelp => 'Help';

  @override
  String get myPageAbout => 'About';

  @override
  String get myPageLogout => 'Logout';

  @override
  String get myPageDeleteAccount => 'Delete Account';

  @override
  String get myPagePrivacyPolicy => 'Privacy Policy';

  @override
  String get myPageTermsOfService => 'Terms of Service';

  @override
  String get myPageVersion => 'Version';

  @override
  String get myPageAppVersion => 'App Version';

  @override
  String get myPageBuildNumber => 'Build Number';

  @override
  String get myPageTitle => 'My Page';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyHeader => 'Privacy Policy';

  @override
  String get privacyPolicySection1Title => '1. Personal Information Collection';

  @override
  String get privacyPolicySection1Content =>
      'This app may receive your date of birth. The entered date of birth is used only within the app for personalized services (e.g., fortune/weather information provision) and is not stored on servers (DB) or externally. The app only stores your push notification reception settings, and does not collect any personal information other than device tokens for notification delivery.';

  @override
  String get privacyPolicySection2Title =>
      '2. Purpose of Personal Information Use';

  @override
  String get privacyPolicySection2Content =>
      'Providing personalized services, novel/poetry/personal guide literature service information, push notification delivery, app function improvement and service quality enhancement';

  @override
  String get privacyPolicySection3Title =>
      '3. Personal Information Storage and Disposal';

  @override
  String get privacyPolicySection3Content =>
      'This app does not separately store users\' personal information (date of birth), and data is not retained when the app is terminated. Device identification tokens for push notifications are immediately disposed of when users delete the app or unsubscribe from notifications.';

  @override
  String get privacyPolicySection4Title =>
      '4. Third-Party Personal Information Provision';

  @override
  String get privacyPolicySection4Content =>
      'This app does not provide any personal information to third parties.';

  @override
  String get privacyPolicySection5Title => '5. Personal Information Protection';

  @override
  String get privacyPolicySection5Content =>
      'This app does not store personal information on servers and processes it only within the device to minimize external leakage possibilities.';

  @override
  String get privacyPolicySection6Title => '6. User Rights';

  @override
  String get privacyPolicySection6Content =>
      'Users can refuse push notifications at any time through app settings. Birth time input is optional, and there are no restrictions on app usage even if not entered.';

  @override
  String get privacyPolicySection7Title => '7. Privacy Policy Change Notice';

  @override
  String get privacyPolicySection7Content =>
      'This policy may be modified according to changes in laws, policies, or security technologies, and users will be notified through app notices or updates when changes occur.';

  @override
  String get privacyPolicyFooter =>
      'We will do our best to protect your personal information.';

  @override
  String get privacyPolicyTeam => 'AstroStar Team';

  @override
  String get myPageManagement => 'Management';

  @override
  String get myPageGeneral => 'General';

  @override
  String get myPageOther => 'Other';

  @override
  String get myPageTheme => 'Theme';

  @override
  String get myPageAppInfo => 'App Info';

  @override
  String get myPageNotificationTime => 'Notification time: ';

  @override
  String get myPageLoggedInWithGoogle => 'Logged in with Google';

  @override
  String get myPageUser => 'User';

  @override
  String get myPageThemeLight => 'Light';

  @override
  String get myPageThemeDark => 'Dark';

  @override
  String get myPageThemeSystem => 'System';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get locationSearchTitle => 'Birth Region Search';

  @override
  String get locationSearchHint => 'Enter region/district/neighborhood';

  @override
  String get locationSearchEmptyMessage => 'Enter a region name to search';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get select => 'Select';

  @override
  String get point => 'pts';

  @override
  String get overall => 'Overall';

  @override
  String get relationship => 'Love';

  @override
  String get wealth => 'Wealth';

  @override
  String get mind => 'Health';

  @override
  String get growth => 'Growth';

  @override
  String get tabTodayGuide => 'Today\'s Guide';

  @override
  String get tabEpisode => 'Episode';

  @override
  String get tabPoetry => 'Poetry';

  @override
  String get todayGuideDetailButton => 'View Today\'s Guide';

  @override
  String get preciousRelationship => 'Precious Love';

  @override
  String get abundance => 'Abundance';

  @override
  String get bodyAndMind => 'Body & Mind';

  @override
  String get growthAndFocus => 'Growth & Focus';

  @override
  String get todayStoryHint =>
      'Today\'s story is just a small hint from the stars.\nYour choices and the path you walk are entirely your own.';

  @override
  String get episodeTitle => 'Today\'s Episode';

  @override
  String get episodeSubtitle => 'Discover a new story about you every day.';

  @override
  String get poetryTitle => 'Today\'s Poetry';

  @override
  String get poetrySubtitle => 'I write a poem for you every day.';
}
