// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '四柱算命应用';

  @override
  String get birthInfoInput => '出生信息输入';

  @override
  String get friendInfoInput => '朋友信息输入';

  @override
  String get name => '姓名';

  @override
  String get nameHint => '请输入您的姓名';

  @override
  String get gender => '性别';

  @override
  String get female => '女性';

  @override
  String get male => '男性';

  @override
  String get nonBinary => '非二元性别';

  @override
  String get birthDate => '出生日期';

  @override
  String get birthDateHint => '请选择您的出生日期';

  @override
  String get birthTime => '出生时间';

  @override
  String get birthTimeHint => '请选择您的出生时间';

  @override
  String get timeUnknown => '时间未知';

  @override
  String get birthRegion => '出生地区';

  @override
  String get searchRegion => '搜索地区';

  @override
  String get searchRegionAgain => '重新搜索地区';

  @override
  String get loveStatus => '我的爱情状态';

  @override
  String get loveStatusHint => '请选择您的状态';

  @override
  String get married => '已婚';

  @override
  String get inRelationship => '恋爱中';

  @override
  String get wantRelationship => '希望恋爱';

  @override
  String get noInterest => '不感兴趣';

  @override
  String get save => '保存';

  @override
  String get saveBirthInfo => '保存出生信息';

  @override
  String get saveFriendInfo => '保存朋友信息';

  @override
  String get infoMessage => 'AI需要您的出生信息来讲述您独特的故事。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get year => '年';

  @override
  String get month => '月';

  @override
  String get day => '日';

  @override
  String get hour => '时';

  @override
  String get minute => '分';

  @override
  String get zodiacSign => '星座';

  @override
  String get zodiacPeriod => '星座期间';

  @override
  String get validationNameRequired => '请输入您的姓名。';

  @override
  String get validationGenderRequired => '请选择您的性别。';

  @override
  String get validationBirthDateRequired => '请选择您的出生日期。';

  @override
  String get validationBirthHourRequired => '请选择您的出生小时。';

  @override
  String get validationBirthMinuteRequired => '请选择您的出生分钟。';

  @override
  String get validationRegionRequired => '请搜索并选择您的出生地区。';

  @override
  String get validationStatusRequired => '请选择您的状态。';

  @override
  String successBirthInfoSaved(Object zodiacSign) {
    return '出生信息已保存！(星座: $zodiacSign)';
  }

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return '朋友信息已保存！(星座: $zodiacSign)';
  }

  @override
  String get errorBirthInfoSaveFailed => '保存出生信息失败。';

  @override
  String get errorFriendInfoSaveFailed => '保存朋友信息失败。';

  @override
  String get splashAppName => 'AstroStar';

  @override
  String get splashSubtitle1 => 'AstroStar基于您的基本信息创作短篇故事。';

  @override
  String get splashSubtitle2 => 'AstroStar基于您的信息每天创作有趣的文学内容。';

  @override
  String get splashSubtitle3 => 'AI讲述您独特的运势故事。';

  @override
  String get splashSubtitle4 => '通过四柱和星座获得新的见解。';

  @override
  String get splashButtonText => '开始AI内容';

  @override
  String myPageWelcome(String userName) {
    return '欢迎，$userName！';
  }

  @override
  String get myPageLogoutSuccess => '您已成功登出。';

  @override
  String get myPageNotificationTitle => '通知';

  @override
  String get myPageNotificationSubtitle => '接收每日运势故事';

  @override
  String get myPageNotificationStatus => '通知已启用';

  @override
  String get myPageNotificationPermissionRequired => '需要通知权限';

  @override
  String get myPageNotificationPermissionTitle => '需要通知权限';

  @override
  String get myPageNotificationPermissionMessage => '请在应用设置 > 通知中启用\"允许通知\"。';

  @override
  String get myPageNotificationPermissionCancel => '取消';

  @override
  String get myPageNotificationPermissionSettings => '前往设置';

  @override
  String get myPageNotificationDisabledMessage => '通知已禁用。请启用通知后重试。';

  @override
  String myPageNotificationTimeSavedMessage(Object hour, Object minute) {
    return '通知时间已保存为 $hour:$minute。';
  }

  @override
  String get myPageNotificationConfirmButton => '确认';

  @override
  String myPageThemeChanged(Object themeName) {
    return '主题已更改为\"$themeName\"。';
  }

  @override
  String get myPageProfile => '个人资料';

  @override
  String get myPageSettings => '设置';

  @override
  String get myPageHelp => '帮助';

  @override
  String get myPageAbout => '关于';

  @override
  String get myPageLogout => '登出';

  @override
  String get myPageDeleteAccount => '删除账户';

  @override
  String get myPagePrivacyPolicy => '隐私政策';

  @override
  String get myPageTermsOfService => '服务条款';

  @override
  String get myPageVersion => '版本';

  @override
  String get myPageAppVersion => '应用版本';

  @override
  String get myPageBuildNumber => '构建号';

  @override
  String get myPageTitle => '我的页面';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicyHeader => '隐私政策';

  @override
  String get privacyPolicySection1Title => '1. 个人信息收集';

  @override
  String get privacyPolicySection1Content =>
      '本应用可能会接收您的出生日期。输入的出生日期仅在应用内用于个性化服务（例如：运势/天气信息提供），不会存储在服务器（数据库）或外部。应用仅存储您的推送通知接收设置，除通知发送所需的设备令牌外，不收集任何个人信息。';

  @override
  String get privacyPolicySection2Title => '2. 个人信息使用目的';

  @override
  String get privacyPolicySection2Content =>
      '提供个性化服务、小说/诗歌/个人指南文学服务信息、推送通知发送、应用功能改进和服务质量提升';

  @override
  String get privacyPolicySection3Title => '3. 个人信息存储和处置';

  @override
  String get privacyPolicySection3Content =>
      '本应用不会单独存储用户的个人信息（出生日期），应用终止时数据不会被保留。推送通知的设备识别令牌在用户删除应用或取消订阅通知时会立即处置。';

  @override
  String get privacyPolicySection4Title => '4. 第三方个人信息提供';

  @override
  String get privacyPolicySection4Content => '本应用不会向第三方提供任何个人信息。';

  @override
  String get privacyPolicySection5Title => '5. 个人信息保护';

  @override
  String get privacyPolicySection5Content =>
      '本应用不会在服务器上存储个人信息，仅在设备内处理以最小化外部泄露可能性。';

  @override
  String get privacyPolicySection6Title => '6. 用户权利';

  @override
  String get privacyPolicySection6Content =>
      '用户可以通过应用设置随时拒绝推送通知。出生时间输入是可选的，即使不输入也不会限制应用使用。';

  @override
  String get privacyPolicySection7Title => '7. 隐私政策变更通知';

  @override
  String get privacyPolicySection7Content =>
      '本政策可能会根据法律、政策或安全技术的变化而修改，变更时将通过应用内通知或更新进行通知。';

  @override
  String get privacyPolicyFooter => '我们将尽最大努力保护您的个人信息。';

  @override
  String get privacyPolicyTeam => 'AstroStar团队';

  @override
  String get myPageManagement => '管理';

  @override
  String get myPageGeneral => '常规';

  @override
  String get myPageOther => '其他';

  @override
  String get myPageTheme => '主题';

  @override
  String get myPageAppInfo => '应用信息';

  @override
  String get myPageNotificationTime => '通知时间：';

  @override
  String get myPageLoggedInWithGoogle => '通过Google登录';

  @override
  String get myPageUser => '用户';

  @override
  String get myPageThemeLight => '浅色';

  @override
  String get myPageThemeDark => '深色';

  @override
  String get myPageThemeSystem => '系统';

  @override
  String get am => '上午';

  @override
  String get pm => '下午';

  @override
  String get locationSearchTitle => '出生地区搜索';

  @override
  String get locationSearchHint => '输入地区/区/街道';

  @override
  String get locationSearchEmptyMessage => '输入地区名称进行搜索';

  @override
  String get selectedLocation => '已选位置';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get select => '选择';

  @override
  String get point => '分';

  @override
  String get overall => '整体';

  @override
  String get relationship => '缘分';

  @override
  String get wealth => '财富';

  @override
  String get mind => '健康';

  @override
  String get growth => '成长';

  @override
  String get tabTodayGuide => '今日指南';

  @override
  String get tabEpisode => '剧集';

  @override
  String get tabPoetry => '诗歌朗诵';

  @override
  String get todayGuideDetailButton => '查看今日指南详情';

  @override
  String get preciousRelationship => '珍贵缘分';

  @override
  String get abundance => '丰盛';

  @override
  String get bodyAndMind => '身心';

  @override
  String get growthAndFocus => '成长与专注';

  @override
  String get todayStoryHint => '今天的故事只是星星给你的小提示。\n你的选择和走过的路完全是你自己的。';
}
