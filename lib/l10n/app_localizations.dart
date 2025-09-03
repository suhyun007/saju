import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Saju App'**
  String get appTitle;

  /// No description provided for @birthInfoInput.
  ///
  /// In en, this message translates to:
  /// **'Birth Information Input'**
  String get birthInfoInput;

  /// No description provided for @friendInfoInput.
  ///
  /// In en, this message translates to:
  /// **'Friend Information Input'**
  String get friendInfoInput;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameHint;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @nonBinary.
  ///
  /// In en, this message translates to:
  /// **'N-binary'**
  String get nonBinary;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth date'**
  String get birthDateHint;

  /// No description provided for @birthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthTime;

  /// No description provided for @birthTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select birth time'**
  String get birthTimeHint;

  /// No description provided for @timeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Time Unknown'**
  String get timeUnknown;

  /// No description provided for @birthRegion.
  ///
  /// In en, this message translates to:
  /// **'Birth Region'**
  String get birthRegion;

  /// No description provided for @searchRegion.
  ///
  /// In en, this message translates to:
  /// **'Search Region'**
  String get searchRegion;

  /// No description provided for @searchRegionAgain.
  ///
  /// In en, this message translates to:
  /// **'Search Region Again'**
  String get searchRegionAgain;

  /// No description provided for @loveStatus.
  ///
  /// In en, this message translates to:
  /// **'My Love Status'**
  String get loveStatus;

  /// No description provided for @loveStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Please select your status'**
  String get loveStatusHint;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @inRelationship.
  ///
  /// In en, this message translates to:
  /// **'In a Relationship'**
  String get inRelationship;

  /// No description provided for @wantRelationship.
  ///
  /// In en, this message translates to:
  /// **'Want a Relationship'**
  String get wantRelationship;

  /// No description provided for @noInterest.
  ///
  /// In en, this message translates to:
  /// **'No Interest'**
  String get noInterest;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveBirthInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Birth Information'**
  String get saveBirthInfo;

  /// No description provided for @saveFriendInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Friend Information'**
  String get saveFriendInfo;

  /// No description provided for @infoMessage.
  ///
  /// In en, this message translates to:
  /// **'AI needs your birth information to tell your unique story.'**
  String get infoMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @zodiacSign.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Sign'**
  String get zodiacSign;

  /// No description provided for @zodiacPeriod.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Period'**
  String get zodiacPeriod;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get validationNameRequired;

  /// No description provided for @validationGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get validationGenderRequired;

  /// No description provided for @validationBirthDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth date.'**
  String get validationBirthDateRequired;

  /// No description provided for @validationBirthHourRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth hour.'**
  String get validationBirthHourRequired;

  /// No description provided for @validationBirthMinuteRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth minute.'**
  String get validationBirthMinuteRequired;

  /// No description provided for @validationRegionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please search and select your birth region.'**
  String get validationRegionRequired;

  /// No description provided for @validationStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your status.'**
  String get validationStatusRequired;

  /// No description provided for @successBirthInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Birth information has been saved! (Zodiac: {zodiacSign})'**
  String successBirthInfoSaved(Object zodiacSign);

  /// No description provided for @successFriendInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Friend information has been saved! (Zodiac: {zodiacSign})'**
  String successFriendInfoSaved(Object zodiacSign);

  /// No description provided for @errorBirthInfoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save birth information.'**
  String get errorBirthInfoSaveFailed;

  /// No description provided for @errorFriendInfoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save friend information.'**
  String get errorFriendInfoSaveFailed;

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'LunaVerse'**
  String get splashAppName;

  /// No description provided for @splashSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'LunaVerse creates short stories based on your basic information.'**
  String get splashSubtitle1;

  /// No description provided for @splashSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'LunaVerse creates fun literary content\ndaily based on your information.'**
  String get splashSubtitle2;

  /// No description provided for @splashSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'AI tells your unique fortune story.'**
  String get splashSubtitle3;

  /// No description provided for @splashSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Gain new insights through Saju and zodiac signs.'**
  String get splashSubtitle4;

  /// No description provided for @splashButtonText.
  ///
  /// In en, this message translates to:
  /// **'AI Contents'**
  String get splashButtonText;

  /// User welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}!'**
  String myPageWelcome(String userName);

  /// No description provided for @myPageLogoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have been logged out.'**
  String get myPageLogoutSuccess;

  /// No description provided for @myPageNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get myPageNotificationTitle;

  /// No description provided for @myPageNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive daily fortune stories'**
  String get myPageNotificationSubtitle;

  /// No description provided for @myPageNotificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get myPageNotificationStatus;

  /// No description provided for @myPageNotificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get myPageNotificationPermissionRequired;

  /// No description provided for @myPageNotificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get myPageNotificationPermissionTitle;

  /// No description provided for @myPageNotificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable \"Allow Notifications\" in App Settings > Notifications.'**
  String get myPageNotificationPermissionMessage;

  /// No description provided for @myPageNotificationPermissionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get myPageNotificationPermissionCancel;

  /// No description provided for @myPageNotificationPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get myPageNotificationPermissionSettings;

  /// No description provided for @myPageNotificationDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Please enable notifications and try again.'**
  String get myPageNotificationDisabledMessage;

  /// Notification time saved message
  ///
  /// In en, this message translates to:
  /// **'Notification time has been saved to {hour}:{minute}.'**
  String myPageNotificationTimeSavedMessage(Object hour, Object minute);

  /// No description provided for @myPageNotificationConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get myPageNotificationConfirmButton;

  /// No description provided for @myPageThemeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme has been changed to \"{themeName}\".'**
  String myPageThemeChanged(Object themeName);

  /// No description provided for @myPageProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get myPageProfile;

  /// No description provided for @myPageSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get myPageSettings;

  /// No description provided for @myPageHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get myPageHelp;

  /// No description provided for @myPageAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get myPageAbout;

  /// No description provided for @myPageLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get myPageLogout;

  /// No description provided for @myPageDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get myPageDeleteAccount;

  /// No description provided for @myPagePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get myPagePrivacyPolicy;

  /// No description provided for @myPageTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get myPageTermsOfService;

  /// No description provided for @myPageVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get myPageVersion;

  /// No description provided for @myPageAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get myPageAppVersion;

  /// No description provided for @myPageBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get myPageBuildNumber;

  /// No description provided for @myPageTitle.
  ///
  /// In en, this message translates to:
  /// **'My Page'**
  String get myPageTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @todayDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Guide'**
  String get todayDetailTitle;

  /// No description provided for @luckyItem.
  ///
  /// In en, this message translates to:
  /// **'Lucky Item'**
  String get luckyItem;

  /// No description provided for @todayOutfit.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Outfit'**
  String get todayOutfit;

  /// No description provided for @overallFlow.
  ///
  /// In en, this message translates to:
  /// **'Overall Flow'**
  String get overallFlow;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get score;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyHeader.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyHeader;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Personal Information Collection'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Content.
  ///
  /// In en, this message translates to:
  /// **'This app may receive your date of birth. The entered date of birth is used only within the app for personalized services (e.g., fortune/weather information provision) and is not stored on servers (DB) or externally. The app only stores your push notification reception settings, and does not collect any personal information other than device tokens for notification delivery.'**
  String get privacyPolicySection1Content;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Purpose of Personal Information Use'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Providing personalized services, novel/poetry/personal guide literature service information, push notification delivery, app function improvement and service quality enhancement'**
  String get privacyPolicySection2Content;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Personal Information Storage and Disposal'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Content.
  ///
  /// In en, this message translates to:
  /// **'This app does not separately store users\' personal information (date of birth), and data is not retained when the app is terminated. Device identification tokens for push notifications are immediately disposed of when users delete the app or unsubscribe from notifications.'**
  String get privacyPolicySection3Content;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Third-Party Personal Information Provision'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Content.
  ///
  /// In en, this message translates to:
  /// **'This app does not provide any personal information to third parties.'**
  String get privacyPolicySection4Content;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Personal Information Protection'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Content.
  ///
  /// In en, this message translates to:
  /// **'This app does not store personal information on servers and processes it only within the device to minimize external leakage possibilities.'**
  String get privacyPolicySection5Content;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. User Rights'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Content.
  ///
  /// In en, this message translates to:
  /// **'Users can refuse push notifications at any time through app settings. Birth time input is optional, and there are no restrictions on app usage even if not entered.'**
  String get privacyPolicySection6Content;

  /// No description provided for @privacyPolicySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Privacy Policy Change Notice'**
  String get privacyPolicySection7Title;

  /// No description provided for @privacyPolicySection7Content.
  ///
  /// In en, this message translates to:
  /// **'This policy may be modified according to changes in laws, policies, or security technologies, and users will be notified through app notices or updates when changes occur.'**
  String get privacyPolicySection7Content;

  /// No description provided for @privacyPolicyFooter.
  ///
  /// In en, this message translates to:
  /// **'We will do our best to protect your personal information.'**
  String get privacyPolicyFooter;

  /// No description provided for @privacyPolicyTeam.
  ///
  /// In en, this message translates to:
  /// **'LunaVerse Team'**
  String get privacyPolicyTeam;

  /// No description provided for @myPageManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get myPageManagement;

  /// No description provided for @myPageGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get myPageGeneral;

  /// No description provided for @myPageOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get myPageOther;

  /// No description provided for @myPageTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get myPageTheme;

  /// No description provided for @myPageAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get myPageAppInfo;

  /// No description provided for @myPageNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time: '**
  String get myPageNotificationTime;

  /// No description provided for @myPageLoggedInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Logged in with Google'**
  String get myPageLoggedInWithGoogle;

  /// No description provided for @myPageUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get myPageUser;

  /// No description provided for @myPageThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get myPageThemeLight;

  /// No description provided for @myPageThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get myPageThemeDark;

  /// No description provided for @myPageThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get myPageThemeSystem;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @locationSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth Region Search'**
  String get locationSearchTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter region/district/neighborhood'**
  String get locationSearchHint;

  /// No description provided for @locationSearchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a region name to search'**
  String get locationSearchEmptyMessage;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get point;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get relationship;

  /// No description provided for @wealth.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get wealth;

  /// No description provided for @mind.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get mind;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @tabTodayGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get tabTodayGuide;

  /// No description provided for @tabEpisode.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get tabEpisode;

  /// No description provided for @tabPoetry.
  ///
  /// In en, this message translates to:
  /// **'Poetry'**
  String get tabPoetry;

  /// No description provided for @todayGuideDetailButton.
  ///
  /// In en, this message translates to:
  /// **'View Today\'s Guide'**
  String get todayGuideDetailButton;

  /// No description provided for @preciousRelationship.
  ///
  /// In en, this message translates to:
  /// **'Precious Love'**
  String get preciousRelationship;

  /// No description provided for @abundance.
  ///
  /// In en, this message translates to:
  /// **'Abundance'**
  String get abundance;

  /// No description provided for @bodyAndMind.
  ///
  /// In en, this message translates to:
  /// **'Body & Mind'**
  String get bodyAndMind;

  /// No description provided for @growthAndFocus.
  ///
  /// In en, this message translates to:
  /// **'Growth & Focus'**
  String get growthAndFocus;

  /// No description provided for @todayStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Today\'s story is just a small hint from the stars.\nYour choices and the path you walk are entirely your own.'**
  String get todayStoryHint;

  /// No description provided for @episodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Episode'**
  String get episodeTitle;

  /// No description provided for @episodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover a new story about you every day.'**
  String get episodeSubtitle;

  /// No description provided for @poetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Poetry'**
  String get poetryTitle;

  /// No description provided for @poetrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'I write a poem for you every day.'**
  String get poetrySubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
