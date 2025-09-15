// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'LunaVerse App';

  @override
  String get birthInfoInput => 'キャラクター設定';

  @override
  String get friendInfoInput => '友達情報入力';

  @override
  String get name => 'キャラクター名';

  @override
  String get nameHint => 'キャラクター名を入力してください。';

  @override
  String get gender => 'キャラクターの性別';

  @override
  String get female => '女性';

  @override
  String get male => '男性';

  @override
  String get nonBinary => 'ノンバイナリー';

  @override
  String get birthDate => 'キャラクターの年齢';

  @override
  String get birthDateHint => '生年月日を選択してください';

  @override
  String get birthTime => '出生時刻';

  @override
  String get birthTimeHint => '時刻選択';

  @override
  String get timeUnknown => '時刻不明';

  @override
  String get birthRegion => 'キャラクターの世界';

  @override
  String get searchRegion => '地域を検索';

  @override
  String get searchRegionAgain => '地域を再検索';

  @override
  String get loveStatus => 'キャラクターのトーン';

  @override
  String get loveStatusHint => 'キャラクターのトーンを選んでください (可选)';

  @override
  String get toneWarm => '暖かい';

  @override
  String get toneCalm => '落ち着いた';

  @override
  String get toneLovely => '愛らしい';

  @override
  String get toneUrban => '都会的';

  @override
  String get tonePositive => 'ポジティブ';

  @override
  String get toneFunny => '面白い';

  @override
  String get toneEmotional => '感性的';

  @override
  String get toneHopeful => '希望に満ちた';

  @override
  String get tonePassionate => '情熱的';

  @override
  String get toneFutureOriented => '未来志向';

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
  String get saveBirthInfo => 'キャラクターを保存';

  @override
  String get saveFriendInfo => '友達情報を保存';

  @override
  String get infoMessage => 'キャラクターに出会い、物語を始めましょう。';

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
  String get validationStatusRequired => 'キャラクターのトーンを選んでください (可选)';

  @override
  String get statusSelectHint => 'キャラクターのトーンを選んでください (可选)';

  @override
  String get successBirthInfoSaved => '情報が保存されました！';

  @override
  String successFriendInfoSaved(Object zodiacSign) {
    return '友達情報が保存されました！(星座: $zodiacSign)';
  }

  @override
  String get errorBirthInfoSaveFailed => '出生情報の保存に失敗しました。';

  @override
  String get errorFriendInfoSaveFailed => '友達情報の保存に失敗しました。';

  @override
  String themeChangedMessage(Object theme) {
    return 'テーマが「$theme」に変更されました。';
  }

  @override
  String get splashAppName => 'LunaVerse';

  @override
  String get splashSubtitle1 => 'LunaVerseがあなたの基本情報を基に短い物語を作成します。';

  @override
  String get splashSubtitle2 =>
      '今日から物語の旅を始めましょう。毎日新しいエピソードや詩に出会い、お気に入りを集めて、自分だけの図書館を作っていきましょう。';

  @override
  String get splashSubtitle3 => 'AIがあなただけの運勢物語を語ります。';

  @override
  String get splashSubtitle4 => '四柱と星座を通じて新しい洞察を得ましょう。';

  @override
  String get splashButtonText => '今日の物語を読む';

  @override
  String myPageWelcome(String userName) {
    return 'ようこそ、$userNameさん！';
  }

  @override
  String get existPlashSubtitle => 'お帰りなさい。\nあなたの物語は続きます。';

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
  String get locationSearchTitle => '地域検索';

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
  String get tabFavorites => 'お気に入り';

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
  String get bodyAndMind => 'バランスと調和';

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

  @override
  String get lightAndHope => '光と希望';

  @override
  String get summaryLabel => '要約';

  @override
  String get shareTitle => '共有';

  @override
  String get shareTextCopy => 'テキストをコピー';

  @override
  String get shareTextCopied => 'テキストがクリップボードにコピーされました';

  @override
  String get shareSummaryPrefix => '💡要約：';

  @override
  String get shareTomorrowPrefix => '🔮明日のエピソードプレビュー：';

  @override
  String get shareTomorrowPoetryPrefix => '🔮明日の詩プレビュー：';

  @override
  String get shareAppPromotion => '✨ LunaVerseで毎日新しい物語を発見しましょう！';

  @override
  String get shareButton => '共有';

  @override
  String get offlineTitle => 'オフライン';

  @override
  String get offlineMessage => 'インターネット接続が必要です。接続してから再試行してください。';

  @override
  String get offlineClose => '閉じる';

  @override
  String get offlineRetry => '再試行';

  @override
  String get sampleStory => 'サンプルストーリーを試す';

  @override
  String get sampleStoryHeader => 'サンプルストーリー 🌙\n「朝の窓辺」';

  @override
  String get sampleStoryP1 =>
      '今朝窓を開けたとき、世界は不思議に静かでした。まるであなたを待っているかのように。薄い青い色を帯びた空の下、その静寂の中で、何か優しいものが開花しているのを感じました。';

  @override
  String get sampleStoryP2 =>
      '街を歩きながら、小さなことに気づきました—枝に引っかかった日光、理由もなく微笑む見知らぬ人、あなただけに聞こえる秘密のリズムのように響く足音...';

  @override
  String get makeMyStoryButton => 'キャラクターを設定';

  @override
  String get aboutLunaVerseTitle => 'LunaVerseについて';

  @override
  String get aboutLunaVerseContent =>
      'LunaVerseはあなたの瞬間からインスピレーションを受け、毎日新しい物語と詩を作り出します。今日はどんな物語が展開されるか確認してみてください。';

  @override
  String get confirmButton => '確認';

  @override
  String get favoritesEmptyTitle => 'お気に入りはまだありません';

  @override
  String get favoritesEmptyMessage => 'お気に入りのエピソードと詩を集めて、あなただけの書斎を作ってみてください。';

  @override
  String get characterEra => '時代';

  @override
  String get eraHint => '時代を選択（任意）';

  @override
  String get eraAncientTimes => '古代';

  @override
  String get eraMedievalAge => '中世';

  @override
  String get eraVictorianEra => 'ヴィクトリア時代';

  @override
  String get eraModernDay => '現代';

  @override
  String get eraNearFuture => '近未来';

  @override
  String get eraDistantFuture => '遠未来';

  @override
  String get eraMythicalAge => '神話の時代';

  @override
  String get eraTimelessRealm => '時を超えた世界';

  @override
  String get characterValidationTitle => '入力されたキャラクター情報がありません。';

  @override
  String get characterValidationBody => '入力内容が空のため、保存できるキャラクター情報がありません。';

  @override
  String get memo => 'メモ';

  @override
  String get memoEdit => 'メモ編集';

  @override
  String get memoInputHint => 'メモを入力してください（最大1000文字）';

  @override
  String get memoAddHint => 'メモを追加してみてください';

  @override
  String get close => '閉じる';

  @override
  String get favoritesDeleteConfirmMessage => 'このお気に入りを削除しますか？';

  @override
  String get favoritesDeleted => '削除しました。';

  @override
  String get memoSaved => 'メモを保存しました。';

  @override
  String get memoDeleted => 'メモを削除しました。';

  @override
  String get experienceTry => 'お試し';

  @override
  String get experienceMode => 'お試しモード';

  @override
  String get experienceEntering => 'お試しモードに入ります。';

  @override
  String get guest => 'ゲスト';

  @override
  String get sajuInfo => '四柱情報';

  @override
  String get sajuInfoInputPrompt => '四柱情報を入力してください。';
}
