import 'package:cloud_firestore/cloud_firestore.dart';

class AiCorrection {
  final String id;
  final String sentenceId;
  final String originalJpText;
  final String correctedJpText;
  final String explanation;
  final String category;
  final DateTime createdAt;

  AiCorrection({
    required this.id,
    required this.sentenceId,
    required this.originalJpText,
    required this.correctedJpText,
    required this.explanation,
    required this.category,
    required this.createdAt,
  });

  factory AiCorrection.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AiCorrection(
      id: doc.id,
      sentenceId: data['sentence_id'] ?? '',
      originalJpText: data['original_jp_text'] ?? '',
      correctedJpText: data['corrected_jp_text'] ?? '',
      explanation: data['explanation'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sentence_id': sentenceId,
      'original_jp_text': originalJpText,
      'corrected_jp_text': correctedJpText,
      'explanation': explanation,
      'category': category,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
