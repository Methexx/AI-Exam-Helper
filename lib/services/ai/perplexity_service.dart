import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class PerplexityService {
  /// Generate explanation for an exam question using Perplexity API
  Future<String> generateExplanation(String question) async {
    try {
      // Validate input
      if (question.isEmpty) {
        throw Exception('Question cannot be empty');
      }

      // Validate API key is set
      if (ApiConstants.perplexityApiKey.isEmpty) {
        throw Exception(
          'Perplexity API key not configured. Please add PERPLEXITY_API_KEY to your .env file.',
        );
      }

      // Create prompt from template
      final prompt = ApiConstants.examQuestionPrompt.replaceAll(
        '{question}',
        question,
      );

      // Make API request to Perplexity
      final response = await http
          .post(
            Uri.parse('https://api.perplexity.ai/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${ApiConstants.perplexityApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': ApiConstants.perplexityModel,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an expert tutor helping students understand exam questions.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 2000,
            }),
          )
          .timeout(
            Duration(seconds: ApiConstants.receiveTimeout),
            onTimeout: () {
              throw Exception('Request timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content']?.trim() ?? '';

        if (text.isEmpty) {
          throw Exception('AI generated empty response');
        }

        return text;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Invalid API key. Please check your Perplexity API key.',
        );
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Perplexity API Error: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e.toString().contains('API key')) {
        rethrow;
      }
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

      final response = await http
          .post(
            Uri.parse('https://api.perplexity.ai/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${ApiConstants.perplexityApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': ApiConstants.perplexityModel,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an expert tutor helping students understand complex concepts.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 2000,
            }),
          )
          .timeout(Duration(seconds: ApiConstants.receiveTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content']?.trim() ?? '';

        if (text.isEmpty) {
          throw Exception('AI generated empty response');
        }

        return text;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to generate clarification: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
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

Provide a simpler version that:
- Uses everyday language
- Breaks down complex terms
- Gives relatable examples
- Is easy to understand for beginners
''';

      final response = await http
          .post(
            Uri.parse('https://api.perplexity.ai/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${ApiConstants.perplexityApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': ApiConstants.perplexityModel,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a tutor who excels at explaining complex topics simply.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 2000,
            }),
          )
          .timeout(Duration(seconds: ApiConstants.receiveTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content']?.trim() ?? '';

        if (text.isEmpty) {
          throw Exception('AI generated empty response');
        }

        return text;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to simplify: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to simplify explanation: ${e.toString()}');
    }
  }
}
