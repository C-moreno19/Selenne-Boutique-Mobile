import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const _pink = Color(0xFFD65391);
  static const _darkStart = Color(0xFF2D1B24);
  static const _midMaroon = Color(0xFF7A3350);
  static const _black = Color(0xFF1A1A1A);
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkStart, _midMaroon, _pink],
  );

  String _cop(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return const Color(0xFF2E7D32);
      case 'enviado':
        return const Color(0xFF1565C0);
      case 'en preparacion':
      case 'en preparación':
        return const Color(0xFFE65100);
      case 'cancelado':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF6A1B9A);
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return Icons.check_circle_outline;
      case 'enviado':
        return Icons.local_shipping_outlined;
      case 'en preparacion':
      case 'en preparación':
        return Icons.inventory_2_outlined;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final pedidos = orderProvider.pedidos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Header con degradado
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: _pink,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: _gradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Mis Pedidos',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pedidos.length} pedido${pedidos.length != 1 ? 's' : ''} realizados',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          pedidos.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: _pink.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_outlined,
                              size: 48, color: _pink),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Aún no tienes pedidos',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡Explora la tienda y haz tu primer pedido!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF888888), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = pedidos[index];
                        final color = _estadoColor(p.estadoTexto);
                        return GestureDetector(
                          onTap: () => _mostrarDetalle(context, p),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fila superior: número + estado
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pedido #${p.id}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: _black),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: color.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_estadoIcon(p.estadoTexto),
                                                size: 12, color: color),
                                            const SizedBox(width: 4),
                                            Text(
                                              p.estadoTexto,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  const SizedBox(height: 12),
                                  // Fila inferior: fecha + total
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Color(0xFF999999)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${p.fechaCreacion.toLocal()}'
                                            .split(' ')[0],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF888888)),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _cop(p.total),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _pink,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Indicador "ver detalle"
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Ver detalle',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: _pink,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 2),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 10, color: _pink),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: pedidos.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, Pedido p) {
    final esCancelado = p.estado.toLowerCase() == 'cancelado' ||
        p.estado.toLowerCase() == 'rechazado';
    final pasos = ['Pendiente', 'Aprobado', 'Enviado', 'Completado'];
    int pasoActivo = 0;
    switch (p.estado.toLowerCase()) {
      case 'pendiente': pasoActivo = 0; break;
      case 'aprobado': pasoActivo = 1; break;
      case 'enviado': pasoActivo = 2; break;
      case 'completado': pasoActivo = 3; break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header con degradado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: const BoxDecoration(
                  gradient: _gradient,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_estadoIcon(p.estadoTexto), color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedido #${p.id}',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(p.estadoTexto,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Text(_cop(p.total),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ],
                ),
              ),
              // Body scrollable
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(14),
                  children: [
                    // Timeline de estado
                    if (!esCancelado) ...[
                      _buildProgressCard(pasos, pasoActivo),
                      const SizedBox(height: 12),
                    ],
                    // Info: pago + dirección
                    _buildInfoCard(p),
                    const SizedBox(height: 12),
                    // Guía de seguimiento
                    if (p.numeroSeguimiento != null && p.numeroSeguimiento!.isNotEmpty) ...[
                      _buildGuiaCard(p.numeroSeguimiento!),
                      const SizedBox(height: 12),
                    ],
                    // Productos
                    if (p.items.isNotEmpty) ...[
                      _buildProductosCard(p),
                      const SizedBox(height: 12),
                    ],
                    // Resumen de precios
                    _buildResumenCard(p),
                    const SizedBox(height: 12),
                    // Fechas
                    _buildFechasCard(p),
                    const SizedBox(height: 20),
                    // Botón cerrar
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Cerrar',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(List<String> pasos, int pasoActivo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado del pedido',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 0.5)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(pasos.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Expanded(
                  child: Container(
                    height: 2,
                    color: i ~/ 2 < pasoActivo ? _pink : const Color(0xFFEEEEEE),
                  ),
                );
              }
              final idx = i ~/ 2;
              final done = idx <= pasoActivo;
              return Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: done ? _pink : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? _pink : const Color(0xFFDDDDDD), width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                    : null,
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: pasos.asMap().entries.map((e) {
              final done = e.key <= pasoActivo;
              return Expanded(
                child: Text(e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                        color: done ? _pink : const Color(0xFFBBBBBB))),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Pedido p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _infoFila(Icons.credit_card_outlined, 'Método de pago',
              p.metodoPago.isNotEmpty ? p.metodoPago : 'No especificado', _pink),
          const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF5F5F5)),
          _infoFila(Icons.location_on_outlined, 'Dirección de envío',
              p.direccionEnvio.isNotEmpty ? p.direccionEnvio : 'No especificada', _pink),
        ],
      ),
    );
  }

  Widget _infoFila(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuiaCard(String guia) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBD9F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Número de guía',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
                Text(guia,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
              ],
            ),
          ),
          const Icon(Icons.copy_outlined, size: 16, color: Color(0xFF1565C0)),
        ],
      ),
    );
  }

  Widget _buildProductosCard(Pedido p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _pink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, size: 18, color: _pink),
                ),
                const SizedBox(width: 12),
                Text('Productos (${p.items.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _black)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          ...p.items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == p.items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.producto.imagen,
                          width: 50, height: 54, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50, height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_not_supported_outlined,
                                size: 20, color: Color(0xFFCCCCCC)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.producto.nombre,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: _black)),
                            const SizedBox(height: 4),
                            Wrap(spacing: 6, children: [
                              if (item.talla.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('T: ${item.talla}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
                                ),
                              if (item.color.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _pink.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(item.color,
                                      style: const TextStyle(fontSize: 10, color: _pink)),
                                ),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_cop(item.producto.precio * item.cantidad),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: _pink)),
                          Text('× ${item.cantidad}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: Color(0xFFF5F5F5)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResumenCard(Pedido p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pink.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
              Text(_cop(p.subtotal),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _black)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Envío', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
              Text(p.envio == 0 ? 'Gratis' : _cop(p.envio),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.envio == 0 ? const Color(0xFF2E7D32) : _black)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: _pink.withValues(alpha: 0.2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _black)),
              Text(_cop(p.total),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: _pink)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFechasCard(Pedido p) {
    final fecha = '${p.fechaCreacion.toLocal()}'.split(' ')[0];
    final entrega = p.fechaEntrega != null
        ? '${p.fechaEntrega!.toLocal()}'.split(' ')[0]
        : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _infoFila(Icons.calendar_today_outlined, 'Fecha del pedido', fecha, const Color(0xFF888888)),
          if (entrega != null) ...[
            const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF5F5F5)),
            _infoFila(Icons.event_available_outlined, 'Fecha de entrega', entrega,
                const Color(0xFF2E7D32)),
          ],
        ],
      ),
    );
  }
}
