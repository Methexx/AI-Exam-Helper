class AppConstants {
  // App Info
  static const String appName = 'AI Exam Helper';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String historyCollection = 'history';
  static const String questionsCollection = 'questions';

  // Limits
  static const int maxImageSizeMB = 5;
  static const int maxQuestionLength = 1000;
  static const int maxHistoryItems = 100;

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String imagePickError =
      'Failed to pick image. Please try again.';
  static const String ocrError =
      'Failed to extract text from image. Please ensure the image is clear.';
  static const String aiError =
      'Failed to generate explanation. Please try again.';
  static const String authError = 'Authentication failed. Please try again.';

  // Success Messages
  static const String savedSuccess = 'Question saved successfully!';
  static const String deletedSuccess = 'Question deleted successfully!';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
}
