import 'package:flutter/material.dart';

/// A NavigatorObserver for route change logging and analytics.
class AppRouteObserver extends NavigatorObserver {
  static final AppRouteObserver instance = AppRouteObserver._();
  AppRouteObserver._();

  final List<String> _routeStack = [];

  List<String> get routeStack => List.unmodifiable(_routeStack);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      _routeStack.add(name);
      debugPrint('[Router] PUSH: $name (stack: $_routeStack)');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      _routeStack.remove(name);
      debugPrint('[Router] POP: $name (stack: $_routeStack)');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      _routeStack.remove(name);
      debugPrint('[Router] REMOVE: $name (stack: $_routeStack)');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newName = newRoute?.settings.name;
    final oldName = oldRoute?.settings.name;
    if (newName != null) {
      if (oldName != null) {
        final idx = _routeStack.indexOf(oldName);
        if (idx >= 0) _routeStack[idx] = newName;
      } else {
        _routeStack.add(newName);
      }
      debugPrint('[Router] REPLACE: $oldName -> $newName (stack: $_routeStack)');
    }
  }
}
