import 'package:flutter/material.dart';
import 'login_screen_web.dart';
import 'login_screen_mobile.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width > 600) {
      return const LoginScreenWeb();
    }
    return const LoginScreenMobile();
  }
}
