import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/favorite_service.dart';
import '../services/saju_service.dart';
import '../models/favorite.dart';
// import '../screens/home_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  String _guestId = '';
  List<Favorite> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGuestId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때 즐겨찾기 목록 새로고침
    if (_guestId.isNotEmpty) {
      _loadFavorites();
    }
  }

  Future<void> _initializeGuestId() async {
    _guestId = await SajuService.getGuestId();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoriteService.getFavoritesByGuestId(_guestId);
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('즐겨찾기 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _buildMainContent(l10n);
  }

  Widget _buildMainContent(AppLocalizations l10n) {
    if (_favorites.isEmpty) {
      return _buildEmptyState(l10n);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          _buildExperienceModeBadge(),
          const SizedBox(height: 10),
          // 즐겨찾기 목록 표시
          ..._favorites.map((favorite) => _buildFavoriteItem(favorite)),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(Favorite favorite) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = primaryColor.withOpacity(0.7);
    
    // 메뉴 타입 로컬라이징
    String menuTypeText = '';
    switch (favorite.menuType) {
      case 'episode':
        menuTypeText = AppLocalizations.of(context)?.tabEpisode ?? 'Episode';
        break;
      case 'poetry':
        menuTypeText = AppLocalizations.of(context)?.tabPoetry ?? 'Poetry';
        break;
      default:
        menuTypeText = favorite.menuType;
    }
    
    // 저장 날짜 포맷팅 (YYYYMMDD -> YYYY-MM-DD)
    String formattedDate = favorite.saveDt;
    if (favorite.saveDt.length == 8) {
      formattedDate = '${favorite.saveDt.substring(0, 4)}-${favorite.saveDt.substring(4, 6)}-${favorite.saveDt.substring(6, 8)}';
    }
    
    return GestureDetector(
      onTap: () => _showFavoriteDetail(favorite),
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Stack(
          children: [
            // 삭제 아이콘 (오른쪽 상단)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _confirmAndDeleteFavorite(favorite),
                child: Icon(
                  Icons.delete_outline,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 40, // 삭제 버튼 공간 확보
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
          // 메뉴 타입과 저장 날짜
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  menuTypeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 제목
          Text(
            favorite.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          // 내용 미리보기 (한 줄만)
          Text(
            favorite.content.length > 45 
                ? '${favorite.content.substring(0, 45)}...'
                : favorite.content,
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
              ),
            ),
    ],
  ),
),
);
  }

  Future<void> _confirmAndDeleteFavorite(Favorite favorite) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        titlePadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        title: Text(AppLocalizations.of(context)!.confirm),
        content: SizedBox(
          height: 28,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.memoInputHint.isNotEmpty
                  ? AppLocalizations.of(context)!.favoritesDeleteConfirmMessage
                  : 'Delete this favorite?'
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // DB에서 삭제
      await _favoriteService.deleteByComposite(
        guestId: favorite.guestId,
        saveDtYmd: favorite.saveDt,
        menuType: favorite.menuType,
        title: favorite.title,
      );
      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((f) => f.id == favorite.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.close.isNotEmpty ? AppLocalizations.of(context)!.favoritesDeleted : '삭제되었습니다.'), duration: const Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e'), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _showFavoriteDetail(Favorite favorite) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FavoriteDetailBottomSheet(
        favorite: favorite,
        onUpdated: (updated) {
          if (!mounted) return;
          setState(() {
            final index = _favorites.indexWhere((f) => f.id == updated.id);
            if (index != -1) {
              _favorites[index] = updated;
            }
          });
        },
      ),
    );
  }

  

  Widget _buildEmptyState(AppLocalizations l10n) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = primary.withOpacity(0.7);
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          _buildExperienceModeBadge(),
          const SizedBox(height: 12),
          const SizedBox(height: 20),
          Text(
            l10n.favoritesEmptyTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.favoritesEmptyMessage,
            style: TextStyle(
              fontSize: 16,
              color: secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceModeBadge() {
    return FutureBuilder<bool>(
      future: SajuService.isExperienceMode(),
      builder: (context, snap) {
        if (snap.data == true) {
          return Align(
            alignment: Alignment.center,
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
    );
  }
}

class _FavoriteDetailBottomSheet extends StatefulWidget {
  final Favorite favorite;
  final void Function(Favorite updated)? onUpdated;

  const _FavoriteDetailBottomSheet({required this.favorite, this.onUpdated});

  @override
  State<_FavoriteDetailBottomSheet> createState() => _FavoriteDetailBottomSheetState();
}

class _FavoriteDetailBottomSheetState extends State<_FavoriteDetailBottomSheet> {
  late Favorite _currentFavorite;
  final FavoriteService _favoriteService = FavoriteService();
  late final TextEditingController _memoDisplayController;
  late final ScrollController _memoScrollController;

  @override
  void initState() {
    super.initState();
    _currentFavorite = widget.favorite;
    _memoDisplayController = TextEditingController(text: _currentFavorite.memo ?? '');
    _memoScrollController = ScrollController();
  }

  @override
  void dispose() {
    _memoDisplayController.dispose();
    _memoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = primaryColor.withOpacity(0.7);
    
    // 메뉴 타입 로컬라이징
    String menuTypeText = '';
    switch (_currentFavorite.menuType) {
      case 'episode':
        menuTypeText = AppLocalizations.of(context)?.tabEpisode ?? 'Episode';
        break;
      case 'poetry':
        menuTypeText = AppLocalizations.of(context)?.tabPoetry ?? 'Poetry';
        break;
      default:
        menuTypeText = _currentFavorite.menuType;
    }
    
    // 저장 날짜 포맷팅 (YYYYMMDD -> YYYY-MM-DD)
    String formattedDate = _currentFavorite.saveDt;
    if (_currentFavorite.saveDt.length == 8) {
      formattedDate = '${_currentFavorite.saveDt.substring(0, 4)}-${_currentFavorite.saveDt.substring(4, 6)}-${_currentFavorite.saveDt.substring(6, 8)}';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.76,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 메뉴 타입과 저장 날짜
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        menuTypeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                    const Spacer(),
                    // 오른쪽 상단 닫기 버튼
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        child: Icon(
                          Icons.close,
                          color: secondaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // 제목
                Text(
                  _currentFavorite.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // 구분선
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: secondaryColor.withOpacity(0.3),
          ),
          // 내용 (스크롤 가능, 남은 영역을 차지)
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _currentFavorite.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          // 구분선
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: secondaryColor.withOpacity(0.3),
          ),
          // 메모 영역 (고정 위치)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.memo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showMemoDialog(_currentFavorite),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _currentFavorite.memo != null && _currentFavorite.memo!.isNotEmpty
                              ? Icons.edit_outlined
                              : Icons.add,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                    if (_currentFavorite.memo != null && _currentFavorite.memo!.isNotEmpty)
                      GestureDetector(
                        onTap: () => _deleteMemo(_currentFavorite),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 0),
                GestureDetector(
                  onTap: () => _showMemoDialog(_currentFavorite),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.grey[800]?.withOpacity(0.5)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: secondaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: SizedBox(
                      height: 80,
                      child: Scrollbar(
                        controller: _memoScrollController,
                        thumbVisibility: true,
                        child: TextField(
                          controller: _memoDisplayController,
                          scrollController: _memoScrollController,
                          readOnly: true,
                          onTap: () => _showMemoDialog(_currentFavorite),
                          enableInteractiveSelection: false,
                          showCursor: false,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context)!.memoAddHint,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: secondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: (_currentFavorite.memo != null && _currentFavorite.memo!.isNotEmpty)
                                ? primaryColor
                                : secondaryColor,
                            fontStyle: (_currentFavorite.memo != null && _currentFavorite.memo!.isNotEmpty)
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // 닫기 버튼
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF272F6E)
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.close,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoDialog(Favorite favorite) {
    final TextEditingController memoController = TextEditingController(text: favorite.memo ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        title: Text(AppLocalizations.of(context)!.memoEdit),
        content: SizedBox(
          width: 300,
          height: 120,
          child: TextField(
            controller: memoController,
            maxLines: 3,
            minLines: 3,
            maxLength: 1000,
            style: const TextStyle(fontSize: 14),
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.memoInputHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _updateMemo(favorite, memoController.text.trim());
              // 바텀시트의 표시용 컨트롤러에도 즉시 반영
              if (mounted) {
                setState(() {
                  _memoDisplayController.text = memoController.text.trim();
                });
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMemo(Favorite favorite, String memo) async {
    try {
      final updatedFavorite = favorite.copyWith(memo: memo.isEmpty ? null : memo);
      await _favoriteService.updateFavorite(updatedFavorite);
      if (!mounted) return;
      setState(() {
        _currentFavorite = updatedFavorite;
        _memoDisplayController.text = updatedFavorite.memo ?? '';
      });
      // 부모 리스트도 동기화
      widget.onUpdated?.call(updatedFavorite);
      final dynamic dl10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(memo.isEmpty ? (dl10n.memoDeleted ?? 'Memo deleted.') : (dl10n.memoSaved ?? '메모가 저장되었습니다.')),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메모 저장 실패: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteMemo(Favorite favorite) async {
    try {
      final updatedFavorite = favorite.copyWith(memo: null);
      await _favoriteService.updateFavorite(updatedFavorite);
      if (!mounted) return;
      setState(() {
        _currentFavorite = updatedFavorite;
        _memoDisplayController.text = '';
      });
      // 부모 리스트도 동기화
      widget.onUpdated?.call(updatedFavorite);
      final dynamic dl10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dl10n.memoDeleted ?? 'Memo deleted.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메모 삭제 실패: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 메모 편집은 바텀시트 위젯 내부에서 처리합니다.
}
