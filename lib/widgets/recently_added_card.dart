import 'package:flutter/material.dart';

class RecentlyAddedCard extends StatelessWidget {
  final String kanjiChar;
  final String word;
  final String furigana;
  final String meaning;
  final String category;
  final Color categoryColor;
  final Color categoryBgColor;
  final VoidCallback onTap;

  const RecentlyAddedCard({
    Key? key,
    required this.kanjiChar,
    required this.word,
    required this.furigana,
    required this.meaning,
    required this.category,
    required this.categoryColor,
    required this.categoryBgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Latar putih murni sesuai desain
        borderRadius: BorderRadius.circular(24), // Sudut lebih membulat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon / Kanji Char (Kotak Abu-Abu)
                Container(
                  width: 64, // Diperbesar proporsional
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Abu-abu muda persis di gambar
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kanjiChar,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 32, // Kanji membesar
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155), // Slate dark
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            word,
                            style: const TextStyle(
                              fontFamily: 'Noto Sans JP',
                              fontSize: 18, // Font tebal untuk nama kata
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($furigana)',
                            style: const TextStyle(
                              fontFamily: 'Noto Sans JP',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B), // Abu-abu keterangan
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Sedikit renggang ke bawah
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan secara vertikal
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryBgColor,
                              borderRadius: BorderRadius.circular(6), // Badge agak membulat
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2, // Spasi huruf ditenangkan
                                color: categoryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12), // Jarak ke arti kata dipanjangkan
                          Text(
                            meaning,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E1), // Icon chevron abu muda
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
