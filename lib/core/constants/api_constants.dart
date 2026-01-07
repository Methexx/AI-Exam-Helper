import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Perplexity API Configuration
  static String get perplexityApiKey => dotenv.env['PERPLEXITY_API_KEY'] ?? '';

  // Perplexity Model (Pro models: sonar-pro, sonar-reasoning)
  static const String perplexityModel = 'sonar-pro';

  // API Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 60; // seconds

  // Rate Limits (Adjust based on your Perplexity plan)
  static const int maxRequestsPerMinute = 100;
  static const int maxRequestsPerDay = 5000;

  // Prompt Templates
  static const String examQuestionPrompt = '''
You are an expert tutor helping a student understand an exam question.

Question: {question}

Please provide:
1. A brief explanation of what the question is asking
2. Step-by-step solution or approach
3. Key concepts involved
4. Final answer (if applicable)

Format your response in a clear, student-friendly manner with proper sections.
''';

  static const String clarificationPrompt = '''
The student needs help understanding this concept from their question:

Original Question: {question}
Student's confusion: {clarification}

Please provide a detailed explanation addressing their specific confusion.
''';
}
