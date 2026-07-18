import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import '../models/sentence.dart';
import '../models/ai_correction.dart';
import '../models/notification_item.dart';
import '../models/quiz_history.dart';
import '../models/review_card.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // VOCABULARIES
  
  // Add new vocabulary
  Future<void> addVocabulary(Vocabulary vocab) async {
    await _db.collection('vocabularies').add(vocab.toFirestore());
  }

  // Get all active vocabularies (useful for auto-detection)
  Future<List<Vocabulary>> getAllVocabularies() async {
    final querySnapshot = await _db
        .collection('vocabularies')
        .get();
    
    return querySnapshot.docs
        .map((doc) => Vocabulary.fromFirestore(doc))
        .where((vocab) => !vocab.isDeleted)
        .toList();
  }

  // Check if a vocabulary with the exact arti_id (Indonesian meaning) exists
  Future<bool> isDuplicateMeaningId(String artiId) async {
    final querySnapshot = await _db
        .collection('vocabularies')
        .where('meaning_id', isEqualTo: artiId.trim())
        .limit(1)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  // Get stream of vocabularies (e.g. for recently added)
  Stream<List<Vocabulary>> getVocabulariesStream() {
    return _db
        .collection('vocabularies')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vocabulary.fromFirestore(doc))
            .where((vocab) => !vocab.isDeleted)
            .toList());
  }

  // Get stream of vocabularies for due review
  Stream<List<Vocabulary>> getDueVocabulariesStream() {
    return _db
        .collection('vocabularies')
        .where('next_review', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vocabulary.fromFirestore(doc))
            .where((vocab) => !vocab.isDeleted)
            .toList());
  }

  // Get stream of DELETED vocabularies (Trash)
  Stream<List<Vocabulary>> getDeletedVocabulariesStream() {
    return _db
        .collection('vocabularies')
        .orderBy('deleted_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vocabulary.fromFirestore(doc))
            .where((vocab) => vocab.isDeleted)
            .toList());
  }

  // Update vocabulary
  Future<void> updateVocabulary(Vocabulary vocab) async {
    await _db.collection('vocabularies').doc(vocab.id).update(vocab.toFirestore());
  }

  // Soft delete vocabulary (move to trash)
  Future<void> softDeleteVocabulary(String id) async {
    await _db.collection('vocabularies').doc(id).update({
      'is_deleted': true,
      'deleted_at': FieldValue.serverTimestamp(),
    });
  }

  // Restore vocabulary from trash
  Future<void> restoreVocabulary(String id) async {
    await _db.collection('vocabularies').doc(id).update({
      'is_deleted': false,
      'deleted_at': FieldValue.delete(),
    });
  }

  // Permanently Delete vocabulary
  Future<void> deleteVocabulary(String id) async {
    await _db.collection('vocabularies').doc(id).delete();
  }

  // SENTENCES
  
  // Add new sentence and return document ID
  Future<String> addSentence(Sentence sentence) async {
    final docRef = await _db.collection('sentences').add(sentence.toFirestore());
    return docRef.id;
  }

  // Update existing sentence
  Future<void> updateSentence(Sentence sentence) async {
    await _db.collection('sentences').doc(sentence.id).update(sentence.toFirestore());
  }

  // Get single sentence by ID
  Future<Sentence?> getSentenceById(String id) async {
    final doc = await _db.collection('sentences').doc(id).get();
    if (doc.exists) {
      return Sentence.fromFirestore(doc);
    }
    return null;
  }

  // Get stream of active sentences
  Stream<List<Sentence>> getSentencesStream() {
    return _db
        .collection('sentences')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sentence.fromFirestore(doc))
            .where((s) => !s.isDeleted)
            .toList());
  }

  // Get stream of AI corrected sentences
  Stream<List<AiCorrection>> getAiHistoryStream() {
    return _db
        .collection('ai_corrections')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AiCorrection.fromFirestore(doc))
            .toList());
  }

  // Add new AI correction history
  Future<void> addAiCorrection(AiCorrection correction) async {
    await _db.collection('ai_corrections').add(correction.toFirestore());
  }

  // Get stream of DELETED sentences (Trash)
  Stream<List<Sentence>> getDeletedSentencesStream() {
    return _db
        .collection('sentences')
        .orderBy('deleted_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sentence.fromFirestore(doc))
            .where((s) => s.isDeleted)
            .toList());
  }

  // Soft delete sentence (move to trash)
  Future<void> softDeleteSentence(String id) async {
    await _db.collection('sentences').doc(id).update({
      'is_deleted': true,
      'deleted_at': FieldValue.serverTimestamp(),
    });
  }

  // Restore sentence from trash
  Future<void> restoreSentence(String id) async {
    await _db.collection('sentences').doc(id).update({
      'is_deleted': false,
      'deleted_at': FieldValue.delete(),
    });
  }

  // Permanently Delete sentence
  Future<void> deleteSentencePermanently(String id) async {
    await _db.collection('sentences').doc(id).delete();
  }

  // NOTIFICATIONS
  
  // Get stream of notifications
  Stream<List<NotificationItem>> getNotificationsStream() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add new notification
  Future<void> addNotification(NotificationItem notification) async {
    await _db.collection('notifications').add(notification.toMap());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    await _db.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  // APP CONFIG (UPDATES)
  
  // Get latest app version info
  Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final doc = await _db.collection('app_config').doc('version_info').get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
    return null;
  }

  // --- SRS & QUIZ METHODS ---

  // Update SRS level and next review date for a card
  Future<void> updateCardSrs(String id, String type, int srsLevel, DateTime nextReview) async {
    final collection = type == 'vocabulary' ? 'vocabularies' : 'sentences';
    await _db.collection(collection).doc(id).update({
      'srs_level': srsLevel,
      'next_review': Timestamp.fromDate(nextReview),
    });
  }

  // Save quiz history
  Future<void> saveQuizHistory(QuizHistory history) async {
    await _db.collection('quiz_histories').add(history.toFirestore());
  }

  // Get due cards for SRS (combined vocabularies and sentences)
  Future<List<ReviewCard>> getDueCards(int limit) async {
    try {
      final now = DateTime.now();
      
      // Fetch active vocabularies
      final vocabSnapshot = await _db
          .collection('vocabularies')
          .where('is_deleted', isEqualTo: false)
          .get();
          
      // Fetch active sentences
      final sentenceSnapshot = await _db
          .collection('sentences')
          .where('is_deleted', isEqualTo: false)
          .get();
          
      final List<Vocabulary> activeVocabs = vocabSnapshot.docs.map((doc) => Vocabulary.fromFirestore(doc)).toList();
      final List<Sentence> activeSentences = sentenceSnapshot.docs.map((doc) => Sentence.fromFirestore(doc)).toList();
      
      List<ReviewCard> dueCards = [];
      
      // Filter and map vocabularies
      for (var v in activeVocabs) {
        if (v.nextReview.isBefore(now) || v.nextReview.isAtSameMomentAs(now)) {
          String backText = v.kanji.isNotEmpty ? v.kanji : v.reading;
          String readingText = v.kanji.isNotEmpty ? v.reading : '';
          
          dueCards.add(ReviewCard(
            id: v.id,
            frontText: v.meaningId,
            backText: backText,
            reading: readingText,
            romaji: v.romaji,
            meaning: v.meaningId,
            notes: v.catatan,
            srsLevel: v.srsLevel,
            nextReview: v.nextReview,
            tags: [v.category],
            type: 'vocabulary',
          ));
        }
      }
      
      // Filter and map sentences
      for (var s in activeSentences) {
        if (s.nextReview.isBefore(now) || s.nextReview.isAtSameMomentAs(now)) {
          dueCards.add(ReviewCard(
            id: s.id,
            frontText: s.meaning,
            backText: s.jpText,
            reading: s.reading,
            romaji: s.romaji,
            meaning: s.meaning,
            notes: s.notes,
            srsLevel: s.srsLevel,
            nextReview: s.nextReview,
            tags: s.tags.isNotEmpty ? s.tags : ['KALIMAT'],
            type: 'sentence',
          ));
        }
      }
      
      dueCards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
      
      return dueCards.take(limit).toList();
    } catch (e) {
      print('Error getting due cards: $e');
      return [];
    }
  }

  // Get stream of quiz histories
  Stream<List<QuizHistory>> getQuizHistoriesStream() {
    return _db
        .collection('quiz_histories')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizHistory.fromFirestore(doc))
            .toList());
  }
}
