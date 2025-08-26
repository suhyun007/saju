import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/saju_info.dart';
import '../services/saju_service.dart';

class SajuCard extends StatefulWidget {
  const SajuCard({super.key});

  @override
  State<SajuCard> createState() => _SajuCardState();
}

class _SajuCardState extends State<SajuCard> {
  SajuInfo? _sajuInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSajuInfo();
  }

  Future<void> _loadSajuInfo() async {
    final sajuInfo = await SajuService.loadSajuInfo();
    setState(() {
      _sajuInfo = sajuInfo;
      _isLoading = false;
    });
  }

  Future<void> _refreshSajuInfo() async {
    await _loadSajuInfo();
  }

  @override
  Widget build(BuildContext context) {
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
                      '출생 정보 (설정에서 수정)',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isLoading 
                          ? '로딩 중...'
                          : _sajuInfo != null
                              ? '${_sajuInfo!.yearText} ${_sajuInfo!.monthText} ${_sajuInfo!.dayText} ${_sajuInfo!.timeText}'
                              : '생년월일시를 입력해주세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // 편집 아이콘 제거: 설정(톱니)에서만 수정 가능
            ],
          ),
          const SizedBox(height: 20),
          _buildSajuGrid(),
        ],
      ),
    );
  }

  Widget _buildSajuGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_sajuInfo == null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSajuItem('년주', '미입력', 'Year')),
              const SizedBox(width: 10),
              Expanded(child: _buildSajuItem('월주', '미입력', 'Month')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSajuItem('일주', '미입력', 'Day')),
              const SizedBox(width: 10),
              Expanded(child: _buildSajuItem('시주', '미입력', 'Hour')),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSajuItem('년주', _sajuInfo!.yearSaju, 'Year')),
            const SizedBox(width: 10),
            Expanded(child: _buildSajuItem('월주', _sajuInfo!.monthSaju, 'Month')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildSajuItem('일주', _sajuInfo!.daySaju, 'Day')),
            const SizedBox(width: 10),
            Expanded(child: _buildSajuItem('시주', _sajuInfo!.hourSaju, 'Hour')),
          ],
        ),
      ],
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
}
