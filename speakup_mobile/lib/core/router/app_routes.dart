abstract class AppRoutes {
  AppRoutes._();

  // ─── Public (unauthenticated) ────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // ─── Shell branches (inside StatefulShellRoute) ──────────────────────────
  static const dashboard = '/dashboard';
  static const reports = '/reports';
  static const mediations = '/mediations';
  static const notifications = '/notifications';
  static const profile = '/profile';

  // ─── Report feature ──────────────────────────────────────────────────────
  static const reportCreate = '/report/create';
  static const reportReview = '/report/review';
  static const reportSuccess = '/report/success';
  static String reportDetail(int id) => '/report/$id';
  static String reportCreateMediation(int id) => '/report/$id/create-mediation';
  static String reportCreateFollowUp(int id) => '/report/$id/create-follow-up';

  // ─── Mediation feature ───────────────────────────────────────────────────
  static String mediationDetail(int id) => '/mediation/$id';
  static const mediationChat = '/mediation-chat';

  // ─── Follow-up feature ───────────────────────────────────────────────────
  static String followUpDetail(int id) => '/followup/$id';

  // ─── Profile feature ─────────────────────────────────────────────────────
  static const profileEdit = '/profile/edit';
  static const profileChangePassword = '/profile/change-password';
  static const profileSettings = '/profile/settings';

  // ─── Admin feature ───────────────────────────────────────────────────────
  static const auditLogs = '/audit-logs';
  static const userManagement = '/users';
  static const masterData = '/master-data';
}
