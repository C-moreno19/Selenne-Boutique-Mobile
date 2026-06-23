import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import 'new_password_page.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _tokenController = TextEditingController();
  int _seconds = 59;
  Timer? _timer;
  bool _isResending = false;

  static const _pink = Color(0xFFD65391);
  static const _darkPink = Color(0xFF9E3A6B);
  static const _lightPink = Color(0xFFE8A0C0);
  static const _black = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF666666);
  static const _border = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tokenController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        t.cancel();
      }
    });
  }

  void _continuar() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código del correo')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewPasswordPage(token: token)),
    );
  }

  Future<void> _reenviar() async {
    setState(() => _isResending = true);
    await context.read<AuthProvider>().solicitarRecuperacion(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado a tu correo')),
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                        'Revisa tu correo',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Ingresa el código',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Copia el código que recibiste en el correo y pégalo aquí.',
                            style: TextStyle(
                                color: _grey, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _tokenController,
                            decoration: InputDecoration(
                              labelText: 'Código de recuperación',
                              hintText: 'Pega aquí el código del correo',
                              labelStyle:
                                  TextStyle(color: _grey, fontSize: 14),
                              prefixIcon: const Icon(
                                  Icons.vpn_key_outlined,
                                  color: _grey,
                                  size: 20),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: _border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: _border)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: _pink, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'El código llegó en el cuerpo del correo. Cópialo completo y pégalo aquí.',
                            style: TextStyle(
                                color: _grey.withValues(alpha: 0.7),
                                fontSize: 12),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _continuar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: const Text('Continuar',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Timer + reenviar
                          Center(
                            child: _isResending
                                ? const CircularProgressIndicator(
                                    color: _pink)
                                : Column(
                                    children: [
                                      if (_seconds > 0)
                                        Text(
                                          'Reenviar código en ${_seconds}s',
                                          style: TextStyle(
                                              color: _grey, fontSize: 13),
                                        )
                                      else
                                        TextButton(
                                          onPressed: _reenviar,
                                          child: Text(
                                            '¿No recibiste el código? Reenviar',
                                            style: TextStyle(
                                              color: _pink,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
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
