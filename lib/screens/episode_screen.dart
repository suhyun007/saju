import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/episode_api_service.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../services/analytics_service.dart';
import '../services/favorite_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EpisodeScreen extends StatefulWidget {
  final ValueNotifier<int>? activeTab;
  final int tabIndex;
  const EpisodeScreen({super.key, this.activeTab, this.tabIndex = 0});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  EpisodeResult? _episode;
  bool _loading = false;
  String? _error;
  VoidCallback? _tabListener;
  bool _episodeClickLogged = false; // 초기 진입 시 에피소드 클릭 로그 중복 방지
  final ScrollController _scrollController = ScrollController();
  bool _showScrollbar = false;
  bool _isFavorite = false; // 즐겨찾기 상태
  final FavoriteService _favoriteService = FavoriteService();
  String? _guestId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeGuestId();
    _tabListener = () {
      if (widget.activeTab?.value == widget.tabIndex) {
        _loadIfNeeded();
      }
    };
    widget.activeTab?.addListener(_tabListener!);
    // 즐겨찾기 변경 이벤트 수신하여 하트 상태 동기화
    FavoriteService().changes.listen((event) async {
      if (!mounted) return;
      try {
        final sajuInfo = await SajuService.loadSajuInfo();
        final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
        if (_episode == null || _guestId == null) return;
        if (event.guestId == _guestId && event.saveDtYmd == ymd && event.title == _episode!.title && event.menuType == 'episode') {
          setState(() {
            _isFavorite = event.action == FavoriteAction.added || (event.action == FavoriteAction.updated && _isFavorite);
            if (event.action == FavoriteAction.deleted) _isFavorite = false;
          });
        }
      } catch (_) {}
    });
    // 최초 선택된 탭과 일치하면 지연 호출
    if (widget.activeTab?.value == widget.tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
    }
  }

  void _initializeGuestId() async {
    // SajuService에서 일관된 게스트 ID 가져오기
    _guestId = await SajuService.getGuestId();
  }

  void _onScroll() {
    if (!_showScrollbar) {
      setState(() {
        _showScrollbar = true;
      });
    }
    // 3초 후 스크롤바 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showScrollbar = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_tabListener != null && widget.activeTab != null) {
      widget.activeTab!.removeListener(_tabListener!);
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_loading) return;
    // 에피소드 객체가 있으나 제목/내용이 비어있으면 다시 로드
    if (_episode != null) {
      final hasMeaningfulData = (_episode!.title.trim().isNotEmpty) && (_episode!.content.trim().isNotEmpty);
      if (hasMeaningfulData) return;
    }
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab?.value != widget.tabIndex) return;
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; });
    // 초기 로딩 시 에피소드 탭 진입을 클릭 이벤트로 기록 (중복 방지)
    if (!_episodeClickLogged) {
      AnalyticsService.logMenuClick('episode');
      _episodeClickLogged = true;
    }
    try {
      // 체험 모드: 더미 데이터 주입
      if (await SajuService.isExperienceMode()) {
        final locale = Localizations.localeOf(context).languageCode;
        
        EpisodeResult dummy;
        switch (locale) {
          case 'ko':
            dummy = EpisodeResult(
              title: '운명의 만남',
              content: '어느 화창한 아침, 작은 마을의 한 카페에서 한 여인이 커피를 마시며 창밖을 바라보고 있었다. 그 순간, 그녀의 시선이 한 남자와 마주쳤다. 남자는 책을 읽고 있었고, 그의 눈빛은 깊은 이야기를 담고 있었다. 여인은 그와의 대화가 운명처럼 느껴졌다. 서로의 취향에 대해 이야기하며, 두 사람은 마음의 벽을 허물기 시작했다. 오늘은 새로운 인연을 만날 수 있는 특별한 날임을 느끼며, 여인은 웃음을 지었다.',
              contentLength: 416,
              summary: '운명적인 만남을 통해 새로운 인연을 발견하는 이야기입니다.',
              tomorrowSummary: '어제의 만남이 새로운 모험으로 이어지는 이야기를 들려드립니다.',
            );
            break;
          case 'ja':
            dummy = EpisodeResult(
              title: '運命の出会い',
              content: 'ある晴れた朝、小さな村のカフェで女性がコーヒーを飲みながら窓の外を見つめていた。その瞬間、彼女の視線が一人の男性と出会った。男性は本を読んでいて、その眼差しには深い物語が込められていた。女性は彼との会話が運命のように感じられた。お互いの趣味について話しながら、二人は心の壁を取り除き始めた。今日は新しい縁を結ぶことができる特別な日であることを感じ、女性は微笑んだ。',
              contentLength: 416,
              summary: '運命的な出会いを通じて新しい縁を発見する物語です。',
              tomorrowSummary: '昨日の出会いが新しい冒険へと続く物語をお届けします。',
            );
            break;
          case 'zh':
            dummy = EpisodeResult(
              title: '命运般的相遇',
              content: '在一个晴朗的早晨，小镇咖啡馆里，一位女子一边喝着咖啡一边凝视着窗外。就在那一刻，她的目光与一位男子相遇了。男子正在读书，他的眼神中似乎蕴含着深刻的故事。女子觉得与他的对话仿佛是命中注定的。在谈论彼此的兴趣爱好时，两人开始拆除心中的壁垒。感受到今天是能够遇见新缘分的特别日子，女子露出了微笑。',
              contentLength: 416,
              summary: '通过命运般的相遇发现新缘分的故事。',
              tomorrowSummary: '明天将讲述昨天相遇如何发展成新冒险的故事。',
            );
            break;
          default: // 영어 (en)
            dummy = EpisodeResult(
              title: 'A Fateful Encounter',
              content: 'On a bright morning in a small village café, a woman sipped her coffee while gazing out the window. At that moment, her eyes met those of a man. He was reading a book, and his gaze seemed to hold a world of untold stories. The woman felt as though their conversation was meant to be. As they spoke about their tastes and interests, the walls around their hearts began to fade. Realizing that today was a special day to meet someone new, the woman smiled warmly.',
              contentLength: 416,
              summary: 'A story about discovering a new connection through a fateful meeting.',
              tomorrowSummary: "Tomorrow reveals how yesterday's encounter blossoms into a new adventure.",
            );
        }
        
        setState(() { _episode = dummy; _loading = false; });
        // 즐겨찾기 상태 확인 (체험 모드에서도 DB 반영 시 표시 유지)
        _checkFavoriteStatus();
        return;
      }
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        dev.log('Episode load aborted: no saju info', name: 'EpisodeScreen');
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      // 캐시 유효하면 캐시로 표시
      final bool expired = sajuInfo.isEpisodeExpiredFor(locale);
      final String cachedContent = (sajuInfo.episode['content'] ?? '').toString();
      // Debug: cache keys and comparison details
      final lastDate = (sajuInfo.episode['lastEpisodeDate'] ?? '').toString();
      final lastFp = (sajuInfo.episode['lastRequestFingerprint'] ?? '').toString();
      final lastLang = (sajuInfo.episode['lastLanguage'] ?? '').toString();
      final todayYmd = sajuInfo.currentTodayDate;
      final expectedComposite = '${sajuInfo.gender}|${sajuInfo.loveStatus ?? ''}|${sajuInfo.world ?? ''}|${sajuInfo.ageGroup ?? ''}|$todayYmd';
      dev.log('[Episode cache check] today=$todayYmd lastDate=$lastDate lastFp=$lastFp expected=$expectedComposite lang=$locale lastLang=$lastLang expired=$expired', name: 'EpisodeScreen');
      dev.log('[Episode] expired=$expired cachedLen=${cachedContent.length} today=$todayYmd lastDate=$lastDate fpOk=${lastFp==expectedComposite} langOk=${lastLang==locale}', name: 'EpisodeScreen');
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('바뀐 데이터 없음!! 서버 호출 안함!!', name: 'EpisodeScreen');
        final cached = EpisodeResult(
          title: (sajuInfo.episode['title'] ?? '').toString(),
          content: cachedContent,
          contentLength: cachedContent.length,
          summary: (sajuInfo.episode['summary'] ?? '').toString(),
          tomorrowSummary: (sajuInfo.episode['tomorrowSummary'] ?? '').toString(),
        );
        setState(() { _episode = cached; _loading = false; });
        // 캐시된 에피소드 로드 후 즐겨찾기 상태 확인
        _checkFavoriteStatus();
        return;
      }
      // 만료 시에만 서버 호출 - 이때만 로딩 표시
      dev.log('바뀐 데이터 있음!! 서버 호출!!!', name: 'EpisodeScreen');
      setState(() { _loading = true; });
      final result = await EpisodeApiService.fetchEpisode(
        sajuInfo: sajuInfo,
        language: locale,
      );
      // 캐시에 저장 (날짜/지문/언어)
      sajuInfo.episode['title'] = result.title;
      sajuInfo.episode['content'] = result.content;
      sajuInfo.episode['tomorrowSummary'] = result.tomorrowSummary;
      sajuInfo.episode['summary'] = result.summary;
      sajuInfo.episode['serverResponse'] = 'ok';
      // 서버 제공 servedDate 우선 사용, 없으면 디바이스 날짜 사용
      final servedDate = (result.servedDate ?? '').replaceAll('-', '');
      sajuInfo.episode['lastEpisodeDate'] = servedDate.isNotEmpty ? servedDate : sajuInfo.currentTodayDate;
      // 조합 지문: gender|loveStatus|world|ageGroup|servedDate(YYYYMMDD)
      final loveStatus = sajuInfo.loveStatus ?? '';
      final compositeFingerprint = '${sajuInfo.gender}|$loveStatus|${sajuInfo.world ?? ''}|${sajuInfo.ageGroup ?? ''}|${sajuInfo.episode['lastEpisodeDate'] ?? ''}';
      sajuInfo.episode['lastRequestFingerprint'] = compositeFingerprint;
      sajuInfo.episode['lastLanguage'] = locale;
      await SajuService.saveSajuInfoContent(sajuInfo);
      setState(() { _episode = result; _loading = false; });
      // 에피소드 로드 후 즐겨찾기 상태 확인
      _checkFavoriteStatus();
    } catch (e) {
      dev.log('Episode load failed', name: 'EpisodeScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }
//_shareToDefault
  void _showShareOptions() {
    final text = _getShareText();
    final subject = '${AppLocalizations.of(context)?.episodeTitle ?? 'Episode'} - ${_episode?.title ?? ''}';
    Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  String _getShareText() {
    if (_episode == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${_episode!.title}

    ${_episode!.content}

    ${_episode!.summary.isNotEmpty ? '${l10n.shareSummaryPrefix} ${_episode!.summary}' : ''}

    ${_episode!.tomorrowSummary.isNotEmpty ? '${l10n.shareTomorrowPrefix} ${_episode!.tomorrowSummary}' : ''}

    ${l10n.shareAppPromotion}
    ''';
  }

  // 즐겨찾기 상태 확인 (날짜 포함)
  Future<void> _checkFavoriteStatus() async {
    if (_episode == null || _guestId == null) return;
    
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
      final isFavorite = await _favoriteService.isFavoriteByDate(_guestId!, ymd, _episode!.title, 'episode');
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      dev.log('즐겨찾기 상태 확인 오류: $e', name: 'EpisodeScreen');
    }
  }

  void _showStarAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => const HeartAnimationWidget(),
    );
    
    // 1초 후 자동으로 닫기
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  // 즐겨찾기 토글 (guest_id + save_dt(YYYYMMDD) + menu_type + title)
  Future<void> _toggleFavorite() async {
    dev.log('즐겨찾기 토글', name: 'EpisodeScreen');
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 즐겨찾기를 지원하지 않습니다.')),
      );
      return;
    }
    if (_episode == null || _guestId == null) return;

    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
      if (_isFavorite) {
        // 즐겨찾기에서 제거
        await _favoriteService.deleteByComposite(
          guestId: _guestId!,
          saveDtYmd: ymd,
          menuType: 'episode',
          title: _episode!.title,
        );
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
        }
      } else {
        // 즐겨찾기에 추가
        final result = await _favoriteService.addIfNotExists(
          guestId: _guestId!,
          saveDtYmd: ymd,
          menuType: 'episode',
          title: _episode!.title,
          content: _episode!.content,
          isExperience: await SajuService.isExperienceMode(),
        );
        
        if (result > 0) {
          // 새로 추가됨
          if (mounted) {
            setState(() {
              _isFavorite = true;
            });
          }
          _showStarAnimation();
        } else {
          // 이미 존재함 (중복)
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.favoriteAlreadySaved ?? '이미 즐겨찾기에 저장되었습니다.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      dev.log('즐겨찾기 토글 오류: $e', name: 'EpisodeScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 공유 버튼 투명도 (0.0 ~ 1.0)
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Column(
                children: [
                  if (isDark) ...[
                    const Icon(
                      Icons.auto_stories,
                      color: Color(0xFFB3B3FF),
                      size: 40,
                    ),
                    const SizedBox(height: 3),
                  ],
                  FutureBuilder<bool>(
                    future: SajuService.isExperienceMode(),
                    builder: (context, snap) {
                      if (snap.data == true) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.experienceMode,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)?.episodeTitle ?? '오늘의 에피소드',
                    style: GoogleFonts.notoSans(
                      fontSize: 22,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    AppLocalizations.of(context)?.episodeSubtitle ?? '매일 새로운 당신의 이야기를 만나보세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // 이야기 내용 - 전체 화면에서 패딩 20 안에 들어가도록
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1) 
                      : Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: _buildBody(context),
              ),
            ),
            const SizedBox(height: 12),
            // 즐겨찾기와 공유 버튼
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 즐겨찾기 별 아이콘
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 36,
                      height: 36,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite 
                          ? const Color(0xFFFF4F87) 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // 공유 버튼
                  ElevatedButton(
                    onPressed: _showShareOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D4B91),
                      foregroundColor: const Color(0xFFFFD400),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_outward, size: 18, color: Color(0xFFFFFFFF)),
                        const SizedBox(width: 3),
                        Text(
                          AppLocalizations.of(context)?.shareButton ?? '공유',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final onText = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error == 'no_saju') {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.infoMessage ?? '출생 정보를 먼저 저장해주세요.',
          style: GoogleFonts.notoSans(fontSize: 16, color: onText),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.offlineTitle ?? 'Connection Error', 
              style: GoogleFonts.notoSans(fontSize: 18, color: onText, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.offlineMessage ?? 'Internet connection is required. Please connect and try again.', 
              style: GoogleFonts.notoSans(fontSize: 14, color: onText.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load, 
              child: Text(AppLocalizations.of(context)?.offlineRetry ?? 'Retry')
            ),
          ],
        ),
      );
    }
    if (_episode == null) {
      return const SizedBox();
    }
    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: _showScrollbar,
      trackVisibility: _showScrollbar,
      thickness: 5,
      radius: const Radius.circular(8),
      thumbColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : const Color(0xFFE6C767),
      padding: const EdgeInsets.only(right: -10),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          if (_episode!.title.trim().isNotEmpty)
            Center(
              child: SelectableText(
                '<${_episode!.title}>',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          if (_episode!.content.trim().isNotEmpty)
            SelectableText(
              _episode!.content,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                color: onText,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 16),
          if (_episode!.summary.isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.summaryLabel}: ${_episode!.summary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          if (_episode!.tomorrowSummary.isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.shareTomorrowPrefix} ${_episode!.tomorrowSummary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartAnimationWidget extends StatefulWidget {
  const HeartAnimationWidget({super.key});

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: const Icon(
                Icons.favorite,
                color: Color(0xFFFF4F87),
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}


