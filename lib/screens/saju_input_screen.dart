import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '../models/saju_info.dart';
import '../models/friend_info.dart';
import '../services/saju_service.dart';
import '../services/friend_service.dart';
import '../services/favorite_service.dart';
import '../services/analytics_service.dart';
import '../utils/zodiac_utils.dart';
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
  // String? _selectedRegion; // unused
  String? _selectedLoveStatus;
  String? _selectedCountry;
  String? _selectedEra;
  String? _selectedAgeGroup;
  
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
    
    // Character's Tone 옵션 (로컬라이징 getter 사용)
    final statuses = [
      l10n.toneWarm,
      l10n.toneCalm,
      l10n.toneLovely,
      l10n.toneUrban,
      l10n.tonePositive,
      l10n.toneFunny,
      l10n.toneEmotional,
      l10n.toneHopeful,
      l10n.tonePassionate,
      l10n.toneFutureOriented,
    ];
    // 저장 키 (영문)
    final statusKeys = ['warm','calm','lovely','urban','positive','funny','emotional','hopeful','passionate','futureOriented'];

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
              Text('${l10n.name} ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary, fontFamily: 'NotoSansKR')),
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
              Text('${l10n.gender} ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
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
          // Character Age (Decade groups)
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${l10n.birthDate} ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 3),
          InkWell(
            onTap: _showAgeBottomSheet,
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
                      _selectedAgeGroup ?? _ageHintText(context),
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedAgeGroup != null ? primary : secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: secondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 캐릭터 배경 (Character's Era)
          /*
          Row(
            children: [
              const SizedBox(width: 4),
              Text(
                l10n.characterEra,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
              ),
            ],
          ),
          const SizedBox(height: 3),
          InkWell(
            onTap: _showEraBottomSheet,
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
                      _selectedEra ?? l10n.eraHint,
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedEra != null ? primary : secondary,
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
        */

          // 태어난 지역
          Row(
            children: [
              const SizedBox(width: 4),
              Text(l10n.birthRegion, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
            ],
          ),
          const SizedBox(height: 3),
          // 국가 선택 - 바텀시트
          InkWell(
            onTap: _showCountryBottomSheet,
            child: Container(
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
                      _selectedCountry ?? _countryHintText(context),
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedCountry != null ? primary : secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: secondary, size: 24),
                ],
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
                      () {
                        final idx = statusKeys.indexOf(_selectedLoveStatus ?? '');
                        return idx >= 0 ? statuses[idx] : l10n.statusSelectHint;
                      }(),
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


  List<String> _countryOptions(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final cc = (locale.countryCode ?? '').toUpperCase();

    // Build language-specific names
    List<String> namesKO = [
      '대한민국','미국','일본','중국','영국','캐나다','독일','프랑스','인도','호주','스페인','이탈리아','러시아','브라질','멕시코','터키','인도네시아','필리핀','베트남','태국','싱가포르','말레이시아','대만','홍콩','아랍에미리트','사우디아라비아','이집트','남아프리카공화국','아르헨티나','칠레','네덜란드','스웨덴','노르웨이','덴마크','핀란드','폴란드','포르투갈','이스라엘','스위스','두바이','뉴질랜드','파키스탄','방글라데시'
    ];
    List<String> namesJA = [
      '韓国','アメリカ','日本','中国','イギリス','カナダ','ドイツ','フランス','インド','オーストラリア','スペイン','イタリア','ロシア','ブラジル','メキシコ','トルコ','インドネシア','フィリピン','ベトナム','タイ','シンガポール','マレーシア','台湾','香港','アラブ首長国連邦','サウジアラビア','エジプト','南アフリカ','アルゼンチン','チリ','オランダ','スウェーデン','ノルウェー','デンマーク','フィンランド','ポーランド','ポルトガル','イスラエル','スイス','ドバイ','ニュージーランド','パキスタン','バングラデシュ'
    ];
    List<String> namesZH = [
      '韩国','美国','日本','中国','英国','加拿大','德国','法国','印度','澳大利亚','西班牙','意大利','俄罗斯','巴西','墨西哥','土耳其','印度尼西亚','菲律宾','越南','泰国','新加坡','马来西亚','台湾','香港','阿联酋','沙特阿拉伯','埃及','南非','阿根廷','智利','荷兰','瑞典','挪威','丹麦','芬兰','波兰','葡萄牙','以色列','瑞士','迪拜','新西兰','巴基斯坦','孟加拉国'
    ];
    List<String> namesEN = [
      'South Korea','United States','Japan','China','United Kingdom','Canada','Germany','France','India','Australia','Spain','Italy','Russia','Brazil','Mexico','Turkey','Indonesia','Philippines','Vietnam','Thailand','Singapore','Malaysia','Taiwan','Hong Kong','United Arab Emirates','Saudi Arabia','Egypt','South Africa','Argentina','Chile','Netherlands','Sweden','Norway','Denmark','Finland','Poland','Portugal','Israel','Switzerland','Dubai (UAE)','New Zealand','Pakistan','Bangladesh'
    ];

    // Determine my country name per language
    String? my;
    if (cc == 'US' || cc == 'KR' || cc == 'JP' || cc == 'CN') {
      switch (lang) {
        case 'ko':
          if (cc == 'US') my = '미국';
          if (cc == 'KR') my = '대한민국';
          if (cc == 'JP') my = '일본';
          if (cc == 'CN') my = '중국';
          break;
        case 'ja':
          if (cc == 'US') my = 'アメリカ';
          if (cc == 'KR') my = '韓国';
          if (cc == 'JP') my = '日本';
          if (cc == 'CN') my = '中国';
          break;
        case 'zh':
          if (cc == 'US') my = '美国';
          if (cc == 'KR') my = '韩国';
          if (cc == 'JP') my = '日本';
          if (cc == 'CN') my = '中国';
          break;
        default:
          if (cc == 'US') my = 'United States';
          if (cc == 'KR') my = 'South Korea';
          if (cc == 'JP') my = 'Japan';
          if (cc == 'CN') my = 'China';
      }
    }

    List<String> base;
    String otherLabel;
    switch (lang) {
      case 'ko':
        base = List.of(namesKO);
        otherLabel = '기타';
        break;
      case 'ja':
        base = List.of(namesJA);
        otherLabel = 'その他';
        break;
      case 'zh':
        base = List.of(namesZH);
        otherLabel = '其他';
        break;
      default:
        base = List.of(namesEN);
        otherLabel = 'Other';
    }

    // Remove duplicates and special labels from sorting
    base.removeWhere((e) => e == otherLabel);
    base = base.toSet().toList();
    base.sort((a, b) => a.compareTo(b));

    if (my != null) {
      base.remove(my);
      return [my, ...base, otherLabel];
    }
    return [...base, otherLabel];
  }

  String _countryHintText(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'ko':
        return '국가 선택 (선택)';
      case 'ja':
        return '国を選択（任意）';
      case 'zh':
        return '选择国家（可选）';
      default:
        return 'Choose a world (optional)';
    }
  }

  void _showCountryBottomSheet() {
    final all = _countryOptions(context);
    final controller = TextEditingController();
    List<String> options = List.of(all);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        return SafeArea(
          child: StatefulBuilder(
            builder: (modalCtx, setModalState) {
              return SizedBox(
                height: 420,
                child: Column(
                  children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 16)),
                      ),
                      Text(
                        AppLocalizations.of(context)!.birthRegion,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: controller,
                    onChanged: (q) {
                      final query = q.trim().toLowerCase();
                      setModalState(() {
                        options = all.where((c) => c.toLowerCase().contains(query)).toList();
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: _countryHintText(context),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const Divider(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final c = options[i];
                      final isSelected = _selectedCountry == c;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedCountry = c);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: isSelected 
                            ? (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.amber.withOpacity(0.1) 
                                : Colors.blue.withOpacity(0.08))
                            : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected 
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                      : onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
            },
          ),
        );
      },
    );
  }

  String _ageHintText(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ko':
        return '연령대를 선택하세요 (선택)';
      case 'ja':
        return '年代を選択（任意）';
      case 'zh':
        return '选择年龄段（可选）';
      default:
        return 'Choose an age group (optional)';
    }
  }

  void _showAgeBottomSheet() {
    List<String> options;
    switch (Localizations.localeOf(context).languageCode) {
      case 'ko':
        options = ['10대', '20대', '30대', '40대', '50대 이상', '선택 안함'];
        break;
      case 'ja':
        options = ['10代', '20代', '30代', '40代', '50代以上', '選択しない'];
        break;
      case 'zh':
        options = ['10代', '20代', '30代', '40代', '50岁以上', '不选择'];
        break;
      default:
        options = ['Teens (13–19)', '20s', '30s', '40s', '50+', 'Prefer not to say'];
    }

    showModalBottomSheet(
      context: context,
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
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                      const Text('Character Age', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                    ],
                  ),
                ),
                const Divider(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final e = options[i];
                      final isSelected = _selectedAgeGroup == e;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedAgeGroup = e);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: isSelected 
                            ? (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.amber.withOpacity(0.1) 
                                : Colors.blue.withOpacity(0.08))
                            : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected 
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                      : onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showEraBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    // 로컬라이징된 Era 옵션
    List<String> options;
    switch (Localizations.localeOf(context).languageCode) {
      case 'ko':
        options = [
          AppLocalizations.of(context)!.eraAncientTimes,
          AppLocalizations.of(context)!.eraMedievalAge,
          AppLocalizations.of(context)!.eraVictorianEra,
          AppLocalizations.of(context)!.eraModernDay,
          AppLocalizations.of(context)!.eraNearFuture,
          AppLocalizations.of(context)!.eraDistantFuture,
          AppLocalizations.of(context)!.eraMythicalAge,
          AppLocalizations.of(context)!.eraTimelessRealm,
        ];
        break;
      case 'ja':
        options = [
          AppLocalizations.of(context)!.eraAncientTimes,
          AppLocalizations.of(context)!.eraMedievalAge,
          AppLocalizations.of(context)!.eraVictorianEra,
          AppLocalizations.of(context)!.eraModernDay,
          AppLocalizations.of(context)!.eraNearFuture,
          AppLocalizations.of(context)!.eraDistantFuture,
          AppLocalizations.of(context)!.eraMythicalAge,
          AppLocalizations.of(context)!.eraTimelessRealm,
        ];
        break;
      case 'zh':
        options = [
          AppLocalizations.of(context)!.eraAncientTimes,
          AppLocalizations.of(context)!.eraMedievalAge,
          AppLocalizations.of(context)!.eraVictorianEra,
          AppLocalizations.of(context)!.eraModernDay,
          AppLocalizations.of(context)!.eraNearFuture,
          AppLocalizations.of(context)!.eraDistantFuture,
          AppLocalizations.of(context)!.eraMythicalAge,
          AppLocalizations.of(context)!.eraTimelessRealm,
        ];
        break;
      default:
        options = [
          AppLocalizations.of(context)!.eraAncientTimes,
          AppLocalizations.of(context)!.eraMedievalAge,
          AppLocalizations.of(context)!.eraVictorianEra,
          AppLocalizations.of(context)!.eraModernDay,
          AppLocalizations.of(context)!.eraNearFuture,
          AppLocalizations.of(context)!.eraDistantFuture,
          AppLocalizations.of(context)!.eraMythicalAge,
          AppLocalizations.of(context)!.eraTimelessRealm,
        ];
    }

    showModalBottomSheet(
      context: context,
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
                      Text(
                        l10n.characterEra,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
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
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final e = options[i];
                      final isSelected = _selectedEra == e;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedEra = e);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: isSelected 
                            ? (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.amber.withOpacity(0.1) 
                                : Colors.blue.withOpacity(0.08))
                            : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected 
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                      : onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  // unused
  String _formatDateForDisplay(DateTime date) => '${date.year}.${date.month}.${date.day}';


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
          _selectedLoveStatus = sajuInfo.loveStatus; // 영어 키값으로 저장
          // New: map saved preferences back into pickers
          _selectedCountry = sajuInfo.world;
          _selectedEra = sajuInfo.era;
          _selectedAgeGroup = sajuInfo.ageGroup;
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
                      Text(
              widget.isFriendInfo ? l10n.friendInfoInput : l10n.birthInfoInput,
            style: TextStyle(
              fontSize: Localizations.localeOf(context).languageCode == 'en' ? 24 : 25, // 영어일 때 -1 작게
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -1 : 0, // 영어일 때 글자 간격 -1
            ),
          ),
          const Spacer(),
          FutureBuilder<bool>(
            future: SajuService.hasSajuInfo(),
            builder: (context, snapshot) {
              final hasInfo = snapshot.data == true;
              if (hasInfo) return const SizedBox.shrink();
              return ElevatedButton(
                onPressed: () async {
                  await SajuService.enableExperienceMode();
                  if (!mounted) return;
                  final l10n2 = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n2.experienceEntering)),
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(0, 40),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_outlined, size: 15),
                    const SizedBox(width: 2),
                    Text(
                      AppLocalizations.of(context)!.experienceTry,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
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

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 하나라도 입력되면 활성화
    final bool isFormValid = !_isPendingCharacterEmpty();

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

  // unused
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
    // 모든 저장 필드가 비어 있으면 안내 메시지 후 종료
    if (_isPendingCharacterEmpty()) {
      await _showEmptyCharacterDialog();
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
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate ?? DateTime.now());
      final friendInfo = FriendInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate ?? DateTime.now(),
        birthHour: 12,
        birthMinute: 0,
        gender: _selectedGender ?? 'female',
        region: '',
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
      // 저장 이전에 기존 출생 정보 존재 여부 확인 (최초 저장 여부 판단)
      final bool hadSajuInfoBeforeSave = await SajuService.hasSajuInfo();

      // 내 정보 생성
      final zodiacSign = ZodiacUtils.getZodiacSign(_selectedDate ?? DateTime.now());
      final sajuInfo = SajuInfo(
        name: _nameController.text.trim(),
        birthDate: _selectedDate ?? DateTime.now(),
        birthHour: 12,
        birthMinute: 0,
        gender: _selectedGender ?? 'female',
        region: '',
        loveStatus: _selectedLoveStatus,
        zodiacSign: zodiacSign,
        // New persisted preferences
        world: _selectedCountry,
        ageGroup: _selectedAgeGroup,
      );

      // 내 정보 저장
      final success = await SajuService.saveSajuInfo(sajuInfo);
      
      if (success) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.successBirthInfoSaved);
        // 최초 저장인 경우(이전 캐릭터 정보가 없던 사용자): 기존 즐겨찾기 전부 삭제
        if (!hadSajuInfoBeforeSave) {
          try {
            final guestId = await SajuService.getGuestId();
            await FavoriteService().deleteAllFavorites(guestId);
          } catch (_) {}
        }
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

  bool _isPendingCharacterEmpty() {
    bool empty(String? s) => s == null || s.trim().isEmpty;
    return empty(_nameController.text)
        && empty(_selectedGender)
        && empty(_selectedCountry)
        && empty(_selectedEra)
        && empty(_selectedAgeGroup)
        && empty(_selectedLoveStatus);
  }

  Future<void> _showEmptyCharacterDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.characterValidationTitle;
    final content = l10n.characterValidationBody;
    final ok = l10n.confirmButton;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(ok)),
        ],
      ),
    );
  }

  void _showStatusBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    // Character's Tone - localized labels and english keys
    final statuses = [
      l10n.toneWarm,
      l10n.toneCalm,
      l10n.toneLovely,
      l10n.toneUrban,
      l10n.tonePositive,
      l10n.toneFunny,
      l10n.toneEmotional,
      l10n.toneHopeful,
      l10n.tonePassionate,
      l10n.toneFutureOriented,
    ];
    final statusKeys = ['warm','calm','lovely','urban','positive','funny','emotional','hopeful','passionate','futureOriented'];

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
