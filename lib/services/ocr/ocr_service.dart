import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/constants/app_constants.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from an image file using ML Kit
  /// Returns the extracted text or throws an exception if extraction fails
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 5MB)
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > AppConstants.maxImageSizeMB) {
        throw Exception(
          'Image size exceeds ${AppConstants.maxImageSizeMB}MB limit',
        );
      }

      // Create InputImage from file
      final inputImage = InputImage.fromFile(imageFile);

      // Process the image
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Extract text
      final String text = recognizedText.text.trim();

      // Validate extracted text
      if (text.isEmpty) {
        throw Exception(
          'No text found in the image. Please ensure the image contains readable text.',
        );
      }

      // Check if text is too long
      if (text.length > AppConstants.maxQuestionLength) {
        return text.substring(0, AppConstants.maxQuestionLength);
      }

      return text;
    } catch (e) {
      throw Exception('OCR Error: ${e.toString()}');
    }
  }

  /// Extract text with detailed block information
  /// Returns a map with text blocks and their metadata
  Future<Map<String, dynamic>> extractTextWithDetails(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      List<Map<String, dynamic>> blocks = [];

      for (TextBlock block in recognizedText.blocks) {
        blocks.add({
          'text': block.text,
          'confidence': 1.0, // ML Kit doesn't provide confidence directly
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'right': block.boundingBox.right,
            'bottom': block.boundingBox.bottom,
          },
          'lines': block.lines.length,
        });
      }

      return {
        'fullText': recognizedText.text,
        'blocks': blocks,
        'blockCount': recognizedText.blocks.length,
      };
    } catch (e) {
      throw Exception('OCR Detail Extraction Error: ${e.toString()}');
    }
  }

  /// Check if image contains readable text (quick validation)
  Future<bool> hasReadableText(File imageFile) async {
    try {
      final text = await extractTextFromImage(imageFile);
      return text.length >
          10; // At least 10 characters to be considered readable
    } catch (e) {
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _textRecognizer.close();
  }
}
