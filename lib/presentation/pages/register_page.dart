import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import 'cliente_view.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const _pink = Color(0xFFE91E8C);
  static const _darkPink = Color(0xFFA3145F);
  static const _lightPink = Color(0xFFFF6FC8);
  static const _black = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF666666);
  static const _border = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, IconData icon,
          {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _grey, fontSize: 14),
        prefixIcon: Icon(icon, color: _grey, size: 20),
        suffixIcon: suffix,
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
          // Fondo degradado
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
              child: _circle(160, Colors.white.withOpacity(0.08))),
          Positioned(
              top: 50, left: -40,
              child: _circle(120, Colors.white.withOpacity(0.06))),
          // Contenido
          SafeArea(
            child: Column(
              children: [
                // Header compacto
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crea tu cuenta',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFD6EF), Color(0xFFE91E8C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/icons/logo_selenne.png',
                            fit: BoxFit.contain,
                          ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Únete a nosotras',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea tu cuenta para empezar a comprar',
                            style: TextStyle(color: _grey, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          // Nombre
                          TextField(
                            controller: _nombreController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDeco(
                                'Nombre Completo', Icons.person_outline),
                          ),
                          const SizedBox(height: 14),
                          // Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                _inputDeco('Email', Icons.email_outlined),
                          ),
                          const SizedBox(height: 14),
                          // Teléfono
                          TextField(
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration:
                                _inputDeco('Teléfono', Icons.phone_outlined),
                          ),
                          const SizedBox(height: 14),
                          // Contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDeco(
                              'Contraseña',
                              Icons.lock_outlined,
                              suffix: IconButton(
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
                          const SizedBox(height: 14),
                          // Confirmar contraseña
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: _inputDeco(
                              'Confirmar Contraseña',
                              Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _grey,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mínimo 6 caracteres',
                            style: TextStyle(
                                color: _grey.withOpacity(0.7),
                                fontSize: 11),
                          ),
                          // Error
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => auth.error != null
                                ? _errorBox(auth.error!)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 24),
                          // Botón
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => _primaryButton(
                              label: 'Crear Cuenta',
                              loading: _isLoading,
                              onPressed: () async {
                                final fav =
                                    context.read<FavoritosProvider>();
                                final notif =
                                    context.read<NotificationProvider>();
                                final orders =
                                    context.read<OrderProvider>();
                                final nav = Navigator.of(context);
                                if (_nombreController.text.trim().isEmpty ||
                                    _emailController.text.trim().isEmpty ||
                                    _passwordController.text.isEmpty ||
                                    _confirmPasswordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Por favor completa todos los campos'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (_passwordController.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('La contraseña debe tener mínimo 6 caracteres'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (_passwordController.text != _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Las contraseñas no coinciden'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _isLoading = true);
                                final ok = await auth.register(
                                  nombre: _nombreController.text,
                                  email: _emailController.text,
                                  telefono: _telefonoController.text,
                                  password: _passwordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
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
                                        builder: (_) => const ClienteView()),
                                    (r) => false,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Link a login
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes cuenta? ',
                                  style:
                                      TextStyle(color: _grey, fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()),
                                  ),
                                  child: Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _pink,
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

  Widget _errorBox(String msg) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD64545).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFFD64545).withOpacity(0.4)),
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
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      );
}
