import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized navigation service.
/// All navigation should ideally go through this service to ensure
/// consistent behavior and single source of truth.
class NavigationService {
  NavigationService._();

  static final NavigationService instance = NavigationService._();
  static NavigationService get I => instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a route (replaces current stack).
  void go(String path, {Object? extra}) {
    final ctx = context;
    if (ctx != null) ctx.go(path, extra: extra);
  }

  /// Push a route onto the stack.
  void push(String path, {Object? extra}) {
    final ctx = context;
    if (ctx != null) ctx.push(path, extra: extra);
  }

  /// Push a named route.
  void pushNamed(String name, {Object? extra}) {
    final ctx = context;
    if (ctx != null) ctx.pushNamed(name, extra: extra);
  }

  /// Pop the current route.
  void pop() {
    final ctx = context;
    if (ctx != null) ctx.pop();
  }

  /// Replace the current route.
  void replace(String path, {Object? extra}) {
    final ctx = context;
    if (ctx != null) ctx.pushReplacement(path, extra: extra);
  }

  /// Can we pop?
  bool canPop() {
    final ctx = context;
    if (ctx == null) return false;
    return ctx.canPop();
  }
}
