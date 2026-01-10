import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore/firestore_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  int _questionsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      _currentUser = _auth.currentUser;
      final count = await _firestoreService.getQuestionsCount();

      setState(() {
        _questionsCount = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppHelpers.showError(context, 'Failed to load profile data');
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _auth.signOut();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Failed to logout: ${e.toString()}');
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all saved questions? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final questions = await _firestoreService.getQuestions();
      for (var q in questions) {
        await _firestoreService.deleteQuestion(q.id);
      }

      setState(() => _questionsCount = 0);

      if (mounted) {
        AppHelpers.showSuccess(context, 'History cleared successfully');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(
          context,
          'Failed to clear history: ${e.toString()}',
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2026 AI Exam Helper\nEducational Use Only',
      children: [
        const SizedBox(height: 16),
        const Text(
          'An AI-powered app to help students study and prepare for exams by scanning questions and generating explanations.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.largePadding),

                  // User Info Card
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: _currentUser?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              _currentUser!.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  Text(
                    _currentUser?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: AppConstants.smallPadding),

                  Text(
                    _currentUser?.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Statistics Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.quiz),
                              title: const Text('Saved Questions'),
                              trailing: Text(
                                '$_questionsCount',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Member Since'),
                              trailing: Text(
                                _currentUser?.metadata.creationTime != null
                                    ? AppHelpers.formatDate(
                                        _currentUser!.metadata.creationTime!,
                                      )
                                    : 'N/A',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Settings Options
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.delete_sweep,
                              color: Colors.orange,
                            ),
                            title: const Text('Clear History'),
                            onTap: _clearHistory,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('About App'),
                            onTap: _showAboutDialog,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
    );
  }
}
