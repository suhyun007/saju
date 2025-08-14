import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../models/saju_info.dart';
import '../services/saju_service.dart';

class SajuInputScreen extends StatefulWidget {
  const SajuInputScreen({super.key});

  @override
  State<SajuInputScreen> createState() => _SajuInputScreenState();
}

class _SajuInputScreenState extends State<SajuInputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedHour;
  String? _selectedMinute;
  String? _selectedGender;
  late final WebViewController _webController;
  bool _showWebView = false;
  
  final List<String> _genders = ['남성', '여성'];
  final List<String> _hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> _minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() async {
    try {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
        AndroidWebViewController.enableDebugging(true);
      }

      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (String url) {
            print('사주 WebView 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            print('사주 WebView 로딩 완료: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('사주 WebView 오류: ${error.description}');
          },
        ))
        ..loadFlutterAsset('web/saju_input.html');
    } catch (e) {
      print('사주 WebView 초기화 오류: $e');
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
                child: _showWebView 
                  ? _buildWebView()
                  : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return WebViewWidget(controller: _webController);
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
            
            // 생년월일 입력
            _buildDateInput(),
            
            const SizedBox(height: 20),
            
            // 출생시간 입력
            _buildTimeInput(),
            
            const SizedBox(height: 20),
            
            // 성별 선택
            _buildGenderInput(),
            
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
          Expanded(
            child: Text(
              '사주 정보 입력',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showWebView = !_showWebView;
              });
            },
            icon: Icon(
              _showWebView ? Icons.apps : Icons.web,
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
            '정확한 사주 분석을 위해\n실제 출생 정보를 입력해주세요',
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
                '출생일',
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
        borderRadius: BorderRadius.circular(15),
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
                    padding: const EdgeInsets.all(15),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveSajuInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          '사주 정보 저장',
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
    }
  }

  void _saveSajuInfo() async {
    if (_selectedDate == null) {
      _showSnackBar('출생일을 선택해주세요.');
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
    
    if (_selectedGender == null) {
      _showSnackBar('성별을 선택해주세요.');
      return;
    }

    // 사주 정보 생성
    final sajuInfo = SajuInfo(
      birthDate: _selectedDate!,
      birthHour: int.parse(_selectedHour!),
      birthMinute: int.parse(_selectedMinute!),
      gender: _selectedGender!,
    );

    // 사주 정보 저장
    final success = await SajuService.saveSajuInfo(sajuInfo);
    
    if (success) {
      _showSnackBar('사주 정보가 저장되었습니다!');
      // 홈 화면으로 돌아가기
      Navigator.pop(context, true); // true를 전달하여 홈 화면에서 새로고침하도록 함
    } else {
      _showSnackBar('사주 정보 저장에 실패했습니다.');
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
