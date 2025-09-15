import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '../models/saju_info.dart';
import '../models/friend_info.dart';
import '../services/saju_service.dart';
import '../services/friend_service.dart';
import '../services/analytics_service.dart';
import '../utils/zodiac_utils.dart';
import 'location_picker_screen.dart';
import 'home_screen.dart';

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
  String? _selectedRegion;
  String? _selectedLoveStatus;
  
  // Google Maps API Key는 AndroidManifest.xml과 AppDelegate.swift에 설정됨
  // 현재 구현에서는 geolocator와 geocoding 패키지를 사용하므로 직접적인 API 키 사용 불필요

  @override
  void initState() {
    super.initState();
    _loadSavedSajuInfo();
    // 화면 진입 즉시 로그 기록
    AnalyticsService.logMenuClick('saveInfo');
    // 이름 입력 필드 변경 감지
    _nameController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    super.dispose();
  }
  
  Widget _buildUnifiedFormCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = primary.withOpacity(0.7);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.7);
    final border = isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
    
    // 상태 배열을 현재 언어로 정의
    final statuses = [l10n.married, l10n.inRelationship, l10n.wantRelationship, l10n.noInterest];
    
    // 영어 키값 매핑
    final statusKeys = ['married', 'inRelationship', 'wantRelationship', 'noInterest'];

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
          // 이름
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${l10n.name} *', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary, fontFamily: 'NotoSansKR')),
            ],
          ),
          const SizedBox(height: 3),
          TextFormField(
            controller: _nameController,
            style: TextStyle(fontSize: 15, color: primary),
            decoration: InputDecoration(
              hintText: l10n.nameHint,
              hintStyle: TextStyle(fontSize: 15, color: secondary),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), 
                borderSide: BorderSide(
                  color: _nameController.text.trim().isEmpty 
                    ? (isDark ? Colors.amber : Colors.blue) 
                    : border
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), 
                borderSide: BorderSide(
                  color: _nameController.text.trim().isEmpty 
                    ? (isDark ? Colors.amber : Colors.blue) 
                    : border
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), 
                borderSide: BorderSide(
                  color: _nameController.text.trim().isEmpty 
                    ? (isDark ? Colors.amber : Colors.blue) 
                    : border
                )
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),

          const SizedBox(height: 15),

          // 성별
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${l10n.gender} *', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              // 여성 (30%)
              Expanded(
                flex: 30,
                child:                 GestureDetector(
                  onTap: () => setState(() => _selectedGender = 'female'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 2.5),
                    padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                    color: _selectedGender == 'female' ? (isDark ? const Color(0xFF5D7DF4).withOpacity(0.2) : Colors.grey.withOpacity(0.4)) : cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedGender == 'female' ? (isDark ? Colors.amber : Colors.blue) : border),
                  ),
                    child: Text(
                      l10n.female,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _selectedGender == 'female' ? (isDark ? Colors.white : Colors.black) : primary),
                    ),
                  ),
                ),
              ),
              // 남성 (30%)
              Expanded(
                flex: 30,
                child:                 GestureDetector(
                  onTap: () => setState(() => _selectedGender = 'male'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'male' ? (isDark ? const Color(0xFF5D7DF4).withOpacity(0.2) : Colors.grey.withOpacity(0.4)) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == 'male' ? (isDark ? Colors.amber : Colors.blue) : border),
                    ),
                    child: Text(
                      l10n.male,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _selectedGender == 'male' ? (isDark ? Colors.white : Colors.black) : primary),
                    ),
                  ),
                ),
              ),
              // 논바이너리 (40%)
              Expanded(
                flex: 40,
                child:                 GestureDetector(
                  onTap: () => setState(() => _selectedGender = 'nonBinary'),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2.5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'nonBinary' ? (isDark ? const Color(0xFF5d7df4).withOpacity(0.2) : Colors.grey.withOpacity(0.4)) : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedGender == 'nonBinary' ? (isDark ? Colors.amber : Colors.blue) : border),
                    ),
                    child: Text(
                      l10n.nonBinary,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _selectedGender == 'nonBinary' ? (isDark ? Colors.white : Colors.black) : primary),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 출생일자
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${l10n.birthDate} *', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 3),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null ? _formatDateForDisplay(_selectedDate!) : l10n.birthDateHint,
                      style: TextStyle(fontSize: 15, color: _selectedDate != null ? primary : secondary),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: secondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 태어난 지역
          Row(
            children: [
              const SizedBox(width: 4),
              Text(l10n.birthRegion, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 3),
          if (_selectedRegion != null && _selectedRegion!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: isDark ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: isDark ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3))
              ),
              child: Row(children: [
                Icon(Icons.check_circle, color: isDark ? Colors.amber : const Color(0xFF3D4B91), size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_selectedRegion!, style: TextStyle(fontSize: 15, color: primary))),
              ]),
            ),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: _searchPlace,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
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
                      style: TextStyle(fontSize: Localizations.localeOf(context).languageCode == 'en' ? 15 : 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 상태
          Row(children: [
            const SizedBox(width: 4),
            Text(l10n.loveStatus, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
          ]),
          const SizedBox(height: 3),
          InkWell(
            onTap: _showStatusBottomSheet,
            child: Container(
              width: double.infinity,
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedLoveStatus != null 
                        ? statuses[statusKeys.indexOf(_selectedLoveStatus!)]
                        : l10n.statusSelectHint,
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedLoveStatus != null ? primary : secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
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




  Future<void> _loadSavedSajuInfo() async {
    if (widget.isFriendInfo) {
      final friendInfo = await FriendService.loadFriendInfo();
      if (friendInfo != null && mounted) {
        setState(() {
          _nameController.text = friendInfo.name;
          _selectedGender = friendInfo.gender; // 영어 키값으로 저장
          _selectedDate = friendInfo.birthDate;
          _selectedRegion = friendInfo.region;
          _regionController.text = friendInfo.region;
          _selectedLoveStatus = friendInfo.loveStatus; // 영어 키값으로 저장
        });
      }
    } else {
      final sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo != null && mounted) {
        setState(() {
          _nameController.text = sajuInfo.name;
          _selectedGender = sajuInfo.gender; // 영어 키값으로 저장
          _selectedDate = sajuInfo.birthDate;
          _selectedRegion = sajuInfo.region;
          _regionController.text = sajuInfo.region;
          _selectedLoveStatus = sajuInfo.loveStatus; // 영어 키값으로 저장
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.transparent : Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDark ? 'assets/design/launch_bg.png' : 'assets/design/bg4.png'),
            fit: BoxFit.cover,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 안내 메시지
            _buildInfoMessage(),
            
            const SizedBox(height: 10),
            
            // 통합 입력 카드
            _buildUnifiedFormCard(),
            
            const SizedBox(height: 20),
            
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
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : const Color(0xFF1B2951), // 다크모드: 흰색, 라이트모드: 네이비
            ),
          ),
          const SizedBox(width: 0),
                      Text(
              widget.isFriendInfo ? l10n.friendInfoInput : l10n.birthInfoInput,
            style: TextStyle(
              fontSize: Localizations.localeOf(context).languageCode == 'en' ? 24 : 25, // 영어일 때 -1 작게
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -1 : 0, // 영어일 때 글자 간격 -1
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.amber : const Color(0xFF3D4B91),
            size: 50,
          ),
          const SizedBox(height: 5),
          Text(
            l10n.infoMessage,
            style: TextStyle(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 모든 필수 항목이 입력되었는지 확인
    final bool isFormValid = _nameController.text.trim().isNotEmpty &&
        _selectedGender != null &&
        _selectedDate != null;
        // _selectedRegion과 _selectedLoveStatus는 선택사항이므로 제거

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isFormValid ? _saveSajuInfo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? (isDark ? const Color(0xFF5d7df4) : const Color(0xFF3D4B91)) : Colors.grey.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: !isFormValid 
              ? BorderSide(
                  color: isDark 
                    ? const Color(0x809E9E9E)  // 다크모드: 50% 투명도
                    : const Color(0x4D9E9E9E), // 라이트모드: 30% 투명도
                  width: 1.5
                )
              : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          widget.isFriendInfo ? l10n.saveFriendInfo : l10n.saveBirthInfo,
          style: TextStyle(
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

    }
  }

  void _saveSajuInfo() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.validationNameRequired);
      return;
    }
    
    if (_selectedGender == null) {
      _showSnackBar(l10n.validationGenderRequired);
      return;
    }
    
    if (_selectedDate == null) {
      _showSnackBar(l10n.validationBirthDateRequired);
      return;
    }
    
    
    // 출생지역과 연애상태는 선택사항으로 변경
    // if (_selectedRegion == null) {
    //   _showSnackBar(l10n.validationRegionRequired);
    //   return;
    // }

    // if (_selectedLoveStatus == null) {
    //   _showSnackBar(l10n.validationStatusRequired);
    //   return;
    // }

    if (widget.isFriendInfo) {
      // 친구 정보 생성
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate!);
      final friendInfo = FriendInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
        birthHour: 12, // 기본값으로 설정
        birthMinute: 0, // 기본값으로 설정
        gender: _selectedGender!,
        region: _selectedRegion ?? '',
        loveStatus: _selectedLoveStatus,
        zodiacSign: zodiacSign,
      );

      // 친구 정보 저장
      final success = await FriendService.saveFriendInfo(friendInfo);
      
      if (success) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.successFriendInfoSaved(zodiacSign));
        Navigator.pop(context, true);
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.errorFriendInfoSaveFailed);
      }
    } else {
      // 내 정보 생성
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate!);
      final sajuInfo = SajuInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
        birthHour: 12, // 기본값으로 설정
        birthMinute: 0, // 기본값으로 설정
        gender: _selectedGender!,
        region: _selectedRegion ?? '',
        loveStatus: _selectedLoveStatus,
        zodiacSign: zodiacSign,
      );

      // 내 정보 저장
      final success = await SajuService.saveSajuInfo(sajuInfo);
      
      if (success) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.successBirthInfoSaved);
        // 홈 화면으로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // 모든 이전 화면 제거
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.errorBirthInfoSaveFailed);
      }
    }
  }

  void _showStatusBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    final statuses = [l10n.married, l10n.inRelationship, l10n.wantRelationship, l10n.noInterest];
    final statusKeys = ['married', 'inRelationship', 'wantRelationship', 'noInterest'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        return SafeArea(
          child: SizedBox(
            height: 280, 
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
                      Text(
                        l10n.loveStatus,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(l10n.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 15),
                Expanded(
                  child: ListView(
                    children: statuses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final status = entry.value;
                      final isSelected = _selectedLoveStatus == statusKeys[index];
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLoveStatus = statusKeys[index];
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? (Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.amber.withOpacity(0.1) 
                                  : Colors.blue.withOpacity(0.1))
                              : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected 
                                      ? (Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : Colors.black)
                                      : onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : Colors.black,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
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
