import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/home_screen.dart';
import 'register_page.dart';

const _green900 = Color(0xFF0D3B2E);
const _green700 = Color(0xFF134D3F);
const _green500 = Color(0xFF1A6B57);
const _green300 = Color(0xFF52A88A);
const _cream = Color(0xFFF5F0E8);
const _gold = Color(0xFFD4A853);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();

    _loadRemembered();
  }


  Future<void> _loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;
    if (!remember) return;

    final savedEmail = prefs.getString('rememberedEmail') ?? '';
    final savedPass  = prefs.getString('rememberedPassword') ?? '';

    if (savedEmail.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailCtrl.text = savedEmail;
        _passCtrl.text  = savedPass;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final prefs    = await SharedPreferences.getInstance();
      final usersStr = prefs.getString('users');
      final users    = usersStr != null
          ? jsonDecode(usersStr) as Map<String, dynamic>
          : <String, dynamic>{};

      final email = _emailCtrl.text.trim();

      if (!users.containsKey(email)) {
        _snack('No account found for that email');
        setState(() => _loading = false);
        return;
      }

      final user   = users[email] as Map<String, dynamic>?;
      final stored = user?['password'] as String?;

      if (stored == null || stored != _passCtrl.text) {
        _snack('Incorrect password');
        setState(() => _loading = false);
        return;
      }

      await prefs.setBool('loggedIn', true);
      await prefs.setString('currentUser', email);
      await prefs.setString('name', user!['name'] as String? ?? '');
      await prefs.setString('email', email);

      if (_rememberMe) {
        await prefs.setBool('rememberMe', true);
        await prefs.setString('rememberedEmail',    email);
        await prefs.setString('rememberedPassword', _passCtrl.text);
      } else {
        await prefs.setBool('rememberMe', false);
        await prefs.remove('rememberedEmail');
        await prefs.remove('rememberedPassword');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      _snack('Something went wrong. Please try again.');
      setState(() => _loading = false);
    }
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
    _slideCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: _GlowCircle(size: size.width * 0.9, color: _green500),
          ),
          Positioned(
            bottom: size.height * 0.35,
            left: -size.width * 0.25,
            child: _GlowCircle(size: size.width * 0.6, color: _green700),
          ),

          Positioned(
            top: size.height * 0.06,
            left: 24,
            child: _LeafDecor(rotate: -0.3),
          ),
          Positioned(
            top: size.height * 0.12,
            right: 20,
            child: _LeafDecor(rotate: 0.5, size: 28),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _gold.withOpacity(0.4), width: 1),
                                ),
                                child: const Text('🌿',
                                    style: TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'EcoTrack',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: _cream,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome\nback.',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: _cream,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Continue your sustainability journey',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: _cream.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

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
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sign in',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: _green900,
                                    )),

                                const SizedBox(height: 6),
                                Text('Enter your credentials to continue',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: Colors.black45)),

                                const SizedBox(height: 28),

                                _EcoField(
                                  controller: _emailCtrl,
                                  hint: 'Email address',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                  v!.isEmpty ? 'Email required' : null,
                                ),

                                const SizedBox(height: 16),

                                _EcoField(
                                  controller: _passCtrl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscure,
                                  validator: (v) => v!.length < 6
                                      ? 'Min 6 characters'
                                      : null,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: _green500,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(
                                                () => _rememberMe = v ?? false),
                                        activeColor: _green700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Remember me',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: Colors.black54)),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _green700,
                                      disabledBackgroundColor:
                                      _green700.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
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
                                      'Sign In',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(color: Colors.black12)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text('or',
                                          style: GoogleFonts.dmSans(
                                              color: Colors.black38,
                                              fontSize: 12)),
                                    ),
                                    Expanded(
                                        child: Divider(color: Colors.black12)),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Center(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const RegisterPage()),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            color: Colors.black54),
                                        children: [
                                          const TextSpan(
                                              text: "Don't have an account? "),
                                          TextSpan(
                                            text: 'Create one',
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
          ),
        ],
      ),
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
        hintStyle:
        GoogleFonts.dmSans(fontSize: 15, color: Colors.black38),
        prefixIcon:
        Icon(icon, color: _green500, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _green500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: Colors.red.shade300, width: 1),
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
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
      ),
    );
  }
}

class _LeafDecor extends StatelessWidget {
  final double rotate;
  final double size;
  const _LeafDecor({required this.rotate, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate,
      child: Text('🍃', style: TextStyle(fontSize: size)),
    );
  }
}