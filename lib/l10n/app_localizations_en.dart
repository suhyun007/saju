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
  String get birthTimeHint => 'Select birth time';

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
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 =>
      'LunaVerse creates short stories based on your basic information.';

  @override
  String get splashSubtitle2 =>
      'LunaVerse creates fun literary content\ndaily based on your information.';

  @override
  String get splashSubtitle3 => 'AI tells your unique fortune story.';

  @override
  String get splashSubtitle4 =>
      'Gain new insights through Saju and zodiac signs.';

  @override
  String get splashButtonText => 'AI Contents';

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
  String get loading => 'Loading...';

  @override
  String get todayDetailTitle => 'Today\'s Guide';

  @override
  String get guideSubtitle => 'Get personalized guidance for your day ahead.';

  @override
  String get luckyItem => 'Lucky Item';

  @override
  String get todayOutfit => 'Today\'s Outfit';

  @override
  String get overallFlow => 'Overall Flow';

  @override
  String get score => 'pts';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyHeader => 'Privacy Policy';

  @override
  String get privacyPolicySection1Title =>
      '1. Purpose of Processing Personal Information';

  @override
  String get privacyPolicySection1Content =>
      'The LunaVerse app processes personal information solely to provide and improve services. If the purpose changes, we will take necessary measures, such as obtaining additional consent, in accordance with applicable laws.';

  @override
  String get privacyPolicySection1_1Title => '1.1 Service Provision';

  @override
  String get privacyPolicySection1_1Content =>
      '• Provide literary content such as episodes, poetry readings, and daily guides\n• Deliver personalized content\n• Improve app functions and services';

  @override
  String get privacyPolicySection1_2Title => '1.2 Customer Support';

  @override
  String get privacyPolicySection1_2Content =>
      '• Handle inquiries and complaints\n• Provide service-related guidance\n• Process complaints and resolve disputes';

  @override
  String get privacyPolicySection2Title =>
      '2. Collection and Processing of Personal Information';

  @override
  String get privacyPolicySection2Highlight =>
      'No personal information is collected:';

  @override
  String get privacyPolicySection2Content =>
      '• The app may request date of birth, gender, or birthplace, but this data is never stored on servers or transmitted externally\n• Entered information is used only within the app for personalized services (episodes, poetry readings, guides)\n• Only the device token for push notifications is stored; no other personal information is collected';

  @override
  String get privacyPolicySection2LocalTitle => 'Local storage:';

  @override
  String get privacyPolicySection2LocalContent =>
      '• User input (e.g., birth info) is temporarily stored only on the device and deleted when the app is uninstalled\n• Device tokens for push notifications are deleted immediately when the user disables notifications or removes the app';

  @override
  String get privacyPolicySection3Title =>
      '3. Retention and Deletion of Personal Information';

  @override
  String get privacyPolicySection3Content =>
      'This app does not store personal information (date of birth) on servers or externally, but temporarily stores it only on the device. Data is retained only on the device until the app is deleted, and all data is immediately deleted when the app is uninstalled. Device tokens for push notifications are immediately deleted when the user disables notifications or removes the app.';

  @override
  String get privacyPolicySection3Highlight => 'Data retention policy:';

  @override
  String get privacyPolicySection3HighlightContent =>
      '• No personal information stored on servers\n• Minimize external leakage by processing only within the device\n• All data immediately deleted when app is uninstalled';

  @override
  String get privacyPolicySection4Title => '4. Provision to Third Parties';

  @override
  String get privacyPolicySection4Content =>
      'This app does not provide any personal information to third parties.';

  @override
  String get privacyPolicySection4Highlight => 'No third-party provision:';

  @override
  String get privacyPolicySection4HighlightContent =>
      '• No personal information stored on servers, making third-party provision impossible\n• All data processed only within the device\n• No transmission to external servers or databases';

  @override
  String get privacyPolicySection5Title =>
      '5. Protection of Personal Information';

  @override
  String get privacyPolicySection5Content =>
      'This app does not store personal information on servers and processes it only within the device to minimize external leakage.';

  @override
  String get privacyPolicySection5Highlight => 'Security measures:';

  @override
  String get privacyPolicySection5HighlightContent =>
      '• No personal information stored on servers\n• Minimize external leakage by processing only within the device\n• All data immediately deleted when app is uninstalled';

  @override
  String get privacyPolicySection6Title => '6. User Rights';

  @override
  String get privacyPolicySection6Content =>
      'Users may opt out of push notifications at any time through app settings. Providing birth information is optional and not required to use the app.';

  @override
  String get privacyPolicySection6Highlight => 'User rights:';

  @override
  String get privacyPolicySection6HighlightContent =>
      '• Right to opt out of push notifications\n• Right to choose whether to provide birth information\n• Right to delete all data by uninstalling the app';

  @override
  String get privacyPolicySection7Title => '7. Changes to this Policy';

  @override
  String get privacyPolicySection7Content =>
      'This policy may be updated due to legal, policy, or technical changes. Users will be notified via app updates or announcements.';

  @override
  String get privacyPolicySection7Highlight => 'Change history:';

  @override
  String get privacyPolicySection7HighlightContent =>
      '• September 1, 2025: Initial implementation\n• September 1, 2025: Policy change to not collect personal information';

  @override
  String get privacyPolicySection8Title => '8. Contact';

  @override
  String get privacyPolicySection8Contact => 'Developer Contact';

  @override
  String get privacyPolicySection8ContactInfo =>
      'Name: Subak Lee\nRole: Developer\nEmail: slee29709@gmail.com';

  @override
  String get privacyPolicySection8Content =>
      'If you have questions about personal information processing, please contact us at the above email address.';

  @override
  String get privacyPolicyFooter =>
      'We will do our best to protect your personal information.';

  @override
  String get privacyPolicyTeam => 'LunaVerse Team';

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
  String get myPageNotificationTime => 'Notification time ';

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
  String get tabTodayGuide => 'Guide';

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

  @override
  String get lightAndHope => 'Light & Hope';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get shareTitle => 'Share';

  @override
  String get shareTextCopy => 'Copy Text';

  @override
  String get shareTextCopied => 'Text has been copied to clipboard';

  @override
  String get shareSummaryPrefix => '💡 Summary:';

  @override
  String get shareTomorrowPrefix => '🔮 Tomorrow\'s Episode Preview:';

  @override
  String get shareAppPromotion =>
      '✨ Discover new stories every day with LunaVerse!';
}
