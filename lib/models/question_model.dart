import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String userId;
  final String question;
  final String answer;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> tags;

  QuestionModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    this.imageUrl,
    required this.createdAt,
    this.tags = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  // Create from Firestore Document
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Create from Map
  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      userId: map['userId'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Create a copy with updated fields
  QuestionModel copyWith({
    String? id,
    String? userId,
    String? question,
    String? answer,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: ${question.substring(0, question.length > 50 ? 50 : question.length)}...)';
  }
}
