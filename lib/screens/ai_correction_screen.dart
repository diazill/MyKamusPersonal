import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/ai_correction.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_utils.dart';

class AICorrectionScreen extends StatefulWidget {
  final Sentence originalSentence;
  final String correctedJpText;
  final String correctedReading;
  final String correctedRomaji;
  final String correctedMeaning;
  final String explanation;
  final String category;

  const AICorrectionScreen({
    Key? key,
    required this.originalSentence,
    required this.correctedJpText,
    required this.correctedReading,
    required this.correctedRomaji,
    required this.correctedMeaning,
    required this.explanation,
    required this.category,
  }) : super(key: key);

  @override
  State<AICorrectionScreen> createState() => _AICorrectionScreenState();
}

class _AICorrectionScreenState extends State<AICorrectionScreen> {
  late TextEditingController _finalJpController;
  late TextEditingController _finalReadingController;
  late TextEditingController _finalRomajiController;
  late TextEditingController _finalMeaningController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _finalJpController = TextEditingController(text: widget.correctedJpText);
    _finalReadingController = TextEditingController(text: widget.correctedReading);
    _finalRomajiController = TextEditingController(text: widget.correctedRomaji);
    _finalMeaningController = TextEditingController(text: widget.correctedMeaning);
  }

  @override
  void dispose() {
    _finalJpController.dispose();
    _finalReadingController.dispose();
    _finalRomajiController.dispose();
    _finalMeaningController.dispose();
    super.dispose();
  }

  Future<void> _saveFinalSentence() async {
    setState(() => _isSaving = true);
    try {
      final hasCorrection = widget.originalSentence.jpText != _finalJpController.text;

      final sentence = Sentence(
        id: widget.originalSentence.id,
        jpText: _finalJpController.text,
        reading: _finalReadingController.text,
        romaji: _finalRomajiController.text,
        meaning: _finalMeaningController.text,
        notes: widget.originalSentence.notes,
        tags: widget.originalSentence.tags,
        vocabIds: widget.originalSentence.vocabIds,
        srsLevel: widget.originalSentence.srsLevel,
        nextReview: widget.originalSentence.nextReview,
        createdAt: widget.originalSentence.createdAt,
        originalJpText: hasCorrection ? widget.originalSentence.jpText : null,
        aiExplanation: hasCorrection ? widget.explanation : null,
        aiCategory: hasCorrection ? widget.category : null,
        hasAiCorrection: hasCorrection,
      );

      String currentSentenceId = sentence.id;
      if (currentSentenceId.isEmpty) {
        currentSentenceId = await _firestoreService.addSentence(sentence);
      } else {
        await _firestoreService.updateSentence(sentence);
      }

      // Add to AI correction history
      final aiCorrection = AiCorrection(
        id: '',
        sentenceId: currentSentenceId,
        originalJpText: widget.originalSentence.jpText,
        correctedJpText: _finalJpController.text,
        explanation: widget.explanation,
        category: widget.category,
        createdAt: DateTime.now(),
      );
      await _firestoreService.addAiCorrection(aiCorrection);

      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Kalimat berhasil disimpan dengan koreksi AI!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Custom colors from HTML design
    final primaryColor = const Color(0xFF32445b);
    final secondaryColor = const Color(0xFF006a62);
    final errorColor = const Color(0xFFba1a1a);
    final surfaceLow = const Color(0xFFf2f4f7);
    final surfaceLowest = const Color(0xFFffffff);

    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xFFf7f9fc),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: primaryColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Koreksi AI',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: primaryColor),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                Text(
                  'Hasil Koreksi AI',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9f390e).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Terdapat Saran Tata Bahasa',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9f390e),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A62).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Sudah Sempurna',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF006A62),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // Main Comparison Card
                // 1. Original Sentence
                Container(
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: errorColor.withValues(alpha: 0.2)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: errorColor.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                          ),
                          child: Text(
                            'KALIMAT ANDA',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: errorColor,
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
                              widget.originalSentence.jpText,
                              style: const TextStyle(
                                fontFamily: 'Noto Sans JP',
                                fontSize: 24,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.originalSentence.romaji,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFe0e3e6)),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.translate, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '"${widget.originalSentence.meaning}"',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF454652),
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
                ),
                const SizedBox(height: 24),

                // 2. Suggested Correction
                Container(
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                          ),
                          child: Text(
                            'SARAN PERBAIKAN',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _finalJpController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontFamily: 'Noto Sans JP',
                                fontSize: 24,
                                height: 1.5,
                                color: secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _finalRomajiController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFe0e3e6)),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.translate, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _finalMeaningController,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF454652),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Anda dapat mengubah teks di atas sebelum menyimpannya.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF454652),
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
                ),
                const SizedBox(height: 40),

                // Error Details Section
                Text(
                  'PENJELASAN DETAIL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.info, color: secondaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan AI',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.explanation,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 1.6,
                                color: Color(0xFF454652),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFe0e3e6).withValues(alpha: 0.8),
                border: const Border(top: BorderSide(color: Colors.white, width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveFinalSentence,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Menyimpan...' : 'Mengerti & Simpan',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tersimpan otomatis ke koleksi pustaka',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757684),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
