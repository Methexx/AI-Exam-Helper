import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ocr/ocr_service.dart';
import '../../services/ai/perplexity_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../result/result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final PerplexityService _perplexityService = PerplexityService();

  File? _selectedImage;
  String? _extractedText;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _errorMessage = null;
        _extractedText = null;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isProcessing = true;
      });

      // Extract text using OCR
      final text = await _ocrService.extractTextFromImage(_selectedImage!);

      setState(() {
        _extractedText = text;
        _isProcessing = false;
      });

      if (mounted) {
        AppHelpers.showSuccess(context, 'Text extracted successfully!');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        AppHelpers.showError(context, AppConstants.ocrError);
      }
    }
  }

  Future<void> _generateExplanation() async {
    if (_extractedText == null || _extractedText!.isEmpty) {
      AppHelpers.showError(context, 'No text to analyze');
      return;
    }

    try {
      setState(() => _isProcessing = true);

      // Navigate to result screen immediately with streaming
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              question: _extractedText!,
              answerStream: _perplexityService.generateExplanationStream(
                _extractedText!,
              ),
            ),
          ),
        );
      }

      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        AppHelpers.showError(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Question'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Image preview
            if (_selectedImage != null)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Loading indicator
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppConstants.defaultPadding),
                    Text('Processing image...'),
                  ],
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Extracted text
            if (_extractedText != null && !_isProcessing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.text_fields, size: 20),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            'Extracted Text',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      const Divider(),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(_extractedText!),
                    ],
                  ),
                ),
              ),

            // Analyze button
            if (_extractedText != null && !_isProcessing)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppConstants.defaultPadding,
                ),
                child: ElevatedButton.icon(
                  onPressed: _generateExplanation,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Get AI Explanation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
