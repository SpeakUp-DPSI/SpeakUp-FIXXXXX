import 'package:flutter/material.dart';
import 'register_screen_web.dart';
import 'register_screen_mobile.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width > 600) {
      return const RegisterScreenWeb();
    }
    return const RegisterScreenMobile();
  }
}
