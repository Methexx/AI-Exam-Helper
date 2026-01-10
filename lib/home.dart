import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore/firestore_service.dart';
import 'models/question_model.dart';
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
      final recent = await _firestoreService.getQuestions(limit: 2);

      setState(() {
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
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFEFD9B0)),
          onPressed: () {},
        ),
        title: Text(
          'Chatty',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEFD9B0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFFEFD9B0)),
            onPressed: () => AppRoutes.navigateToProfile(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEFD9B0)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFEFD9B0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tap to chat card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFD9B0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tap to chat',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF131313),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131313),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFEFD9B0),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Color(0xFF131313),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ask me any questions you have ${_currentUser?.displayName?.split(' ').first ?? 'Methum'}. I can answer all questions and talk to you',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF131313),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEFD9B0),
                          ),
                        ),
                        TextButton(
                          onPressed: () => AppRoutes.navigateToHistory(context),
                          child: Text(
                            'See All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFFEFD9B0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // History Cards
                    if (_recentQuestions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No history yet. Start chatting!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(
                              0xFFEFD9B0,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (_recentQuestions.isNotEmpty)
                            Expanded(
                              child: _buildHistoryCard(_recentQuestions[0]),
                            ),
                          if (_recentQuestions.length > 1) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildHistoryCard(_recentQuestions[1]),
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Popular Category Section
                    Text(
                      'Popular Category',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEFD9B0),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCategoryCard(
                          'MCQ Helper',
                          'Generate the explanations',
                          Icons.quiz_outlined,
                          () => AppRoutes.navigateToScan(context),
                        ),
                        _buildCategoryCard(
                          'Deep Research',
                          'Researching the full of content and gives answer',
                          Icons.search,
                          () => AppRoutes.navigateToScan(context),
                        ),
                        _buildCategoryCard(
                          'Exam project',
                          'Give the full project model using relative content',
                          Icons.assignment_outlined,
                          () => AppRoutes.navigateToScan(context),
                        ),
                        _buildCategoryCard(
                          'Recipe',
                          'Give the recipe for any food dishes',
                          Icons.restaurant_menu,
                          () => AppRoutes.navigateToScan(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHistoryCard(QuestionModel question) {
    final DateTime date = question.createdAt;
    final String dateStr =
        '${date.day < 10 ? '0' : ''}${date.day} ${_getMonthName(date.month)}, ${date.year}';
    final String timeStr =
        '${date.hour}:${date.minute < 10 ? '0' : ''}${date.minute}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              question: question.question,
              answer: question.answer,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Color(0xFFEFD9B0),
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFFEFD9B0).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
                  color: Color(0xFFEFD9B0),
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFFEFD9B0).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEFD9B0),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'More',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFFEFD9B0).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: const Color(0xFFEFD9B0).withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3FE1B0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF131313), size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEFD9B0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFFEFD9B0).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
