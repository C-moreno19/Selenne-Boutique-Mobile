import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login_page.dart';

class PasswordChangedPage extends StatefulWidget {
  const PasswordChangedPage({super.key});

  @override
  State<PasswordChangedPage> createState() => _PasswordChangedPageState();
}

class _PasswordChangedPageState extends State<PasswordChangedPage> {
  int _seconds = 4;
  Timer? _timer;

  static const _pink = Color(0xFFD65391);
  static const _darkPink = Color(0xFF9E3A6B);
  static const _lightPink = Color(0xFFE8A0C0);
  static const _black = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lightPink, _pink, _darkPink],
              ),
            ),
          ),
          Positioned(
              top: -50, right: -30,
              child: _circle(160, Colors.white.withValues(alpha: 0.08))),
          Positioned(
              top: 60, left: -40,
              child: _circle(110, Colors.white.withValues(alpha: 0.06))),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 24, 32),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFD6EF), Color(0xFFD65391)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/icons/logo_selenne.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Contraseña Actualizada',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todo listo',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tarjeta blanca
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ícono de éxito
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEF7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: _pink.withValues(alpha: 0.3),
                                    width: 2),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: _pink,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            '¡Contraseña Cambiada!',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tu contraseña ha sido actualizada con éxito. Ya puedes iniciar sesión con tu nueva contraseña.',
                            style: TextStyle(
                                color: _grey, fontSize: 14, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _navigateToLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Redirigiendo en $_seconds segundos...',
                              style:
                                  TextStyle(color: _grey, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
