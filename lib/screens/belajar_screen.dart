import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';
import '../services/firestore_service.dart';
import 'srs_session_screen.dart';
import 'quiz_loading_screen.dart';
import '../models/sentence.dart';

class BelajarScreen extends StatelessWidget {
  const BelajarScreen({Key? key}) : super(key: key);

  void _startSRS(BuildContext context) async {
    final firestore = FirestoreService();
    SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Memuat flashcard...');
    final dueCards = await firestore.getDueCards(10); // Default limit 10
    
    if (!context.mounted) return;
    
    if (dueCards.isEmpty) {
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Hebat! Tidak ada kartu yang perlu direview hari ini.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SRSSessionScreen(dueCards: dueCards),
      ),
    );
  }

  void _startQuizAI(BuildContext context) async {
    final firestore = FirestoreService();
    SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Menyiapkan kuis AI...');
    
    // For quiz, get active sentences and vocabularies.
    final sentencesSnapshot = await firestore.getSentencesStream().first;
    final vocabulariesSnapshot = await firestore.getVocabulariesStream().first;
    if (!context.mounted) return;
    
    // Convert vocabularies to sentences for the quiz
    final vocabAsSentences = vocabulariesSnapshot.map((v) => Sentence(
      id: v.id,
      jpText: v.kanji.isNotEmpty ? v.kanji : v.reading,
      reading: v.reading,
      meaning: v.meaningId,
      romaji: v.romaji,
      srsLevel: v.srsLevel,
      nextReview: v.nextReview,
      createdAt: v.createdAt,
    )).toList();

    final allItems = [...sentencesSnapshot, ...vocabAsSentences];
    
    if (allItems.isEmpty) {
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Anda belum memiliki kosakata/kalimat untuk kuis.');
      return;
    }
    
    final list = List.of(allItems)..shuffle();
    final quizSentences = list.take(10).toList(); // Target harian 10 soal

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizLoadingScreen(sentences: quizSentences),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf7f9fc),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zen Scholar',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            color: Color(0xFF32445b),
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFe6e8eb),
              child: Icon(Icons.person, color: const Color(0xFF32445b).withOpacity(0.5)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle Background Deco
            const Center(
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  '学',
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 200,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFe0e3e6),
                  ),
                ),
              ),
            ),
            
            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih Mode Belajar',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32445b),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih jalanmu menuju kemahiran.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF454652),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _ModeCard(
                              title: 'Metode SRS',
                              icon: Icons.style,
                              iconColor: const Color(0xFF32445b),
                              onTap: () => _startSRS(context),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _ModeCard(
                              title: 'Kuis AI',
                              icon: Icons.smart_toy,
                              iconColor: const Color(0xFF006a62),
                              onTap: () => _startQuizAI(context),
                            ),
                          ),
                        ],
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

class _ModeCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF32445b) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFc5c5d4).withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 48,
                  color: _isHovered ? Colors.white : widget.iconColor,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isHovered ? Colors.white : const Color(0xFF191c1e),
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
