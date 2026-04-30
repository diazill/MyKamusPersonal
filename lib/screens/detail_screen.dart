import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../models/sentence.dart';
import '../services/firestore_service.dart';

class DetailScreen extends StatelessWidget {
  final Vocabulary vocab;

  const DetailScreen({Key? key, required this.vocab}) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _calculateDaysInterval(DateTime nextReview) {
    final diff = nextReview.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final firestoreService = FirestoreService();

    // Determine category badge colors based on string (similar to Beranda logic)
    Color badgeColor = colors.primary;
    Color badgeBg = colors.primaryContainer;
    String displayCategory = vocab.category.toUpperCase();
    
    final catLower = vocab.category.toLowerCase();
    if (catLower.contains('kerja') || catLower.contains('verba')) {
      badgeColor = const Color(0xFF138973); // Dark teal
      badgeBg = const Color(0xFF90F4D0);    // Light mint
      displayCategory = 'KATA KERJA';
    } else if (catLower.contains('sifat')) {
      badgeColor = const Color(0xFFA14930); // Dark red/brown
      badgeBg = const Color(0xFFF7D6C8);    // Peach
      displayCategory = 'KATA SIFAT';
    } else if (catLower.contains('benda')) {
      badgeColor = const Color(0xFF4C658D); // Dark slate blue
      badgeBg = const Color(0xFFD3EEFC);    // Light blue
      displayCategory = 'KATA BENDA';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // From surface in HTML
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8), // Match topbar bg
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Kata',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: colors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO SECTION
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -24,
                  left: -16,
                  child: Text(
                    vocab.kanji.isNotEmpty ? vocab.kanji[0] : (vocab.reading.isNotEmpty ? vocab.reading[0] : ''), // Show first char as giant bg
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 140,
                      fontWeight: FontWeight.w800,
                      color: colors.primary.withOpacity(0.05),
                      height: 1.0,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocab.kanji.isNotEmpty ? vocab.reading : vocab.romaji,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans JP',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.0,
                        color: Color(0xFF006A62), // Text-secondary
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vocab.kanji.isNotEmpty ? vocab.kanji : vocab.reading,
                      style: TextStyle(
                        fontFamily: 'Noto Sans JP',
                        fontSize: 64, // Big text
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2.0,
                        color: colors.primary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),

            // MEANING CARD
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC5C5D4).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          displayCategory,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      if (vocab.subCategory.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E8EB), // surface-container-high
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vocab.subCategory.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFF454652),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vocab.meaningId,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vocab.catatan.isNotEmpty 
                        ? vocab.catatan 
                        : 'Tidak ada catatan tambahan untuk kosakata ini.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.6,
                      fontStyle: vocab.catatan.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      color: const Color(0xFF454652),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QUICK SRS PULSE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -48,
                    right: -48,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MASTERY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${vocab.srsLevel}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Ready in ${_formatDate(vocab.nextReview)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // SECTION: CONTOH KALIMAT
            _buildSectionHeader('Contoh Kalimat'),
            const SizedBox(height: 24),
            StreamBuilder<List<Sentence>>(
              stream: firestoreService.getSentencesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState('Belum ada contoh kalimat.');
                }

                // Filter sentences by vocabId
                final sentences = snapshot.data!.where((s) => s.vocabIds.contains(vocab.id)).toList();

                if (sentences.isEmpty) {
                  return _buildEmptyState('Belum ada contoh kalimat untuk kata ini.');
                }

                return Column(
                  children: sentences.map((sentence) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7), // surface-container-low
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: colors.primary.withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sentence.reading,
                          style: const TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                            color: Color(0xFF454652), // Text-on-surface-variant/60 equivalent
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sentence.jpText,
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"${sentence.meaning}"',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF191C1E),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 40),

            // SECTION: INFO SRS
            _buildSectionHeader('SRS Info'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSrsInfoCard(
                    icon: Icons.calendar_today,
                    iconColor: const Color(0xFF006A62),
                    iconBg: const Color(0xFF9CEFE4).withOpacity(0.3),
                    title: 'Review Berikutnya',
                    value: _formatDate(vocab.nextReview),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSrsInfoCard(
                    icon: Icons.timelapse,
                    iconColor: const Color(0xFF7C2500),
                    iconBg: const Color(0xFF9F390E).withOpacity(0.1),
                    title: 'Interval',
                    value: '${_calculateDaysInterval(vocab.nextReview)} Hari',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFC5C5D4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF94A3B8), // Slate 400
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFC5C5D4)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5C5D4).withOpacity(0.2)),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF757684), // outline
        ),
      ),
    );
  }

  Widget _buildSrsInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5C5D4).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Color(0xFF94A3B8), // slate-400
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF32445B), // primary
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
