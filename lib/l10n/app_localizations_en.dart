// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LunaVerse App';

  @override
  String get notificationTitle => 'Moonlight Chat';

  @override
  String get birthInfoInput => 'Character Setup';

  @override
  String get friendInfoInput => 'Friend Information Input';

  @override
  String get name => 'Character Name';

  @override
  String get nameHint => 'Enter your character’s name';

  @override
  String get gender => 'Character Gender';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get nonBinary => 'N-binary';

  @override
  String get birthDate => 'Character Age';

  @override
  String get birthDateHint => 'Please select character birth date';

  @override
  String get birthTime => 'Birth Time';

  @override
  String get birthTimeHint => 'Select birth time';

  @override
  String get timeUnknown => 'Time Unknown';

  @override
  String get birthRegion => 'Character’s World';

  @override
  String get searchRegion => 'Search Region';

  @override
  String get searchRegionAgain => 'Search Region Again';

  @override
  String get loveStatus => 'Character’s Tone';

  @override
  String get loveStatusHint => 'Choose a character tone (optional)';

  @override
  String get toneWarm => 'Warm';

  @override
  String get toneCalm => 'Calm';

  @override
  String get toneLovely => 'Lovely';

  @override
  String get toneUrban => 'Urban';

  @override
  String get tonePositive => 'Positive';

  @override
  String get toneFunny => 'Funny';

  @override
  String get toneEmotional => 'Emotional';

  @override
  String get toneHopeful => 'Hopeful';

  @override
  String get tonePassionate => 'Passionate';

  @override
  String get toneFutureOriented => 'Future-oriented';

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
  String get saveBirthInfo => 'Save Character';

  @override
  String get saveFriendInfo => 'Save Friend Information';

  @override
  String get infoMessage => 'Meet your character\nand begin your story.';

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
  String get validationStatusRequired => 'Choose a character tone (optional)';

  @override
  String get statusSelectHint => 'Choose a character tone (optional)';

  @override
  String get successBirthInfoSaved => 'Information has been saved!';

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return 'Friend information has been saved! (Zodiac: $zodiacSign)';
  }

  @override
  String get favoriteAlreadySaved => 'Already saved to favorites.';

  @override
  String get errorBirthInfoSaveFailed => 'Failed to save birth information.';

  @override
  String get errorFriendInfoSaveFailed => 'Failed to save friend information.';

  @override
  String themeChangedMessage(Object theme) {
    return 'Theme has been changed to \"$theme\".';
  }

  @override
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 =>
      'LunaVerse creates short stories based on your basic information.';

  @override
  String get splashSubtitle2 =>
      'Begin your journey today—\ndiscover a new episode and poem each day, save your favorites, and gently build your own library.';

  @override
  String get splashSubtitle3 => 'AI tells your unique fortune story.';

  @override
  String get splashSubtitle4 =>
      'Gain new insights through Saju and zodiac signs.';

  @override
  String get splashButtonText => 'Read Today’s Story';

  @override
  String myPageWelcome(String userName) {
    return 'Welcome, $userName!';
  }

  @override
  String get existPlashSubtitle =>
      'Good to see you again.\nYour story continues.';

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
  String get locationSearchTitle => 'Region Search';

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
  String get tabFavorites => 'Favorites';

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
  String get bodyAndMind => 'Balance & Harmony';

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
  String get shareSummaryPrefix => '💡Summary:';

  @override
  String get shareTomorrowPrefix => '🔮Tomorrow\'s Episode Preview:';

  @override
  String get shareTomorrowPoetryPrefix => '🔮Tomorrow\'s Poetry Preview:';

  @override
  String get shareAppPromotion =>
      '✨ Discover new stories every day with LunaVerse!';

  @override
  String get shareButton => 'Share';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineMessage =>
      'Internet connection is required. Please connect and try again.';

  @override
  String get offlineClose => 'Close';

  @override
  String get offlineRetry => 'Retry';

  @override
  String get sampleStory => 'Try a Sample Story';

  @override
  String get sampleStoryHeader => 'Sample Story 🌙\n“The Morning Window”';

  @override
  String get sampleStoryP1 =>
      'When you opened your window this morning, the world felt strangely quiet, as if waiting for you. The sky carried a pale shade of blue, and in that stillness, you sensed something tender unfolding.';

  @override
  String get sampleStoryP2 =>
      'Walking down the street, you noticed small details—sunlight caught in the branches, a stranger smiling for no reason...';

  @override
  String get makeMyStoryButton => 'Set Up Character';

  @override
  String get aboutLunaVerseTitle => 'About LunaVerse';

  @override
  String get aboutLunaVerseContent =>
      'LunaVerse takes inspiration from your moments to create new stories and poems every day. Check out what story will unfold today.';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get favoritesEmptyTitle => 'No Favorites Yet';

  @override
  String get favoritesEmptyMessage =>
      'Collect your favorite episodes and poetry to create your personal library.';

  @override
  String get characterEra => 'Character’s Era';

  @override
  String get eraHint => 'Choose an era (optional)';

  @override
  String get eraAncientTimes => 'Ancient Times';

  @override
  String get eraMedievalAge => 'Medieval Age';

  @override
  String get eraVictorianEra => 'Victorian Era';

  @override
  String get eraModernDay => 'Modern Day';

  @override
  String get eraNearFuture => 'Near Future';

  @override
  String get eraDistantFuture => 'Distant Future';

  @override
  String get eraMythicalAge => 'Mythical Age';

  @override
  String get eraTimelessRealm => 'Timeless Realm';

  @override
  String get characterValidationTitle =>
      'No character information has been entered.';

  @override
  String get characterValidationBody =>
      'Your input is empty, so there\'s no character information to save.';

  @override
  String get memo => 'Memo';

  @override
  String get memoEdit => 'Edit Memo';

  @override
  String get memoInputHint => 'Enter memo (max 1000 characters)';

  @override
  String get memoAddHint => 'Add a memo';

  @override
  String get close => 'Close';

  @override
  String get favoritesDeleteConfirmMessage => 'Delete this favorite?';

  @override
  String get favoritesDeleted => 'Deleted.';

  @override
  String get memoSaved => 'Memo saved.';

  @override
  String get memoDeleted => 'Memo deleted.';

  @override
  String get experienceTry => 'Try Demo';

  @override
  String get experienceMode => 'Demo Mode';

  @override
  String get experienceEntering => 'Entering demo mode.';

  @override
  String get guest => 'Guest';

  @override
  String get sajuInfo => 'Character Info';

  @override
  String get sajuInfoInputPrompt => 'Please enter your character info.';

  @override
  String get pushPixMessage => 'Right now, a special story is waiting for you.';
}
