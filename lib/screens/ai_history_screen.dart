import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ai_correction.dart';
import '../services/firestore_service.dart';
import 'sentence_detail_screen.dart';

class AIHistoryScreen extends StatefulWidget {
  const AIHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AIHistoryScreen> createState() => _AIHistoryScreenState();
}

class _AIHistoryScreenState extends State<AIHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, List<AiCorrection>> _groupSentences(List<AiCorrection> corrections) {
    final Map<String, List<AiCorrection>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var s in corrections) {
      final date = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      String groupKey = '';
      if (date == today) {
        groupKey = 'Hari Ini';
      } else if (date == yesterday) {
        groupKey = 'Kemarin';
      } else {
        groupKey = DateFormat('dd MMM yyyy').format(s.createdAt);
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(s);
    }
    return grouped;
  }

  IconData _getGroupIcon(String key) {
    if (key == 'Hari Ini') return Icons.today;
    if (key == 'Kemarin') return Icons.event_note;
    return Icons.date_range;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF32445B)), // primary
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Koreksi AI',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            color: Color(0xFF32445B),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AiCorrection>>(
        stream: _firestoreService.getAiHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final corrections = snapshot.data ?? [];
          if (corrections.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat koreksi AI.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF757684),
                ),
              ),
            );
          }

          final grouped = _groupSentences(corrections);

          return ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final key = grouped.keys.elementAt(index);
              final items = grouped[key]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 24),
                    child: Row(
                      children: [
                        Icon(_getGroupIcon(key), color: const Color(0xFF006A62), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          key,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF32445B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...items.map((correction) => _buildHistoryCard(correction)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(AiCorrection correction) {
    final timeString = DateFormat('HH:mm').format(correction.createdAt);
    final category = (correction.category.isNotEmpty) 
        ? correction.category 
        : 'Koreksi';

    return GestureDetector(
      onTap: () async {
        final sentence = await _firestoreService.getSentenceById(correction.sentenceId);
        if (sentence != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SentenceDetailScreen(sentence: sentence),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kalimat tidak ditemukan atau sudah dihapus.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC5C5D4).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Color(0xFF454652)),
                          const SizedBox(width: 4),
                          Text(
                            timeString,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF454652),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9F390E).withValues(alpha: 0.1), // tertiary-container approx
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9F390E), // on-tertiary-container
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Asli
                  if (correction.originalJpText.isNotEmpty)
                    Text(
                      correction.originalJpText,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans JP',
                        fontSize: 18,
                        color: Color(0xFF191C1E),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.redAccent,
                        decorationThickness: 2,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Koreksi
                  Text(
                    'Seharusnya: \${correction.correctedJpText}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF454652), // on-surface-variant
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFF32445B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
