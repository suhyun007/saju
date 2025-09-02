import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: Color(0xFFB3B3FF),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘의 시 낭독',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '매일 당신에게 시 한 편을 지어드려요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 시 내용
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '《오늘, 바람에게 묻다》',
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '아침의 창문은\n호기심으로 반짝였다\n\n바람이 장난처럼\n머리칼을 흔들자\n내 마음도 웃었다\n\n낯선 골목에서\n새로운 대화가 피어났고\n작은 우연이\n오늘의 별자리를 연결했다\n\n머릿속 번개 같은 깨달음\n손끝에서 빛이 흘러\n내일로 가는 길을 비춘다\n\n밤하늘에 한 점 별이\n눈을 깜빡이며 말한다\n"오늘의 용기를 잊지 말 것\n그것이 내일을 부른다"',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '오늘은 호기심과 대화, 작은 결심이 행운을 불러오는 날이에요.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.8) : const Color(0xFF1A1A1A).withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
