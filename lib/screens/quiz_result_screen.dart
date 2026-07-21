import 'package:flutter/material.dart';
import '../models/quiz_history.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizHistory history;

  const QuizResultScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int correctCount = history.questions.where((q) => q.userOption == q.correctOption).length;
    int wrongCount = history.questions.length - correctCount;
    
    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9cefe4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006a62).withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF0a6f66),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Luar Biasa!',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF32445b),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Target Kuis Selesai!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF454652),
                    ),
                  ),
                ],
              ),
            ),
            
            // Score Circle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: history.score / 100,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFe6e8eb),
                      color: const Color(0xFF006a62),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${history.score}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF32445b),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454652),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Summary List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF32445b),
                          ),
                        ),
                        Text(
                          '$correctCount Benar • $wrongCount Salah',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF454652),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: history.questions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final q = history.questions[index];
                          final isCorrect = q.userOption == q.correctOption;
                          
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFf2f4f7)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCorrect ? const Color(0xFF9cefe4).withOpacity(0.5) : const Color(0xFFffdad6).withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? const Color(0xFF006a62) : const Color(0xFFba1a1a),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.question,
                                        style: const TextStyle(
                                          fontFamily: 'Noto Sans JP',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF191c1e),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (isCorrect)
                                        Text(
                                          q.correctOption,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Color(0xFF454652),
                                          ),
                                        )
                                      else
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: Color(0xFF454652),
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${q.userOption} ',
                                                style: const TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                  color: Color(0xFFba1a1a),
                                                ),
                                              ),
                                              TextSpan(text: q.correctOption),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFf7f9fc),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: Color(0xFF32445b),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                q.explanation.isNotEmpty ? q.explanation : 'Penjelasan tidak tersedia.',
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 13,
                                                  color: Color(0xFF454652),
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to Belajar Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32445b),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
