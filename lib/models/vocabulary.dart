import 'package:cloud_firestore/cloud_firestore.dart';

class Vocabulary {
  final String id;
  final String kanji;
  final String reading;
  final String romaji;
  final String meaningId;
  final String meaningEn;
  final String category;
  final String subCategory;
  final String catatan;
  final int srsLevel;
  final DateTime nextReview;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  Vocabulary({
    required this.id,
    required this.kanji,
    required this.reading,
    required this.romaji,
    required this.meaningId,
    required this.meaningEn,
    required this.category,
    required this.subCategory,
    this.catatan = '',
    required this.srsLevel,
    required this.nextReview,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Vocabulary.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Vocabulary(
      id: doc.id,
      kanji: data['kanji'] ?? '',
      reading: data['reading'] ?? '',
      romaji: data['romaji'] ?? '',
      meaningId: data['meaning_id'] ?? '',
      meaningEn: data['meaning_en'] ?? '',
      category: data['category'] ?? '',
      subCategory: data['sub_category'] ?? '',
      catatan: data['catatan'] ?? '',
      srsLevel: data['srs_level'] ?? 0,
      nextReview: (data['next_review'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['is_deleted'] ?? false,
      deletedAt: (data['deleted_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kanji': kanji,
      'reading': reading,
      'romaji': romaji,
      'meaning_id': meaningId,
      'meaning_en': meaningEn,
      'category': category,
      'sub_category': subCategory,
      'catatan': catatan,
      'srs_level': srsLevel,
      'next_review': Timestamp.fromDate(nextReview),
      'created_at': Timestamp.fromDate(createdAt),
      'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': Timestamp.fromDate(deletedAt!),
    };
  }
}
