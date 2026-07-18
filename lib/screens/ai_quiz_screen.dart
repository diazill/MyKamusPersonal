import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import '../services/firestore_service.dart';
import 'quiz_result_screen.dart';

class AIQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const AIQuizScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<AIQuizScreen> createState() => _AIQuizScreenState();
}

class _AIQuizScreenState extends State<AIQuizScreen> {
  int _currentIndex = 0;
  String _selectedOption = '';
  final FirestoreService _firestoreService = FirestoreService();

  void _nextQuestion() async {
    // Save answer
    final currentQ = widget.questions[_currentIndex];
    widget.questions[_currentIndex] = QuizQuestion(
      question: currentQ.question,
      options: currentQ.options,
      correctOption: currentQ.correctOption,
      userOption: _selectedOption,
      explanation: currentQ.explanation,
    );

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = '';
      });
    } else {
      // Finish Quiz
      int score = 0;
      for (var q in widget.questions) {
        if (q.userOption == q.correctOption) score += 100 ~/ widget.questions.length;
      }
      
      final history = QuizHistory(
        id: '',
        score: score,
        totalQuestions: widget.questions.length,
        createdAt: DateTime.now(),
        questions: widget.questions,
      );
      
      await _firestoreService.saveQuizHistory(history);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizResultScreen(history: history)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const Scaffold();

    final currentQ = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFf2f4f7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF454652)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Soal ${_currentIndex + 1} dari ${widget.questions.length}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF454652),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFeceef1),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Color(0xFF32445b), width: 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VOCABULARY CHECK',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF32445b),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentQ.question,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF191c1e),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Options
                    Column(
                      children: currentQ.options.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String option = entry.value;
                        bool isSelected = _selectedOption == option;
                        String letter = String.fromCharCode(65 + idx); // A, B, C, D
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOption = option;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : const Color(0xFFffffff),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF32445b) : Colors.transparent,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  else
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF32445b) : const Color(0xFFeceef1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : const Color(0xFF454652),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 20,
                                        color: isSelected ? const Color(0xFF32445b) : const Color(0xFF191c1e),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF32445b),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _selectedOption.isNotEmpty ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32445b),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: const Color(0xFF32445b).withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex == widget.questions.length - 1 ? 'Selesai' : 'Selanjutnya',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
