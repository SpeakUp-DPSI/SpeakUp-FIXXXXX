import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/auth_stepper.dart';

// ────────────────────────────────────────────────────────────────────────────
// RegisterScreen — Controller utama multi-step register
// ────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;

  // Form data yang dikumpulkan antar step
  String _selectedRole = 'Siswa';
  String _verificationMethod = 'email'; // 'email' | 'sms'
  bool _agreeTerms = false;

  // Controllers Step 1
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nisnCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nisnCtrl.dispose();
    _birthDateCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _goNext() => setState(() => _currentStep++);
  void _goBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _Step1DataDiri(
          key: const ValueKey(1),
          selectedRole: _selectedRole,
          onRoleChanged: (r) => setState(() => _selectedRole = r),
          nameCtrl: _nameCtrl,
          emailCtrl: _emailCtrl,
          phoneCtrl: _phoneCtrl,
          nisnCtrl: _nisnCtrl,
          birthDateCtrl: _birthDateCtrl,
          passwordCtrl: _passwordCtrl,
          confirmPasswordCtrl: _confirmPasswordCtrl,
          obscurePassword: _obscurePassword,
          obscureConfirm: _obscureConfirm,
          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
          onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
          agreeTerms: _agreeTerms,
          onAgreeChanged: (v) => setState(() => _agreeTerms = v ?? false),
          onNext: _goNext,
          onBack: _goBack,
        );
      case 2:
        return _Step2PilihMetode(
          key: const ValueKey(2),
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          selectedMethod: _verificationMethod,
          onMethodChanged: (m) => setState(() => _verificationMethod = m),
          onNext: _goNext,
          onBack: _goBack,
        );
      case 3:
        return _Step3InputOTP(
          key: const ValueKey(3),
          method: _verificationMethod,
          destination: _verificationMethod == 'email' ? _emailCtrl.text : _phoneCtrl.text,
          onVerified: _goNext,
          onBack: _goBack,
        );
      case 4:
        return _Step4Selesai(
          key: const ValueKey(4),
          onDone: () => context.go('/login'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 1 — Data Diri
// ────────────────────────────────────────────────────────────────────────────

class _Step1DataDiri extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, nisnCtrl,
      birthDateCtrl, passwordCtrl, confirmPasswordCtrl;
  final bool obscurePassword, obscureConfirm, agreeTerms;
  final VoidCallback onTogglePassword, onToggleConfirm;
  final ValueChanged<bool?> onAgreeChanged;
  final VoidCallback onNext, onBack;

  const _Step1DataDiri({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.nisnCtrl,
    required this.birthDateCtrl,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.agreeTerms,
    required this.onAgreeChanged,
    required this.onNext,
    required this.onBack,
  });

  static const _roles = [
    {'name': 'Siswa', 'icon': Icons.person_outline},
    {'name': 'Guru BK', 'icon': Icons.admin_panel_settings_outlined},
    {'name': 'Kepsek', 'icon': Icons.badge_outlined},
    {'name': 'Wali Murid', 'icon': Icons.people_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        _AuthAppBar(title: 'Buat Akun Baru', onBack: onBack),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper
                const AuthStepper(currentStep: 1),
                const SizedBox(height: 24),

                // Pilih Peran
                const _SectionTitle('Pilih Peran Anda'),
                const SizedBox(height: 12),
                Row(
                  children: _roles.map((role) {
                    final isSelected = selectedRole == role['name'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onRoleChanged(role['name'] as String),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary600 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary600 : AppTheme.neutral300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                role['icon'] as IconData,
                                color: isSelected ? Colors.white : AppTheme.neutral500,
                                size: 26,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role['name'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppTheme.neutral700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Form Fields
                _fieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: nameCtrl,
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                _fieldLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: emailCtrl,
                  hint: 'Masukkan email aktif',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                _fieldLabel('Nomor Telepon'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: phoneCtrl,
                  hint: 'Masukkan nomor telepon',
                  icon: Icons.phone_outlined,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                _fieldLabel('NISN / No. Identitas'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: nisnCtrl,
                  hint: 'Masukkan NISN / No. Identitas',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),

                _fieldLabel('Tanggal Lahir'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: birthDateCtrl,
                  hint: 'Pilih tanggal lahir',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2005),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      birthDateCtrl.text =
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    }
                  },
                ),
                const SizedBox(height: 14),

                _fieldLabel('Password'),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Buat password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.neutral400),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.neutral400,
                      ),
                      onPressed: onTogglePassword,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _fieldLabel('Konfirmasi Password'),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.neutral400),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.neutral400,
                      ),
                      onPressed: onToggleConfirm,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Lanjutkan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Syarat & Ketentuan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: agreeTerms,
                        onChanged: onAgreeChanged,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        activeColor: AppTheme.primary600,
                        side: const BorderSide(color: AppTheme.neutral300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: 'Saya menyetujui ',
                          style: TextStyle(fontSize: 12, color: AppTheme.neutral500),
                          children: [
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                  color: AppTheme.primary600,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: ' dan '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                  color: AppTheme.primary600,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sudah punya akun?
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(fontSize: 14, color: AppTheme.neutral500),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: AppTheme.primary600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Trust badges
                _buildTrustBadges(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? type,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.neutral400),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.neutral900,
        ),
      );

  Widget _buildTrustBadges() {
    const badges = [
      {'icon': Icons.lock_outline, 'label': 'Aman & Terlindungi'},
      {'icon': Icons.people_outline, 'label': 'Peran Sesuai Kebutuhan'},
      {'icon': Icons.flash_on_outlined, 'label': 'Proses Mudah & Cepat'},
      {'icon': Icons.verified_outlined, 'label': 'Privasi Terjaga'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.5,
      children: badges.map((b) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary100),
          ),
          child: Row(
            children: [
              Icon(b['icon'] as IconData,
                  color: AppTheme.primary600, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  b['label'] as String,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.neutral700,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 2 — Pilih Metode Verifikasi
// ────────────────────────────────────────────────────────────────────────────

class _Step2PilihMetode extends StatelessWidget {
  final String email, phone, selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onNext, onBack;

  const _Step2PilihMetode({
    super.key,
    required this.email,
    required this.phone,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthAppBar(title: 'Verifikasi Akun', onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthStepper(currentStep: 2),
                const SizedBox(height: 28),

                const _SectionTitle('Pilih Metode Verifikasi'),
                const SizedBox(height: 16),

                // Opsi Email
                _MethodCard(
                  icon: Icons.email_outlined,
                  iconColor: AppTheme.primary600,
                  iconBg: AppTheme.primary50,
                  title: 'Verifikasi via Email',
                  subtitle: 'Kami akan mengirimkan kode ke\n${email.isNotEmpty ? email : 'email@contoh.com'}',
                  selected: selectedMethod == 'email',
                  onTap: () => onMethodChanged('email'),
                ),
                const SizedBox(height: 12),

                // Opsi SMS
                _MethodCard(
                  icon: Icons.sms_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFD1FAE5),
                  title: 'Verifikasi via SMS',
                  subtitle: 'Kami akan mengirimkan kode ke\n${phone.isNotEmpty ? phone : '08xx-xxxx-xxxx'}',
                  selected: selectedMethod == 'sms',
                  onTap: () => onMethodChanged('sms'),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Kirim Kode Verifikasi',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: onBack,
                    child: const Text(
                      'Kembali ke Data Diri',
                      style: TextStyle(
                        color: AppTheme.primary600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary600 : AppTheme.neutral300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutral900)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.neutral500, height: 1.4)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppTheme.primary600 : AppTheme.neutral300,
                    width: selected ? 2 : 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary600,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 3 — Input OTP
// ────────────────────────────────────────────────────────────────────────────

class _Step3InputOTP extends StatefulWidget {
  final String method, destination;
  final VoidCallback onVerified, onBack;

  const _Step3InputOTP({
    super.key,
    required this.method,
    required this.destination,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<_Step3InputOTP> createState() => _Step3InputOTPState();
}

class _Step3InputOTPState extends State<_Step3InputOTP> {
  static const _otpLength = 5;
  final List<TextEditingController> _otpCtrl =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  int _secondsLeft = 300; // 5 menit
  Timer? _timer;
  bool _hasError = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpCtrl) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otp => _otpCtrl.map((c) => c.text).join();

  void _verify() {
    if (_otp.length < _otpLength) {
      setState(() => _hasError = true);
      return;
    }
    // Simulasi: kode benar jika semua digit sama (demo)
    if (_otp == '11111') {
      setState(() => _hasError = false);
      widget.onVerified();
    } else {
      setState(() => _hasError = true);
    }
  }

  void _resend() {
    setState(() {
      _isResending = true;
      _hasError = false;
      for (final c in _otpCtrl) { c.clear(); }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isResending = false);
        _startTimer();
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthAppBar(title: 'Verifikasi Akun', onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthStepper(currentStep: 2),
                const SizedBox(height: 28),

                // Ikon amplop
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_outlined,
                            size: 42, color: AppTheme.primary600),
                      ),
                      if (!_isResending)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        )
                      else
                        Positioned(
                          right: -4,
                          top: -4,
                          child: const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.primary600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    'Kode Verifikasi Terkirim!',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutral900),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Kami telah mengirimkan kode verifikasi ke ${widget.method == 'email' ? 'Email' : 'SMS'} Anda:',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppTheme.neutral500),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary200),
                    ),
                    child: Text(
                      widget.destination,
                      style: const TextStyle(
                          color: AppTheme.primary600,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Masukkan Kode Verifikasi',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral900),
                ),
                const SizedBox(height: 12),

                // OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_otpLength, (i) {
                    return SizedBox(
                      width: 52,
                      height: 60,
                      child: TextField(
                        controller: _otpCtrl[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutral900),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _hasError
                              ? const Color(0xFFFEE2E2)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError ? AppTheme.danger600 : AppTheme.neutral300,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError ? AppTheme.danger600 : AppTheme.neutral300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primary600, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && i < _otpLength - 1) {
                            _focusNodes[i + 1].requestFocus();
                          } else if (val.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          setState(() => _hasError = false);
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),

                // Timer
                Center(
                  child: Text(
                    'Kode akan kedaluarsa dalam $_timerLabel',
                    style: const TextStyle(fontSize: 13, color: AppTheme.neutral400),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Banner
                if (_hasError) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.danger600.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppTheme.danger600, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kode yang anda masukkan salah',
                            style: TextStyle(fontSize: 13, color: AppTheme.danger600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Info box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppTheme.neutral500, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pastikan kode yang Anda masukkan sudah benar sebelum memverifikasi.',
                          style: TextStyle(fontSize: 12, color: AppTheme.neutral600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Kirim ulang
                GestureDetector(
                  onTap: _secondsLeft == 0 ? _resend : null,
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 16, color: AppTheme.neutral500),
                      const SizedBox(width: 6),
                      const Text(
                        'Tidak menerima kode? ',
                        style: TextStyle(fontSize: 13, color: AppTheme.neutral500),
                      ),
                      Text(
                        'Kirim ulang kode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _secondsLeft == 0
                              ? AppTheme.primary600
                              : AppTheme.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Verifikasikan Sekarang',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: widget.onBack,
                    child: const Text(
                      'Kembali ke Pilih Metode',
                      style: TextStyle(
                        color: AppTheme.primary600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 4 — Selesai
// ────────────────────────────────────────────────────────────────────────────

class _Step4Selesai extends StatelessWidget {
  final VoidCallback onDone;

  const _Step4Selesai({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthAppBar(title: 'Pendaftaran Selesai', showBack: false, onBack: () {}),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const AuthStepper(currentStep: 3),
                const Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      size: 56, color: Color(0xFF059669)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Akun Berhasil Dibuat!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutral900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selamat datang di SpeakUp!\nAkun Anda telah berhasil diverifikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.neutral500, height: 1.5),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Masuk ke Akun',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ────────────────────────────────────────────────────────────────────────────

class _AuthAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final bool showBack;

  const _AuthAppBar({
    required this.title,
    required this.onBack,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppTheme.neutral700),
                onPressed: onBack,
              )
            else
              const SizedBox(width: 48),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary600,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.neutral900,
      ),
    );
  }
}
