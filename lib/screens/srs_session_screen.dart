import 'dart:math';
import 'package:flutter/material.dart';
import '../models/review_card.dart';
import '../services/firestore_service.dart';

class SRSSessionScreen extends StatefulWidget {
  final List<ReviewCard> dueCards;

  const SRSSessionScreen({Key? key, required this.dueCards}) : super(key: key);

  @override
  State<SRSSessionScreen> createState() => _SRSSessionScreenState();
}

class _SRSSessionScreenState extends State<SRSSessionScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  final FirestoreService _firestoreService = FirestoreService();
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showAnswer) return;
    setState(() {
      _showAnswer = true;
    });
    _animationController.forward();
  }

  void _gradeCard(int grade) async {
    // grade: 0 (Lupa), 1 (Sulit), 2 (Baik), 3 (Mudah)
    final card = widget.dueCards[_currentIndex];
    int currentSrs = card.srsLevel;
    
    int newSrs = currentSrs;
    int intervalDays = 1;
    
    // Simplistic SM-2 inspired calculation
    double easeFactor = 2.5; 
    
    if (grade == 0) { // Lupa
      newSrs = 0;
      intervalDays = 1;
    } else if (grade == 1) { // Sulit
      newSrs = currentSrs + 1;
      intervalDays = currentSrs == 0 ? 1 : 2;
    } else if (grade == 2) { // Baik
      newSrs = currentSrs + 1;
      if (currentSrs == 0) intervalDays = 1;
      else if (currentSrs == 1) intervalDays = 3;
      else intervalDays = (3 * easeFactor).round();
    } else if (grade == 3) { // Mudah
      newSrs = currentSrs + 2;
      if (currentSrs == 0) intervalDays = 4;
      else intervalDays = (4 * easeFactor).round();
    }

    if (intervalDays > 30) intervalDays = 30; // Max interval
    final nextReview = DateTime.now().add(Duration(days: intervalDays));
    
    await _firestoreService.updateCardSrs(card.id, card.type, newSrs, nextReview);

    if (mounted) {
      if (_currentIndex < widget.dueCards.length - 1) {
        // Prepare next card
        _animationController.reverse().then((_) {
          setState(() {
            _currentIndex++;
            _showAnswer = false;
          });
        });
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dueCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('SRS Session')),
        body: const Center(child: Text('Tidak ada kartu untuk direview.')),
      );
    }

    final currentCard = widget.dueCards[_currentIndex];
    final progress = (_currentIndex + 1) / widget.dueCards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF191c1e)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFe6e8eb),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF32445b),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_currentIndex + 1}/${widget.dueCards.length}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF454652),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF191c1e)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Card
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isFront = angle <= pi / 2;
                      
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 600, minHeight: 320),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isFront
                              ? _buildFrontCard(currentCard)
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _buildBackCard(currentCard),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Footer Actions
            if (_showAnswer)
              Positioned(
                bottom: 48,
                left: 24,
                right: 24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe0e3e6).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGradeButton(
                            icon: Icons.close,
                            label: 'Lupa',
                            color: const Color(0xFFba1a1a),
                            bgColor: const Color(0xFFffdad6),
                            onPressed: () => _gradeCard(0),
                          ),
                          _buildGradeButton(
                            icon: Icons.priority_high,
                            label: 'Sulit',
                            color: const Color(0xFF9f390e),
                            bgColor: const Color(0xFFffc6b3),
                            onPressed: () => _gradeCard(1),
                          ),
                          _buildGradeButton(
                            icon: Icons.check,
                            label: 'Baik',
                            color: Colors.white,
                            bgColor: const Color(0xFF006a62),
                            isPrimary: true,
                            onPressed: () => _gradeCard(2),
                          ),
                          _buildGradeButton(
                            icon: Icons.done_all,
                            label: 'Mudah',
                            color: const Color(0xFF081c32),
                            bgColor: const Color(0xFFc1d4f0),
                            onPressed: () => _gradeCard(3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!_showAnswer)
              Positioned(
                bottom: 48,
                left: 24,
                right: 24,
                child: Center(
                  child: Text(
                    'Ketuk kartu untuk melihat jawaban',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: const Color(0xFF454652).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(ReviewCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            card.tags.isNotEmpty ? card.tags.first.toUpperCase() : 'UMUM',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757684),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          card.frontText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF32445b),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildBackCard(ReviewCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            card.tags.isNotEmpty ? card.tags.first.toUpperCase() : 'UMUM',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757684),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          card.backText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF32445b),
            height: 1.5,
          ),
        ),
        if (card.reading.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            card.reading,
            style: const TextStyle(
              fontFamily: 'Noto Sans JP',
              fontSize: 20,
              color: Color(0xFF757684),
            ),
          ),
        ],
        if (card.romaji.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            card.romaji,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFF454652),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          card.meaning,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191c1e),
          ),
        ),
        if (card.notes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFf2f4f7),
              border: Border(
                left: BorderSide(color: Color(0xFF9cefe4), width: 4),
              ),
            ),
            child: Text(
              card.notes,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF454652),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGradeButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 56 : 48,
            height: isPrimary ? 56 : 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, color: color, size: isPrimary ? 28 : 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF454652),
            ),
          ),
        ],
      ),
    );
  }
}
