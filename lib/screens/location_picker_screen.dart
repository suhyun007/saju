import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedAddress = '';
  double? _selectedLatitude;
  double? _selectedLongitude;
  List<Map<String, dynamic>> _searchResults = []; // ✅ 검색 결과 저장 리스트
  Timer? _debounceTimer; // ✅ 디바운싱용 타이머



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel(); // 타이머 정리
    super.dispose();
  }

  /// ✅ 서버를 통한 지역 검색 API 호출 (디바운싱 적용)
  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _searchResults.clear();
        _selectedAddress = ''; // 검색어가 비면 선택된 지역도 초기화
      });
      return;
    }

    // 새로운 검색 시작 시 선택된 지역 초기화
    setState(() {
      _selectedAddress = '';
    });

    // 이전 타이머 취소
    _debounceTimer?.cancel();
    
    // 500ms 후에 서버 API 호출
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final url = Uri.parse('https://saju-server-j9ti.vercel.app/api/places/search');
      final locale = Localizations.localeOf(context);

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'input': input,
            'language': locale.languageCode, // 현재 언어 정보 전달
          }),
        );
        
        print('🌍 클라이언트에서 보내는 언어: ${locale.languageCode}');
        print('🌍 검색어: $input');

        print('📌 서버 API 상태코드: ${response.statusCode}');
        print('📌 서버 API 응답: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final predictions = data['predictions'] ?? [];
          
          if (mounted) {
            setState(() {
              _searchResults = List<Map<String, dynamic>>.from(predictions);
            });
          }
        } else {
          print("❌ 서버 API 호출 실패: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ 서버 API 에러: $e");
      }
    });
  }

  Future<void> _selectPlace(String placeId, String description) async {
    print('🚀 _selectPlace 함수 시작');
    print('🚀 placeId: $placeId');
    print('🚀 description: $description');
    
    // 서버 API 호출 없이 바로 UI 업데이트
    setState(() {
      _selectedAddress = description;
      _selectedLatitude = 37.5665; // 서울 기본값 (임시)
      _selectedLongitude = 126.9780; // 서울 기본값 (임시)
      _searchController.text = description; // 입력창에 선택된 지역명 표시
      _searchResults.clear(); // 검색 결과 숨김
    });

    // _showSnackBar('위치가 선택되었습니다: $description'); // 메시지 제거
    
    // 서버 API 호출은 백그라운드에서 시도 (위도/경도 업데이트용)
    _fetchLocationDetails(placeId, description);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _selectedAddress = '';
      _selectedLatitude = null;
      _selectedLongitude = null;
    });
  }

  Future<void> _fetchLocationDetails(String placeId, String description) async {
    final url = Uri.parse('https://saju-server-j9ti.vercel.app/api/places/details');
    final locale = Localizations.localeOf(context);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'placeId': placeId,
          'language': locale.languageCode, // 현재 언어 정보 전달
        }),
      );

      print("📌 서버 상세조회 상태코드: ${response.statusCode}");
      print("📌 서버 상세조회 응답: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['location'];
        
        setState(() {
          _selectedLatitude = location['latitude'];
          _selectedLongitude = location['longitude'];
        });
      } else {
        print("❌ 서버 장소 상세조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 서버 상세조회 에러: $e");
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
              _buildHeader(),
              _buildSearchInput(),

              // 선택된 지역 표시
              if (_selectedAddress.isNotEmpty) _buildSelectedLocation(),

              // 🔍 검색 결과 리스트 (선택된 지역이 없을 때만 표시)
              if (_selectedAddress.isEmpty)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: _searchResults.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final place = _searchResults[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.location_on, color: Colors.amber),
                                  title: Text(
                                    place['description'],
                                    style: GoogleFonts.notoSans(color: Colors.white),
                                  ),
                                  onTap: () {
                                    print('🎯 지역 클릭됨: ${place['description']}');
                                    print('🎯 place_id: ${place['place_id']}');
                                    _selectPlace(place['place_id'], place['description']);
                                  },
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)?.locationSearchEmptyMessage ?? '지역명을 입력하여 검색하세요',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              AppLocalizations.of(context)?.locationSearchTitle ?? '태어난 지역 검색',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.locationSearchHint ?? '지역/구/동을 입력하세요',
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
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    _clearSearch();
                  },
                )
              : null,
        ),
        onChanged: (value) => _searchPlaces(value),
      ),
    );
  }

  Widget _buildSelectedLocation() {
    return Container(
      margin: const EdgeInsets.all(20),
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
              const Icon(Icons.location_on, color: Colors.amber, size: 24),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)?.selectedLocation ?? '선택된 위치',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedAddress,
            style: GoogleFonts.notoSans(fontSize: 16, color: Colors.white),
          ),
          if (_selectedLatitude != null && _selectedLongitude != null) ...[
            const SizedBox(height: 5),
            Text(
              '${AppLocalizations.of(context)?.latitude ?? '위도'}: ${_selectedLatitude!.toStringAsFixed(6)}, '
              '${AppLocalizations.of(context)?.longitude ?? '경도'}: ${_selectedLongitude!.toStringAsFixed(6)}',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.cancel ?? '취소',
                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedAddress.isNotEmpty
                  ? () {
                      Navigator.pop(context, {
                        'address': _selectedAddress,
                        'latitude': _selectedLatitude,
                        'longitude': _selectedLongitude,
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.select ?? '선택',
                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
