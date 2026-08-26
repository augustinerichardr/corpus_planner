import 'package:flutter/material.dart';
import '../../services/app_language_service.dart';

class MfEducationHubTabView extends StatelessWidget {
  const MfEducationHubTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = AppLanguageService();

    return AnimatedBuilder(
      animation: langService,
      builder: (context, _) {
        final t = langService.mutualFundsStrings;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card 1: What is a Mutual Fund & How Does It Work?
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xFF38BDF8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t['mfBasicsTitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t['mfBasicsBadge']!,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t['mfBasicsDesc']!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildBox(
                        t['unitsTitle']!,
                        t['unitsDesc']!,
                        const Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 10),
                      _buildBox(
                        t['navTitle']!,
                        t['navDesc']!,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 10),
                      _buildBox(
                        t['diversificationTitle']!,
                        t['diversificationDesc']!,
                        const Color(0xFFA78BFA),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_objects_outlined,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t['mfTrivia']!,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Growth vs. IDCW
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.alt_route_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t['growthVsIdcwTitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t['growthVsIdcwBadge']!,
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['growthTitle']!,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '• ${t['growthB1']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• ${t['growthB2']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• ${t['growthB3']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['idcwTitle']!,
                                style: const TextStyle(
                                  color: Color(0xFFF87171),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '• ${t['idcwB1']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• ${t['idcwB2']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• ${t['idcwB3']!}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.psychology_outlined,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t['buffettTrivia']!,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: 3-Step Direct SIP Roadmap
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        color: Color(0xFFA78BFA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t['roadmapTitle']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildRoadmapStep(
                        t['step1Num']!,
                        t['step1Tag']!,
                        t['step1Title']!,
                        t['step1Desc']!,
                        const Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 10),
                      _buildRoadmapStep(
                        t['step2Num']!,
                        t['step2Tag']!,
                        t['step2Title']!,
                        t['step2Desc']!,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 10),
                      _buildRoadmapStep(
                        t['step3Num']!,
                        t['step3Tag']!,
                        t['step3Title']!,
                        t['step3Desc']!,
                        const Color(0xFFA78BFA),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBox(String title, String desc, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapStep(
    String num,
    String tag,
    String title,
    String desc,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  num,
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: accent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
