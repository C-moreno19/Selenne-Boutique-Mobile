import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import 'cliente_view.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const _pink = Color(0xFFE8609A);
  static const _pinkBorder = Color(0xFFEDA0C0);
  static const _pinkFill = Color(0xFFFFF0F6);
  static const _grey = Color(0xFF888888);
  static const _dark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo: degradado oscuro de marca arriba → blanco abajo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A2029),
              Color(0xFF6B3348),
              Colors.white,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Brillo suave superior derecho
            Positioned(
              top: -100,
              right: -100,
              child: _softGlow(380, Colors.white.withValues(alpha: 0.28)),
            ),
            // Brillo suave superior izquierdo
            Positioned(
              top: 60,
              left: -120,
              child: _softGlow(300, Colors.white.withValues(alpha: 0.18)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 44),
                      // Logo con anillo blanco elegante
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.35),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD65391).withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFF0F8), Color(0xFFEE80C0), Color(0xFFD04898)],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/icons/logo_selenne.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline en cursiva elegante
                      Text(
                        'Acordate de sentirte única  ✦',
                        style: GoogleFonts.dancingScript(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD65391).withValues(alpha: 0.12),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '¡Bienvenida!',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.favorite_border_rounded,
                                    color: Color(0xFFF090B8), size: 26),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Inicia sesión para continuar',
                              style: TextStyle(color: _grey, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            _pinkInput(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _pinkInputPassword(),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordPage()),
                                ),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: _pink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => auth.error != null
                                  ? _errorBox(auth.error!)
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 18),
                            _loginButton(),
                            const SizedBox(height: 18),
                            _divider(),
                            const SizedBox(height: 18),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage()),
                              ),
                              icon: const Icon(Icons.person_outline_rounded,
                                  color: _pink, size: 20),
                              label: const Text(
                                'Crear Cuenta Nueva',
                                style: TextStyle(
                                    color: _dark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _pinkBorder, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.security_rounded,
                                color: Color(0xFFE8609A), size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tus datos están protegidos',
                            style: TextStyle(
                                color: Color(0xFF888888), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _pinkInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: _dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _grey.withValues(alpha: 0.7), fontSize: 15),
          prefixIcon: Icon(icon, color: _pink, size: 22),
          filled: true,
          fillColor: _pinkFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkBorder, width: 1.2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pink, width: 2)),
        ),
      );

  Widget _pinkInputPassword() => TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15, color: _dark),
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: TextStyle(color: _grey.withValues(alpha: 0.7), fontSize: 15),
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: _pink, size: 22),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _grey,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: _pinkFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkBorder, width: 1.2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pink, width: 2)),
        ),
      );

  Widget _loginButton() => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      colors: [
                        Color(0xFF2D1B24),
                        Color(0xFF7A3350),
                        Color(0xFFD65391),
                      ],
                    ),
              color: _isLoading ? const Color(0xFFDDDDDD) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4),
                    ),
            ),
          ),
        ),
      );

  Future<void> _handleLogin() async {
    final fav = context.read<FavoritosProvider>();
    final notif = context.read<NotificationProvider>();
    final orders = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      AppSnackBar.show(context, 'Ingresa tu email y contraseña', type: SnackType.error);
      return;
    }
    setState(() => _isLoading = true);
    final ok = await auth.login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (ok && mounted) {
      final u = auth.usuarioActual;
      fav.sincronizarConAPI();
      notif.cargarNotificaciones();
      if (u != null) orders.cargarPedidos(u.usuarioID);
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ClienteView()),
        (r) => false,
      );
    }
  }

  Widget _errorBox(String msg) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD64545).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD64545).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFD64545), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(msg,
                    style: const TextStyle(color: Color(0xFFD64545), fontSize: 13)),
              ),
            ],
          ),
        ),
      );

  Widget _divider() => const Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('o', style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
          ),
          Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
        ],
      );
}
