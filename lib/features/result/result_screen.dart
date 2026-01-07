import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore/firestore_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class ResultScreen extends StatefulWidget {
  final String question;
  final String? answer;
  final Stream<String>? answerStream;

  const ResultScreen({
    super.key,
    required this.question,
    this.answer,
    this.answerStream,
  }) : assert(
         answer != null || answerStream != null,
         'Either answer or answerStream must be provided',
       );

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;
  bool _isSaved = false;
  String _currentAnswer = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    if (widget.answer != null) {
      _currentAnswer = widget.answer!;
    } else if (widget.answerStream != null) {
      _isStreaming = true;
      _listenToStream();
    }
  }

  void _listenToStream() {
    widget.answerStream!.listen(
      (partialAnswer) {
        if (mounted) {
          setState(() {
            _currentAnswer = partialAnswer;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isStreaming = false);
          AppHelpers.showError(context, error.toString());
        }
      },
      onDone: () {
        if (mounted) {
          setState(() => _isStreaming = false);
        }
      },
    );
  }

  Future<void> _saveQuestion() async {
    try {
      setState(() => _isSaving = true);

      await _firestoreService.saveQuestion(
        question: widget.question,
        answer: _currentAnswer,
      );

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      if (mounted) {
        AppHelpers.showSuccess(context, AppConstants.savedSuccess);
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        AppHelpers.showError(context, 'Failed to save: ${e.toString()}');
      }
    }
  }

  void _shareContent() {
    final content = 'Question:\n${widget.question}\n\nAnswer:\n$_currentAnswer';
    Clipboard.setData(ClipboardData(text: content));
    AppHelpers.showSuccess(context, 'Copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explanation'),
        actions: [
          IconButton(
            onPressed: _shareContent,
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, size: 20),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          'Question',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    const Divider(),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      widget.question,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Answer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 20),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          'AI Explanation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    const Divider(),
                    const SizedBox(height: AppConstants.smallPadding),
                    _isStreaming && _currentAnswer.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text(
                            _currentAnswer,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                    if (_isStreaming && _currentAnswer.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Generating...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Save Button
            if (!_isSaved)
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveQuestion,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bookmark_add),
                label: Text(_isSaving ? 'Saving...' : 'Save to History'),
              ),

            if (_isSaved)
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: AppConstants.smallPadding),
                    Text(
                      'Saved to History',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
