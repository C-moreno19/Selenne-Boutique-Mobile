import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import 'cliente_view.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const _pink = Color(0xFFE91E8C);
  static const _darkPink = Color(0xFFA3145F);
  static const _lightPink = Color(0xFFFF6FC8);
  static const _black = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF666666);
  static const _border = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _grey, fontSize: 14),
        prefixIcon: Icon(icon, color: _grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _pink, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD64545))),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo degradado ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lightPink, _pink, _darkPink],
              ),
            ),
          ),
          // Círculos decorativos (efecto satin)
          Positioned(
            top: -60,
            right: -40,
            child: _circle(180, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            top: 60,
            left: -50,
            child: _circle(140, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            top: 120,
            right: 20,
            child: _circle(80, Colors.white.withOpacity(0.1)),
          ),
          // ── Contenido ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Branding
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFD6EF), Color(0xFFE91E8C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
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
                      const SizedBox(height: 8),
                      Text(
                        'Descubre tu estilo único',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Tarjeta blanca ─────────────────────────────────
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
                            'Bienvenida',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicia sesión para continuar',
                            style:
                                TextStyle(color: _grey, fontSize: 14),
                          ),
                          const SizedBox(height: 28),
                          // Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                _inputDeco('Email', Icons.email_outlined),
                          ),
                          const SizedBox(height: 16),
                          // Contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDeco(
                                    'Contraseña', Icons.lock_outlined)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _grey,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Olvidé contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordPage()),
                              ),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                    color: _pink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          // Error
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => auth.error != null
                                ? _errorBox(auth.error!)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 20),
                          // Botón login (negro como en web)
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => _primaryButton(
                              label: 'Iniciar Sesión',
                              loading: _isLoading,
                              onPressed: () async {
                                final fav =
                                    context.read<FavoritosProvider>();
                                final notif =
                                    context.read<NotificationProvider>();
                                final orders =
                                    context.read<OrderProvider>();
                                final nav = Navigator.of(context);
                                setState(() => _isLoading = true);
                                if (_emailController.text.trim().isEmpty ||
                                    _passwordController.text.isEmpty) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ingresa tu email y contraseña'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final ok = await auth.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                setState(() => _isLoading = false);
                                if (ok && mounted) {
                                  final u = auth.usuarioActual;
                                  fav.sincronizarConAPI();
                                  notif.cargarNotificaciones();
                                  if (u != null) {
                                    orders.cargarPedidos(u.usuarioID);
                                  }
                                  nav.pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ClienteView()),
                                    (r) => false,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          _divider(),
                          const SizedBox(height: 20),
                          // Botón registro (outline)
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _black,
                              side: const BorderSide(
                                  color: _border, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                            child: const Text(
                              'Crear Cuenta Nueva',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
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
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );

  Widget _errorBox(String msg) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD64545).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: const Color(0xFFD64545).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFD64545), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        color: Color(0xFFD64545), fontSize: 13)),
              ),
            ],
          ),
        ),
      );

  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _divider() => Row(
        children: [
          Expanded(
              child: Container(height: 1, color: const Color(0xFFE8E8E8))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('O',
                style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
          ),
          Expanded(
              child: Container(height: 1, color: const Color(0xFFE8E8E8))),
        ],
      );
}
