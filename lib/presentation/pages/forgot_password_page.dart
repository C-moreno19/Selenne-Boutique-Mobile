import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'verify_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  static const _pink = Color(0xFFE8609A);
  static const _pinkBorder = Color(0xFFEDA0C0);
  static const _pinkFill = Color(0xFFFFF0F6);
  static const _grey = Color(0xFF888888);
  static const _dark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final email = _emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ingresa un correo válido'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    final ok = await auth.solicitarRecuperacion(email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VerifyCodePage(email: email),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Error al enviar el correo'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo: rosa arriba → blanco abajo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF07AB8),
              Color(0xFFFAD4E8),
              Colors.white,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Brillos suaves
            Positioned(
              top: -80,
              right: -80,
              child: _softGlow(300, Colors.white.withValues(alpha: 0.25)),
            ),
            Positioned(
              top: 30,
              left: -100,
              child: _softGlow(260, Colors.white.withValues(alpha: 0.18)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Zona superior (fondo rosa) ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        children: [
                          // Botón back
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Logo con anillo
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.35),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD65391)
                                      .withValues(alpha: 0.22),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFF0F8),
                                    Color(0xFFEE80C0),
                                    Color(0xFFD04898),
                                  ],
                                  stops: [0.0, 0.55, 1.0],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Image.asset(
                                'assets/icons/logo_selenne.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Título con estrella
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                'Recuperar Contraseña',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Positioned(
                                top: -8,
                                right: -20,
                                child: Text('✦',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Te ayudamos a recuperarla',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),

                    // ── Card blanca flotante ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD65391).withValues(alpha: 0.10),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título + ícono candado
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _pinkFill,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: _pinkBorder, width: 1.2),
                                ),
                                child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: _pink,
                                    size: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ingresa tu correo y te enviaremos un código para restablecerla.',
                            style: TextStyle(
                                color: _grey, fontSize: 14, height: 1.55),
                          ),
                          const SizedBox(height: 24),
                          // Campo email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15, color: _dark),
                            decoration: InputDecoration(
                              hintText: 'Correo electrónico',
                              hintStyle: TextStyle(
                                  color: _grey.withValues(alpha: 0.7),
                                  fontSize: 15),
                              prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: _pink,
                                  size: 22),
                              filled: true,
                              fillColor: _pinkFill,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: _pinkBorder)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: _pinkBorder, width: 1.2)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: _pink, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Botón Enviar Código
                          _sendButton(),
                          const SizedBox(height: 24),
                          // Divider con ícono
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFEEDDEE), thickness: 1)),
                              const SizedBox(width: 10),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _pinkFill,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _pinkBorder, width: 1.2),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _pink,
                                    size: 15),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFEEDDEE), thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Volver al login
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Volver al inicio de sesión',
                                style: TextStyle(
                                  color: _pink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendButton() => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSend,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ).copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _isLoading
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFF590BC), Color(0xFFD64E8A)],
                    ),
              color: _isLoading ? const Color(0xFFDDDDDD) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enviar Código',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.4),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      );

  Widget _softGlow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.white.withValues(alpha: 0.0)],
          ),
        ),
      );
}
