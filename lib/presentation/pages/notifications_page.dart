import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  static const _pink = Color(0xFFE91E8C);
  static const _darkPink = Color(0xFFA3145F);
  static const _lightPink = Color(0xFFFF6FC8);
  static const _black = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notificaciones = provider.notificaciones;
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
                              'Notificaciones',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.notificacionesNoLeidas} sin leer',
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
                actions: [
                  if (provider.notificacionesNoLeidas > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: provider.marcarTodasComoLeidas,
                        child: const Text(
                          'Marcar leídas',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),

              // Contenido
              notificaciones.isEmpty
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
                              child: const Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: _pink),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Sin notificaciones',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _black),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Aquí aparecerán tus alertas y novedades',
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
                            final n = notificaciones[index];
                            final info = _getTipoInfo(n.tipo);
                            final Color tipoColor = info['color'] as Color;
                            return Dismissible(
                              key: Key(n.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white, size: 24),
                              ),
                              onDismissed: (_) {
                                provider.eliminarNotificacion(n.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Notificación eliminada')),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (!n.leida) {
                                    provider.marcarComoLeida(n.id);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: n.leida
                                        ? Colors.white
                                        : _pink.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: n.leida
                                          ? const Color(0xFFEEEEEE)
                                          : _pink.withValues(alpha: 0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Ícono tipo
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: tipoColor
                                                .withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                              info['icon'] as IconData,
                                              color: tipoColor,
                                              size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        // Contenido
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      n.titulo,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: n.leida
                                                            ? FontWeight.w600
                                                            : FontWeight.w700,
                                                        color: _black,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (!n.leida) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: _pink,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                n.mensaje,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF666666),
                                                    height: 1.4),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: tipoColor
                                                          .withValues(
                                                              alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                    ),
                                                    child: Text(
                                                      info['label'] as String,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: tipoColor),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    _formatearFecha(n.fecha),
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFFAAAAAA)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: notificaciones.length,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getTipoInfo(String tipo) {
    switch (tipo) {
      case 'pedido':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': _pink,
          'label': 'Pedido',
        };
      case 'promocion':
        return {
          'icon': Icons.local_offer_outlined,
          'color': const Color(0xFFE65100),
          'label': 'Promoción',
        };
      case 'informativo':
      default:
        return {
          'icon': Icons.info_outline,
          'color': const Color(0xFF1565C0),
          'label': 'Información',
        };
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final dif = ahora.difference(fecha);
    if (dif.inMinutes < 1) return 'Ahora';
    if (dif.inMinutes < 60) return 'Hace ${dif.inMinutes} min';
    if (dif.inHours < 24) return 'Hace ${dif.inHours} h';
    if (dif.inDays < 7) return 'Hace ${dif.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
