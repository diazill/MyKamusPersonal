import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistory {
  final String id;
  final int score;
  final int totalQuestions;
  final DateTime createdAt;
  final List<QuizQuestion> questions;

  QuizHistory({
    required this.id,
    required this.score,
    required this.totalQuestions,
    required this.createdAt,
    required this.questions,
  });

  factory QuizHistory.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QuizHistory(
      id: doc.id,
      score: data['score'] ?? 0,
      totalQuestions: data['total_questions'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      questions: (data['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'created_at': Timestamp.fromDate(createdAt),
      'questions': questions.map((e) => e.toMap()).toList(),
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctOption;
  final String userOption;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.userOption,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOption: map['correct_option'] ?? '',
      userOption: map['user_option'] ?? '',
      explanation: map['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correct_option': correctOption,
      'user_option': userOption,
      'explanation': explanation,
    };
  }
}
