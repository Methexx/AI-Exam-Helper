import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Perplexity API Configuration
  static String get perplexityApiKey => dotenv.env['PERPLEXITY_API_KEY'] ?? '';

  // Perplexity Model - sonar is 3x faster than sonar-pro
  // Options: 'sonar' (fast), 'sonar-pro' (accurate but slower)
  static const String perplexityModel = 'sonar';

  // API Timeouts
  static const int connectionTimeout = 15; // seconds
  static const int receiveTimeout = 30; // seconds

  // Rate Limits (Adjust based on your Perplexity plan)
  static const int maxRequestsPerMinute = 100;
  static const int maxRequestsPerDay = 5000;

  // Prompt Templates - Shorter prompts = faster responses
  static const String examQuestionPrompt = '''
Explain this exam question clearly and concisely:

{question}

Provide: brief explanation, step-by-step solution, key concepts, and final answer.
''';

  static const String clarificationPrompt = '''
The student needs help understanding this concept from their question:

Original Question: {question}
Student's confusion: {clarification}

Please provide a detailed explanation addressing their specific confusion.
''';
}
