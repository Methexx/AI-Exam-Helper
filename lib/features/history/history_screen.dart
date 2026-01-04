import 'package:flutter/material.dart';
import '../../services/firestore/firestore_service.dart';
import '../../models/question_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../features/result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<QuestionModel> _allQuestions = [];
  List<QuestionModel> _filteredQuestions = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() => _isLoading = true);

      final questions = await _firestoreService.getQuestions();

      setState(() {
        _allQuestions = questions;
        _filteredQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        AppHelpers.showError(
          context,
          'Failed to load history: ${e.toString()}',
        );
      }
    }
  }

  void _filterQuestions(String query) {
    if (query.isEmpty) {
      setState(() => _filteredQuestions = _allQuestions);
      return;
    }

    final searchLower = query.toLowerCase();
    setState(() {
      _filteredQuestions = _allQuestions
          .where(
            (q) =>
                q.question.toLowerCase().contains(searchLower) ||
                q.answer.toLowerCase().contains(searchLower),
          )
          .toList();
    });
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestoreService.deleteQuestion(question.id);

      setState(() {
        _allQuestions.removeWhere((q) => q.id == question.id);
        _filteredQuestions.removeWhere((q) => q.id == question.id);
      });

      if (mounted) {
        AppHelpers.showSuccess(context, AppConstants.deletedSuccess);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Failed to delete: ${e.toString()}');
      }
    }
  }

  void _viewQuestion(QuestionModel question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(question: question.question, answer: question.answer),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search questions...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _filterQuestions,
              )
            : const Text('History'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredQuestions = _allQuestions;
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredQuestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No saved questions yet'
                        : 'No results found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  if (_searchController.text.isEmpty)
                    const Text(
                      'Start scanning questions to build your history',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadQuestions,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: _filteredQuestions.length,
                itemBuilder: (context, index) {
                  final question = _filteredQuestions[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppConstants.defaultPadding,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      title: Text(
                        AppHelpers.truncateText(question.question, 100),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: AppConstants.smallPadding,
                        ),
                        child: Text(
                          AppHelpers.formatDate(question.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteQuestion(question),
                      ),
                      onTap: () => _viewQuestion(question),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
