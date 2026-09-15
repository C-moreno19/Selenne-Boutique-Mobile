import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/snackbar.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _pink = Color(0xFFD65391);
  static const _darkStart = Color(0xFF2D1B24);
  static const _midMaroon = Color(0xFF7A3350);
  static const _black = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().cargarNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notificaciones = provider.notificaciones;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: RefreshIndicator(
            color: _pink,
            onRefresh: provider.cargarNotificaciones,
            child: CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 130,
                  pinned: true,
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_darkStart, _midMaroon, _pink],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Notificaciones',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                provider.notificacionesNoLeidas > 0
                                    ? '${provider.notificacionesNoLeidas} sin leer'
                                    : 'Todo al día',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    if (notificaciones.isNotEmpty)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: Colors.white),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) async {
                          if (value == 'leer') {
                            await provider.marcarTodasComoLeidas();
                          } else if (value == 'eliminar') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: Text('Eliminar todas',
                                    style: GoogleFonts.playfairDisplay(
                                        fontWeight: FontWeight.bold)),
                                content: const Text(
                                    '¿Seguro que quieres eliminar todas las notificaciones?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar',
                                        style:
                                            TextStyle(color: Color(0xFF888888))),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.limpiarTodas();
                              if (!context.mounted) return;
                              AppSnackBar.show(
                                  context, 'Notificaciones eliminadas',
                                  type: SnackType.info);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          if (provider.notificacionesNoLeidas > 0)
                            const PopupMenuItem(
                              value: 'leer',
                              child: Row(children: [
                                Icon(Icons.done_all_rounded,
                                    size: 18, color: Color(0xFF555555)),
                                SizedBox(width: 10),
                                Text('Marcar todas como leídas',
                                    style: TextStyle(fontSize: 14)),
                              ]),
                            ),
                          const PopupMenuItem(
                            value: 'eliminar',
                            child: Row(children: [
                              Icon(Icons.delete_sweep_rounded,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Eliminar todas',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red)),
                            ]),
                          ),
                        ],
                      ),
                  ],
                ),

                // ── Contenido ─────────────────────────────────────────────────
                if (notificaciones.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: _pink.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none_rounded,
                                size: 44, color: _pink),
                          ),
                          const SizedBox(height: 20),
                          Text('Sin notificaciones',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _black)),
                          const SizedBox(height: 8),
                          const Text(
                            'Aquí aparecerán tus alertas y\nnovedades de tus pedidos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 14,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                              padding: const EdgeInsets.only(right: 24),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_rounded,
                                      color: Colors.white, size: 26),
                                  SizedBox(height: 4),
                                  Text('Eliminar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              provider.eliminarNotificacion(n.id);
                              AppSnackBar.show(
                                  context, 'Notificación eliminada',
                                  type: SnackType.info);
                            },
                            child: GestureDetector(
                              onTap: () {
                                if (!n.leida) provider.marcarComoLeida(n.id);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border(
                                    left: BorderSide(
                                        color: tipoColor, width: 4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Ícono tipo
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color:
                                              tipoColor.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    n.titulo,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: n.leida
                                                          ? FontWeight.w600
                                                          : FontWeight.w800,
                                                      color: _black,
                                                    ),
                                                  ),
                                                ),
                                                if (!n.leida)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 4, left: 6),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: _pink,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              n.mensaje,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: n.leida
                                                      ? const Color(0xFF888888)
                                                      : const Color(0xFF555555),
                                                  height: 1.4),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: tipoColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    info['label'] as String,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: tipoColor),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  _formatearFecha(n.fecha),
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFFBBBBBB)),
                                                ),
                                                const SizedBox(width: 6),
                                                // Botón eliminar visible
                                                GestureDetector(
                                                  onTap: () {
                                                    provider
                                                        .eliminarNotificacion(
                                                            n.id);
                                                    AppSnackBar.show(
                                                        context,
                                                        'Notificación eliminada',
                                                        type: SnackType.info);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF5F5F5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Icon(
                                                        Icons.close_rounded,
                                                        size: 14,
                                                        color:
                                                            Color(0xFFAAAAAA)),
                                                  ),
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
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getTipoInfo(String tipo) {
    switch (tipo) {
      case 'pedido':
      case 'success':
        return {
          'icon': Icons.shopping_bag_rounded,
          'color': _pink,
          'label': 'Pedido',
        };
      case 'error':
        return {
          'icon': Icons.cancel_rounded,
          'color': const Color(0xFFD32F2F),
          'label': 'Rechazado',
        };
      case 'warning':
        return {
          'icon': Icons.warning_amber_rounded,
          'color': const Color(0xFFF57C00),
          'label': 'Aviso',
        };
      case 'promocion':
        return {
          'icon': Icons.local_offer_rounded,
          'color': const Color(0xFFE65100),
          'label': 'Promoción',
        };
      case 'info':
      case 'informativo':
      default:
        return {
          'icon': Icons.info_rounded,
          'color': const Color(0xFF1976D2),
          'label': 'Info',
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
