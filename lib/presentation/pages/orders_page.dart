import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  static const _pink = Color(0xFFE91E8C);
  static const _darkPink = Color(0xFFA3145F);
  static const _lightPink = Color(0xFFFF6FC8);
  static const _black = Color(0xFF1A1A1A);

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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_lightPink, _pink, _darkPink],
                  ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
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
    final color = _estadoColor(p.estadoTexto);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            // Encabezado del modal
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_estadoIcon(p.estadoTexto),
                      size: 22, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${p.id}',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(p.estadoTexto,
                        style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            _detalleRow(Icons.attach_money_rounded, 'Total',
                _cop(p.total), _pink),
            const SizedBox(height: 14),
            _detalleRow(Icons.location_on_outlined, 'Dirección de envío',
                p.direccionEnvio, const Color(0xFF666666)),
            const SizedBox(height: 14),
            _detalleRow(Icons.calendar_today_outlined, 'Fecha del pedido',
                '${p.fechaCreacion.toLocal()}'.split(' ')[0],
                const Color(0xFF666666)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Cerrar',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detalleRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF999999))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
