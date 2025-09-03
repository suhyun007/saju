import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class DetailStoryScreen extends StatelessWidget {
  const DetailStoryScreen({super.key});

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
                    Icons.auto_stories,
                    color: Color(0xFFB3B3FF),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.episodeTitle ?? '오늘의 에피소드',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)?.episodeSubtitle ?? '매일 새로운 당신의 이야기를 만나보세요.',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A).withOpacity(0.9),
                      letterSpacing: Localizations.localeOf(context).languageCode == 'en' ? -0.2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 이야기 내용 - 전체 화면에서 패딩 20 안에 들어가도록
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
                        '《별이 내리는 밤》',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '오전 열 시, 수현은 커튼 사이로 스며든 햇살을 손등으로 받았다. 쌍둥이자리의 호기심이 살짝 간지럽혀, 갑자기 낯선 골목 카페가 떠올랐다.가볼까? 스스로에게 묻는 말이 이미 답이었다.\n'
                        '카페 문을 여니, 종이 종이 울렸다. 바리스타가 웃으며 말한다. "오늘의 추천은 라임 허니 라떼예요." 달큰한 향이 코끝에 닿자, 마음이 금세 가벼워졌다. 수현은 창가 자리에 앉아 노트를 펼쳤다. 오늘은 머릿속 별들이 유난히 수다스러웠다.\n'
                        '첫 페이지에 적었다. "오늘의 키워드: 전환, 균형, 대화." 문장을 마침표로 닫는 순간, 휴대폰이 진동했다. 오래 연락 없던 동창에게서 근처인데, 커피 한 잔? 메시지. 우연은 언제나 쌍둥이의 편이었다.\n'
                        '둘은 쉬지 않고 이야기했다. 대수롭지 않은 농담이 빵빵 터졌고, 다섯 번째 웃음 뒤에선 진짜 이야기가 고개를 내밀었다. "요즘, 뭘 더 하고 싶어?" 묻는 질문에 수현은 잠깐 멈췄다. 대답은 생각보다 단순했다. "가벼운 용기."\n'
                        '점심 무렵, 머릿속에서 스파크가 튀었다. 미뤄둔 아이디어의 마지막 퍼즐이 맞춰진 느낌. 균형 잡힌 문장, 필요한 사람, 정확한 타이밍—세 가지가 동시에 자리 잡았다. 메시지 하나를 보냈을 뿐인데, 답장은 의외로 빨랐다. 좋아요. 오늘 오후, 간단히 미팅할까요?\n'
                        '해질녘, 작은 회의실의 공기는 맑았다. 수현은 말수를 줄이고 핵심만 꿰뚫었다. 질문은 가볍고, 결론은 단단했다. 그녀의 말 끝에서 상대의 미소가 번졌다. 이 톤, 좋습니다. 다음 단계로 갈게요.\n'
                        '집으로 돌아오는 길, 바람이 앞머리를 스쳤다. 신호등이 초록으로 바뀌자, 발걸음도 리듬을 탔다. 오늘의 만남, 오늘의 문장, 오늘의 결정—모두가 그린 선이 하나의 별자리처럼 연결되었다. 그 중심에는 \'대화\'가 있었다.\n'
                        '현관 앞에서 수현은 하늘을 올려다봤다. 별 한 점이 딱, 깜빡였다. 그녀는 조용히 주문처럼 중얼거렸다. "내가 움직이면, 세상도 한 칸 움직인다." 그리고 노트에 마지막 줄을 더했다.',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '내일의 에피소드 : 오늘의 용기를 복사해서 붙여넣기.',
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
