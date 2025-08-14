import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/kma_weather_service.dart';

class KmaWeatherChip extends StatefulWidget {
  const KmaWeatherChip({super.key});

  @override
  State<KmaWeatherChip> createState() => _KmaWeatherChipState();
}

class _KmaWeatherChipState extends State<KmaWeatherChip> {
  KmaWeatherInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await KmaWeatherService.fetchWeather();
      if (mounted) {
        setState(() {
          _info = info;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 80,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
        ),
      );
    }

    if (_info == null) {
      return Text('날씨 정보 없음', style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12));
    }

    final skyText = _info!.pty != 0
        ? '강수'
        : (_info!.sky == 1
            ? '맑음'
            : (_info!.sky == 3 ? '구름많음' : '흐림'));

    return InkWell(
      onTap: () {
        if (_info != null) {
          _showDetailSheet(context, _info!);
        }
      },
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _info!.locationName,
          style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12),
        ),
        _divider(),
        Text('미세 먼지 • $skyText', style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
        _divider(),
        Text('${_info!.temperatureCelsius}°C', style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 6),
        Icon(
          _info!.pty != 0 ? Icons.umbrella : Icons.wb_sunny_outlined,
          size: 16,
          color: Colors.white,
        )
      ],
    ));
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(width: 1, height: 12, color: Colors.white24),
      );
}

void _showDetailSheet(BuildContext context, KmaWeatherInfo info) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final skyText = info.pty != 0
              ? '흐리고 비'
              : (info.sky == 1
                  ? '맑음'
                  : (info.sky == 3 ? '구름많음' : '흐림'));
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C1810).withOpacity(0.98),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text('오늘의 날씨',
                          style: GoogleFonts.notoSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(info.locationName,
                        style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Icon(
                    info.pty != 0 ? Icons.cloudy_snowing : Icons.wb_cloudy_outlined,
                    color: Colors.white,
                    size: 96,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${info.temperatureCelsius}°C',
                        style: GoogleFonts.notoSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(width: 10),
                    Text(skyText,
                        style: GoogleFonts.notoSans(
                            fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 24),
                _aqRow('미세 먼지', info.pm10),
                const SizedBox(height: 8),
                _aqRow('초미세 먼지', info.pm25),
                const SizedBox(height: 24),
                Center(
                  child: Text('관측된 자료는 현지 사정이나 수신 상태에 의해 차이가 발생할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(color: Colors.white60, fontSize: 12)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text('기상청, 한국환경공단 제공',
                        style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _aqRow(String label, int? value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label, style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 14)),
      const SizedBox(width: 8),
      Text(value != null ? '좋음 $value' : '정보 없음',
          style: GoogleFonts.notoSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
    ],
  );
}


