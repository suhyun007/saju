// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '四柱推命アプリ';

  @override
  String get birthInfoInput => '出生情報入力';

  @override
  String get friendInfoInput => '友達情報入力';

  @override
  String get name => '名前';

  @override
  String get nameHint => '名前を入力してください';

  @override
  String get gender => '性別';

  @override
  String get female => '女性';

  @override
  String get male => '男性';

  @override
  String get nonBinary => 'ノンバイナリー';

  @override
  String get birthDate => '出生日';

  @override
  String get birthDateHint => '生年月日を選択してください';

  @override
  String get birthTime => '出生時刻';

  @override
  String get birthTimeHint => '時刻を選択してください';

  @override
  String get timeUnknown => '時刻不明';

  @override
  String get birthRegion => '出生地';

  @override
  String get searchRegion => '地域を検索';

  @override
  String get searchRegionAgain => '地域を再検索';

  @override
  String get loveStatus => '恋愛に関する私の状態';

  @override
  String get loveStatusHint => '状態を選択してください';

  @override
  String get married => '既婚';

  @override
  String get inRelationship => '恋愛中';

  @override
  String get wantRelationship => '恋愛希望';

  @override
  String get noInterest => '興味なし';

  @override
  String get save => '保存';

  @override
  String get saveBirthInfo => '出生情報を保存';

  @override
  String get saveFriendInfo => '友達情報を保存';

  @override
  String get infoMessage => 'AIがあなただけの物語を\n語るには出生情報が必要です。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get year => '年';

  @override
  String get month => '月';

  @override
  String get day => '日';

  @override
  String get hour => '時';

  @override
  String get minute => '分';

  @override
  String get zodiacSign => '星座';

  @override
  String get zodiacPeriod => '星座期間';

  @override
  String get validationNameRequired => '名前を入力してください。';

  @override
  String get validationGenderRequired => '性別を選択してください。';

  @override
  String get validationBirthDateRequired => '出生日を選択してください。';

  @override
  String get validationBirthHourRequired => '出生時刻（時）を選択してください。';

  @override
  String get validationBirthMinuteRequired => '出生時刻（分）を選択してください。';

  @override
  String get validationRegionRequired => '出生地を検索して選択してください。';

  @override
  String get validationStatusRequired => '状態を選択してください。';

  @override
  String successBirthInfoSaved(Object zodiacSign) {
    return '出生情報が保存されました！(星座: $zodiacSign)';
  }

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return '友達情報が保存されました！(星座: $zodiacSign)';
  }

  @override
  String get errorBirthInfoSaveFailed => '出生情報の保存に失敗しました。';

  @override
  String get errorFriendInfoSaveFailed => '友達情報の保存に失敗しました。';

  @override
  String get splashAppName => 'AstroStar';

  @override
  String get splashSubtitle1 => 'AstroStarがあなたの基本情報を基に短い物語を作成します。';

  @override
  String get splashSubtitle2 => 'AstroStarがあなたの情報を基に毎日楽しい文学コンテンツを作成します。';

  @override
  String get splashSubtitle3 => 'AIがあなただけの運勢物語を語ります。';

  @override
  String get splashSubtitle4 => '四柱と星座を通じて新しい洞察を得ましょう。';

  @override
  String get splashButtonText => 'AIコンテンツ開始';

  @override
  String myPageWelcome(String userName) {
    return 'ようこそ、$userNameさん！';
  }

  @override
  String get myPageLogoutSuccess => 'ログアウトしました。';

  @override
  String get myPageNotificationTitle => '通知';

  @override
  String get myPageNotificationSubtitle => '毎日の運勢物語を受け取る';

  @override
  String get myPageNotificationStatus => '通知が有効になっています';

  @override
  String get myPageNotificationPermissionRequired => '通知権限が必要です';

  @override
  String get myPageNotificationPermissionTitle => '通知権限が必要です';

  @override
  String get myPageNotificationPermissionMessage =>
      'アプリ設定 > 通知で「通知を許可」をオンにしてください。';

  @override
  String get myPageNotificationPermissionCancel => 'キャンセル';

  @override
  String get myPageNotificationPermissionSettings => '設定へ移動';

  @override
  String get myPageNotificationDisabledMessage =>
      '通知が無効になっています。通知をオンにして再試行してください。';

  @override
  String myPageNotificationTimeSavedMessage(Object hour, Object minute) {
    return '通知時間が $hour:$minute に保存されました。';
  }

  @override
  String get myPageNotificationConfirmButton => '確認';

  @override
  String myPageThemeChanged(Object themeName) {
    return 'テーマが「$themeName」に変更されました。';
  }

  @override
  String get myPageProfile => 'プロフィール';

  @override
  String get myPageSettings => '設定';

  @override
  String get myPageHelp => 'ヘルプ';

  @override
  String get myPageAbout => '情報';

  @override
  String get myPageLogout => 'ログアウト';

  @override
  String get myPageDeleteAccount => 'アカウント削除';

  @override
  String get myPagePrivacyPolicy => 'プライバシーポリシー';

  @override
  String get myPageTermsOfService => '利用規約';

  @override
  String get myPageVersion => 'バージョン';

  @override
  String get myPageAppVersion => 'アプリバージョン';

  @override
  String get myPageBuildNumber => 'ビルド番号';

  @override
  String get myPageTitle => 'マイページ';

  @override
  String get todayDetailTitle => '今日のガイド';

  @override
  String get luckyItem => 'ラッキーアイテム';

  @override
  String get todayOutfit => '今日のコーデ';

  @override
  String get overallFlow => '全体の流れ';

  @override
  String get score => '点';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyPolicyHeader => 'プライバシーポリシー';

  @override
  String get privacyPolicySection1Title => '1. 収集する個人情報';

  @override
  String get privacyPolicySection1Content =>
      '本アプリはユーザーの生年月日を入力していただく場合があります。入力された生年月日は個人カスタマイズサービス（例：運勢/天気情報提供など）のためにアプリ内でのみ使用され、サーバー（DB）や外部に保存されることはありません。アプリはユーザーのプッシュ通知受信設定のみを保存し、通知送信のためのデバイストークン以外の個人情報は収集しません。';

  @override
  String get privacyPolicySection2Title => '2. 個人情報の利用目的';

  @override
  String get privacyPolicySection2Content =>
      '個人カスタマイズサービス提供、小説/詩/個人ガイド文学サービス情報提供、プッシュ通知送信、アプリ機能改善およびサービス品質向上';

  @override
  String get privacyPolicySection3Title => '3. 個人情報の保管および廃棄';

  @override
  String get privacyPolicySection3Content =>
      '本アプリはユーザーの個人情報（生年月日）を別途保存せず、アプリ終了時にデータは保管されません。プッシュ通知のためのデバイス識別トークンは、ユーザーがアプリを削除するか通知受信を解除すると即座に廃棄されます。';

  @override
  String get privacyPolicySection4Title => '4. 個人情報第三者提供';

  @override
  String get privacyPolicySection4Content => '本アプリは如何なる個人情報も第三者に提供しません。';

  @override
  String get privacyPolicySection5Title => '5. 個人情報保護';

  @override
  String get privacyPolicySection5Content =>
      '本アプリは個人情報をサーバーに保存せず、デバイス内でのみ処理して外部漏洩の可能性を最小化します。';

  @override
  String get privacyPolicySection6Title => '6. 利用者権利';

  @override
  String get privacyPolicySection6Content =>
      'ユーザーはアプリ内設定を通じていつでもプッシュ通知を拒否できます。出生時刻入力は任意であり、入力しなくてもアプリ使用に制限はありません。';

  @override
  String get privacyPolicySection7Title => '7. プライバシーポリシー変更案内';

  @override
  String get privacyPolicySection7Content =>
      '本方針は法令、政策またはセキュリティ技術の変更に従って修正される場合があり、変更時はアプリ内通知またはアップデートを通じて案内します。';

  @override
  String get privacyPolicyFooter => '個人情報保護のために最善を尽くします。';

  @override
  String get privacyPolicyTeam => 'AstroStarチーム';

  @override
  String get myPageManagement => '管理';

  @override
  String get myPageGeneral => '一般';

  @override
  String get myPageOther => 'その他';

  @override
  String get myPageTheme => 'テーマ';

  @override
  String get myPageAppInfo => 'アプリ情報';

  @override
  String get myPageNotificationTime => '通知時間：';

  @override
  String get myPageLoggedInWithGoogle => 'Googleでログイン';

  @override
  String get myPageUser => 'ユーザー';

  @override
  String get myPageThemeLight => 'ライト';

  @override
  String get myPageThemeDark => 'ダーク';

  @override
  String get myPageThemeSystem => 'システム';

  @override
  String get am => '午前';

  @override
  String get pm => '午後';

  @override
  String get locationSearchTitle => '出生地域検索';

  @override
  String get locationSearchHint => '地域/区/町を入力してください';

  @override
  String get locationSearchEmptyMessage => '地域名を入力して検索してください';

  @override
  String get selectedLocation => '選択された位置';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '経度';

  @override
  String get select => '選択';

  @override
  String get point => '点';

  @override
  String get overall => '全体';

  @override
  String get relationship => '縁';

  @override
  String get wealth => '豊かさ';

  @override
  String get mind => '心';

  @override
  String get growth => '成長';

  @override
  String get tabTodayGuide => '今日のガイド';

  @override
  String get tabEpisode => 'エピソード';

  @override
  String get tabPoetry => '詩朗読';

  @override
  String get todayGuideDetailButton => '今日のガイド詳細';

  @override
  String get preciousRelationship => '大切な縁';

  @override
  String get abundance => '豊かさ';

  @override
  String get bodyAndMind => '心身';

  @override
  String get growthAndFocus => '成長と集中';

  @override
  String get todayStoryHint =>
      '今日の物語は星からの小さなヒントに過ぎません。\nあなたの選択と歩む道は完全にあなただけのものです。';

  @override
  String get episodeTitle => '今日のエピソード';

  @override
  String get episodeSubtitle => '毎日あなたについての新しい物語を発見しましょう。';

  @override
  String get poetryTitle => '今日の詩朗読';

  @override
  String get poetrySubtitle => '毎日あなたに詩を一首書いてあげます。';
}
