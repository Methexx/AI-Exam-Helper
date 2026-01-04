class ApiConstants {
  // Gemini API Configuration
  // TODO: Replace with your actual Gemini API key from https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // Gemini Model
  static const String geminiModel = 'gemini-1.5-flash';

  // API Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 60; // seconds

  // Rate Limits (Free Tier)
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerDay = 1500;

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
