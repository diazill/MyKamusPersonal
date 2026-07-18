import 'package:cloud_firestore/cloud_firestore.dart';

class Sentence {
  final String id;
  final String jpText;
  final String reading;
  final String meaning;
  final String romaji;
  final String notes;
  final List<String> tags;
  final List<String> vocabIds;
  final int srsLevel;
  final DateTime nextReview;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? originalJpText;
  final String? aiExplanation;
  final String? aiCategory;
  final bool hasAiCorrection;

  Sentence({
    required this.id,
    required this.jpText,
    required this.reading,
    required this.meaning,
    required this.romaji,
    this.notes = '',
    this.tags = const [],
    this.vocabIds = const [],
    required this.srsLevel,
    required this.nextReview,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.originalJpText,
    this.aiExplanation,
    this.aiCategory,
    this.hasAiCorrection = false,
  });

  factory Sentence.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Sentence(
      id: doc.id,
      jpText: data['jp_text'] ?? '',
      reading: data['reading'] ?? '',
      meaning: data['meaning'] ?? '',
      romaji: data['romaji'] ?? '',
      notes: data['notes'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      vocabIds: List<String>.from(data['vocab_ids'] ?? []),
      srsLevel: data['srs_level'] ?? 0,
      nextReview: (data['next_review'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['is_deleted'] ?? false,
      deletedAt: (data['deleted_at'] as Timestamp?)?.toDate(),
      originalJpText: data['original_jp_text'],
      aiExplanation: data['ai_explanation'],
      aiCategory: data['ai_category'],
      hasAiCorrection: data['has_ai_correction'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> map = {
      'jp_text': jpText,
      'reading': reading,
      'meaning': meaning,
      'romaji': romaji,
      'notes': notes,
      'tags': tags,
      'vocab_ids': vocabIds,
      'srs_level': srsLevel,
      'next_review': Timestamp.fromDate(nextReview),
      'created_at': Timestamp.fromDate(createdAt),
      'is_deleted': isDeleted,
      'has_ai_correction': hasAiCorrection,
    };
    if (deletedAt != null) {
      map['deleted_at'] = Timestamp.fromDate(deletedAt!);
    }
    if (originalJpText != null) map['original_jp_text'] = originalJpText;
    if (aiExplanation != null) map['ai_explanation'] = aiExplanation;
    if (aiCategory != null) map['ai_category'] = aiCategory;
    
    return map;
  }
}
