/// App route name constants
abstract class AppRoutes {
  // ── Onboarding ──────────────────────────────────────────
  static const String onboarding = '/onboarding';

  // ── Auth ────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ── Main Shell ──────────────────────────────────────────
  static const String home = '/home';
  static const String explore = '/explore';
  static const String community = '/community';
  static const String services = '/services';
  static const String nearby = '/nearby';

  // ── Feature Routes ──────────────────────────────────────
  static const String amenityDetail = '/amenity/:id';
  static const String eventDetail = '/event/:id';
  static const String newsDetail = '/news/:id';
  static const String jobDetail = '/job/:id';
  static const String postDetail = '/post/:id';
  static const String reportIssue = '/report-issue';
  static const String emergency = '/emergency';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
}
