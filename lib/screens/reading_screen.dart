import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/poetry_api_service.dart';
import '../services/saju_service.dart';
import '../services/favorite_service.dart';
import '../models/saju_info.dart';

class PoetryScreen extends StatefulWidget {
  final ValueNotifier<int>? activeTab;
  final int tabIndex;
  const PoetryScreen({super.key, this.activeTab, this.tabIndex = 1});

  @override
  State<PoetryScreen> createState() => _PoetryScreenState();
}

class _PoetryScreenState extends State<PoetryScreen> {
  bool _loading = false;
  String? _error;
  PoetryResult? _poem;
  VoidCallback? _tabListener;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollbar = false;
  final FavoriteService _favoriteService = FavoriteService();
  String? _guestId;
  bool _isFavorite = false;

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
    if (widget.activeTab?.value == widget.tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
    }
    // 즐겨찾기 변경 이벤트 수신하여 하트 상태 동기화
    FavoriteService().changes.listen((event) async {
      if (!mounted) return;
      try {
        final sajuInfo = await SajuService.loadSajuInfo();
        final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
        if (_poem == null || _guestId == null) return;
        if (event.guestId == _guestId && event.saveDtYmd == ymd && event.title == _poem!.title && event.menuType == 'poetry') {
          setState(() {
            _isFavorite = event.action == FavoriteAction.added || (event.action == FavoriteAction.updated && _isFavorite);
            if (event.action == FavoriteAction.deleted) _isFavorite = false;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때 즐겨찾기 상태 확인
    if (_poem != null && _guestId != null) {
      _checkFavoriteStatus();
    }
  }

  void _initializeGuestId() async {
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
    if (_poem != null) {
      // 이미 로드되어 있어도 즐겨찾기 상태는 확인
      if (_guestId != null) {
        _checkFavoriteStatus();
      }
      return;
    }
    // 다른 탭이 활성화되어 있으면 로드하지 않음
    if (widget.activeTab?.value != widget.tabIndex) return;
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; });
    try {
      // 체험 모드: 더미 시 주입
      if (await SajuService.isExperienceMode()) {
        final locale = Localizations.localeOf(context).languageCode;
        final bool isKorean = locale == 'ko';
        final dummy = PoetryResult(
          title: isKorean ? '사랑의 여정을 기다리며' : 'Awaiting the Journey of Love',
          content: isKorean 
            ? '가을의 첫 숨결, \n온 세상이 황금빛으로 물들어가네.  \n내 마음의 깊은 곳,  \n사랑의 씨앗이 움트기를  \n조용히 바래며,  \n그 사람의 향기를 그려본다.  \n\n그리움의 나날,  \n고백할 수 없는 마음이,  \n파란 하늘 아래,  \n함께할 순간을 꿈꾸며  \n하늘의 별에 소원을 빌어본다.  \n\n이 길의 끝에,  \n마주칠 너를 위해,  \n내 마음의 준비를 다하고  \n한 걸음 더 나아간다.  \n\n사랑이 찾아오는 그 날,  \n내 마음에 피어나는  \n작은 꽃들이,  \n너와 나를 잇는  \n희망의 다리가 될 거야.'
            : 'The first breath of autumn,  \nturning the whole world into shades of gold.  \nDeep within my heart,  \nI quietly wish for the seed of love to sprout,  \nas I picture the scent of that person.  \n\nDays filled with longing,  \na heart unable to confess,  \ndreaming of moments together  \nbeneath the blue sky,  \nwhispering my wish to the stars above.  \n\nAt the end of this path,  \nfor the moment I meet you,  \nI ready my heart  \nand take one more step forward.  \n\nOn the day love finally arrives,  \nsmall blossoms blooming in my heart  \nwill become a bridge of hope  \nthat connects you and me.'
          ,
          summary: isKorean ? '사랑의 기다림과 희망을 담은 시.' : 'A poem capturing the longing and hope for love.',
          tomorrowHint: isKorean ? '내일은 새로운 만남의 가능성을 이야기합니다.' : 'Tomorrow speaks of the possibility of a new encounter.',
        );
        setState(() { _poem = dummy; _loading = false; });
        // 즐겨찾기 상태 확인 (체험 모드에서도 DB 반영 시 표시 유지)
        _checkFavoriteStatus();
        return;
      }
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        dev.log('Poetry load aborted: no saju info', name: 'PoetryScreen');
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      // 캐시 우선
      final bool expired = sajuInfo.isPoetryExpiredFor(lang);
      final String cachedContent = (sajuInfo.poetry['content'] ?? '').toString();
      // Debug: cache keys and comparison details
      final lastDate = (sajuInfo.poetry['lastPoetryDate'] ?? '').toString();
      final lastFp = (sajuInfo.poetry['lastRequestFingerprint'] ?? '').toString();
      final lastLang = (sajuInfo.poetry['lastLanguage'] ?? '').toString();
      final todayYmd = sajuInfo.currentTodayDate;
      final expectedComposite = '${sajuInfo.gender}|${sajuInfo.loveStatus ?? ''}|${sajuInfo.world ?? ''}|${sajuInfo.ageGroup ?? ''}|$todayYmd';
      dev.log('[Poetry cache check] today=$todayYmd lastDate=$lastDate lastFp=$lastFp expected=$expectedComposite lang=$lang lastLang=$lastLang expired=$expired', name: 'PoetryScreen');
      if (!expired && cachedContent.isNotEmpty) {
        dev.log('바뀐 데이터 없음!! 서버 호출 안함!!', name: 'PoetryScreen');
        final cached = PoetryResult(
          title: (sajuInfo.poetry['title'] ?? '').toString(),
          content: cachedContent,
          summary: (sajuInfo.poetry['summary'] ?? '').toString(),
          tomorrowHint: (sajuInfo.poetry['tomorrowHint'] ?? '').toString(),
        );
        setState(() { _poem = cached; _loading = false; });
        // 캐시된 시 로드 후 즐겨찾기 상태 확인
        _checkFavoriteStatus();
        return;
      }

      // 만료 시 호출 - 이때만 로딩 표시
      dev.log('바뀐 데이터 있음!! 서버 호출!!!', name: 'PoetryScreen');
      setState(() { _loading = true; });
      final result = await PoetryApiService.fetchPoetry(
        sajuInfo: sajuInfo,
        language: lang,
      );
      // 저장
      sajuInfo.poetry['title'] = result.title;
      sajuInfo.poetry['content'] = result.content;
      sajuInfo.poetry['summary'] = result.summary;
      sajuInfo.poetry['tomorrowHint'] = result.tomorrowHint;
      sajuInfo.poetry['serverResponse'] = 'ok';
      final servedDate = (result.servedDate ?? '').replaceAll('-', '');
      sajuInfo.poetry['lastPoetryDate'] = servedDate.isNotEmpty ? servedDate : sajuInfo.currentTodayDate;
      // 조합 지문: gender|loveStatus|world|ageGroup|servedDate(YYYYMMDD)
      final loveStatus = sajuInfo.loveStatus ?? '';
      final compositeFingerprint = '${sajuInfo.gender}|$loveStatus|${sajuInfo.world ?? ''}|${sajuInfo.ageGroup ?? ''}|${sajuInfo.poetry['lastPoetryDate'] ?? ''}';
      sajuInfo.poetry['lastRequestFingerprint'] = compositeFingerprint;
      sajuInfo.poetry['lastLanguage'] = lang;
      await SajuService.saveSajuInfoContent(sajuInfo);
      setState(() { _poem = result; _loading = false; });
      // 즐겨찾기 상태 확인
      _checkFavoriteStatus();
    } catch (e) {
      dev.log('Poetry load failed', name: 'PoetryScreen', error: e);
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _checkFavoriteStatus() async {
    try {
      if (_poem == null || _guestId == null) return;
      
      final sajuInfo = await SajuService.loadSajuInfo();
      final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
      dev.log('시 낭독 즐겨찾기 체크: guestId=$_guestId, ymd=$ymd, title=${_poem!.title}', name: 'PoetryScreen');
      final isFavorite = await _favoriteService.isFavoriteByDate(_guestId!, ymd, _poem!.title, 'poetry');
      dev.log('시 낭독 즐겨찾기 결과: $isFavorite', name: 'PoetryScreen');
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      dev.log('즐겨찾기 상태 확인 오류: $e', name: 'PoetryScreen');
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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _toggleFavorite() async {
    dev.log('즐겨찾기 토글', name: 'PoetryScreen');
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      final ymd = sajuInfo?.currentTodayDate ?? DateTime.now().toIso8601String().substring(0,10).replaceAll('-', '');
      
      if (_isFavorite) {
        // 즐겨찾기 해제
        await _favoriteService.deleteByComposite(
          guestId: _guestId!,
          saveDtYmd: ymd,
          menuType: 'poetry',
          title: _poem!.title,
        );
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
        }
      } else {
        // 즐겨찾기 추가
        await _favoriteService.addIfNotExists(
          guestId: _guestId!,
          saveDtYmd: ymd,
          menuType: 'poetry',
          title: _poem!.title,
          content: _poem!.content,
          isExperience: await SajuService.isExperienceMode(),
        );
        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
        }
        _showStarAnimation();
      }
    } catch (e) {
      dev.log('즐겨찾기 토글 오류: $e', name: 'PoetryScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showShareOptions() {
    final text = _getShareText();
    final subject = '${AppLocalizations.of(context)?.poetryTitle ?? 'Poetry'} - ${_poem?.title ?? ''}';
    Share.share('Subject: $subject\n\n$text', subject: subject);
  }

  String _getShareText() {
    if (_poem == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    return '''
    📖 ${_poem!.title}

    ${_poem!.content}

    ${_poem!.summary.isNotEmpty ? '${l10n.shareSummaryPrefix} ${_poem!.summary}' : ''}

    ${_poem!.tomorrowHint.isNotEmpty ? '${l10n.shareTomorrowPrefix} ${_poem!.tomorrowHint}' : ''}

    ${l10n.shareAppPromotion}
    ''';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poetry UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Column(
                children: [
                  if (isDark) ...[
                    const Icon(
                      Icons.record_voice_over,
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
                    AppLocalizations.of(context)?.poetryTitle ?? '오늘의 시 낭독',
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
                    AppLocalizations.of(context)?.poetrySubtitle ?? '매일 당신에게 시 한 편을 지어드려요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.3 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 0),
            
            // Poetry 내용만 표시
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
                  // 즐겨찾기 버튼
                  GestureDetector(
                    onTap: _poem != null ? _toggleFavorite : null,
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_outward, size: 18, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          AppLocalizations.of(context)?.shareButton ?? '공유',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: Colors.white,
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
    if (_poem == null) {
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
          if ((_poem!.title).isNotEmpty)
            Center(
              child: SelectableText(
                '<${_poem!.title}>',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          if (_poem!.content.isNotEmpty)
            Center(
              child: SelectableText(
                _poem!.content,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  color: onText,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 15),
          if ((_poem!.summary).isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.summaryLabel}: ${_poem!.summary}',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: onText.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          if ((_poem!.tomorrowHint).isNotEmpty)
            SelectableText(
              '${AppLocalizations.of(context)!.shareTomorrowPoetryPrefix} ${_poem!.tomorrowHint}',
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
  late Animation<double> _bounceAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
