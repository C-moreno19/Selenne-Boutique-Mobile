import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';

const _pink = Color(0xFFD65391);
const _black = Color(0xFF1A1A1A);
const _grey = Color(0xFF666666);
const _border = Color(0xFFE0E0E0);
const _darkStart = Color(0xFF2D1B24);
const _midMaroon = Color(0xFF7A3350);
const _gradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [_darkStart, _midMaroon, _pink],
);

const List<String> _ciudadesColombia = [
  'Armenia', 'Barranquilla', 'Bogotá', 'Bucaramanga', 'Cali',
  'Cartagena', 'Cúcuta', 'Florencia', 'Ibagué', 'Inírida',
  'La Chorrera', 'Leticia', 'Manizales', 'Medellín', 'Mitú',
  'Mocoa', 'Montería', 'Neiva', 'Pasto', 'Pereira',
  'Puerto Carreño', 'Quibdó', 'Riohacha', 'San Andrés',
  'Santa Marta', 'Sincelejo', 'Tunja', 'Valledupar',
  'Villavicencio', 'Yopal',
];

class CheckoutModalContent extends StatefulWidget {
  /// Cuando se pasa, el modal usa estos ítems en lugar del carrito global.
  final List<CartItem>? itemsDirectos;

  const CheckoutModalContent({super.key, this.itemsDirectos});

  @override
  State<CheckoutModalContent> createState() => _CheckoutModalContentState();
}

