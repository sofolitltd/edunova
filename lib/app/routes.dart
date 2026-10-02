import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/change_password_screen.dart';
import '../features/auth/screens/edit_profile_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/exam_detail_screen.dart';
import '../features/home/screens/class_detail_screen.dart';
import '../features/home/screens/batch_detail_screen.dart';
import '../features/home/services/batch_service.dart' show SuggestedBatch;
import '../features/home/screens/help_support_screen.dart';
import '../features/home/screens/about_screen.dart';
import '../features/home/screens/terms_screen.dart';
import '../features/home/screens/privacy_screen.dart';
import '../features/articles/screens/articles_screen.dart';
import '../features/notifications/screens/notification_history_screen.dart';
import '../features/notifications/screens/notification_detail_screen.dart';
import '../features/notifications/services/notification_history_service.dart';
import '../features/courses/screens/courses_screen.dart';
import '../features/courses/screens/course_detail_screen.dart';
import '../features/courses/screens/enrollment_screen.dart';
import '../features/courses/screens/my_enrollments_screen.dart';
import '../features/exams/screens/live_exams_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/results/screens/results_screen.dart';
import '../features/practice/screens/practice_hub_screen.dart';
import '../features/daily_content/screens/daily_content_screen.dart';
import '../features/transitions/screens/transition_form_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/models/auth_state.dart';
import '../shared/constants/app_colors.dart';
import '../shared/services/secure_storage_service.dart';

const _pageTitles = {
  '/login': 'Login',
  '/register': 'Register',
  '/forgot-password': 'Forgot Password',
  '/otp-verify': 'Verify OTP',
  '/home': 'Home',
  '/change-password': 'Change Password',
  '/edit-profile': 'Edit Profile',
  '/profile-setup': 'Profile Setup',
  '/welcome': 'Welcome',
  '/exam-detail': 'Exam Details',
  '/class-detail': 'Class Details',
  '/help-support': 'Help & Support',
  '/about': 'About Us',
  '/terms': 'Terms & Conditions',
  '/privacy': 'Privacy Policy',
  '/articles': 'Articles',
  '/notifications': 'Notifications',
  '/notification-detail': 'Notification Details',
  '/courses': 'Courses',
  '/my-enrollments': 'My Enrollments',
  '/live-exams': 'Live Exams',
  '/notes': 'Notes',
  '/results': 'Results',
  '/practice': 'Practice',
  '/daily-content': 'Daily Content',
  '/transition': 'Transition',
};

/// Returns the browser/window title for the given route path, e.g. "EduNova - Home".
String titleForPath(String path) {
  String? page = _pageTitles[path];
  page ??= path.startsWith('/courses/')
      ? 'Course Details'
      : path.startsWith('/enroll/')
      ? 'Enrollment'
      : null;
  return page == null ? 'EduNova' : 'EduNova - $page';
}

/// The gated route (location + extra) a user with an incomplete profile was
/// trying to reach, so [ProfileSetupScreen] can resume it after completion
/// instead of always dropping them back on the home screen.
final pendingGatedRouteProvider = StateProvider<(String, Object?)?>(
  (ref) => null,
);

