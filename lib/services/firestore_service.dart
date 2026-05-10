import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import '../models/sentence.dart';
import '../models/notification_item.dart';

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
  
  // Add new sentence
  Future<void> addSentence(Sentence sentence) async {
    await _db.collection('sentences').add(sentence.toFirestore());
  }

  // Get stream of sentences
  Stream<List<Sentence>> getSentencesStream() {
    return _db
        .collection('sentences')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sentence.fromFirestore(doc))
            .toList());
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
}
