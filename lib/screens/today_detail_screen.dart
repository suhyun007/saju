import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';
import '../l10n/app_localizations.dart';

class TodayDetailScreen extends StatefulWidget {
  const TodayDetailScreen({super.key});

  @override
  State<TodayDetailScreen> createState() => _TodayDetailScreenState();
}

class _TodayDetailScreenState extends State<TodayDetailScreen> {
  SajuInfo? _sajuInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSajuInfo();
  }

  Future<void> _loadSajuInfo() async {
    try {
      final sajuInfo = await SajuService.loadSajuInfo();
      setState(() {
        _sajuInfo = sajuInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('SajuInfo 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 첫 번째 마침표를 만나면 엔터를 추가하는 메서드
  String _addNewlineAtFirstPeriod(String text) {
    final periodIndex = text.indexOf('. ');
    if (periodIndex == -1) {
      return text; // 마침표+스페이스가 없으면 그대로 반환
    }
    return '${text.substring(0, periodIndex + 1)}\n${text.substring(periodIndex + 2)}'; // +2로 스페이스까지 건너뛰기
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

    if (_sajuInfo == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            '출생 정보를 먼저 입력해주세요.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.todayDetailTitle ?? '오늘의 가이드',
          textAlign: TextAlign.left,
          style: GoogleFonts.notoSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _shareFortune(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체의 흐름 카드
            _buildFortuneDetailCard(
              AppLocalizations.of(context)?.overallFlow ?? '전체의 흐름',
              '${_sajuInfo!.todayFortune['overallScore']}${AppLocalizations.of(context)?.score ?? '점'}',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['overall']),
              Icons.star,
              Colors.amber,
            ),
            
            const SizedBox(height: 20),
            
            // 행운의 아이템 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.luckyItem ?? '행운의 아이템',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['luckyItem']),
            ),
            
            const SizedBox(height: 20),
            
            // 오늘의 코디 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.todayOutfit ?? '오늘의 코디',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['todayOutfit']),
            ),

            const SizedBox(height: 20),
            
            // 몸과 마음 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.bodyAndMind ?? '몸과 마음',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['health']),
            ),

            const SizedBox(height: 20),
            
            // 소중한 인연 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.preciousRelationship ?? '소중한 인연',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['love']),
            ),
            
            const SizedBox(height: 20),
            
            // 풍요로움 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.abundance ?? '풍요로움',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['wealth']),
            ),
            
            const SizedBox(height: 20),
            
            // 학업운 카드
            _buildStyleCardWithoutIcon(
              AppLocalizations.of(context)?.growthAndFocus ?? '성장과 집중',
              _addNewlineAtFirstPeriod(_sajuInfo!.todayFortune['study']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneDetailCard(String title, String score, String description, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀과 점수를 박스 밖으로 이동
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              score,
              style: GoogleFonts.notoSans(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 0),
        // 내용만 박스 안에
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.1) 
                : Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Text(
            description,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleCardWithoutIcon(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀을 박스 밖으로 이동
        Row(
          children: [
            //Icon(Icons.star, color: Colors.amber, size: 24),
            //const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 내용만 박스 안에
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.1) 
                : Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Text(
            description,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _shareFortune() {
    final String shareText = '''
      🌟 ${AppLocalizations.of(context)?.todayDetailTitle ?? '오늘의 가이드'} 🌟
      #오늘의가이드 #사주앱
''';
    
    Share.share(shareText, subject: AppLocalizations.of(context)?.todayDetailTitle ?? '오늘의 가이드');
  }
}
