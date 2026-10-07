import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

const _green900 = Color(0xFF0D3B2E);
const _green700 = Color(0xFF134D3F);
const _green500 = Color(0xFF1A6B57);
const _cream = Color(0xFFF5F0E8);
const _gold = Color(0xFFD4A853);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agree = false;
  bool _loading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      _snack('Please accept the Terms of Service to continue');
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString('users');
    final users =
    usersStr != null ? jsonDecode(usersStr) as Map<String, dynamic> : {};

    final email = _emailCtrl.text.trim();
    if (users.containsKey(email)) {
      _snack('An account with this email already exists');
      setState(() => _loading = false);
      return;
    }

    users[email] = {
      'name': _nameCtrl.text.trim(),
      'password': _passCtrl.text,
    };

    await prefs.setString('users', jsonEncode(users));
    setState(() => _loading = false);

    _snack('Account created! Welcome to EcoTrack 🌿');

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: _green700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _green900,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.2,
            left: -size.width * 0.1,
            child: _GlowCircle(size: size.width * 0.7, color: _green500),
          ),
          Positioned(
            top: size.height * 0.04,
            right: 18,
            child: const _LeafDecor(rotate: 0.4),
          ),
          Positioned(
            top: size.height * 0.10,
            left: 22,
            child: const _LeafDecor(rotate: -0.6, size: 26),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: _gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _gold.withOpacity(0.4), width: 1),
                              ),
                              child: const Text('🌿',
                                  style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'EcoTrack',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _cream,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join the\nmovement.',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: _cream,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start your eco-conscious journey today',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: _cream.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Create Account',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _green900,
                                  )),

                              const SizedBox(height: 22),

                              _FieldLabel('Full Name'),
                              _EcoField(
                                controller: _nameCtrl,
                                hint: 'Your name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                v!.isEmpty ? 'Name required' : null,
                              ),

                              const SizedBox(height: 14),

                              _FieldLabel('Email'),
                              _EcoField(
                                controller: _emailCtrl,
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                v!.contains('@') ? null : 'Invalid email',
                              ),

                              const SizedBox(height: 14),

                              _FieldLabel('Password'),
                              _EcoField(
                                controller: _passCtrl,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePass,
                                validator: (v) => v!.length < 8
                                    ? 'Minimum 8 characters'
                                    : null,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: _green500,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass),
                                ),
                              ),

                              const SizedBox(height: 14),

                              _FieldLabel('Confirm Password'),
                              _EcoField(
                                controller: _confirmCtrl,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscureConfirm,
                                validator: (v) => v != _passCtrl.text
                                    ? 'Passwords do not match'
                                    : null,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: _green500,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                  _obscureConfirm = !_obscureConfirm),
                                ),
                              ),

                              const SizedBox(height: 16),

                              GestureDetector(
                                onTap: () =>
                                    setState(() => _agree = !_agree),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _agree,
                                        onChanged: (v) => setState(
                                                () => _agree = v ?? false),
                                        activeColor: _green700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: Colors.black54,
                                            height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green700,
                                    disabledBackgroundColor:
                                    _green700.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : Text(
                                    'Create Account',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: Colors.black54),
                                      children: [
                                        const TextSpan(
                                            text: 'Already have an account? '),
                                        TextSpan(
                                          text: 'Sign in',
                                          style: GoogleFonts.dmSans(
                                            color: _green700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _green900)),
    );
  }
}

class _EcoField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _EcoField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(fontSize: 15, color: _green900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 15, color: Colors.black38),
        prefixIcon: Icon(icon, color: _green500, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _green500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.18),
    ),
  );
}

class _LeafDecor extends StatelessWidget {
  final double rotate;
  final double size;
  const _LeafDecor({required this.rotate, this.size = 34});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: rotate,
    child: Text('🍃', style: TextStyle(fontSize: size)),
  );
}