class _CheckoutModalContentState extends State<CheckoutModalContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _documentoCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _barrioCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _notasCtrl;
  String? _ciudad;
  String _metodoPago = 'contra_entrega';
  PlatformFile? _comprobante;
  bool _enviando = false;

  Map<String, String> _banco = {
    'banco': 'Bancolombia',
    'numeroCuenta': '91292106179',
    'titular': 'Selenne Boutique',
    'tipoCuenta': 'Ahorros',
  };

  // ── Direcciones guardadas ────────────────────────────────────────────────
  static const _addressKey = 'saved_addresses_v1';
  List<Map<String, String>> _savedAddresses = [];
  int? _selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().usuarioActual;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _documentoCtrl = TextEditingController(text: u?.documento ?? '');
    _direccionCtrl = TextEditingController(text: u?.direccion ?? '');
    _barrioCtrl = TextEditingController();
    _telefonoCtrl = TextEditingController(text: u?.telefono ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _notasCtrl = TextEditingController();
    if (u?.ciudad != null && _ciudadesColombia.contains(u!.ciudad)) {
      _ciudad = u.ciudad;
    }
    _cargarDatosBanco();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_addressKey);
    if (raw != null && mounted) {
      final List<dynamic> list = jsonDecode(raw);
      setState(() {
        _savedAddresses =
            list.map((e) => Map<String, String>.from(e as Map)).toList();
      });
    }
  }

  Future<void> _saveAddressList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, jsonEncode(_savedAddresses));
  }

  void _applyAddress(Map<String, String> addr) {
    setState(() {
      _nombreCtrl.text = addr['nombre'] ?? '';
      _documentoCtrl.text = addr['documento'] ?? '';
      _telefonoCtrl.text = addr['telefono'] ?? '';
      _emailCtrl.text = addr['email'] ?? '';
      _direccionCtrl.text = addr['direccion'] ?? '';
      _barrioCtrl.text = addr['barrio'] ?? '';
      final c = addr['ciudad'];
      _ciudad = (c != null && _ciudadesColombia.contains(c)) ? c : null;
    });
  }

  void _saveCurrentAsAddress() {
    final addr = {
      'nombre': _nombreCtrl.text.trim(),
      'documento': _documentoCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'barrio': _barrioCtrl.text.trim(),
      'ciudad': _ciudad ?? '',
    };
    final label =
        '${addr['direccion']}, ${addr['barrio']}, ${addr['ciudad']}';
    if (addr['direccion']!.isEmpty || addr['ciudad']!.isEmpty) {
      _showSnack('Completa dirección y ciudad antes de guardar', error: true);
      return;
    }
    setState(() {
      _savedAddresses.add({...addr, 'label': label});
      _selectedAddressIndex = _savedAddresses.length - 1;
    });
    _saveAddressList();
    _showSnack('Dirección guardada', error: false);
  }

  void _deleteAddress(int index) {
    setState(() {
      _savedAddresses.removeAt(index);
      if (_selectedAddressIndex == index) _selectedAddressIndex = null;
      if (_selectedAddressIndex != null && _selectedAddressIndex! > index) {
        _selectedAddressIndex = _selectedAddressIndex! - 1;
      }
    });
    _saveAddressList();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _documentoCtrl.dispose();
    _direccionCtrl.dispose();
    _barrioCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosBanco() async {
    try {
      final data = await ApiService.get('/api/config/banco');
      if (mounted && data is Map) {
        final d = data;
        setState(() {
          _banco = {
            'banco': (d['banco'] ?? d['Banco'] ?? 'Bancolombia').toString(),
            'numeroCuenta': (d['numeroCuenta'] ?? d['NumeroCuenta'] ?? '91292106179').toString(),
            'titular': (d['titular'] ?? d['Titular'] ?? 'Selenne Boutique').toString(),
            'tipoCuenta': (d['tipoCuenta'] ?? d['TipoCuenta'] ?? 'Ahorros').toString(),
          };
        });
      }
    } catch (_) {}
  }

  String _formatCOP(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  InputDecoration _inputDeco(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _grey, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: _grey, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _pink, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
      );

  Future<void> _confirmar() async {
    try {
      if (!(_formKey.currentState?.validate() ?? false)) {
        _showSnack('Completa todos los campos requeridos', error: true);
        return;
      }
      if (_ciudad == null || _ciudad!.isEmpty) {
        _showSnack('Selecciona una ciudad', error: true);
        return;
      }
      if (_metodoPago == 'transferencia' && _comprobante == null) {
        _showSnack('Sube el comprobante de pago', error: true);
        return;
      }

      setState(() => _enviando = true);

      final carrito = context.read<CarritoProvider>();
      final orders = context.read<OrderProvider>();
      final items = widget.itemsDirectos ?? carrito.items;

      // Subir comprobante si aplica
      String? comprobanteUrl;
      if (_metodoPago == 'transferencia' &&
          _comprobante != null &&
          _comprobante!.bytes != null) {
        comprobanteUrl = await ApiService.uploadFile(
          '/api/upload/imagen',
          _comprobante!.bytes!,
          _comprobante!.name,
        );
      }

      final notasBase = _notasCtrl.text.trim();

      final pedido = await orders.crearPedidoAPI(
        nombreCliente: _nombreCtrl.text.trim(),
        emailCliente: _emailCtrl.text.trim(),
        telefonoCliente: _telefonoCtrl.text.trim(),
        documento: _documentoCtrl.text.trim(),
        direccionEnvio:
            '${_direccionCtrl.text.trim()}, ${_barrioCtrl.text.trim()}',
        ciudad: _ciudad!,
        metodoPago: _metodoPago,
        items: items,
        notas: notasBase.isEmpty ? null : notasBase,
        comprobantePago: comprobanteUrl,
      );

      if (!mounted) return;
      setState(() => _enviando = false);

      if (pedido != null) {
        // Solo vaciar el carrito global cuando no es compra directa
        if (widget.itemsDirectos == null) carrito.limpiarCarrito();
        // Recargar notificaciones para mostrar la que genera el backend al crear el pedido
        context.read<NotificationProvider>().cargarNotificaciones();
        Navigator.of(context).pop();
        AppSnackBar.show(context, 'Tu pedido fue registrado y está siendo procesado.',
            title: '¡Pedido confirmado!', duration: const Duration(seconds: 4));
      } else {
        _showSnack(orders.error ?? 'Error al crear el pedido', error: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        _showSnack('Error: ${e.toString()}', error: true);
      }
    }
  }

  void _showSnack(String msg, {required bool error}) {
    AppSnackBar.show(context, msg, type: error ? SnackType.error : SnackType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoProvider>(
      builder: (ctx, carrito, _) {
        final items = widget.itemsDirectos ?? carrito.items;
        final total = items.fold<double>(0, (s, i) => s + i.subtotal);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: Color(0xFF1A1A1A), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Finalizar Compra',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatCOP(total),
                        style: const TextStyle(
                          color: _pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Formulario
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Resumen de productos
                      _sectionTitle('Resumen del Pedido', Icons.receipt_outlined),
                      const SizedBox(height: 10),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: item.producto.imagen,
                                width: 48, height: 54,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 48, height: 54,
                                  color: const Color(0xFFF5F5F5),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 48, height: 54,
                                  color: const Color(0xFFF5F5F5),
                                  child: const Icon(Icons.image_not_supported, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.producto.nombre,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('${item.talla} · ${item.color} · x${item.cantidad}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Text(_formatCOP(item.producto.precio * item.cantidad),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold, color: _pink)),
                          ],
                        ),
                      )),
                      const Divider(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Envío:', style: TextStyle(color: _grey)),
                          Text('Gratis',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_formatCOP(total),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15, color: _pink)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Direcciones guardadas (picker estilo Temu)
                      if (_savedAddresses.isNotEmpty) ...[
                        _sectionTitle('Mis Direcciones', Icons.location_on_outlined),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _savedAddresses.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              if (i == _savedAddresses.length) {
                                // Tarjeta "Nueva dirección"
                                return GestureDetector(
                                  onTap: _saveCurrentAsAddress,
                                  child: Container(
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: _pink.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: _pink.withValues(alpha: 0.4)),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_location_alt_outlined, color: _pink, size: 22),
                                        SizedBox(height: 6),
                                        Text('Guardar actual',
                                            style: TextStyle(fontSize: 11, color: _pink, fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              final addr = _savedAddresses[i];
                              final selected = _selectedAddressIndex == i;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedAddressIndex = i);
                                  _applyAddress(addr);
                                },
                                child: Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 160,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: selected ? _pink.withValues(alpha: 0.08) : const Color(0xFFFAFAFA),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected ? _pink : _border,
                                          width: selected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.home_outlined,
                                                  size: 14,
                                                  color: selected ? _pink : _grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  addr['nombre'] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: selected ? _pink : _black),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            addr['direccion'] ?? '',
                                            style: const TextStyle(fontSize: 10, color: _grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${addr['barrio'] ?? ''}, ${addr['ciudad'] ?? ''}',
                                            style: const TextStyle(fontSize: 10, color: _grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Botón eliminar
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _deleteAddress(i),
                                        child: Container(
                                          width: 18, height: 18,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Datos de envío
                      Row(
                        children: [
                          Expanded(child: _sectionTitle('Datos de Envío', Icons.local_shipping_outlined)),
                          if (_savedAddresses.isEmpty)
                            TextButton.icon(
                              onPressed: _saveCurrentAsAddress,
                              icon: const Icon(Icons.save_outlined, size: 16, color: _pink),
                              label: const Text('Guardar',
                                  style: TextStyle(fontSize: 12, color: _pink)),
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nombreCtrl,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))],
                        decoration: _inputDeco('Nombre Completo *', icon: Icons.person_outline),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _documentoCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _inputDeco('Número de Documento (opcional)', icon: Icons.badge_outlined),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _inputDeco('Teléfono *', icon: Icons.phone_outlined),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDeco('Email *', icon: Icons.email_outlined),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _direccionCtrl,
                        keyboardType: TextInputType.streetAddress,
                        decoration: _inputDeco('Dirección *', icon: Icons.home_outlined),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _barrioCtrl,
                        keyboardType: TextInputType.streetAddress,
                        decoration: _inputDeco('Barrio *', icon: Icons.location_on_outlined),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _ciudad,
                        decoration: _inputDeco('Ciudad *', icon: Icons.location_city_outlined),
                        hint: const Text('Selecciona una ciudad',
                            style: TextStyle(color: _grey, fontSize: 13)),
                        items: _ciudadesColombia
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _ciudad = v),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Selecciona una ciudad' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notasCtrl,
                        maxLines: 2,
                        decoration: _inputDeco('Notas del pedido (opcional)',
                            icon: Icons.notes_outlined),
                      ),
                      const SizedBox(height: 24),

                      // Método de pago
                      _sectionTitle('Método de Pago', Icons.payment_outlined),
                      const SizedBox(height: 12),
                      _buildMetodoPagoCard('contra_entrega', 'Contra Entrega',
                          'Paga cuando recibas tu pedido', Icons.delivery_dining_outlined),
                      const SizedBox(height: 8),
                      _buildMetodoPagoCard('transferencia', 'Transferencia Bancaria',
                          'Transfiere y sube el comprobante', Icons.account_balance_outlined),

                      // Sección transferencia
                      if (_metodoPago == 'transferencia') ...[
                        const SizedBox(height: 16),
                        _buildTransferenciaSection(total),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Botón confirmar
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: _enviando ? null : _gradient,
                  color: _enviando ? Colors.grey[400] : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _enviando ? null : _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _enviando
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Confirmar Pedido',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _pink.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _pink, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
      ],
    );
  }

  Widget _buildMetodoPagoCard(
      String value, String title, String subtitle, IconData icon) {
    final selected = _metodoPago == value;
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _pink.withValues(alpha:0.06) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _pink : _border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _pink : _grey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? _black : _grey)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: selected ? _grey : Colors.grey[400])),
                ],
              ),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _pink : Colors.transparent,
                border: Border.all(
                    color: selected ? _pink : _border, width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferenciaSection(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Datos bancarios',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: _black)),
          const SizedBox(height: 10),
          _bankRow('Banco', _banco['banco'] ?? ''),
          _bankRow('Tipo de cuenta', _banco['tipoCuenta'] ?? ''),
          _bankRow('Número de cuenta', _banco['numeroCuenta'] ?? ''),
          _bankRow('Titular', _banco['titular'] ?? ''),
          _bankRow('Monto a transferir', _formatCOP(total),
              valueColor: _pink, bold: true),
          const SizedBox(height: 16),
          // QR de transferencia
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                Text(
                  'Escanea para transferir',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/qr-transferencia.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Subir comprobante
          GestureDetector(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                withData: true,
              );
              if (result != null && result.files.isNotEmpty) {
                setState(() => _comprobante = result.files.first);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: _comprobante != null
                    ? Colors.green.withValues(alpha:0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _comprobante != null ? Colors.green : _border,
                  width: _comprobante != null ? 2 : 1,
                ),
              ),
              child: _comprobante == null
                  ? Column(
                      children: [
                        const Icon(Icons.upload_file,
                            color: _grey, size: 28),
                        const SizedBox(height: 6),
                        const Text('Subir comprobante de pago',
                            style: TextStyle(
                                color: _grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('PNG, JPG o PDF (máx. 5MB)',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_comprobante!.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text('Comprobante adjuntado',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _comprobante = null),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 18),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.orange.withValues(alpha:0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu pedido quedará pendiente hasta que el administrador confirme el pago.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: _grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? _black)),
        ],
      ),
    );
  }
}
