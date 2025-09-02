import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../models/saju_info.dart';
import '../models/friend_info.dart';
import '../services/saju_service.dart';
import '../services/friend_service.dart';
import '../utils/zodiac_utils.dart';
import 'location_picker_screen.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

class SajuInputScreen extends StatefulWidget {
  final bool isFriendInfo;
  
  const SajuInputScreen({
    super.key,
    this.isFriendInfo = false,
  });

  @override
  State<SajuInputScreen> createState() => _SajuInputScreenState();
}

class _SajuInputScreenState extends State<SajuInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _selectedHour;
  String? _selectedMinute;
  String? _selectedRegion;
  String? _selectedStatus;
  bool _isTimeUnknown = false;
  
  // Google Maps API Key는 AndroidManifest.xml과 AppDelegate.swift에 설정됨
  // 현재 구현에서는 geolocator와 geocoding 패키지를 사용하므로 직접적인 API 키 사용 불필요
  
  final List<String> _genders
   = ['여성', '남성', '논바이너리'];
  final List<String> _hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> _minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  final List<String> _statuses = ['기혼', '연애 중', '연애희망', '관심없음'];

  @override
  void initState() {
    super.initState();
    _loadSavedSajuInfo();
  }

  Widget _buildUnifiedFormCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    final hasTime = _selectedHour != null && _selectedMinute != null;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름
          Row(
            children: [
              const SizedBox(width: 4),
              Text('이름', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.notoSans(fontSize: 17, color: primary),
            decoration: InputDecoration(
              hintText: '이름을 입력해주세요',
              hintStyle: GoogleFonts.notoSans(fontSize: 17, color: secondary),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.amber)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            ),
          ),

          const SizedBox(height: 25),

          // 성별
          Row(
            children: [
              const SizedBox(width: 4),
              Text('성별', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 여성
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = '여성'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 2.5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _selectedGender == '여성' ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == '여성' ? const Color(0xFF5d7df4) : border),
                    ),
                    child: Text(
                      '여성',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selectedGender == '여성' ? const Color(0xFF5d7df4) : primary),
                    ),
                  ),
                ),
              ),
              // 남성
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = '남성'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _selectedGender == '남성' ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == '남성' ? const Color(0xFF5d7df4) : border),
                    ),
                    child: Text(
                      '남성',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selectedGender == '남성' ? const Color(0xFF5d7df4) : primary),
                    ),
                  ),
                ),
              ),
              // 논바이너리
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = '논바이너리'),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2.5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _selectedGender == '논바이너리' ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == '논바이너리' ? const Color(0xFF5d7df4) : border),
                    ),
                    child: Text(
                      '논바이너리',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selectedGender == '논바이너리' ? const Color(0xFF5d7df4) : primary),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // 출생일자
          Row(
            children: [
              const SizedBox(width: 4),
              Text('출생일자', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일' : '생년월일을 선택해주세요',
                      style: GoogleFonts.notoSans(fontSize: 17, color: _selectedDate != null ? primary : secondary),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: secondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 출생시간
          Row(
            children: [
              const SizedBox(width: 4),
              Text('출생시간', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _isTimeUnknown ? null : _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: _isTimeUnknown ? cardBg.withOpacity(0.5) : cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isTimeUnknown ? '시간모름' : ( _selectedHour != null && _selectedMinute != null ? '${_selectedHour!.padLeft(2, '0')}시 ${_selectedMinute!.padLeft(2, '0')}분' : '시간을 선택해주세요'),
                            style: GoogleFonts.notoSans(fontSize: 17, color: _isTimeUnknown ? secondary.withOpacity(0.5) : (_selectedHour != null ? primary : secondary)),
                          ),
                        ),
                        if (!_isTimeUnknown) Icon(Icons.arrow_drop_down, color: secondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isTimeUnknown = !_isTimeUnknown;
                      if (_isTimeUnknown) { _selectedHour = null; _selectedMinute = null; }
                    });
                  },
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(color: _isTimeUnknown ? const Color(0xFF5d7df4) : cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _isTimeUnknown ? const Color(0xFF5d7df4) : border)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isTimeUnknown ? Icons.check_box : Icons.check_box_outline_blank, color: _isTimeUnknown ? Colors.white : secondary),
                          const SizedBox(width: 6),
                          Text('시간모름', style: GoogleFonts.notoSans(fontSize: 14, color: _isTimeUnknown ? Colors.white : secondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // 태어난 지역
          Row(
            children: [
              const SizedBox(width: 4),
              Text('태어난 지역', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedRegion != null && _selectedRegion!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: const Color(0xFF5d7df4).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF5d7df4).withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Color(0xFF5d7df4), size: 17),
                const SizedBox(width: 8),
                Expanded(child: Text(_selectedRegion!, style: GoogleFonts.notoSans(fontSize: 15, color: primary))),
              ]),
            ),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: _searchPlace,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _selectedRegion != null && _selectedRegion!.isNotEmpty ? '지역 다시 검색' : '지역 검색하기',
                      style: GoogleFonts.notoSans(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 상태
          Row(children: [
            const SizedBox(width: 4),
            Text('사랑에 대한 나의 상태', style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              underline: Container(),
              style: GoogleFonts.notoSans(
                fontSize: 17,
                color: primary,
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              hint: Text(
                '상태를 선택해주세요',
                style: GoogleFonts.notoSans(
                  fontSize: 17,
                  color: secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _loadSavedSajuInfo() async {
    if (widget.isFriendInfo) {
      final friendInfo = await FriendService.loadFriendInfo();
      if (friendInfo != null && mounted) {
        setState(() {
          _nameController.text = friendInfo.name;
          _selectedGender = friendInfo.gender;
          _selectedDate = friendInfo.birthDate;
          _selectedHour = friendInfo.birthHour.toString().padLeft(2, '0');
          _selectedMinute = friendInfo.birthMinute.toString().padLeft(2, '0');
          _selectedRegion = friendInfo.region;
          _regionController.text = friendInfo.region;
          _selectedStatus = friendInfo.status;
        });
      }
    } else {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null && mounted) {
        setState(() {
          _nameController.text = sajuInfo.name;
          _selectedGender = sajuInfo.gender;
          _selectedDate = sajuInfo.birthDate;
          _selectedHour = sajuInfo.birthHour.toString().padLeft(2, '0');
          _selectedMinute = sajuInfo.birthMinute.toString().padLeft(2, '0');
          _selectedRegion = sajuInfo.region;
          _regionController.text = sajuInfo.region;
          _selectedStatus = sajuInfo.status;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            
            // 메인 콘텐츠
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 안내 메시지
            _buildInfoMessage(),
            
            const SizedBox(height: 30),
            
            // 통합 입력 카드
            _buildUnifiedFormCard(),
            
            const SizedBox(height: 30),
            
            // 저장 버튼
            _buildSaveButton(),
            
            // 하단 여백 추가 (오버플로우 방지)
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // 일반적인 뒤로가기
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(width: 0),
          Text(
            widget.isFriendInfo ? '친구 정보 입력' : '출생 정보 입력',
            style: GoogleFonts.notoSans(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    final primary = Theme.of(context).colorScheme.onBackground;
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.amber,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            'AI가 당신만의 이야기를\n풀어내려면 출생정보가 필요해요.',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '이름',
                style: GoogleFonts.notoSans(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.notoSans(
              fontSize: 17,
              color: primary,
            ),
            decoration: InputDecoration(
              hintText: '이름을 입력해주세요',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 17,
                color: secondary,
              ),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildDateInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '출생일자',
                style: GoogleFonts.notoSans(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                          : '생년월일을 선택해주세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 17,
                        color: _selectedDate != null ? primary : secondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    final hasTime = _selectedHour != null && _selectedMinute != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                '출생시간',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _isTimeUnknown ? null : _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: _isTimeUnknown ? cardBg.withOpacity(0.5) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isTimeUnknown 
                                ? '시간모름'
                                : hasTime
                                    ? '${_selectedHour!.padLeft(2, '0')}시 ${_selectedMinute!.padLeft(2, '0')}분'
                                    : '시간을 선택해주세요',
                            style: GoogleFonts.notoSans(
                              fontSize: 17,
                              color: _isTimeUnknown 
                                  ? secondary.withOpacity(0.5)
                                  : hasTime ? primary : secondary,
                            ),
                          ),
                        ),
                        if (!_isTimeUnknown)
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isTimeUnknown = !_isTimeUnknown;
                      if (_isTimeUnknown) {
                        _selectedHour = null;
                        _selectedMinute = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: _isTimeUnknown ? primary : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _isTimeUnknown ? primary : border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isTimeUnknown ? Icons.check_box : Icons.check_box_outline_blank,
                          color: _isTimeUnknown ? Colors.white : secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '시간모름',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: _isTimeUnknown ? Colors.white : secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final int initHour = int.tryParse(_selectedHour ?? '') ?? DateTime.now().hour;
    final int initMinute = int.tryParse(_selectedMinute ?? '') ?? DateTime.now().minute;
    DateTime temp = DateTime(2000, 1, 1, initHour, initMinute);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소', style: TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, temp),
                        child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                // Column labels for hour/minute
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('시', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                      const SizedBox(width: 20),
                      Text('분', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: temp,
                    onDateTimeChanged: (value) {
                      temp = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

          if (picked != null) {
        setState(() {
          _selectedHour = picked.hour.toString().padLeft(2, '0');
          _selectedMinute = picked.minute.toString().padLeft(2, '0');
        });
      }
  }

  Widget _buildGenderInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '성별',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _genders.map((gender) {
              final isSelected = _selectedGender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : border,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.amber[800] : primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '태어난 지역',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedRegion != null && _selectedRegion!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.amber,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedRegion!,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _searchPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.search),
              label: Text(
                _selectedRegion != null && _selectedRegion!.isNotEmpty
                    ? '지역 다시 검색'
                    : '지역 검색하기',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_outline,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '사랑에 대한 나의 상태',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _statuses.map((status) {
              final isSelected = _selectedStatus == status;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : border,
                      ),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.amber[800] : primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

    Future<void> _searchPlace() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const LocationPickerScreen(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedRegion = result['address'];
        _regionController.text = result['address'];
      });
    }
  }

  Widget _buildSaveButton() {
    // 모든 필수 항목이 입력되었는지 확인 (시간모름 선택 시 시간 정보는 선택사항)
    final bool isFormValid = _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _selectedDate != null &&
        (_selectedHour != null && _selectedMinute != null || _isTimeUnknown) &&
        _selectedRegion != null &&
        _selectedStatus != null;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isFormValid ? _saveSajuInfo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? const Color(0xFF5d7df4) : Colors.grey.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.isFriendInfo ? '친구 정보 저장' : '출생 정보 저장',
          style: GoogleFonts.notoSans(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime initial = _selectedDate ?? DateTime.now();
    int tempYear = initial.year;
    int tempMonth = initial.month;
    int tempDay = initial.day;

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소', style: TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, DateTime(tempYear, tempMonth, tempDay)),
                        child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 년/월/일 라벨
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('년', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                      Text('월', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                      Text('일', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      // 년도 선택
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: tempYear - 1900,
                          ),
                          onSelectedItemChanged: (index) {
                            tempYear = 1900 + index;
                            // 월/일 유효성 검사
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) {
                              tempDay = maxDay;
                            }
                          },
                          children: List.generate(
                            DateTime.now().year - 1900 + 1,
                            (index) => Center(
                              child: Text(
                                '${1900 + index}',
                                style: TextStyle(fontSize: 18, color: onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 월 선택
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: tempMonth - 1,
                          ),
                          onSelectedItemChanged: (index) {
                            tempMonth = index + 1;
                            // 일 유효성 검사
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) {
                              tempDay = maxDay;
                            }
                          },
                          children: List.generate(
                            12,
                            (index) => Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: 18, color: onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 일 선택
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: tempDay - 1,
                          ),
                          onSelectedItemChanged: (index) {
                            tempDay = index + 1;
                          },
                          children: List.generate(
                            31,
                            (index) => Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: 18, color: onSurface),
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
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      final zodiacSign = ZodiacUtils.getZodiacSign(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '별자리: $zodiacSign (${ZodiacUtils.getZodiacPeriod(zodiacSign)})',
              style: GoogleFonts.notoSans(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: Colors.amber,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _saveSajuInfo() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('이름을 입력해주세요.');
      return;
    }
    
    if (_selectedGender == null) {
      _showSnackBar('성별을 선택해주세요.');
      return;
    }
    
    if (_selectedDate == null) {
      _showSnackBar('출생일자을 선택해주세요.');
      return;
    }
    
    // 시간모름이 아닌 경우에만 시간 정보 검증
    if (!_isTimeUnknown) {
      if (_selectedHour == null) {
        _showSnackBar('출생시간(시)을 선택해주세요.');
        return;
      }
      
      if (_selectedMinute == null) {
        _showSnackBar('출생시간(분)을 선택해주세요.');
        return;
      }
    }
    
    if (_selectedRegion == null) {
      _showSnackBar('태어난 지역을 검색하여 선택해주세요.');
      return;
    }

    if (_selectedStatus == null) {
      _showSnackBar('나의 상태를 선택해주세요.');
      return;
    }

    if (widget.isFriendInfo) {
      // 친구 정보 생성
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate!);
      final friendInfo = FriendInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
        birthHour: _isTimeUnknown ? 12 : int.parse(_selectedHour!),
        birthMinute: _isTimeUnknown ? 0 : int.parse(_selectedMinute!),
        gender: _selectedGender!,
        region: _selectedRegion!,
        status: _selectedStatus!,
        zodiacSign: zodiacSign,
      );

      // 친구 정보 저장
      final success = await FriendService.saveFriendInfo(friendInfo);
      
      if (success) {
        _showSnackBar('친구 정보가 저장되었습니다! (별자리: $zodiacSign)');
        Navigator.pop(context, true);
      } else {
        _showSnackBar('친구 정보 저장에 실패했습니다.');
      }
    } else {
      // 내 정보 생성
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate!);
      final sajuInfo = SajuInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
        birthHour: _isTimeUnknown ? 12 : int.parse(_selectedHour!),
        birthMinute: _isTimeUnknown ? 0 : int.parse(_selectedMinute!),
        gender: _selectedGender!,
        region: _selectedRegion!,
        status: _selectedStatus!,
        zodiacSign: zodiacSign,
      );

      // 내 정보 저장
      final success = await SajuService.saveSajuInfo(sajuInfo);
      
      if (success) {
        _showSnackBar('출생 정보가 저장되었습니다! (별자리: $zodiacSign)');
        // 홈 화면으로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // 모든 이전 화면 제거
        );
      } else {
        _showSnackBar('출생 정보 저장에 실패했습니다.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