/// Bridges Riverpod auth-state changes to GoRouter's [refreshListenable]
/// without rebuilding the [GoRouter] instance itself — recreating the
/// router on every auth change tears down and rebuilds the whole nav tree,
/// which resets in-progress screens (e.g. clearing the login form fields).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: ref.read(authProvider).token != null ? '/home' : '/login',
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return OTPVerifyScreen(mobile: mobile);
        },
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/exam-detail',
        name: 'exam-detail',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ExamDetailScreen(
            title: data['title'] ?? '',
            date: data['date'] ?? '',
            time: data['time'] ?? '',
            duration: data['duration'] ?? '',
            questions: data['questions'] ?? 0,
            color: data['color'] ?? AppColors.primary,
          );
        },
      ),
      GoRoute(
        path: '/class-detail',
        name: 'class-detail',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ClassDetailScreen(
            batchId: data['batchId'] ?? 0,
            fallbackTitle: data['subject'] ?? '',
            color: data['color'] ?? AppColors.primary,
          );
        },
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/articles',
        name: 'articles',
        builder: (context, state) => const ArticlesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationHistoryScreen(),
      ),
      GoRoute(
        path: '/notification-detail',
        name: 'notification-detail',
        builder: (context, state) {
          final notification = state.extra as AppNotification;
          return NotificationDetailScreen(notification: notification);
        },
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'all';
          return CoursesScreen(initialType: type);
        },
      ),
      GoRoute(
        path: '/courses/:id',
        name: 'course-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/enroll/:courseId',
        name: 'enrollment',
        builder: (context, state) {
          final courseId =
              int.tryParse(state.pathParameters['courseId'] ?? '') ?? 0;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EnrollmentScreen(
            courseId: courseId,
            courseName: extra['courseName'] ?? '',
            courseTitleBn: extra['courseTitleBn'] ?? '',
            price: extra['price'] ?? 0,
            type: extra['type'] ?? 'paid',
          );
        },
      ),
      GoRoute(
        path: '/batches/:id',
        name: 'batch-detail',
        builder: (context, state) {
          final batch = state.extra as SuggestedBatch;
          return BatchDetailScreen(batch: batch);
        },
      ),
      GoRoute(
        path: '/enroll-batch/:batchId',
        name: 'enroll-batch',
        builder: (context, state) {
          final batchId =
              int.tryParse(state.pathParameters['batchId'] ?? '') ?? 0;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EnrollmentScreen(
            batchId: batchId,
            courseName: extra['batchName'] ?? '',
            courseTitleBn: extra['batchName'] ?? '',
            price: extra['price'] ?? 0,
            type: extra['type'] ?? 'paid',
            batchClassLevel: extra['classLevel'] ?? '',
            batchDays: (extra['days'] as List?)?.cast<String>() ?? const [],
            batchStartTime: extra['startTime'] ?? '',
            batchEndTime: extra['endTime'] ?? '',
            batchSchedule: extra['schedule'] ?? '',
            batchShift: extra['shift'] ?? '',
            batchCourseName: extra['courseName'] ?? '',
            admissionFee: extra['admissionFee'] ?? 0,
            noteFee: extra['noteFee'] ?? 0,
            monthlyFee: extra['monthlyFee'] ?? 0,
            maxStudents: extra['maxStudents'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/my-enrollments',
        name: 'my-enrollments',
        builder: (context, state) => const MyEnrollmentsScreen(),
      ),
      GoRoute(
        path: '/live-exams',
        name: 'live-exams',
        builder: (context, state) => const LiveExamsScreen(),
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/practice',
        name: 'practice',
        builder: (context, state) => const PracticeHubScreen(),
      ),
      GoRoute(
        path: '/daily-content',
        name: 'daily-content',
        builder: (context, state) => const DailyContentScreen(),
      ),
      GoRoute(
        path: '/transition',
        name: 'transition',
        builder: (context, state) => const TransitionFormScreen(),
      ),
    ],
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final hasToken = authState.token != null;
      final path = state.matchedLocation;
      final storage = SecureStorageService();
      final seenWelcome = await storage.hasSeenWelcome();

      final isPublicRoute =
          path == '/login' ||
          path == '/register' ||
          path == '/forgot-password' ||
          path == '/otp-verify' ||
          path == '/profile-setup' ||
          path == '/welcome' ||
          path == '/terms' ||
          path == '/privacy' ||
          path == '/help-support' ||
          path == '/articles' ||
          path == '/my-enrollments';

      // Not logged in: show welcome first, then login
      if (!hasToken) {
        if (!seenWelcome && path != '/welcome') return '/welcome';
        return isPublicRoute ? null : '/login';
      }

      // Logged in but on login page
      if (hasToken && path == '/login') {
        final user = authState.user;
        if (user != null && !user.isProfileComplete) return '/profile-setup';
        return '/home';
      }

      // Logged in with incomplete profile, trying to enroll in a course or
      // batch (which needs the student's class/school/guardian info) →
      // send to profile-setup first, remembering where to resume after.
      final isGatedRoute =
          path.startsWith('/enroll/') || path.startsWith('/enroll-batch/');
      if (hasToken && isGatedRoute) {
        final user = authState.user;
        if (user != null && !user.isProfileComplete) {
          ref.read(pendingGatedRouteProvider.notifier).state = (
            state.uri.toString(),
            state.extra,
          );
          return '/profile-setup';
        }
      }
      return null;
    },
  );
});
