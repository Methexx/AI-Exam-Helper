import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/question_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Save a question to Firestore
  Future<String> saveQuestion({
    required String question,
    required String answer,
    String? imageUrl,
    List<String> tags = const [],
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final questionModel = QuestionModel(
        id: '', // Will be set by Firestore
        userId: currentUserId!,
        question: question,
        answer: answer,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        tags: tags,
      );

      // Save to user's history subcollection
      final docRef = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .add(questionModel.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save question: ${e.toString()}');
    }
  }

  /// Get all questions for current user
  Future<List<QuestionModel>> getQuestions({int? limit}) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: ${e.toString()}');
    }
  }

  /// Get a single question by ID
  Future<QuestionModel?> getQuestion(String questionId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .doc(questionId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return QuestionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch question: ${e.toString()}');
    }
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete question: ${e.toString()}');
    }
  }

  /// Update a question
  Future<void> updateQuestion(
    String questionId, {
    String? question,
    String? answer,
    List<String>? tags,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final Map<String, dynamic> updates = {};
      if (question != null) updates['question'] = question;
      if (answer != null) updates['answer'] = answer;
      if (tags != null) updates['tags'] = tags;

      if (updates.isEmpty) return;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .doc(questionId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update question: ${e.toString()}');
    }
  }

  /// Search questions by text
  Future<List<QuestionModel>> searchQuestions(String searchTerm) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that fetches all and filters locally
      // For production, consider using Algolia or similar service

      final allQuestions = await getQuestions();

      final searchLower = searchTerm.toLowerCase();
      return allQuestions.where((q) {
        return q.question.toLowerCase().contains(searchLower) ||
            q.answer.toLowerCase().contains(searchLower) ||
            q.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search questions: ${e.toString()}');
    }
  }

  /// Get questions count for current user
  Future<int> getQuestionsCount() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.historyCollection)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Stream of questions (real-time updates)
  Stream<List<QuestionModel>> questionsStream({int? limit}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .collection(AppConstants.historyCollection)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }
}
