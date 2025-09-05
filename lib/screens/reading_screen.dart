import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../services/poetry_api_service.dart';
import '../services/saju_service.dart';
import '../models/saju_info.dart';

class PoetryScreen extends StatefulWidget {
  const PoetryScreen({super.key});

  @override
  State<PoetryScreen> createState() => _PoetryScreenState();
}

class _PoetryScreenState extends State<PoetryScreen> {
  bool _loading = false;
  String? _error;
  String? _poem;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final SajuInfo? sajuInfo = await SajuService.loadSajuInfo();
      if (sajuInfo == null) {
        setState(() { _error = 'no_saju'; _loading = false; });
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      final res = await PoetryApiService.fetchPoetry(sajuInfo: sajuInfo, language: lang);
      setState(() { _poem = res.content; _loading = false; });
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poetry UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: Color(0xFFB3B3FF),
                    size: 40,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)?.poetryTitle ?? '오늘의 시 낭독',
                    style: GoogleFonts.notoSans(
                      fontSize: 22,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    AppLocalizations.of(context)?.poetrySubtitle ?? '매일 당신에게 시 한 편을 지어드려요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.3 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 0),
            
            // Poetry 내용만 표시
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final onText = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error == 'no_saju') {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.infoMessage ?? '출생 정보를 먼저 저장해주세요.',
          style: GoogleFonts.notoSans(fontSize: 16, color: onText),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error', style: GoogleFonts.notoSans(fontSize: 18, color: onText, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.notoSans(fontSize: 14, color: onText.withOpacity(0.8))),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_poem == null) {
      return const SizedBox();
    }
    return SingleChildScrollView(
      child: Text(
        _poem!,
        style: GoogleFonts.notoSans(
          fontSize: 18,
          color: onText,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
