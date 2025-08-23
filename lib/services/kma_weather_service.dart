import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class KmaWeatherInfo {
  final String locationName;
  final int temperatureCelsius; // TMP
  final int sky; // SKY (1 맑음, 3 구름많음, 4 흐림)
  final int pty; // PTY 강수형태 (0 없음, 1 비 ...)
  final int? pm10; // 미세먼지(μg/m³)
  final int? pm25; // 초미세먼지(μg/m³)

  const KmaWeatherInfo({
    required this.locationName,
    required this.temperatureCelsius,
    required this.sky,
    required this.pty,
    this.pm10,
    this.pm25,
  });
}

class KmaWeatherService {
  // 사용자가 제공한 인코딩된 서비스 키
  static const String _encodedServiceKey =
      'Bkmy%2FbKnFcXMPZ6sUH2b6zC48W%2B0%2Blbb4n7l6Sq%2BghOx3rogiJYwL4MH3MBpYwLyTofOZdldAvQpFH5yUU%2F8UA%3D%3D';

  static Future<({double lat, double lon, String city, String region})>
      _fetchApproxLocation() async {
    // IP 기반 위치 조회
    try {
      final uri = Uri.parse('https://ipapi.co/json');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final latitude = (json['latitude'] as num?)?.toDouble();
        final longitude = (json['longitude'] as num?)?.toDouble();
        final englishCity = (json['city'] as String?);
        final englishRegion = (json['region'] as String?);
        
        // 실제 위치 정보가 있는 경우에만 사용
        if (latitude != null && longitude != null) {
          // 시스템 언어 설정 확인
          final systemLocale = ui.window.locale.languageCode;
          
          // 영어 도시명을 한국어로 변환 (한국어 설정인 경우에만)
          final city = systemLocale == 'ko' && englishCity != null 
              ? _translateCityToKorean(englishCity) 
              : (englishCity ?? '현재 위치');
          final region = systemLocale == 'ko' && englishRegion != null 
              ? _translateRegionToKorean(englishRegion) 
              : (englishRegion ?? '');
          
          print('IP 기반 위치 조회 성공: $city, $region ($latitude, $longitude)');
          return (lat: latitude, lon: longitude, city: city, region: region);
        }
      }
    } catch (e) {
      print('IP 기반 위치 조회 실패: $e');
    }
    
