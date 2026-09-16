import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/snackbar.dart';
import '../pages/checkout_modal_content.dart';
import '../providers/providers.dart';

/// Tarjeta de producto
class ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductCard({
    required this.producto,
    required this.onTap,
    super.key,
  });

  static String _copCard(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2D1B24), Color(0xFF7A3350), AppColors.primary],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritosProvider>(
      builder: (context, favoritosProvider, _) {
        final isFavorite = favoritosProvider.isFavorito(producto.id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con badges de descuento, detalle y favorito
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: CachedNetworkImage(
                          imageUrl: producto.imagen,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightGray,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightGray,
                            child: const Center(
                                child: Icon(Icons.image_not_supported)),
                          ),
                        ),
                      ),
                    ),
                    // Badge de descuento o sale
                    if (producto.hayDescuento || producto.categoria == 'sale')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: producto.hayDescuento
                                ? AppColors.error
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            producto.hayDescuento
                                ? '-${producto.descuentoPorcentaje.toStringAsFixed(0)}%'
                                : 'SALE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    // Insignia "Detalle"
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: _gradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye_outlined,
                                size: 12, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'DETALLE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón Favorito
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          favoritosProvider.toggleFavorito(producto.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Contenido
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Precio
                        if (producto.hayDescuento)
                          Text(
                            _copCard(producto.precioOriginal!),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          _copCard(producto.precio),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        // Círculos de color
                        if (producto.colores.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: producto.colores.take(5).map((c) {
                              final hex = producto.colorHex[c] ?? '#000000';
                              final hexClean = hex.replaceFirst('#', '');
                              final colorVal =
                                  int.tryParse('0xFF$hexClean') ?? 0xFF000000;
                              final color = Color(colorVal);
                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow
                                            .withValues(alpha: 0.15),
                                        blurRadius: 1.5,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
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
}

/// Modal de detalle del producto — bottom sheet compacto
class DetalleProductoModal extends StatefulWidget {
  final Producto producto;

  const DetalleProductoModal({required this.producto, super.key});

  @override
  State<DetalleProductoModal> createState() => _DetalleProductoModalState();
}

class _DetalleProductoModalState extends State<DetalleProductoModal> {
  static const _pink = AppColors.primary;
  static const _black = Color(0xFF1A1A1A);

  late PageController _pageController;
  int _imagenActual = 0;
  String? _talla;
  String? _color;
  int _cantidad = 1;

  String _cop(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final canAdd = (_talla != null || p.tallas.isEmpty) && (_color != null || p.colores.isEmpty);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Imagen con badges flotantes ──────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _imagenActual = i),
                  itemCount: p.imagenes.length,
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: p.imagenes[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFFF0F0F0)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFF0F0F0),
                      child: const Icon(Icons.image_not_supported,
                          size: 48, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              // Badge descuento o sale
              if (p.hayDescuento || p.categoria == 'sale')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.hayDescuento
                          ? const Color(0xFFC62828)
                          : const Color(0xFFD65391),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.hayDescuento
                          ? '-${p.descuentoPorcentaje.toStringAsFixed(0)}%'
                          : 'SALE',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              // Favorito
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<FavoritosProvider>(
                  builder: (_, fav, __) {
                    final isFav = fav.isFavorito(p.id);
                    return GestureDetector(
                      onTap: () => fav.toggleFavorito(p.id),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? _pink : const Color(0xFFAAAAAA),
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Cerrar
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Color(0xFF666666)),
                  ),
                ),
              ),
              // Indicador páginas
              if (p.imagenes.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      p.imagenes.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _imagenActual == i ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _imagenActual == i
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Info scrolleable ─────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p.nombre,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _black)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (p.hayDescuento)
                            Text(
                              _cop(p.precioOriginal!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAAAAAA),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            _cop(p.precio),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${p.rating} · ${p.reviewCount} reseñas',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF888888)),
                      ),
                      const SizedBox(width: 12),
                      Text('Material: ${p.materiales}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          height: 1.5)),
                  const SizedBox(height: 14),

                  // ── Tallas ──
                  if (p.tallas.isNotEmpty) ...[
                    _label('Talla', _talla),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: p.tallas.map((t) {
                        final sel = _talla == t;
                        return GestureDetector(
                          onTap: () => setState(() => _talla = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? _pink : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: sel
                                      ? _pink
                                      : const Color(0xFFDDDDDD)),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                          color: _pink.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2))
                                    ]
                                  : [],
                            ),
                            child: Text(t,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xFF333333))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Colores ──
                  if (p.colores.isNotEmpty) ...[
                    _label('Color', _color),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: p.colores.map((c) {
                        final sel = _color == c;
                        final hex = p.colorHex[c] ?? '#000000';
                        final hexClean = hex.replaceFirst('#', '');
                        final colorVal =
                            int.tryParse('0xFF$hexClean') ?? 0xFF000000;
                        return GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Column(
                            children: [
                              Container(
                                width: sel ? 34 : 30,
                                height: sel ? 34 : 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(colorVal),
                                  border: Border.all(
                                    color: sel
                                        ? _pink
                                        : const Color(0xFFCCCCCC),
                                    width: sel ? 2.5 : 1,
                                  ),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                              color: _pink.withValues(
                                                  alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2))
                                        ]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(c,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: sel
                                          ? _pink
                                          : const Color(0xFF888888),
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.normal)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Cantidad ──
                  Row(
                    children: [
                      const Text('Cantidad',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _black)),
                      const Spacer(),
                      _btnCantidad(Icons.remove_rounded, () {
                        if (_cantidad > 1) setState(() => _cantidad--);
                      }),
                      const SizedBox(width: 14),
                      Text('$_cantidad',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 14),
                      _btnCantidad(Icons.add_rounded,
                          () => setState(() => _cantidad++)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Botones de acción ────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).viewPadding.bottom + 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              children: [
                // Agregar al carrito
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: canAdd
                          ? () {
                              context.read<CarritoProvider>().agregarAlCarrito(
                                    widget.producto,
                                    _talla ?? '',
                                    _color ?? '',
                                    _cantidad,
                                  );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('¡Agregado al carrito!',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13)),
                                            Text(widget.producto.nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFFd65391),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  elevation: 6,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      label: const Text('Al carrito',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFDDDDDD),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Comprar ahora — abre checkout directo sin tocar el carrito
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: canAdd
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF2D1B24),
                                Color(0xFF7A3350),
                                Color(0xFFD65391),
                              ],
                            )
                          : null,
                      color: canAdd ? null : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: canAdd
                          ? () {
                              final item = CartItem(
                                id: '${widget.producto.id}_direct',
                                producto: widget.producto,
                                talla: _talla ?? '',
                                color: _color ?? '',
                                cantidad: _cantidad,
                              );
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                useRootNavigator: true,
                                builder: (_) => DraggableScrollableSheet(
                                  initialChildSize: 0.92,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.95,
                                  builder: (_, __) => CheckoutModalContent(
                                    itemsDirectos: [item],
                                  ),
                                ),
                              ).then((_) {
                                if (context.mounted) Navigator.pop(context);
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Comprar',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _label(String titulo, String? seleccionado) => Row(
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _black)),
          if (seleccionado != null) ...[
            const SizedBox(width: 8),
            Text(seleccionado,
                style: const TextStyle(
                    fontSize: 12,
                    color: _pink,
                    fontWeight: FontWeight.w600)),
          ],
        ],
      );

  Widget _btnCantidad(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _black),
        ),
      );
}

/// Bottom sheet de filtros con diseño de marca
class FiltrosDrawer extends StatefulWidget {
  const FiltrosDrawer({super.key});

  @override
  State<FiltrosDrawer> createState() => _FiltrosDrawerState();
}

class _FiltrosDrawerState extends State<FiltrosDrawer> {
  static const _pink = AppColors.primary;
  static const _black = Color(0xFF1A1A1A);

  String _cop(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  bool _tallasExpanded = true;
  bool _coloresExpanded = false;
  bool _tiposExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TiendaProvider>(
      builder: (context, tiendaProvider, _) {
        final precioMaxReal = tiendaProvider.getPrecioMaximo();
        final maxSlider = precioMaxReal > 0 ? precioMaxReal : 1000000.0;
        final currentMin = tiendaProvider.precioMin.clamp(0.0, maxSlider);
        final currentMax = tiendaProvider.precioMax.clamp(0.0, maxSlider);

        final totalActivos = tiendaProvider.tallasSeleccionadas.length +
            tiendaProvider.coloresSeleccionados.length +
            tiendaProvider.tiposSeleccionados.length;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header filtros
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Filtros',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (totalActivos > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _pink.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$totalActivos activo${totalActivos != 1 ? 's' : ''}',
                              style: const TextStyle(
                                  color: _pink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (totalActivos > 0)
                          GestureDetector(
                            onTap: () => setState(() {
                              tiendaProvider.limpiarFiltros();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Limpiar',
                                style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contenido scrolleable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Rango de Precio ---
                      _seccionTitulo('Rango de Precio',
                          Icons.attach_money_rounded),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _precioBadge(_cop(currentMin)),
                          const Spacer(),
                          _precioBadge(_cop(currentMax)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: _pink,
                          inactiveTrackColor:
                              const Color(0xFFEEEEEE),
                          thumbColor: _pink,
                          overlayColor:
                              _pink.withValues(alpha: 0.15),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 11),
                          rangeThumbShape:
                              const RoundRangeSliderThumbShape(
                                  enabledThumbRadius: 11),
                        ),
                        child: RangeSlider(
                          values: RangeValues(currentMin, currentMax),
                          min: 0,
                          max: maxSlider,
                          divisions: 20,
                          onChanged: (values) {
                            tiendaProvider.setPrecioRange(
                                values.start, values.end);
                          },
                          activeColor: _pink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 8),

                      // --- Tallas ---
                      _seccionExpandible(
                        titulo: 'Talla',
                        icono: Icons.straighten_rounded,
                        expandido: _tallasExpanded,
                        onToggle: () => setState(
                            () => _tallasExpanded = !_tallasExpanded),
                        seleccionados:
                            tiendaProvider.tallasSeleccionadas.length,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tiendaProvider
                              .getTallasDisponibles()
                              .map((talla) {
                            final sel = tiendaProvider
                                .tallasSeleccionadas
                                .contains(talla);
                            return GestureDetector(
                              onTap: () => setState(
                                  () => tiendaProvider.toggleTalla(talla)),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? _pink : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                    color: sel
                                        ? _pink
                                        : const Color(0xFFDDDDDD),
                                  ),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                            color: _pink.withValues(
                                                alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  talla,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        sel ? Colors.white : _black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(color: Color(0xFFF0F0F0)),

                      // --- Colores ---
                      _seccionExpandible(
                        titulo: 'Color',
                        icono: Icons.palette_outlined,
                        expandido: _coloresExpanded,
                        onToggle: () => setState(
                            () => _coloresExpanded = !_coloresExpanded),
                        seleccionados:
                            tiendaProvider.coloresSeleccionados.length,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tiendaProvider
                              .getColoresDisponibles()
                              .map((color) {
                            final sel = tiendaProvider
                                .coloresSeleccionados
                                .contains(color);
                            return GestureDetector(
                              onTap: () => setState(
                                  () => tiendaProvider.toggleColor(color)),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel ? _pink : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: sel
                                        ? _pink
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                child: Text(
                                  color,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        sel ? Colors.white : _black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(color: Color(0xFFF0F0F0)),

                      // --- Tipo ---
                      _seccionExpandible(
                        titulo: 'Tipo de producto',
                        icono: Icons.category_outlined,
                        expandido: _tiposExpanded,
                        onToggle: () => setState(
                            () => _tiposExpanded = !_tiposExpanded),
                        seleccionados:
                            tiendaProvider.tiposSeleccionados.length,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tiendaProvider
                              .getTiposDisponibles()
                              .map((tipo) {
                            final sel = tiendaProvider
                                .tiposSeleccionados
                                .contains(tipo);
                            return GestureDetector(
                              onTap: () => setState(
                                  () => tiendaProvider.toggleTipo(tipo)),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? _pink.withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                    color: sel
                                        ? _pink
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                child: Text(
                                  tipo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: sel ? _pink : _black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Botón aplicar
              Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20,
                    MediaQuery.of(context).viewPadding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      totalActivos > 0
                          ? 'Ver resultados ($totalActivos filtro${totalActivos != 1 ? 's' : ''})'
                          : 'Ver todos los productos',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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

  Widget _seccionTitulo(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 18, color: _pink),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _black),
        ),
      ],
    );
  }

  Widget _precioBadge(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _pink.withValues(alpha: 0.2)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _pink),
      ),
    );
  }

  Widget _seccionExpandible({
    required String titulo,
    required IconData icono,
    required bool expandido,
    required VoidCallback onToggle,
    required int seleccionados,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icono, size: 18, color: _pink),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _black),
                ),
                if (seleccionados > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$seleccionados',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
                const Spacer(),
                Icon(
                  expandido
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFAAAAAA),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: expandido
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 250),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// Vista del carrito
class CarritoView extends StatelessWidget {
  const CarritoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, _) {
        if (carritoProvider.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 16),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: carritoProvider.items.length,
                itemBuilder: (context, index) {
                  final item = carritoProvider.items[index];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.producto.imagen,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.lightGray,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.lightGray,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.producto.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.talla} - ${item.color}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item.producto.precio.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (item.cantidad > 1) {
                                                carritoProvider
                                                    .actualizarCantidad(
                                                  item.id,
                                                  item.cantidad - 1,
                                                );
                                              }
                                            },
                                            child: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 18,
                                                color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${item.cantidad}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              carritoProvider
                                                  .actualizarCantidad(
                                                item.id,
                                                item.cantidad + 1,
                                              );
                                            },
                                            child: const Icon(
                                                Icons.add_circle_outline,
                                                size: 18,
                                                color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () {
                                carritoProvider.eliminarDelCarrito(item.id);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '\$${carritoProvider.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío:',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        carritoProvider.subtotal > 0
                            ? '\$${carritoProvider.envio}'
                            : 'Gratis',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${carritoProvider.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: carritoProvider.items.isEmpty
                        ? null
                        : () {
                            AppSnackBar.show(context, 'Ir a Checkout', type: SnackType.info);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: AppColors.textLight,
                    ),
                    child: const Text('Ir a Checkout'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
