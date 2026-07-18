import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quiz_history.dart';

class QuizHistoryDetailScreen extends StatelessWidget {
  final QuizHistory history;

  const QuizHistoryDetailScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int correctCount = history.questions.where((q) => q.userOption == q.correctOption).length;
    int incorrectCount = history.questions.length - correctCount;
    double percentage = history.questions.isEmpty ? 0 : (correctCount / history.questions.length) * 100;
    
    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fc),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF454652)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Sesi Kuis',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: Color(0xFF191c1e),
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFe6e8eb), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kuis AI: Kosakata',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF32445b),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Color(0xFF454652)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(history.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF454652),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('•', style: TextStyle(color: Color(0xFF454652))),
                          ),
                          const Icon(Icons.schedule, size: 16, color: Color(0xFF454652)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(history.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF454652),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          percentage.round().toString(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006a62),
                            height: 1,
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            color: Color(0xFF454652),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pencapaian',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF00504a),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Stats Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL SOAL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Color(0xFF454652),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${history.questions.length}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191c1e),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFf2f4f7)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BENAR',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Color(0xFF006a62),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$correctCount',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0a6f66),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFf2f4f7)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERLU REVIEW',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Color(0xFF7c2500),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$incorrectCount',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7c2500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Analisis Pertanyaan',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF32445b),
              ),
            ),
            const SizedBox(height: 24),
            
            // Question List
            ...history.questions.map((q) {
              bool isCorrect = q.userOption == q.correctOption;
              return _buildQuestionCard(q, isCorrect);
            }).toList(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion q, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isCorrect)
              Container(width: 4, color: const Color(0xFF7c2500)),
              
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            q.question,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191c1e),
                            ),
                          ),
                        ),
                        if (!isCorrect)
                          Container(
                            margin: const EdgeInsets.only(left: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFffc6b3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Review',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFF9f390e),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (isCorrect) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF006a62), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'JAWABAN ANDA',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF454652),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q.userOption,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF191c1e),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf7f9fc),
                          border: Border.all(color: const Color(0xFFc5c5d4).withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel, color: Color(0xFFba1a1a), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'JAWABAN ANDA',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Color(0xFF454652),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q.userOption,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF191c1e).withValues(alpha: 0.7),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF006a62), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'JAWABAN BENAR',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF006a62),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q.correctOption,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF191c1e),
                                  ),
                                ),
                                if (q.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.only(top: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(top: BorderSide(color: Color(0xFFe6e8eb))),
                                    ),
                                    child: Text(
                                      q.explanation,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Color(0xFF454652),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
