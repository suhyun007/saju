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
  String get birthTimeHint => '時刻選択';

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
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 => 'LunaVerseがあなたの基本情報を基に短い物語を作成します。';

  @override
  String get splashSubtitle2 => 'LunaVerseがあなたの情報を基に毎日楽しい文学コンテンツを作成します。';

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
  String get loading => '読み込み中...';

  @override
  String get todayDetailTitle => '今日のガイド';

  @override
  String get guideSubtitle => '今日一日のためのパーソナライズされたガイドを受け取ってください。';

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
  String get privacyPolicySection1Title => '1. 個人情報の処理目的';

  @override
  String get privacyPolicySection1Content =>
      'LunaVerseアプリは、サービスを提供し改善するためにのみ個人情報を処理します。目的が変更される場合は、適用される法律に従って、追加の同意を得るなどの必要な措置を講じます。';

  @override
  String get privacyPolicySection1_1Title => '1.1 サービス提供';

  @override
  String get privacyPolicySection1_1Content =>
      '• エピソード、詩の朗読、日々のガイドなどの文学コンテンツを提供\n• パーソナライズされたコンテンツを提供\n• アプリの機能とサービスを改善';

  @override
  String get privacyPolicySection1_2Title => '1.2 カスタマーサポート';

  @override
  String get privacyPolicySection1_2Content =>
      '• お問い合わせと苦情の処理\n• サービス利用に関する案内\n• 苦情処理と紛争解決';

  @override
  String get privacyPolicySection2Title => '2. 個人情報の収集と処理';

  @override
  String get privacyPolicySection2Highlight => '個人情報は収集されません：';

  @override
  String get privacyPolicySection2Content =>
      '• アプリは生年月日、性別、出生地を要求する場合がありますが、このデータはサーバーに保存されたり外部に送信されたりすることはありません\n• 入力された情報は、パーソナライズされたサービス（エピソード、詩の朗読、ガイド）のためにアプリ内でのみ使用されます\n• プッシュ通知のデバイストークンのみが保存され、他の個人情報は収集されません';

  @override
  String get privacyPolicySection2LocalTitle => 'ローカルストレージ：';

  @override
  String get privacyPolicySection2LocalContent =>
      '• ユーザー入力（例：出生情報）はデバイス上にのみ一時的に保存され、アプリがアンインストールされると削除されます\n• プッシュ通知のデバイストークンは、ユーザーが通知を無効にしたりアプリを削除したりすると即座に削除されます';

  @override
  String get privacyPolicySection3Title => '3. 個人情報の保持と削除';

  @override
  String get privacyPolicySection3Content =>
      'このアプリは個人情報（生年月日）をサーバーや外部に保存せず、デバイス上でのみ一時的に保存します。データはアプリが削除されるまでデバイス上でのみ保持され、アプリがアンインストールされるとすべてのデータが即座に削除されます。プッシュ通知のデバイストークンは、ユーザーが通知を無効にしたりアプリを削除したりすると即座に削除されます。';

  @override
  String get privacyPolicySection3Highlight => 'データ保持ポリシー：';

  @override
  String get privacyPolicySection3HighlightContent =>
      '• サーバーに個人情報を保存しない\n• デバイス内でのみ処理して外部漏洩を最小化\n• アプリがアンインストールされるとすべてのデータを即座に削除';

  @override
  String get privacyPolicySection4Title => '4. 第三者への提供';

  @override
  String get privacyPolicySection4Content => 'このアプリは第三者に個人情報を提供しません。';

  @override
  String get privacyPolicySection4Highlight => '第三者提供禁止：';

  @override
  String get privacyPolicySection4HighlightContent =>
      '• サーバーに個人情報を保存しないため、第三者への提供は不可能\n• すべてのデータはデバイス内でのみ処理\n• 外部サーバーやデータベースへの個人情報送信なし';

  @override
  String get privacyPolicySection5Title => '5. 個人情報の保護';

  @override
  String get privacyPolicySection5Content =>
      'このアプリは個人情報をサーバーに保存せず、デバイス内でのみ処理して外部漏洩を最小化します。';

  @override
  String get privacyPolicySection5Highlight => 'セキュリティ対策：';

  @override
  String get privacyPolicySection5HighlightContent =>
      '• サーバーに個人情報を保存しない\n• デバイス内でのみ処理して外部漏洩を最小化\n• アプリがアンインストールされるとすべてのデータを即座に削除';

  @override
  String get privacyPolicySection6Title => '6. ユーザーの権利';

  @override
  String get privacyPolicySection6Content =>
      'ユーザーはアプリ設定を通じていつでもプッシュ通知をオプトアウトできます。出生情報の提供は任意であり、アプリを使用するために必要ではありません。';

  @override
  String get privacyPolicySection6Highlight => 'ユーザーの権利：';

  @override
  String get privacyPolicySection6HighlightContent =>
      '• プッシュ通知をオプトアウトする権利\n• 出生情報を提供するかどうかを選択する権利\n• アプリをアンインストールしてすべてのデータを削除する権利';

  @override
  String get privacyPolicySection7Title => '7. このポリシーの変更';

  @override
  String get privacyPolicySection7Content =>
      'このポリシーは、法律、政策、または技術の変更により更新される場合があります。ユーザーにはアプリの更新またはお知らせを通じて通知されます。';

  @override
  String get privacyPolicySection7Highlight => '変更履歴：';

  @override
  String get privacyPolicySection7HighlightContent =>
      '• 2025年9月1日：初期実装\n• 2025年9月1日：個人情報を収集しないポリシーに変更';

  @override
  String get privacyPolicySection8Title => '8. お問い合わせ';

  @override
  String get privacyPolicySection8Contact => '開発者連絡先';

  @override
  String get privacyPolicySection8ContactInfo =>
      '名前：Subak Lee\n役職：開発者\nメール：slee29709@gmail.com';

  @override
  String get privacyPolicySection8Content =>
      '個人情報の処理に関するご質問がございましたら、上記のメールアドレスまでお問い合わせください。';

  @override
  String get privacyPolicyFooter => '個人情報保護のために最善を尽くします。';

  @override
  String get privacyPolicyTeam => 'LunaVerseチーム';

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
  String get myPageNotificationTime => '通知時間 ';

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
