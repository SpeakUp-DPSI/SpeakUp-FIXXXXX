import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import 'app_routes.dart';

/// Redirects unauthenticated users to login.
String? authGuard(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authProvider);
  final isAuthenticated = authState is AuthSuccess;

  final path = state.uri.toString();
  final publicPaths = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
  };
  final isPublicPath = publicPaths.contains(path);

  if (!isAuthenticated && !isPublicPath) {
    return AppRoutes.login;
  }
  if (isAuthenticated && isPublicPath) {
    return AppRoutes.dashboard;
  }
  return null;
}

/// Redirects authenticated users away from guest-only pages (login, register).
String? guestGuard(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authProvider);
  final isAuthenticated = authState is AuthSuccess;

  if (isAuthenticated) {
    return AppRoutes.dashboard;
  }
  return null;
}

/// Restricts access to routes based on user roles.
/// Usage: pass [allowedRoles] to the route's extra or use in redirect.
String? roleGuard(BuildContext context, GoRouterState state, List<String> allowedRoles) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authProvider);

  if (authState is! AuthSuccess) {
    return AppRoutes.login;
  }

  final userRoles = authState.user.roles.map((r) => r.toLowerCase()).toList();
  final hasAccess = allowedRoles.any((role) => userRoles.contains(role));

  if (!hasAccess) {
    return AppRoutes.dashboard;
  }
  return null;
}

/// Extracts the user's primary role from auth state.
String getUserRole(WidgetRef ref) {
  final authState = ref.read(authProvider);
  if (authState is AuthSuccess) {
    if (authState.user.roles.isNotEmpty) {
      return authState.user.roles.first.toLowerCase();
    }
  }
  return 'siswa';
}

/// Checks if the user has a specific role.
bool hasRole(WidgetRef ref, String role) {
  final userRole = getUserRole(ref);
  return userRole.contains(role.toLowerCase());
}
