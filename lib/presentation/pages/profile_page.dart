import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../routes/app_routes.dart';

const _pink = Color(0xFFD65391);
const _darkPink = Color(0xFF9E3A6B);
const _lightPink = Color(0xFFE8A0C0);
const _black = Color(0xFF1A1A1A);
const _grey = Color(0xFF666666);
const _border = Color(0xFFE0E0E0);

const List<String> _ciudadesColombia = [
  'Armenia', 'Arauca', 'Barranquilla', 'Bogotá', 'Bucaramanga', 'Buga',
  'Cali', 'Cartagena', 'Cúcuta', 'Dosquebradas', 'Ibagué', 'Itagüí',
  'Leticia', 'Manizales', 'Medellín', 'Mitú', 'Mocoa', 'Montería',
  'Neiva', 'Palmira', 'Pasto', 'Pereira', 'Popayán', 'Puerto Carreño',
  'Quibdó', 'Riohacha', 'San Andrés', 'Santa Marta', 'Sincelejo',
  'Soacha', 'Soledad', 'Tunja', 'Valledupar', 'Villavicencio', 'Yopal',
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editando = false;
  bool _guardando = false;
  bool _cambioPass = false;
  bool _showPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _documentoCtrl;
  late TextEditingController _direccionCtrl;
  String? _ciudad;

  final _passFormKey = GlobalKey<FormState>();
  final _passActualCtrl = TextEditingController();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().usuarioActual;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: u?.telefono ?? '');
    _documentoCtrl = TextEditingController(text: u?.documento ?? '');
    _direccionCtrl = TextEditingController(text: u?.direccion ?? '');
    if (u?.ciudad != null && _ciudadesColombia.contains(u!.ciudad)) {
      _ciudad = u.ciudad;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _documentoCtrl.dispose();
    _direccionCtrl.dispose();
    _passActualCtrl.dispose();
    _passNuevaCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  void _cancelarEdicion(Usuario u) {
    setState(() {
      _editando = false;
      _nombreCtrl.text = u.nombre;
      _telefonoCtrl.text = u.telefono;
      _documentoCtrl.text = u.documento ?? '';
      _direccionCtrl.text = u.direccion ?? '';
      _ciudad = (_ciudadesColombia.contains(u.ciudad)) ? u.ciudad : null;
    });
  }

  Future<void> _guardarPerfil() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.actualizarPerfil(
      nombre: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      documento: _documentoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      ciudad: _ciudad,
    );
    if (!mounted) return;
    setState(() {
      _guardando = false;
      if (ok) _editando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Perfil actualizado' : (auth.error ?? 'Error al guardar')),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  Future<void> _cambiarContrasena() async {
    if (!(_passFormKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.cambiarContrasena(
      actual: _passActualCtrl.text,
      nueva: _passNuevaCtrl.text,
    );
    if (!mounted) return;
    setState(() {
      _guardando = false;
      if (ok) {
        _cambioPass = false;
        _passActualCtrl.clear();
        _passNuevaCtrl.clear();
        _passConfirmCtrl.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Contraseña actualizada' : (auth.error ?? 'Error')),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  InputDecoration _deco(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _grey, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: _grey, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            borderSide: const BorderSide(color: Colors.red)),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final u = auth.usuarioActual;
        if (u == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final iniciales = u.nombre.trim().split(' ').take(2).map((s) =>
            s.isNotEmpty ? s[0].toUpperCase() : '').join();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: CustomScrollView(
            slivers: [
              // ── Header con degradado ────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _pink,
                foregroundColor: Colors.white,
                actions: [
                  if (!_editando)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar perfil',
                      onPressed: () => setState(() => _editando = true),
                    ),
                  if (_editando) ...[
                    TextButton(
                      onPressed: _guardando ? null : () => _cancelarEdicion(u),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: _guardando ? null : _guardarPerfil,
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Guardar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_lightPink, _pink, _darkPink],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.25),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 3),
                            ),
                            child: Center(
                              child: Text(
                                iniciales.isEmpty ? 'US' : iniciales,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            u.nombre,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            u.email,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Contenido ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Tarjeta datos personales ──────────────────────
                      _card(
                        titulo: 'Datos Personales',
                        icono: Icons.person_outline,
                        child: _editando
                            ? _buildFormEdicion()
                            : _buildDatosLectura(u),
                      ),
                      const SizedBox(height: 12),

                      // ── Cambio de contraseña ──────────────────────────
                      _card(
                        titulo: 'Seguridad',
                        icono: Icons.lock_outline,
                        child: _cambioPass
                            ? _buildFormPassword()
                            : ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.lock_reset,
                                    color: _pink, size: 20),
                                title: const Text('Cambiar contraseña',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: _grey),
                                onTap: () =>
                                    setState(() => _cambioPass = true),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // ── Mis compras ───────────────────────────────────
                      _sectionHeader('MIS COMPRAS'),
                      _card(
                        child: Column(
                          children: [
                            _opcion(context, Icons.shopping_bag_outlined,
                                'Mis Pedidos', 'Ver historial de compras',
                                () => Navigator.pushNamed(context, AppRoutes.orders)),
                            _divider(),
                            _opcion(context, Icons.favorite_outline,
                                'Mis Favoritos', 'Productos guardados',
                                () => Navigator.pushNamed(context, AppRoutes.favorites)),
                            _divider(),
                            _opcion(context, Icons.local_shipping_outlined,
                                'Seguimiento', 'Rastrea tus paquetes',
                                () => Navigator.pushNamed(context, AppRoutes.shipments)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Notificaciones ────────────────────────────────
                      _sectionHeader('NOTIFICACIONES'),
                      _card(
                        child: _opcion(
                          context,
                          Icons.notifications_outlined,
                          'Notificaciones',
                          'Alertas de pedidos y novedades',
                          () => Navigator.pushNamed(
                              context, AppRoutes.notifications),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Información ───────────────────────────────────
                      _sectionHeader('INFORMACIÓN'),
                      _card(
                        child: Column(
                          children: [
                            _opcion(context, Icons.help_outline,
                                'Ayuda y Soporte', 'Preguntas frecuentes',
                                () => Navigator.pushNamed(context, AppRoutes.support)),
                            _divider(),
                            _opcion(context, Icons.privacy_tip_outlined,
                                'Términos y Condiciones', 'Políticas de privacidad',
                                () => Navigator.pushNamed(context, AppRoutes.terms)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Cerrar sesión ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('Cerrar Sesión',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Cerrar Sesión'),
                                content: const Text(
                                    '¿Estás seguro que deseas cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Salir',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true && context.mounted) {
                              context.read<FavoritosProvider>().limpiar();
                              context
                                  .read<NotificationProvider>()
                                  .limpiarTodas();
                              context.read<OrderProvider>().limpiar();
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (r) => false,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Datos en modo lectura ─────────────────────────────────────────────────

  Widget _buildDatosLectura(Usuario u) {
    return Column(
      children: [
        _datoRow(Icons.person_outline, 'Nombre', u.nombre),
        _datoRow(Icons.email_outlined, 'Email', u.email),
        _datoRow(Icons.phone_outlined, 'Teléfono',
            u.telefono.isNotEmpty ? u.telefono : 'No registrado'),
        _datoRow(Icons.badge_outlined, 'Documento',
            u.documento?.isNotEmpty == true ? u.documento! : 'No registrado'),
        _datoRow(Icons.home_outlined, 'Dirección',
            u.direccion?.isNotEmpty == true ? u.direccion! : 'No registrada'),
        _datoRow(Icons.location_city_outlined, 'Ciudad',
            u.ciudad?.isNotEmpty == true ? u.ciudad! : 'No registrada',
            last: true),
      ],
    );
  }

  Widget _datoRow(IconData icon, String label, String value,
      {bool last = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _pink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 11, color: _grey,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14,
                            color: _black,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }

  // ── Formulario de edición ─────────────────────────────────────────────────

  Widget _buildFormEdicion() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreCtrl,
            decoration: _deco('Nombre Completo *', icon: Icons.person_outline),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _telefonoCtrl,
            decoration: _deco('Teléfono *', icon: Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _documentoCtrl,
            decoration: _deco('Documento', icon: Icons.badge_outlined),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _direccionCtrl,
            decoration: _deco('Dirección', icon: Icons.home_outlined),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _ciudad,
            decoration: _deco('Ciudad', icon: Icons.location_city_outlined),
            hint: const Text('Selecciona una ciudad',
                style: TextStyle(color: _grey, fontSize: 13)),
            items: _ciudadesColombia
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _ciudad = v),
          ),
        ],
      ),
    );
  }

  // ── Formulario cambio contraseña ──────────────────────────────────────────

  Widget _buildFormPassword() {
    return Form(
      key: _passFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _passActualCtrl,
            obscureText: !_showPass,
            decoration: _deco('Contraseña actual',
                icon: Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                    _showPass ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _grey),
                onPressed: () => setState(() => _showPass = !_showPass),
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Ingresa tu contraseña actual' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passNuevaCtrl,
            obscureText: !_showNewPass,
            decoration: _deco('Nueva contraseña',
                icon: Icons.lock_reset_outlined).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                    _showNewPass ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _grey),
                onPressed: () =>
                    setState(() => _showNewPass = !_showNewPass),
              ),
            ),
            validator: (v) => v == null || v.length < 6
                ? 'Mínimo 6 caracteres'
                : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passConfirmCtrl,
            obscureText: !_showConfirmPass,
            decoration: _deco('Confirmar contraseña',
                icon: Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                    _showConfirmPass ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _grey),
                onPressed: () =>
                    setState(() => _showConfirmPass = !_showConfirmPass),
              ),
            ),
            validator: (v) => v != _passNuevaCtrl.text
                ? 'Las contraseñas no coinciden'
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _guardando
                      ? null
                      : () {
                          setState(() {
                            _cambioPass = false;
                            _passActualCtrl.clear();
                            _passNuevaCtrl.clear();
                            _passConfirmCtrl.clear();
                          });
                        },
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _guardando ? null : _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _card({String? titulo, IconData? icono, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Row(
              children: [
                if (icono != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _pink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icono, color: _pink, size: 16),
                  ),
                if (icono != null) const SizedBox(width: 8),
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _black)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _grey,
              letterSpacing: 0.8)),
    );
  }

  Widget _opcion(BuildContext context, IconData icon, String titulo,
      String subtitulo, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _pink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _pink, size: 18),
      ),
      title: Text(titulo,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _black)),
      subtitle: Text(subtitulo,
          style: const TextStyle(fontSize: 11, color: _grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: _grey),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 50, endIndent: 0);
}
