import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreenWeb extends ConsumerStatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  ConsumerState<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends ConsumerState<LoginScreenWeb> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Masuk Ke Akun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary600,
                    ),
                  ),
                  const SizedBox(height: 56),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Masukkan email, NIS, atau NIP Anda',
                      hintStyle: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                      contentPadding: EdgeInsets.only(bottom: 8),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryDark),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryDark),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primary600, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _handleLogin(),
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi Anda',
                      hintStyle: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 8),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryDark),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryDark),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primary600, width: 2),
                      ),
                      suffixIconConstraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.primaryDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              activeColor: AppTheme.primary600,
                              side: const BorderSide(color: AppTheme.primaryDark, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ingat saya',
                            style: TextStyle(
                              fontSize: 13, 
                              color: AppTheme.primaryDark, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            color: AppTheme.primaryDark, 
                            fontSize: 13, 
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: AppTheme.primary600,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi email dan kata sandi')),
      );
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);

    if (mounted) {
      final state = ref.read(authProvider);
      if (state is AuthSuccess) {
        context.go('/dashboard');
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppTheme.danger600,
          ),
        );
      }
    }
  }
}
