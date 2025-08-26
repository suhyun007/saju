import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../models/saju_info.dart';
import '../models/friend_info.dart';
import '../services/saju_service.dart';
import '../services/friend_service.dart';
import '../utils/zodiac_utils.dart';
import 'location_picker_screen.dart';

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
  
  // Google Maps API Key는 AndroidManifest.xml과 AppDelegate.swift에 설정됨
  // 현재 구현에서는 geolocator와 geocoding 패키지를 사용하므로 직접적인 API 키 사용 불필요
  
  final List<String> _genders
   = ['남성', '여성'];
  final List<String> _hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> _minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  final List<String> _statuses = ['기혼', '연애 중', '연애희망', '관심없음'];

  @override
  void initState() {
    super.initState();
    _loadSavedSajuInfo();
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
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 안내 메시지
            _buildInfoMessage(),
            
            const SizedBox(height: 30),
            
            // 이름 입력
            _buildNameInput(),
            
            const SizedBox(height: 20),
            
            // 성별 선택
            _buildGenderInput(),
            
            const SizedBox(height: 20),
            
            // 출생일자 입력
            _buildDateInput(),
            
            const SizedBox(height: 20),
            
            // 출생시간 입력
            _buildTimeInput(),
            
            const SizedBox(height: 20),
            
            // 태어난 지역 선택
            _buildRegionInput(),
            
            const SizedBox(height: 20),
            
            // 나의 상태 선택
            _buildStatusInput(),
            
            const SizedBox(height: 30),
            
            // 저장 버튼
            _buildSaveButton(),
          ],
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
            widget.isFriendInfo ? '친구 정보 입력' : '출생 정보 입력',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.amber,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            '정확한 점성술 분석을 위해\n정확한 출생정보를 입력해주세요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
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
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '이름',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '이름을 입력해주세요',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.white70,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                          : '생년월일을 선택해주세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: _selectedDate != null ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
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
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '출생시간',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // 시간 선택
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedHour,
                      hint: Text(
                        '시',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      dropdownColor: const Color(0xFF4A2C1A),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      items: _hours.map((String hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedHour = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                ':',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // 분 선택
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMinute,
                      hint: Text(
                        '분',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      dropdownColor: const Color(0xFF4A2C1A),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      items: _minutes.map((String minute) {
                        return DropdownMenuItem<String>(
                          value: minute,
                          child: Text(minute),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMinute = newValue;
                        });
                      },
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

  Widget _buildGenderInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '성별',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      gender,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.amber : Colors.white,
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
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '태어난 지역',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // 현재 선택된 지역 표시
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
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedRegion!,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 지역 검색 버튼
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
                  fontSize: 16,
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
          Row(
            children: [
              const Icon(
                Icons.favorite_outline,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '나의 상태',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
                      color: isSelected 
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.amber : Colors.white,
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
    // 바텀시트로 지역 검색 화면 표시
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true, // 전체 화면 높이 사용
      backgroundColor: Colors.transparent, // 배경 투명
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5, // 화면의 1/3 높이
        decoration: const BoxDecoration(
          color: Color(0xFF2C1810), // 배경색
          borderRadius: BorderRadius.only(
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
        _regionController.text = result['address']; // 입력창에도 지역명 표시
      });
    }
  }

  Widget _buildSaveButton() {
    // 모든 필수 항목이 입력되었는지 확인
    final bool isFormValid = _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _selectedDate != null &&
        _selectedHour != null &&
        _selectedMinute != null &&
        _selectedRegion != null &&
        _selectedStatus != null;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isFormValid ? _saveSajuInfo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? Colors.amber : Colors.grey.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isFormValid ? 5 : 0,
        ),
        child: Text(
          widget.isFriendInfo ? '친구 정보 저장' : '출생 정보 저장',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: Color(0xFF4A2C1A),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF2C1810)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // 날짜가 선택되면 별자리 정보를 스낵바로 표시
      final zodiacSign = ZodiacUtils.getZodiacSign(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '별자리: $zodiacSign (${ZodiacUtils.getZodiacPeriod(zodiacSign)})',
              style: GoogleFonts.notoSans(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: Colors.amber,
            duration: const Duration(seconds: 3),
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
    
    if (_selectedHour == null) {
      _showSnackBar('출생시간(시)을 선택해주세요.');
      return;
    }
    
    if (_selectedMinute == null) {
      _showSnackBar('출생시간(분)을 선택해주세요.');
      return;
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
        birthHour: int.parse(_selectedHour!),
        birthMinute: int.parse(_selectedMinute!),
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
        birthHour: int.parse(_selectedHour!),
        birthMinute: int.parse(_selectedMinute!),
        gender: _selectedGender!,
        region: _selectedRegion!,
        status: _selectedStatus!,
        zodiacSign: zodiacSign,
      );

      // 내 정보 저장
      final success = await SajuService.saveSajuInfo(sajuInfo);
      
      if (success) {
        _showSnackBar('출생 정보가 저장되었습니다! (별자리: $zodiacSign)');
        Navigator.pop(context, true);
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
