import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import 'cliente_view.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const _pink = Color(0xFFE8609A);
  static const _pinkBorder = Color(0xFFEDA0C0);
  static const _pinkFill = Color(0xFFFFF0F6);
  static const _grey = Color(0xFF888888);
  static const _dark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _documentoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Brillo suave superior derecho
            Positioned(
              top: -80,
              right: -80,
              child: _softGlow(300, Colors.white.withValues(alpha: 0.25)),
            ),
            // Brillo suave izquierdo
            Positioned(
              top: 20,
              left: -100,
              child: _softGlow(260, Colors.white.withValues(alpha: 0.18)),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        // Botón back
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Crear tu cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Logo pequeño
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFDDEE), Color(0xFFE060A0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD65391).withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
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
                      ],
                    ),
                  ),
                  // Card blanca que ocupa el resto
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título
                            Row(
                              children: [
                                Text(
                                  'Únete a nosotras',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.favorite_border_rounded,
                                    color: Color(0xFFF090B8), size: 24),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Crea tu cuenta para empezar a comprar',
                              style: TextStyle(color: _grey, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            // Nombre
                            _pinkInput(
                              controller: _nombreController,
                              hint: 'Nombre Completo',
                              icon: Icons.person_outline_rounded,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))
                              ],
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 14),
                            // Email
                            _pinkInput(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            // Teléfono
                            _pinkInput(
                              controller: _telefonoController,
                              hint: 'Teléfono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 14),
                            // Documento
                            _pinkInput(
                              controller: _documentoController,
                              hint: 'Número de Documento',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 14),
                            // Contraseña
                            _pinkInputPassword(
                              controller: _passwordController,
                              hint: 'Contraseña',
                              obscure: _obscurePassword,
                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 14),
                            // Confirmar contraseña
                            _pinkInputPassword(
                              controller: _confirmPasswordController,
                              hint: 'Confirmar Contraseña',
                              obscure: _obscureConfirm,
                              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            const SizedBox(height: 16),
                            // Términos
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.shield_outlined,
                                    color: _pink.withValues(alpha: 0.7), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                          color: _grey, fontSize: 12),
                                      children: [
                                        TextSpan(
                                            text: 'Al crear una cuenta, aceptas nuestros '),
                                        TextSpan(
                                          text: 'Términos y Condiciones',
                                          style: TextStyle(
                                              color: _pink,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(text: ' y '),
                                        TextSpan(
                                          text: 'Política de Privacidad.',
                                          style: TextStyle(
                                              color: _pink,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Error
                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => auth.error != null
                                  ? _errorBox(auth.error!)
                                  : const SizedBox.shrink(),
                            ),
                            // Botón Crear Cuenta
                            _createButton(),
                            const SizedBox(height: 20),
                            // Divider
                            _divider('o continúa con'),
                            const SizedBox(height: 20),
                            // ¿Ya tienes cuenta?
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('¿Ya tienes cuenta? ',
                                      style: TextStyle(color: _grey, fontSize: 14)),
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()),
                                    ),
                                    child: const Text(
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
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

  Widget _pinkInputPassword({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15, color: _dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _grey.withValues(alpha: 0.7), fontSize: 15),
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: _pink, size: 22),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _grey,
              size: 20,
            ),
            onPressed: onToggle,
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

  Widget _createButton() => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
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
                          'Crear Cuenta',
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

  Future<void> _handleRegister() async {
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _documentoController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      AppSnackBar.show(context, 'Por favor completa todos los campos', type: SnackType.error);
      return;
    }
    final pass = _passwordController.text;
    if (!RegExp(r'^(?=(.*\d){2})(?=.*[^a-zA-Z0-9\s]).{9,20}$').hasMatch(pass)) {
      AppSnackBar.show(context, 'La contraseña debe tener 9–20 caracteres, al menos 2 números y 1 carácter especial', type: SnackType.error);
      return;
    }
    if (pass != _confirmPasswordController.text) {
      AppSnackBar.show(context, 'Las contraseñas no coinciden', type: SnackType.error);
      return;
    }
    final fav = context.read<FavoritosProvider>();
    final notif = context.read<NotificationProvider>();
    final orders = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    setState(() => _isLoading = true);
    final ok = await auth.register(
      nombre: _nombreController.text,
      email: _emailController.text,
      telefono: _telefonoController.text,
      documento: _documentoController.text,
      password: pass,
      confirmPassword: _confirmPasswordController.text,
    );
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
        padding: const EdgeInsets.only(bottom: 12),
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

  Widget _divider(String label) => Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
          ),
          const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
        ],
      );
}
