import 'package:flutter/material.dart';

class FeaturedWordCard extends StatelessWidget {
  final String kanji;
  final String furigana;
  final String meaning;
  final String partOfSpeech;

  const FeaturedWordCard({
    Key? key,
    required this.kanji,
    required this.furigana,
    required this.meaning,
    required this.partOfSpeech,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background large Kanji character
          Positioned(
            right: -24,
            bottom: -32,
            child: Opacity(
              opacity: 0.1,
              child: Text(
                kanji.substring(0, 1),
                style: TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimary,
                  height: 1.0,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOKUS HARI INI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0, // 0.2em roughly
                    color: colors.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      kanji,
                      style: TextStyle(
                        fontFamily: 'Noto Sans JP',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meaning,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: colors.onPrimary,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '$furigana | $partOfSpeech',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