    // IP 기반 조회가 실패한 경우 기본값 사용
    return (lat: 37.5665, lon: 126.9780, city: '서울특별시', region: '서울');
  }

  // 위경도 → 기상청 격자 (DFS)
  static ({int nx, int ny}) _toGridXY(double lat, double lon) {
    const double RE = 6371.00877; // 지구 반경(km)
    const double GRID = 5.0; // 격자 간격(km)
    const double SLAT1 = 30.0; // 투영 위도1(degree)
    const double SLAT2 = 60.0; // 투영 위도2(degree)
    const double OLON = 126.0; // 기준점 경도(degree)
    const double OLAT = 38.0; // 기준점 위도(degree)
    const double XO = 43.0; // 기준점 X좌표(GRID)
    const double YO = 136.0; // 기준점 Y좌표(GRID)

    const double DEGRAD = (math.pi / 180.0);
    double re = RE / GRID;
    double slat1 = SLAT1 * DEGRAD;
    double slat2 = SLAT2 * DEGRAD;
    double olon = OLON * DEGRAD;
    double olat = OLAT * DEGRAD;

    double sn = (math.log(math.cos(slat1) / math.cos(slat2)) /
        math.log(math.tan(math.pi * 0.25 + slat2 * 0.5) /
            math.tan(math.pi * 0.25 + slat1 * 0.5)));
    double sf = (math.pow(math.tan(math.pi * 0.25 + slat1 * 0.5), sn).toDouble() *
        math.cos(slat1)) /
        sn;
    double ro = re * sf /
        math.pow(math.tan(math.pi * 0.25 + olat * 0.5), sn).toDouble();

    double ra = re * sf /
        math.pow(math.tan(math.pi * 0.25 + lat * DEGRAD * 0.5), sn).toDouble();
    double theta = lon * DEGRAD - olon;
    if (theta > math.pi) theta -= 2.0 * math.pi;
    if (theta < -math.pi) theta += 2.0 * math.pi;
    theta *= sn;

    int x = (ra * math.sin(theta) + XO + 0.5).floor();
    int y = (ro - ra * math.cos(theta) + YO + 0.5).floor();
    return (nx: x, ny: y);
  }

  static Future<KmaWeatherInfo> fetchWeather() async {
    final loc = await _fetchApproxLocation();
    final grid = _toGridXY(loc.lat, loc.lon);

    final now = DateTime.now();
    final baseDate = _formatDate(_calcBaseDateTime(now).$1);
    final baseTime = _calcBaseDateTime(now).$2; // HHmm
    final fcstTime = _nearestFcstTime(now); // HHmm, 현재시각 반영

    final uri = Uri.parse(
        'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
        '?serviceKey=$_encodedServiceKey&pageNo=1&numOfRows=500&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime&nx=${grid.nx}&ny=${grid.ny}');

    int tmp = 0;
    int sky = 1;
    int pty = 0;

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final items = (((json['response']?['body']?['items']?['item']) ?? []) as List)
            .cast<dynamic>();

        for (final it in items) {
          final m = it as Map<String, dynamic>;
          if (m['fcstDate'] == baseDate && m['fcstTime'] == fcstTime) {
            final cat = m['category'] as String?;
            final val = m['fcstValue'];
            if (cat == 'TMP') tmp = int.tryParse('$val') ?? tmp;
            if (cat == 'SKY') sky = int.tryParse('$val') ?? sky;
            if (cat == 'PTY') pty = int.tryParse('$val') ?? pty;
          }
        }
      }
    } catch (_) {}

    // 공기질(미세/초미세) - Open‑Meteo Air Quality (보조 데이터)
    int? pm10;
    int? pm25;
    try {
      final airUrl = Uri.parse(
          'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${loc.lat}&longitude=${loc.lon}&hourly=pm10,pm2_5&timezone=auto');
      final airRes = await http.get(airUrl).timeout(const Duration(seconds: 8));
      if (airRes.statusCode == 200) {
        final map = jsonDecode(airRes.body) as Map<String, dynamic>;
        final hourly = (map['hourly'] as Map<String, dynamic>?);
        final pm10List = (hourly?['pm10'] as List?)?.cast<num>();
        final pm25List = (hourly?['pm2_5'] as List?)?.cast<num>();
        if (pm10List != null && pm10List.isNotEmpty) pm10 = pm10List.last.round();
        if (pm25List != null && pm25List.isNotEmpty) pm25 = pm25List.last.round();
      }
    } catch (_) {}

    final locationName = loc.region.isNotEmpty ? '${loc.region} ${loc.city}' : loc.city;
    return KmaWeatherInfo(
      locationName: locationName,
      temperatureCelsius: tmp,
      sky: sky,
      pty: pty,
      pm10: pm10,
      pm25: pm25,
    );
  }

  static (DateTime, String) _calcBaseDateTime(DateTime now) {
    // getVilageFcst base times
    const times = [0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300];
    int hhmm = now.hour * 100 + now.minute;
    int chosen = times.first;
    for (final t in times) {
      if (hhmm >= t) {
        chosen = t;
      } else {
        break;
      }
    }
    DateTime base = DateTime(now.year, now.month, now.day);
    if (hhmm < times.first) {
      // use previous day 2300
      base = base.subtract(const Duration(days: 1));
      chosen = 2300;
    }
    return (base, chosen.toString().padLeft(4, '0'));
  }

  static String _nearestFcstTime(DateTime now) {
    // forecast time is every hour HH00 for TMP/SKY/PTY
    return (now.hour * 100).toString().padLeft(4, '0');
  }

  static String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';
  }

  // 영어 도시명을 한국어로 변환
  static String _translateCityToKorean(String englishCity) {
    final cityMap = {
      'Seoul': '서울특별시',
      'Busan': '부산광역시',
      'Daegu': '대구광역시',
      'Incheon': '인천광역시',
      'Gwangju': '광주광역시',
      'Daejeon': '대전광역시',
      'Ulsan': '울산광역시',
      'Sejong': '세종특별자치시',
      'Gangwon': '강원도',
      'Chungbuk': '충청북도',
      'Chungnam': '충청남도',
      'Jeonbuk': '전라북도',
      'Jeonnam': '전라남도',
      'Gyeongbuk': '경상북도',
      'Gyeongnam': '경상남도',
      'Jeju': '제주특별자치도',
      'Busan-si': '부산광역시',
      'Daegu-si': '대구광역시',
      'Incheon-si': '인천광역시',
      'Gwangju-si': '광주광역시',
      'Daejeon-si': '대전광역시',
      'Ulsan-si': '울산광역시',
      'Sejong-si': '세종특별자치시',
      // 추가 도시명들
      'Suwon': '수원시',
      'Goyang': '고양시',
      'Seongnam': '성남시',
      'Bucheon': '부천시',
      'Ansan': '안산시',
      'Anyang': '안양시',
      'Pohang': '포항시',
      'Changwon': '창원시',
      'Jeonju': '전주시',
      'Cheongju': '청주시',
      'Chuncheon': '춘천시',
      'Gangneung': '강릉시',
      'Jeju City': '제주시',
      'Seogwipo': '서귀포시',
      // 더 많은 도시들
      'Dongducheon': '동두천시',
      'Guri': '구리시',
      'Namyangju': '남양주시',
      'Osan': '오산시',
      'Siheung': '시흥시',
      'Gunpo': '군포시',
      'Uijeongbu': '의정부시',
      'Yongin': '용인시',
      'Paju': '파주시',
      'Icheon': '이천시',
      'Anseong': '안성시',
      'Gimpo': '김포시',
      'Hwaseong': '화성시',
      'Gwangmyeong': '광명시',
      'Pyeongtaek': '평택시',
      'Yeoju': '여주시',
      'Yangpyeong': '양평군',
      'Gapyeong': '가평군',
      'Yangju': '양주시',
      'Donghae': '동해시',
      'Samcheok': '삼척시',
      'Wonju': '원주시',
      'Chungju': '충주시',
      'Jecheon': '제천시',
      'Boeun': '보은군',
      'Okcheon': '옥천군',
      'Yeongdong': '영동군',
      'Jincheon': '진천군',
      'Goesan': '괴산군',
      'Eumseong': '음성군',
      'Danyang': '단양군',
      'Jangseong': '장성군',
      'Gangjin': '강진군',
      'Haenam': '해남군',
      'Yeongam': '영암군',
      'Mokpo': '목포시',
      'Yeosu': '여수시',
      'Suncheon': '순천시',
      'Naju': '나주시',
      'Gwangju-si': '광주시',
      'Damyang': '담양군',
      'Gokseong': '곡성군',
      'Gurye': '구례군',
      'Goheung': '고흥군',
      'Boseong': '보성군',
      'Hwasun': '화순군',
      'Jangheung': '장흥군',
      'Jindo': '진도군',
      'Sinan': '신안군',
      'Gimje': '김제시',
      'Jeongeup': '정읍시',
      'Namwon': '남원시',
      'Gunsan': '군산시',
      'Iksan': '익산시',
      'Wanju': '완주군',
      'Jinan': '진안군',
      'Muju': '무주군',
      'Jangsu': '장수군',
      'Imsil': '임실군',
      'Sunchang': '순창군',
      'Gochang': '고창군',
      'Buan': '부안군',
      'Gimcheon': '김천시',
      'Gumi': '구미시',
      'Yeongju': '영주시',
      'Yeongcheon': '영천시',
      'Sangju': '상주시',
      'Mungyeong': '문경시',
      'Gyeongju': '경주시',
      'Gimhae': '김해시',
      'Miryang': '밀양시',
      'Sacheon': '사천시',
      'Jinju': '진주시',
      'Tongyeong': '통영시',
      'Geoje': '거제시',
      'Yangsan': '양산시',
      'Uiryeong': '의령군',
      'Haman': '함안군',
      'Changnyeong': '창녕군',
      'Goseong': '고성군',
      'Namhae': '남해군',
      'Hadong': '하동군',
      'Sancheong': '산청군',
      'Hamyang': '함양군',
      'Geochang': '거창군',
      'Hapcheon': '합천군',
    };
    
    return cityMap[englishCity] ?? englishCity;
  }

  // 영어 지역명을 한국어로 변환
  static String _translateRegionToKorean(String englishRegion) {
    final regionMap = {
      'Seoul': '서울',
      'Busan': '부산',
      'Daegu': '대구',
      'Incheon': '인천',
      'Gwangju': '광주',
      'Daejeon': '대전',
      'Ulsan': '울산',
      'Sejong': '세종',
      'Gangwon': '강원',
      'Chungbuk': '충북',
      'Chungnam': '충남',
      'Jeonbuk': '전북',
      'Jeonnam': '전남',
      'Gyeongbuk': '경북',
      'Gyeongnam': '경남',
      'Jeju': '제주',
    };
    
    return regionMap[englishRegion] ?? englishRegion;
  }

  // GPS 좌표로 대략적인 지역 추정
  static String _estimateLocationFromGPS(double lat, double lon) {
    // 한국 주요 도시들의 대략적인 좌표 범위
    if (lat >= 37.4 && lat <= 37.7 && lon >= 126.8 && lon <= 127.2) {
      return '서울특별시';
    } else if (lat >= 35.0 && lat <= 35.3 && lon >= 129.0 && lon <= 129.3) {
      return '부산광역시';
    } else if (lat >= 35.8 && lat <= 36.0 && lon >= 128.5 && lon <= 128.7) {
      return '대구광역시';
    } else if (lat >= 37.4 && lat <= 37.6 && lon >= 126.6 && lon <= 126.8) {
      return '인천광역시';
    } else if (lat >= 35.1 && lat <= 35.2 && lon >= 126.8 && lon <= 127.0) {
      return '광주광역시';
    } else if (lat >= 36.3 && lat <= 36.4 && lon >= 127.3 && lon <= 127.5) {
      return '대전광역시';
    } else if (lat >= 35.5 && lat <= 35.6 && lon >= 129.3 && lon <= 129.4) {
      return '울산광역시';
    } else if (lat >= 37.2 && lat <= 37.3 && lon >= 127.0 && lon <= 127.2) {
      return '수원시';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 126.8 && lon <= 127.0) {
      return '고양시';
    } else if (lat >= 37.4 && lat <= 37.5 && lon >= 127.1 && lon <= 127.3) {
      return '성남시';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 126.7 && lon <= 126.9) {
      return '부천시';
    } else if (lat >= 37.3 && lat <= 37.4 && lon >= 126.8 && lon <= 127.0) {
      return '안산시';
    } else if (lat >= 37.4 && lat <= 37.5 && lon >= 126.9 && lon <= 127.1) {
      return '안양시';
    } else if (lat >= 37.2 && lat <= 37.3 && lon >= 127.1 && lon <= 127.3) {
      return '용인시';
    } else if (lat >= 37.8 && lat <= 37.9 && lon >= 126.7 && lon <= 126.9) {
      return '파주시';
    } else if (lat >= 37.2 && lat <= 37.3 && lon >= 127.4 && lon <= 127.6) {
      return '이천시';
    } else if (lat >= 37.0 && lat <= 37.1 && lon >= 127.2 && lon <= 127.4) {
      return '안성시';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 126.6 && lon <= 126.8) {
      return '김포시';
    } else if (lat >= 37.2 && lat <= 37.3 && lon >= 126.9 && lon <= 127.1) {
      return '화성시';
    } else if (lat >= 37.0 && lat <= 37.1 && lon >= 126.9 && lon <= 127.1) {
      return '광명시';
    } else if (lat >= 36.9 && lat <= 37.0 && lon >= 127.0 && lon <= 127.2) {
      return '평택시';
    } else if (lat >= 37.3 && lat <= 37.4 && lon >= 127.6 && lon <= 127.8) {
      return '여주시';
    } else if (lat >= 37.4 && lat <= 37.5 && lon >= 127.5 && lon <= 127.7) {
      return '양평군';
    } else if (lat >= 37.8 && lat <= 37.9 && lon >= 127.5 && lon <= 127.7) {
      return '가평군';
    } else if (lat >= 37.8 && lat <= 37.9 && lon >= 127.0 && lon <= 127.2) {
      return '양주시';
    } else if (lat >= 37.9 && lat <= 38.0 && lon >= 127.0 && lon <= 127.2) {
      return '동두천시';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.1 && lon <= 127.3) {
      return '구리시';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.2 && lon <= 127.4) {
      return '남양주시';
    } else if (lat >= 37.1 && lat <= 37.2 && lon >= 127.0 && lon <= 127.2) {
      return '오산시';
    } else if (lat >= 37.3 && lat <= 37.4 && lon >= 126.7 && lon <= 126.9) {
      return '시흥시';
    } else if (lat >= 37.3 && lat <= 37.4 && lon >= 126.9 && lon <= 127.1) {
      return '군포시';
    } else if (lat >= 37.7 && lat <= 37.8 && lon >= 127.0 && lon <= 127.2) {
      return '의정부시';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 127.0 && lon <= 127.2) {
      return '하남시';
    } else if (lat >= 37.4 && lat <= 37.5 && lon >= 127.0 && lon <= 127.2) {
      return '과천시';
    } else if (lat >= 37.5 && lat <= 37.6 && lon <= 126.9) {
      return '강서구';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 126.9 && lon <= 127.1) {
      return '마포구';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 127.1 && lon <= 127.3) {
      return '서초구';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 127.3 && lon <= 127.5) {
      return '강남구';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 127.5 && lon <= 127.7) {
      return '송파구';
    } else if (lat >= 37.5 && lat <= 37.6 && lon >= 127.7 && lon <= 127.9) {
      return '강동구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.0 && lon <= 127.2) {
      return '노원구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.2 && lon <= 127.4) {
      return '도봉구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.4 && lon <= 127.6) {
      return '중랑구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.6 && lon <= 127.8) {
      return '광진구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 127.8 && lon <= 128.0) {
      return '성동구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 128.0 && lon <= 128.2) {
      return '동대문구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 128.2 && lon <= 128.4) {
      return '중구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 128.4 && lon <= 128.6) {
      return '용산구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 128.6 && lon <= 128.8) {
      return '영등포구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 128.8 && lon <= 129.0) {
      return '강북구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 129.0 && lon <= 129.2) {
      return '성북구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 129.2 && lon <= 129.4) {
      return '종로구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 129.4 && lon <= 129.6) {
      return '서대문구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 129.6 && lon <= 129.8) {
      return '은평구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 129.8 && lon <= 130.0) {
      return '양천구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 130.0 && lon <= 130.2) {
      return '구로구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 130.2 && lon <= 130.4) {
      return '금천구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 130.4 && lon <= 130.6) {
      return '동작구';
    } else if (lat >= 37.6 && lat <= 37.7 && lon >= 130.6 && lon <= 130.8) {
      return '관악구';
    } else {
      // 기본값: 서울
      return '서울특별시';
    }
  }
}


