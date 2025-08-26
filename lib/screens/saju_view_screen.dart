import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/saju_info.dart';
import '../models/saju_api_response.dart';
import '../services/saju_api_service.dart';

class SajuViewScreen extends StatefulWidget {
  final SajuInfo sajuInfo;

  const SajuViewScreen({
    super.key,
    required this.sajuInfo,
  });

  @override
  State<SajuViewScreen> createState() => _SajuViewScreenState();
}

class _SajuViewScreenState extends State<SajuViewScreen> {
  SajuApiResponse? _apiResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSajuAnalysis();
  }

  Future<void> _loadSajuAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 실제 API 호출
      SajuApiResponse response;
      try {
        response = await SajuApiService.getSajuAnalysis(widget.sajuInfo);
      } catch (e) {
        print('실제 API 호출 실패, 더미 데이터로 폴백: $e');
        // API 실패 시 더미 데이터로 폴백
        print('saju_view_screen.dart 호출');
        response = await SajuApiService.getSimpleSajuAnalysis(widget.sajuInfo);
      }

      setState(() {
        _apiResponse = response;
        _isLoading = false;
      });

      if (!response.success) {
        setState(() {
          _errorMessage = response.error ?? response.message ?? '알 수 없는 오류가 발생했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '사주 분석 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF4A2C1A),
              Color(0xFF8B4513),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              
              // 메인 콘텐츠
              Expanded(
                child: _isLoading
                    ? _buildLoadingView()
                    : _errorMessage != null
                        ? _buildErrorView()
                        : _buildSajuContentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            '사주 분석 결과',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadSajuAnalysis,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.amber,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            '사주를 분석하고 있습니다...',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '잠시만 기다려주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              '사주 분석 실패',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? '알 수 없는 오류가 발생했습니다.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loadSajuAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '다시 시도',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSajuContentView() {
    if (_apiResponse?.data == null) {
      return _buildErrorView();
    }

    final data = _apiResponse!.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 기본 정보 카드
          _buildBasicInfoCard(data),
          
          const SizedBox(height: 20),
          
          // 사주 그리드
          _buildSajuGrid(data),
          
          const SizedBox(height: 20),
          
          // 사주 분석
          _buildAnalysisCard(data),
          
          const SizedBox(height: 20),
          
          // 오늘의 운세
          _buildFortuneCard(data),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(SajuData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B4513),
            Color(0xFFDAA520),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 정보',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${data.yearText} ${data.monthText} ${data.dayText} ${data.hourText}',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSajuGrid(SajuData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '출생 정보',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          // 새로운 API 형식의 출생 정보 표시
          if (data.saju != null) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '사주 팔자',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.saju!,
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          
          // 사주 요소별 상세 정보
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSajuItem('년주', data.elements?.year ?? data.yearSaju ?? '미입력', 'Year')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSajuItem('월주', data.elements?.month ?? data.monthSaju ?? '미입력', 'Month')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildSajuItem('일주', data.elements?.day ?? data.daySaju ?? '미입력', 'Day')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSajuItem('시주', data.elements?.hour ?? data.hourSaju ?? '미입력', 'Hour')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSajuItem(String label, String value, String english) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            english,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(SajuData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '사주 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            data.analysis ?? '사주 분석 정보가 없습니다.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneCard(SajuData data) {
    final todayFortune = data.todayFortune;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '오늘의 운세',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // 전체 운세
          if (todayFortune?.overall != null) ...[
            _buildFortuneSection('전체 운세', todayFortune!.overall!, Icons.psychology),
            const SizedBox(height: 15),
          ],
          
          // 세부 운세들
          if (todayFortune != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildFortuneSection('💰 재물운', todayFortune.wealth ?? '정보 없음', Icons.attach_money),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFortuneSection('💪 건강운', todayFortune.health ?? '정보 없음', Icons.favorite),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildFortuneSection('💕 연애운', todayFortune.love ?? '정보 없음', Icons.favorite_border),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFortuneSection('💡 조언', todayFortune.advice ?? '정보 없음', Icons.lightbulb),
                ),
              ],
            ),
          ] else ...[
            // 기존 호환성을 위한 폴백
            Text(
              data.fortune ?? '오늘의 운세 정보가 없습니다.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
