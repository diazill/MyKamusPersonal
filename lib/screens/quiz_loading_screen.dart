import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../services/ai_service.dart';
import 'ai_quiz_screen.dart';
import '../utils/snackbar_utils.dart';

class QuizLoadingScreen extends StatefulWidget {
  final List<Sentence> sentences;

  const QuizLoadingScreen({Key? key, required this.sentences}) : super(key: key);

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final AIService _aiService = AIService();
  
  String _statusText = 'Menyelaraskan kurikulum...';
  double _progress = 0.35;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _generateQuiz();
    _simulateProgress();
  }
  
  void _simulateProgress() async {
    final statuses = [
      "Menyelaraskan kurikulum...",
      "Memilih kosakata yang relevan...",
      "Menyusun pola tata bahasa...",
      "Memfinalisasi kuis..."
    ];
    
    int statusIndex = 0;
    while (_progress < 0.9 && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) break;
      
      setState(() {
        _progress += (0.05 + (0.05 * (DateTime.now().millisecond % 5) / 10)); // Random progress
        
        if (_progress > 0.5 && statusIndex == 0) statusIndex = 1;
        if (_progress > 0.75 && statusIndex == 1) statusIndex = 2;
        if (_progress > 0.9 && statusIndex == 2) statusIndex = 3;
        
        _statusText = statuses[statusIndex];
      });
    }
  }

  Future<void> _generateQuiz() async {
    try {
      final quizQuestions = await _aiService.generateQuiz(widget.sentences);
      if (!mounted) return;
      
      setState(() {
        _progress = 1.0;
        _statusText = 'Siap dimulai!';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AIQuizScreen(questions: quizQuestions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: e.toString());
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFd2e4ff).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF9ff1e6).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Zen Scholar',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF32445b),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.only(top: 16, bottom: 64),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32445b).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  // Animated Icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF32445b).withOpacity(0.2 * _pulseController.value),
                              spreadRadius: 20 * _pulseController.value,
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 64,
                          color: Color(0xFF32445b),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  const Text(
                    'AI sedang meracik soal untukmu...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF32445b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Menganalisis tingkat pemahaman dan menyusun tantangan yang tepat. Harap tunggu sebentar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF454652),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Progress Bar
                  SizedBox(
                    width: 240,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFe6e8eb),
                            color: const Color(0xFF32445b),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _statusText,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFF757684),
                              ),
                            ),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF32445b),
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
          ),
        ],
      ),
    );
  }
}
