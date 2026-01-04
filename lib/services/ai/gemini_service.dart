import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // Initialize Gemini model
    _model = GenerativeModel(
      model: ApiConstants.geminiModel,
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  /// Generate explanation for an exam question
  /// Returns the AI-generated explanation
  Future<String> generateExplanation(String question) async {
    try {
      // Validate input
      if (question.isEmpty) {
        throw Exception('Question cannot be empty');
      }

      // Validate API key is set
      if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception(
          'Gemini API key not configured. Please update ApiConstants.geminiApiKey with your actual API key.',
        );
      }

      // Create prompt from template
      final prompt = ApiConstants.examQuestionPrompt.replaceAll(
        '{question}',
        question,
      );

      // Generate content
      final response = await _model.generateContent([Content.text(prompt)]);

      // Extract text from response
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        throw Exception('AI generated empty response');
      }

      return text;
    } on GenerativeAIException catch (e) {
      // Handle specific Gemini API errors
      if (e.message.contains('API_KEY_INVALID')) {
        throw Exception('Invalid API key. Please check your Gemini API key.');
      } else if (e.message.contains('RATE_LIMIT_EXCEEDED')) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (e.message.contains('SAFETY')) {
        throw Exception(
          'Content blocked by safety filters. Please rephrase your question.',
        );
      } else {
        throw Exception('Gemini API Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to generate explanation: ${e.toString()}');
    }
  }

  /// Generate clarification for a specific confusion
  Future<String> generateClarification(
    String question,
    String clarification,
  ) async {
    try {
      if (question.isEmpty || clarification.isEmpty) {
        throw Exception('Question and clarification cannot be empty');
      }

      // Create prompt from template
      final prompt = ApiConstants.clarificationPrompt
          .replaceAll('{question}', question)
          .replaceAll('{clarification}', clarification);

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        throw Exception('AI generated empty response');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to generate clarification: ${e.toString()}');
    }
  }

  /// Generate a simpler explanation for complex topics
  Future<String> simplifyExplanation(String complexText) async {
    try {
      final prompt =
          '''
Please simplify the following explanation for easier understanding:

$complexText

Provide a simpler version that a student can easily grasp, using everyday language and examples where helpful.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        throw Exception('AI generated empty response');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to simplify explanation: ${e.toString()}');
    }
  }

  /// Generate follow-up questions for deeper understanding
  Future<List<String>> generateFollowUpQuestions(String topic) async {
    try {
      final prompt =
          '''
Based on this topic: "$topic"

Generate 3 follow-up questions that would help a student understand this topic better.
Format: Return only the questions, one per line, numbered 1-3.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        return [];
      }

      // Parse questions from response
      final questions = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      return questions.take(3).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if API is properly configured and working
  Future<bool> testConnection() async {
    try {
      if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        return false;
      }

      final response = await _model.generateContent([
        Content.text('Test: Reply with "OK" if you receive this message.'),
      ]);

      return response.text?.isNotEmpty ?? false;
    } catch (e) {
      return false;
    }
  }
}
