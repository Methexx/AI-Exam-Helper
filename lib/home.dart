import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore/firestore_service.dart';
import 'models/question_model.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/helpers.dart';
import 'routes/app_routes.dart';
import 'features/result/result_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  int _questionsCount = 0;
  List<QuestionModel> _recentQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      _currentUser = _auth.currentUser;
      final count = await _firestoreService.getQuestionsCount();
      final recent = await _firestoreService.getQuestions(limit: 3);

      setState(() {
        _questionsCount = count;
        _recentQuestions = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppHelpers.showError(context, 'Failed to load data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Exam Helper'),
        actions: [
          IconButton(
            onPressed: () => AppRoutes.navigateToProfile(context),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            Text(
                              _currentUser?.displayName ?? 'Student',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Quick Stats
                    Text(
                      'Quick Stats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              Icons.bookmark,
                              'Saved',
                              '$_questionsCount',
                            ),
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _buildStatItem(
                              context,
                              Icons.calendar_today,
                              'This Week',
                              '${_recentQuestions.length}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Feature Cards
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            context,
                            icon: Icons.camera_alt,
                            title: 'Scan Question',
                            color: Colors.blue,
                            onTap: () => AppRoutes.navigateToScan(context),
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: _buildFeatureCard(
                            context,
                            icon: Icons.history,
                            title: 'View History',
                            color: Colors.green,
                            onTap: () => AppRoutes.navigateToHistory(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Recent Questions
                    if (_recentQuestions.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Questions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () =>
                                AppRoutes.navigateToHistory(context),
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ..._recentQuestions.map((question) {
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.defaultPadding,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: const Icon(Icons.quiz),
                            ),
                            title: Text(
                              AppHelpers.truncateText(question.question, 60),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              AppHelpers.formatDate(question.createdAt),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    question: question.question,
                                    answer: question.answer,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppRoutes.navigateToScan(context),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan'),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
