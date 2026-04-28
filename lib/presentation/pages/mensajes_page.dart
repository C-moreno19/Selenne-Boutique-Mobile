import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Mensaje {
  final String id;
  final String remitente;
  final String contenido;
  final DateTime fecha;
  final bool leido;
  final String tipo; // 'soporte' | 'pedido' | 'promo'

  Mensaje({
    required this.id,
    required this.remitente,
    required this.contenido,
    required this.fecha,
    this.leido = false,
    this.tipo = 'soporte',
  });
}

class MensajesPage extends StatefulWidget {
  const MensajesPage({Key? key}) : super(key: key);

  @override
  State<MensajesPage> createState() => _MensajesPageState();
}

class _MensajesPageState extends State<MensajesPage>
    with SingleTickerProviderStateMixin {
  static const _pink = Color(0xFFE91E8C);
  static const _darkPink = Color(0xFFA3145F);
  static const _lightPink = Color(0xFFFF6FC8);
  static const _black = Color(0xFF1A1A1A);

  late List<Mensaje> _mensajes;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mensajes = [
      Mensaje(
        id: '1',
        remitente: 'Soporte Selenne',
        contenido: 'Hola, ¿en qué podemos ayudarte con tu pedido?',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
        leido: true,
        tipo: 'soporte',
      ),
      Mensaje(
        id: '2',
        remitente: 'Tu Pedido #12345',
        contenido:
            'Tu pedido ha sido despachado. Número de seguimiento: ABC123',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        leido: true,
        tipo: 'pedido',
      ),
      Mensaje(
        id: '3',
        remitente: 'Promociones Selenne',
        contenido: '¡Descuento del 30% en toda la nueva colección!',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        leido: false,
        tipo: 'promo',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noLeidos = _mensajes.where((m) => !m.leido).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
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
                          'Mensajes',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${noLeidos.length} mensaje${noLeidos.length != 1 ? 's' : ''} sin leer',
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: Container(
                color: _darkPink,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Todos'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Sin leer'),
                          if (noLeidos.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${noLeidos.length}',
                                style: const TextStyle(
                                    color: _pink,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildListaMensajes(_mensajes),
            _buildListaMensajes(noLeidos),
          ],
        ),
      ),
    );
  }

  Widget _buildListaMensajes(List<Mensaje> lista) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.mail_outline, size: 44, color: _pink),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay mensajes',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí aparecerán tus conversaciones',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final msg = lista[index];
        final info = _getTipoInfo(msg.tipo);
        final Color tipoColor = info['color'] as Color;

        return GestureDetector(
          onTap: () => _mostrarDetalle(msg),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: msg.leido
                  ? Colors.white
                  : _pink.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: msg.leido
                    ? const Color(0xFFEEEEEE)
                    : _pink.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tipoColor.withValues(alpha: 0.3),
                          tipoColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info['icon'] as IconData,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              msg.remitente,
                              style: TextStyle(
                                fontWeight: msg.leido
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                fontSize: 14,
                                color: _black,
                              ),
                            ),
                            Text(
                              _formatearTiempo(msg.fecha),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFAAAAAA)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg.contenido,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: msg.leido
                                ? const Color(0xFF888888)
                                : _black,
                            height: 1.4,
                          ),
                        ),
                        if (!msg.leido) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _pink,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Text('Nuevo',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetalle(Mensaje msg) {
    if (!msg.leido) {
      setState(() {
        final i = _mensajes.indexWhere((m) => m.id == msg.id);
        if (i >= 0) {
          _mensajes[i] = Mensaje(
            id: msg.id,
            remitente: msg.remitente,
            contenido: msg.contenido,
            fecha: msg.fecha,
            leido: true,
            tipo: msg.tipo,
          );
        }
      });
    }

    final info = _getTipoInfo(msg.tipo);
    final Color tipoColor = info['color'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            // Encabezado
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tipoColor.withValues(alpha: 0.3),
                        tipoColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(info['icon'] as IconData,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.remitente,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _black),
                      ),
                      Text(
                        _formatearTiempo(msg.fecha),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            Text(
              msg.contenido,
              style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
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

  Map<String, dynamic> _getTipoInfo(String tipo) {
    switch (tipo) {
      case 'pedido':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': _pink,
        };
      case 'promo':
        return {
          'icon': Icons.local_offer_outlined,
          'color': const Color(0xFFE65100),
        };
      case 'soporte':
      default:
        return {
          'icon': Icons.headset_mic_outlined,
          'color': const Color(0xFF1565C0),
        };
    }
  }

  String _formatearTiempo(DateTime fecha) {
    final ahora = DateTime.now();
    final dif = ahora.difference(fecha);
    if (dif.inMinutes < 1) return 'Ahora';
    if (dif.inMinutes < 60) return 'Hace ${dif.inMinutes} min';
    if (dif.inHours < 24) return 'Hace ${dif.inHours} h';
    if (dif.inDays < 7) return 'Hace ${dif.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
