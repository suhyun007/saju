import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
  
  final List<String> _hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> _minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    _loadSavedSajuInfo();
  }
  


  Widget _buildUnifiedFormCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    final hasTime = _selectedHour != null && _selectedMinute != null;
    
    // 성별과 상태 배열을 현재 언어로 정의
    final genders = [l10n.female, l10n.male, l10n.nonBinary];
    final statuses = [l10n.married, l10n.inRelationship, l10n.wantRelationship, l10n.noInterest];

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
              Text(l10n.name, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.notoSans(fontSize: 15, color: primary),
            decoration: InputDecoration(
              hintText: l10n.nameHint,
              hintStyle: GoogleFonts.notoSans(fontSize: 15, color: secondary),
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
              Text(l10n.gender, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 여성 (30%)
              Expanded(
                flex: 30,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = l10n.female),
                  child: Container(
                    margin: const EdgeInsets.only(right: 2.5),
                    padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                    color: _selectedGender == l10n.female ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedGender == l10n.female ? const Color(0xFF5d7df4) : border),
                  ),
                    child: Text(
                      l10n.female,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w500, color: _selectedGender == l10n.female ? const Color(0xFF5d7df4) : primary),
                    ),
                  ),
                ),
              ),
              // 남성 (30%)
              Expanded(
                flex: 30,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = l10n.male),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _selectedGender == l10n.male ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == l10n.male ? const Color(0xFF5d7df4) : border),
                    ),
                    child: Text(
                      l10n.male,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w500, color: _selectedGender == l10n.male ? const Color(0xFF5d7df4) : primary),
                    ),
                  ),
                ),
              ),
              // 논바이너리 (40%)
              Expanded(
                flex: 40,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = l10n.nonBinary),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2.5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _selectedGender == l10n.nonBinary ? const Color(0xFF5d7df4).withOpacity(0.2) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == l10n.nonBinary ? const Color(0xFF5d7df4) : border),
                    ),
                    child: Text(
                      l10n.nonBinary,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w500, color: _selectedGender == l10n.nonBinary ? const Color(0xFF5d7df4) : primary),
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
              Text(l10n.birthDate, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.w600, color: primary)),
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
                      _selectedDate != null ? _formatDateForDisplay(_selectedDate!) : l10n.birthDateHint,
                      style: GoogleFonts.notoSans(fontSize: 15, color: _selectedDate != null ? primary : secondary),
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
              Text(l10n.birthTime, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.bold, color: primary)),
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
                            _isTimeUnknown ? l10n.timeUnknown : ( _selectedHour != null && _selectedMinute != null ? _formatTimeForDisplay(_selectedHour, _selectedMinute) : l10n.birthTimeHint),
                            style: GoogleFonts.notoSans(fontSize: 13, color: _isTimeUnknown ? secondary.withOpacity(0.5) : (_selectedHour != null ? primary : secondary)),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    decoration: BoxDecoration(color: _isTimeUnknown ? const Color(0xFF5d7df4) : cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _isTimeUnknown ? const Color(0xFF5d7df4) : border)),
                    child: Row(
                      children: [
                        Icon(_isTimeUnknown ? Icons.check_box : Icons.check_box_outline_blank, color: _isTimeUnknown ? Colors.white : secondary, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.timeUnknown, 
                            style: GoogleFonts.notoSans(fontSize: 13, color: _isTimeUnknown ? Colors.white : secondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
              Text(l10n.birthRegion, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.w600, color: primary)),
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
                Expanded(child: Text(_selectedRegion!, style: GoogleFonts.notoSans(fontSize: 13, color: primary))),
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
                      _selectedRegion != null && _selectedRegion!.isNotEmpty ? l10n.searchRegionAgain : l10n.searchRegion,
                      style: GoogleFonts.notoSans(fontSize: Localizations.localeOf(context).languageCode == 'en' ? 15 : 16, fontWeight: FontWeight.w600, color: Colors.white),
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
            Text(l10n.loveStatus, style: GoogleFonts.notoSans(fontSize: 21, fontWeight: FontWeight.w600, color: primary)),
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
                fontSize: 15,
                color: primary,
              ),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      status,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                  fontSize: 15,
                  color: secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _mapStatusToCurrentLanguage(String? savedStatus) {
    if (savedStatus == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    // 저장된 값이 현재 언어의 값과 일치하는지 확인
    final currentStatuses = [l10n.married, l10n.inRelationship, l10n.wantRelationship, l10n.noInterest];
    if (currentStatuses.contains(savedStatus)) {
      return savedStatus;
    }
    
    // 저장된 값이 다른 언어의 값인 경우 매핑
    if (savedStatus == '연애중' || savedStatus == 'In a Relationship' || savedStatus == '恋爱中' || savedStatus == '恋愛中') {
      return l10n.inRelationship;
    } else if (savedStatus == '결혼' || savedStatus == 'Married' || savedStatus == '已婚' || savedStatus == '結婚') {
      return l10n.married;
    } else if (savedStatus == '연애하고 싶음' || savedStatus == 'Want a Relationship' || savedStatus == '想恋爱' || savedStatus == '恋愛したい') {
      return l10n.wantRelationship;
    } else if (savedStatus == '관심없음' || savedStatus == 'No Interest' || savedStatus == '不感兴趣' || savedStatus == '興味なし') {
      return l10n.noInterest;
    }
    
    // 매핑되지 않은 경우 기본값 반환
    return l10n.inRelationship;
  }

  String _formatDateForDisplay(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    
    // 영어일 때는 year, month, day 텍스트 없이 숫자만 표시
    if (locale.languageCode == 'en') {
      return '${date.month}.${date.day}.${date.year}';
    } else {
      // 다른 언어는 기존 형식 유지
      return '${date.year}${l10n.year} ${date.month}${l10n.month} ${date.day}${l10n.day}';
    }
  }

  String _formatTimeForDisplay(String? hour, String? minute) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    
    if (hour == null || minute == null) return '';
    
    // 영어일 때는 hour, minute 텍스트 없이 숫자만 표시
    if (locale.languageCode == 'en') {
      return '${hour.padLeft(2, '0')}:${minute.padLeft(2, '0')}';
    } else {
      // 다른 언어는 기존 형식 유지
      return '${hour.padLeft(2, '0')}${l10n.hour} ${minute.padLeft(2, '0')}${l10n.minute}';
    }
  }

  Widget _buildYearPicker(int year, Function(int) onChanged, Color onSurface) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: year - 1900,
        ),
        onSelectedItemChanged: (index) {
          onChanged(1900 + index);
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
    );
  }

  Widget _buildMonthPicker(int month, Function(int) onChanged, Color onSurface) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: month - 1,
        ),
        onSelectedItemChanged: (index) {
          onChanged(index + 1);
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
    );
  }

  Widget _buildDayPicker(int day, Function(int) onChanged, Color onSurface) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: day - 1,
        ),
        onSelectedItemChanged: (index) {
          onChanged(index + 1);
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
    );
  }

  int _getHourIndex(int hour) {
    return hour;
  }

  int _getHourFromIndex(int index) {
    return index;
  }

  String _formatHourForDisplay(int hour, AppLocalizations l10n, Locale locale) {
    if (locale.languageCode == 'en') {
      // 영어: AM/PM 형식
      if (hour == 0) {
        return '${l10n.am} 12';
      } else if (hour < 12) {
        return '${l10n.am} ${hour.toString().padLeft(2, '0')}';
      } else if (hour == 12) {
        return '${l10n.pm} 12';
      } else {
        return '${l10n.pm} ${(hour - 12).toString().padLeft(2, '0')}';
      }
    } else {
      // 다른 언어: 24시간 형식
      return '${hour.toString().padLeft(2, '0')}';
    }
  }

  String _mapGenderToCurrentLanguage(String? savedGender) {
    if (savedGender == null) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    // 저장된 값이 현재 언어의 값과 일치하는지 확인
    final currentGenders = [l10n.female, l10n.male, l10n.nonBinary];
    if (currentGenders.contains(savedGender)) {
      return savedGender;
    }
    
    // 저장된 값이 다른 언어의 값인 경우 매핑
    if (savedGender == '여성' || savedGender == 'Female' || savedGender == '女性' || savedGender == '女') {
      return l10n.female;
    } else if (savedGender == '남성' || savedGender == 'Male' || savedGender == '男性' || savedGender == '男') {
      return l10n.male;
    } else if (savedGender == '논바이너리' || savedGender == 'N-binary' || savedGender == 'ノンバイナリー' || savedGender == '非二元') {
      return l10n.nonBinary;
    }
    
    // 매핑되지 않은 경우 기본값 반환
    return l10n.female;
  }

  Future<void> _loadSavedSajuInfo() async {
    if (widget.isFriendInfo) {
      final friendInfo = await FriendService.loadFriendInfo();
      if (friendInfo != null && mounted) {
        setState(() {
          _nameController.text = friendInfo.name;
          _selectedGender = _mapGenderToCurrentLanguage(friendInfo.gender);
          _selectedDate = friendInfo.birthDate;
          _selectedHour = friendInfo.birthHour.toString().padLeft(2, '0');
          _selectedMinute = friendInfo.birthMinute.toString().padLeft(2, '0');
          _selectedRegion = friendInfo.region;
          _regionController.text = friendInfo.region;
          _selectedStatus = _mapStatusToCurrentLanguage(friendInfo.status);
        });
      }
    } else {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null && mounted) {
        setState(() {
          _nameController.text = sajuInfo.name;
          _selectedGender = _mapGenderToCurrentLanguage(sajuInfo.gender);
          _selectedDate = sajuInfo.birthDate;
          _selectedHour = sajuInfo.birthHour.toString().padLeft(2, '0');
          _selectedMinute = sajuInfo.birthMinute.toString().padLeft(2, '0');
          _selectedRegion = sajuInfo.region;
          _regionController.text = sajuInfo.region;
          _selectedStatus = _mapStatusToCurrentLanguage(sajuInfo.status);
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
    final l10n = AppLocalizations.of(context)!;
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
              widget.isFriendInfo ? l10n.friendInfoInput : l10n.birthInfoInput,
            style: GoogleFonts.notoSans(
              fontSize: Localizations.localeOf(context).languageCode == 'en' ? 24 : 25, // 영어일 때 -1 작게
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
              letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -1 : 0, // 영어일 때 글자 간격 -1
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.infoMessage,
            style: GoogleFonts.notoSans(
              fontSize: Localizations.localeOf(context).languageCode == 'en' ? 17 : 18,
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
    final l10n = AppLocalizations.of(context)!;
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
                l10n.name,
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
              hintText: l10n.nameHint,
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
    final l10n = AppLocalizations.of(context)!;
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
                                ? l10n.timeUnknown
                                : hasTime
                                    ? _formatTimeForDisplay(_selectedHour, _selectedMinute)
                                    : l10n.birthTimeHint,
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
    int tempHour = initHour;
    int tempMinute = initMinute;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

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
                        child: Text(l10n.cancel, style: const TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, DateTime(2000, 1, 1, tempHour, tempMinute)),
                        child: Text(l10n.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                // 언어에 따른 라벨
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(l10n.hour, style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                      const SizedBox(width: 20),
                      Text(l10n.minute, style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                Expanded(
                  child: Row(
                    children: [
                      // 시 선택 (오전/오후 포함)
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: _getHourIndex(initHour),
                          ),
                          onSelectedItemChanged: (index) {
                            tempHour = _getHourFromIndex(index);
                          },
                          children: List.generate(
                            24,
                            (index) => Center(
                              child: Text(
                                _formatHourForDisplay(index, l10n, locale),
                                style: TextStyle(fontSize: 18, color: onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 분 선택
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: initMinute,
                          ),
                          onSelectedItemChanged: (index) {
                            tempMinute = index;
                          },
                          children: List.generate(
                            60,
                            (index) => Center(
                              child: Text(
                                '${index.toString().padLeft(2, '0')}',
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
        _selectedHour = picked.hour.toString().padLeft(2, '0');
        _selectedMinute = picked.minute.toString().padLeft(2, '0');
      });
    }
  }

  Widget _buildGenderInput() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    
    // 성별 배열을 현재 언어로 정의
    final genders = [l10n.female, l10n.male, l10n.nonBinary];
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
            children: genders.map((gender) {
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onBackground;
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    
    // 상태 배열을 현재 언어로 정의
    final statuses = [l10n.married, l10n.inRelationship, l10n.wantRelationship, l10n.noInterest];
    
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
                l10n.loveStatus,
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
            children: statuses.map((status) {
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
    final l10n = AppLocalizations.of(context)!;
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
          widget.isFriendInfo ? l10n.saveFriendInfo : l10n.saveBirthInfo,
          style: GoogleFonts.notoSans(
            fontSize: Localizations.localeOf(context).languageCode == 'en' ? 20 : 21,
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
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;

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
                        child: Text(l10n.cancel, style: const TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, DateTime(tempYear, tempMonth, tempDay)),
                        child: Text(l10n.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 언어에 따른 라벨 순서
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: locale.languageCode == 'en' 
                      ? [
                          Text('Month', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                          Text('Day', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                          Text('Year', style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                        ]
                      : [
                          Text(l10n.year, style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                          Text(l10n.month, style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                          Text(l10n.day, style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7))),
                        ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: locale.languageCode == 'en' 
                      ? [
                          // 영어: 월, 일, 년도 순서
                          _buildMonthPicker(tempMonth, (month) {
                            tempMonth = month;
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) tempDay = maxDay;
                          }, onSurface),
                          _buildDayPicker(tempDay, (day) => tempDay = day, onSurface),
                          _buildYearPicker(tempYear, (year) {
                            tempYear = year;
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) tempDay = maxDay;
                          }, onSurface),
                        ]
                      : [
                          // 다른 언어: 년도, 월, 일 순서
                          _buildYearPicker(tempYear, (year) {
                            tempYear = year;
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) tempDay = maxDay;
                          }, onSurface),
                          _buildMonthPicker(tempMonth, (month) {
                            tempMonth = month;
                            int maxDay = DateTime(tempYear, tempMonth + 1, 0).day;
                            if (tempDay > maxDay) tempDay = maxDay;
                          }, onSurface),
                          _buildDayPicker(tempDay, (day) => tempDay = day, onSurface),
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
