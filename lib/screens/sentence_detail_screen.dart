import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sentence.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_utils.dart';

class SentenceDetailScreen extends StatefulWidget {
  final Sentence sentence;

  const SentenceDetailScreen({
    Key? key,
    required this.sentence,
  }) : super(key: key);

  @override
  State<SentenceDetailScreen> createState() => _SentenceDetailScreenState();
}

class _SentenceDetailScreenState extends State<SentenceDetailScreen> {
  final _firestoreService = FirestoreService();

  Future<void> _deleteSentence() async {
    final colors = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: colors.onErrorContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hapus Kalimat?',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apakah Anda yakin ingin menghapus kalimat ini? Kalimat akan dipindah ke Tempat Sampah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurface,
                            side: BorderSide(color: colors.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: colors.onError,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Hapus'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestoreService.softDeleteSentence(widget.sentence.id);
        if (mounted) {
          SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Kalimat dipindah ke Tempat Sampah');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Gagal menghapus: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sentence = widget.sentence;

    String primaryTag = sentence.tags.isNotEmpty ? sentence.tags.first : 'UMUM';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // bg-background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF006A62).withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF006A62)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Detail Kalimat',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006A62),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF006A62)),
                        onPressed: () {
                          // TODO: Edit functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF7C2500)), // text-tertiary
                        onPressed: _deleteSentence,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Japanese Text & Reading
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CEFE4).withOpacity(0.3), // bg-secondary-container/30
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF006A62), size: 16), // text-secondary
                          const SizedBox(width: 4),
                          Text(
                            primaryTag.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: Color(0xFF0A6F66), // text-on-secondary-container
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sentence.jpText,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans JP',
                        fontSize: 36, // 4xl
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.05 * 36,
                        color: Color(0xFF32445B), // text-primary
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: const Color(0xFF32445B).withOpacity(0.1), // border-primary/10
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sentence.reading,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              color: Color(0xFF454652), // text-on-surface-variant
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sentence.romaji,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              letterSpacing: 1.0,
                              color: Color(0xFF757684), // text-outline
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Translation Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white, // bg-surface-container-lowest
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: -32,
                        width: 4,
                        child: Container(color: const Color(0xFF006A62)), // bg-secondary
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TERJEMAHAN',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0, // tracking-[0.2em]
                              color: Color(0xFF006A62), // text-secondary
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${sentence.meaning}"',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Color(0xFF191C1E), // text-on-surface
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bento Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // SRS Level Card
                        SizedBox(
                          width: isWide ? (constraints.maxWidth / 2) - 8 : constraints.maxWidth,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7), // bg-surface-container-low
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SRS PROGRESS',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                        color: Color(0xFF757684), // text-outline
                                      ),
                                    ),
                                    const Icon(Icons.eco, color: Color(0xFF7C2500), size: 20), // text-tertiary
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${sentence.srsLevel}',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF32445B), // text-primary
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '/ 10',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Color(0xFF454652), // text-on-surface-variant
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC5C5D4).withOpacity(0.3), // bg-outline-variant/30
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: (sentence.srsLevel / 10).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF32445B), // bg-primary
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Learning Phase: Active',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF757684), // text-outline
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Notes Section
                        SizedBox(
                          width: isWide ? (constraints.maxWidth / 2) - 8 : constraints.maxWidth,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7), // bg-surface-container-low
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFC5C5D4).withOpacity(0.5), // border-outline-variant/50
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sticky_note_2, color: Color(0xFF757684), size: 24),
                                const SizedBox(height: 8),
                                const Text(
                                  'CATATAN',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    color: Color(0xFF757684), // text-outline
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sentence.notes.isEmpty ? 'Belum ada catatan untuk kalimat ini.' : sentence.notes,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF757684), // text-outline
                                  ),
                                ),
                                if (sentence.notes.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'TAMBAH CATATAN',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: Color(0xFF32445B), // text-primary
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Time Metadata
                        SizedBox(
                          width: constraints.maxWidth,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Wrap(
                              spacing: 48,
                              runSpacing: 24,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DIBUAT PADA',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                        color: Color(0xFF757684),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Color(0xFF454652)),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(sentence.createdAt),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF454652),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${DateFormat('h:mm a').format(sentence.createdAt)}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            color: Color(0xFF757684),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ULASAN BERIKUTNYA',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                        color: Color(0xFF757684),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.event_repeat, size: 14, color: Color(0xFF006A62)),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(sentence.nextReview),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006A62),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${DateFormat('h:mm a').format(sentence.nextReview)}',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            color: const Color(0xFF006A62).withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Visual Context Anchor (Placeholder)
                Container(
                  height: 192, // h-48
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDy5pVs2UGzExCVGXe_Sinruvpv5kD-dwhQyrAgYeATGvqZOrV3iKkATiXUzk3yhKni4LoiPX_GXlBqKBGbDttYULIjDFpx4A5E-YkKE3jDlPySYuVAcz1jIe3LUokE7DTCpGPzm8xOx9Ik-rAPRFtwUHxkm8t3rpL1Qoszy1H2osAmkh4-7xsnIN6K6w2xA99oSwJKDPuUPiIOfJ7gLCj2yhnUA2pXElLXMEf6LrqaG8Mk3GBvabeI10lDRwBuTMbeslv7k9hzx1tf'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF32445B).withOpacity(0.6), // primary/60
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 24, bottom: 16),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'VISUAL CONTEXT',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Urban Hanoi Life',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
