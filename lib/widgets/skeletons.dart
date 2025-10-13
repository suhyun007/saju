import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EpisodeSkeleton extends StatelessWidget {
  const EpisodeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);
    final hi = isDark ? const Color(0x44FFFFFF) : const Color(0x33000000);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20, width: 180, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          ...List.generate(6, (i) => Container(
                height: 14,
                margin: EdgeInsets.only(bottom: i == 2 ? 16 : 10),
                width: i.isEven ? double.infinity : MediaQuery.of(context).size.width * 0.7,
                color: Colors.white,
              )),
          Container(height: 14, width: 160, margin: const EdgeInsets.only(top: 8), color: Colors.white),
        ],
      ),
    );
  }
}

class PoetrySkeleton extends StatelessWidget {
  const PoetrySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);
    final hi = isDark ? const Color(0x44FFFFFF) : const Color(0x33000000);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20, width: 200, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          ...List.generate(10, (i) => Container(
                height: 14,
                margin: const EdgeInsets.only(bottom: 10),
                width: (i % 3 == 0) ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
                color: Colors.white,
              )),
          Container(height: 14, width: 180, margin: const EdgeInsets.only(top: 8), color: Colors.white),
        ],
      ),
    );
  }
}



