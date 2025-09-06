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
  String get birthTimeHint => '选择出生时间';

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
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 => 'LunaVerse基于您的基本信息创作短篇故事。';

  @override
  String get splashSubtitle2 => 'LunaVerse基于您的信息每天创作有趣的文学内容。';

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
  String get loading => '加载中...';

  @override
  String get todayDetailTitle => '今日指南';

  @override
  String get guideSubtitle => '获取为您的一天量身定制的个性化指导。';

  @override
  String get luckyItem => '幸运物品';

  @override
  String get todayOutfit => '今日穿搭';

  @override
  String get overallFlow => '整体运势';

  @override
  String get score => '分';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicyHeader => '隐私政策';

  @override
  String get privacyPolicySection1Title => '1. 个人信息处理目的';

  @override
  String get privacyPolicySection1Content =>
      'LunaVerse应用程序仅为了提供和改进服务而处理个人信息。如果目的发生变化，我们将根据适用法律采取必要措施，例如获得额外同意。';

  @override
  String get privacyPolicySection1_1Title => '1.1 服务提供';

  @override
  String get privacyPolicySection1_1Content =>
      '• 提供文学内容，如剧集、诗歌朗诵和每日指南\n• 提供个性化内容\n• 改进应用程序功能和服务';

  @override
  String get privacyPolicySection1_2Title => '1.2 客户支持';

  @override
  String get privacyPolicySection1_2Content =>
      '• 处理询问和投诉\n• 提供与服务相关的指导\n• 处理投诉和解决争议';

  @override
  String get privacyPolicySection2Title => '2. 个人信息收集和处理';

  @override
  String get privacyPolicySection2Highlight => '不收集个人信息：';

  @override
  String get privacyPolicySection2Content =>
      '• 应用程序可能要求出生日期、性别或出生地，但这些数据从不存储在服务器上或外部传输\n• 输入的信息仅在应用程序内用于个性化服务（剧集、诗歌朗诵、指南）\n• 仅存储推送通知的设备令牌；不收集其他个人信息';

  @override
  String get privacyPolicySection2LocalTitle => '本地存储：';

  @override
  String get privacyPolicySection2LocalContent =>
      '• 用户输入（例如出生信息）仅临时存储在设备上，卸载应用程序时删除\n• 当用户禁用通知或删除应用程序时，推送通知的设备令牌立即删除';

  @override
  String get privacyPolicySection3Title => '3. 个人信息保留和删除';

  @override
  String get privacyPolicySection3Content =>
      '此应用程序不在服务器或外部存储个人信息（出生日期），但仅在设备上临时存储。数据仅在设备上保留直到删除应用程序，卸载应用程序时所有数据立即删除。当用户禁用通知或删除应用程序时，推送通知的设备令牌立即删除。';

  @override
  String get privacyPolicySection3Highlight => '数据保留政策：';

  @override
  String get privacyPolicySection3HighlightContent =>
      '• 不在服务器上存储个人信息\n• 仅在设备内处理以最小化外部泄漏\n• 卸载应用程序时立即删除所有数据';

  @override
  String get privacyPolicySection4Title => '4. 向第三方提供';

  @override
  String get privacyPolicySection4Content => '此应用程序不向第三方提供任何个人信息。';

  @override
  String get privacyPolicySection4Highlight => '禁止向第三方提供：';

  @override
  String get privacyPolicySection4HighlightContent =>
      '• 不在服务器上存储个人信息，使向第三方提供变得不可能\n• 所有数据仅在设备内处理\n• 不向外部服务器或数据库传输';

  @override
  String get privacyPolicySection5Title => '5. 个人信息保护';

  @override
  String get privacyPolicySection5Content =>
      '此应用程序不在服务器上存储个人信息，仅在设备内处理以最小化外部泄漏。';

  @override
  String get privacyPolicySection5Highlight => '安全措施：';

  @override
  String get privacyPolicySection5HighlightContent =>
      '• 不在服务器上存储个人信息\n• 仅在设备内处理以最小化外部泄漏\n• 卸载应用程序时立即删除所有数据';

  @override
  String get privacyPolicySection6Title => '6. 用户权利';

  @override
  String get privacyPolicySection6Content =>
      '用户可以通过应用程序设置随时选择退出推送通知。提供出生信息是可选的，不是使用应用程序所必需的。';

  @override
  String get privacyPolicySection6Highlight => '用户权利：';

  @override
  String get privacyPolicySection6HighlightContent =>
      '• 选择退出推送通知的权利\n• 选择是否提供出生信息的权利\n• 通过卸载应用程序删除所有数据的权利';

  @override
  String get privacyPolicySection7Title => '7. 此政策变更';

  @override
  String get privacyPolicySection7Content =>
      '此政策可能因法律、政策或技术变更而更新。用户将通过应用程序更新或公告得到通知。';

  @override
  String get privacyPolicySection7Highlight => '变更历史：';

  @override
  String get privacyPolicySection7HighlightContent =>
      '• 2025年9月1日：初始实施\n• 2025年9月1日：政策变更为不收集个人信息';

  @override
  String get privacyPolicySection8Title => '8. 联系';

  @override
  String get privacyPolicySection8Contact => '开发者联系';

  @override
  String get privacyPolicySection8ContactInfo =>
      '姓名：Subak Lee\n职位：开发者\n邮箱：slee29709@gmail.com';

  @override
  String get privacyPolicySection8Content => '如果您对个人信息处理有疑问，请通过上述邮箱地址联系我们。';

  @override
  String get privacyPolicyFooter => '我们将尽最大努力保护您的个人信息。';

  @override
  String get privacyPolicyTeam => 'LunaVerse团队';

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
  String get myPageNotificationTime => '通知时间 ';

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

  @override
  String get episodeTitle => '今日剧集';

  @override
  String get episodeSubtitle => '每天发现关于你的新故事。';

  @override
  String get poetryTitle => '今日诗歌';

  @override
  String get poetrySubtitle => '每天为您写一首诗。';

  @override
  String get lightAndHope => '光与希望';

  @override
  String get summaryLabel => '摘要';

  @override
  String get shareTitle => '分享';

  @override
  String get shareTextCopy => '复制文本';

  @override
  String get shareTextCopied => '文本已复制到剪贴板';

  @override
  String get shareSummaryPrefix => '💡 摘要：';

  @override
  String get shareTomorrowPrefix => '🔮 明日剧集预览：';

  @override
  String get shareTomorrowPoetryPrefix => '🔮 明日诗歌预览：';

  @override
  String get shareAppPromotion => '✨ 在LunaVerse中每天发现新故事！';
}
