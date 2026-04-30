import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String kanji;
  final String furigana;
  final String meaning;
  final String category;
  final String? subCategory;
  final Color categoryColor;
  final Color categoryBgColor;

  const WordCard({
    Key? key,
    required this.kanji,
    required this.furigana,
    required this.meaning,
    required this.category,
    this.subCategory,
    required this.categoryColor,
    required this.categoryBgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Kanji Display Box
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kanji,
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: categoryColor,
                              ),
                            ),
                          ),
                          if (subCategory != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              subCategory!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meaning,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        furigana,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colors.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: colors.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
