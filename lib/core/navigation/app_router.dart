import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/amenities/screens/explore_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/events/models/event_model.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/community/screens/post_detail_screen.dart';
import '../../features/community/screens/user_profile_screen.dart';
import '../../features/community/models/post_model.dart';
import '../../features/jobs/screens/jobs_screen.dart';
import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/jobs/models/job_model.dart';
import '../../features/reporting/screens/report_issue_screen.dart';
import '../../features/reporting/screens/my_reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/news/screens/news_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/news/models/news_model.dart';
import '../../shared/widgets/cl_bottom_nav.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (isAuthenticated && (isOnAuth || isOnOnboarding)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),

      // ── Full-screen routes ─────────────────────────
      GoRoute(
          path: '/event/:id',
          builder: (_, s) => EventDetailScreen(event: s.extra as EventModel)),
      GoRoute(
          path: '/post/:id',
          builder: (_, s) => PostDetailScreen(post: s.extra as PostModel)),
      GoRoute(
          path: '/job/:id',
          builder: (_, s) => JobDetailScreen(job: s.extra as JobModel)),
      GoRoute(
          path: '/news/:id',
          builder: (_, s) => NewsDetailScreen(article: s.extra as NewsModel)),

      // ── User profile (tap avatar on feed) ─────────
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final userId = state.pathParameters['id'] ?? '';
          return UserProfileScreen(
            userId: userId,
            userName: extra['userName'] as String?,
            userInitials: extra['userInitials'] as String?,
          );
        },
      ),

      GoRoute(
          path: AppRoutes.reportIssue,
          builder: (_, __) => const ReportIssueScreen()),
      GoRoute(path: '/my-reports', builder: (_, __) => const MyReportsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: AppRoutes.editProfile,
          builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),

      // ── Main Shell ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.explore,
                builder: (_, __) => const ExploreScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.community,
                builder: (_, __) => const CommunityScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.services,
                builder: (_, __) => const JobsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.nearby,
                builder: (_, __) => const EventsScreen()),
          ]),
        ],
      ),
    ],
  );
});
