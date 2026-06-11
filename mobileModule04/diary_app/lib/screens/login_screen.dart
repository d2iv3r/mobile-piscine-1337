import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'diary_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        _navigateToDiary();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithGitHub();
      if (result != null && mounted) {
        _navigateToDiary();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDiary() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Center(child: Text('Welcome back, User!', style: TextStyle(fontSize: 24))),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D52),
                  Color(0xFF4CAF82),
                  Color(0xFF81C784),
                ],
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo ──────────────────────────────────────────
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.book_rounded,
                            size: 48,
                            color: Color(0xFF2E7D52),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Title ─────────────────────────────────────────
                        const Text(
                          'Welcome to your\nDiary',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your thoughts, safely stored.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ── Auth card ─────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Sign in to continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose your preferred sign-in method',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Error message ──────────────────────────
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFEF9A9A),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Color(0xFFD32F2F),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFD32F2F),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ── Google button ──────────────────────────
                              _SignInButton(
                                onPressed: _isLoading ? null : _handleGoogleSignIn,
                                isLoading: _isLoading,
                                icon: _GoogleIcon(),
                                label: 'Continue with Google',
                                backgroundColor: const Color(0xFFF8F9FA),
                                textColor: const Color(0xFF1A1A2E),
                                borderColor: const Color(0xFFE0E0E0),
                              ),
                              const SizedBox(height: 12),

                              // ── GitHub button ──────────────────────────
                              _SignInButton(
                                onPressed: _isLoading ? null : _handleGitHubSignIn,
                                isLoading: _isLoading,
                                icon: const _GitHubIcon(),
                                label: 'Continue with GitHub',
                                backgroundColor: const Color(0xFF24292E),
                                textColor: Colors.white,
                                borderColor: const Color(0xFF24292E),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          'By signing in, you agree to keep your\nthoughts private and secure.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sign-in Button Widget ────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _SignInButton({
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google Icon (SVG-like using CustomPaint) ─────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Simplified Google "G" using arcs
    final center = Offset(s / 2, s / 2);
    final radius = s * 0.46;

    // Blue arc (right side)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.3,
      1.9,
      false,
      paint..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.18
        ..strokeCap = StrokeCap.butt,
    );

    // Red arc (top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.5,
      1.1,
      false,
      paint,
    );

    // Yellow arc (bottom left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.3,
      1.2,
      false,
      paint,
    );

    // Green arc (bottom right to right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.6,
      0.72,
      false,
      paint,
    );

    // Horizontal bar of "G"
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(s * 0.48, s * 0.38, s * 0.52, s * 0.22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── GitHub Icon ──────────────────────────────────────────────────────────────

class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.code, color: Colors.white, size: 20);
  }
}