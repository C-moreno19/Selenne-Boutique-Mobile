import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../routes/app_routes.dart';
import '../../core/services/cart_service.dart';
import '../../core/utils/adaptive_image.dart';
import 'checkout_modal_content.dart';

const _pink = Color(0xFFE91E8C);
const _darkPink = Color(0xFFA3145F);
const _lightPink = Color(0xFFFF6FC8);
const _black = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await CartService.getCartItems();
    setState(() {
      _cartItems.clear();
      _cartItems.addAll(items);
    });
  }

  String _cop(int price) =>
      '\$${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  int get _subtotal => _cartItems.fold(
      0, (s, i) => s + (i['price'] as int) * (i['quantity'] as int));

  void _removeItem(int index) {
    CartService.removeFromCart(_cartItems[index]).then((_) => _loadCart());
  }

  void _updateQuantity(int index, int change) {
    final item = _cartItems[index];
    final newQty = (item['quantity'] as int) + change;
    if (newQty > 0) {
      CartService.updateQuantity(item, newQty).then((_) => _loadCart());
    } else {
      _removeItem(index);
    }
  }

  void _abrirCheckout() {
    final items = _cartItems.map((m) {
      final precio = (m['price'] is int)
          ? (m['price'] as int).toDouble()
          : double.tryParse(m['price']?.toString() ?? '0') ?? 0.0;
      final producto = Producto(
        id: m['id']?.toString() ?? '0',
        nombre: m['name']?.toString() ?? '',
        precio: precio,
        imagen: m['image']?.toString() ?? '',
        imagenes: [m['image']?.toString() ?? ''],
        tallas: [m['size']?.toString() ?? ''],
        colores: [m['color']?.toString() ?? ''],
        colorHex: {},
        materiales: '',
        tipoProducto: '',
        subcategoria: '',
        categoria: 'mujer',
        rating: 0,
        reviewCount: 0,
        descripcion: '',
      );
      return CartItem(
        id: '${producto.id}_${m['size']}',
        producto: producto,
        talla: m['size']?.toString() ?? '',
        color: m['color']?.toString() ?? '',
        cantidad: (m['quantity'] as int? ?? 1),
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, __) => CheckoutModalContent(itemsDirectos: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: _pink,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_cartItems.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Vaciar bolsa'),
                        content: const Text(
                            '¿Eliminar todos los productos?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Vaciar',
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      for (final item in List.from(_cartItems)) {
                        await CartService.removeFromCart(item);
                      }
                      _loadCart();
                    }
                  },
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white70, size: 18),
                  label: const Text('Vaciar',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_lightPink, _pink, _darkPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            const Text('Mi Bolsa',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_cartItems.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_cartItems.length} ítem${_cartItems.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────────────
          _cartItems.isEmpty
              ? SliverFillRemaining(child: _buildEmpty())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildItem(i),
                      childCount: _cartItems.length,
                    ),
                  ),
                ),

          // ── Resumen total ─────────────────────────────────────────────
          if (_cartItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildResumen(),
              ),
            ),
        ],
      ),

      // ── Botón proceder ─────────────────────────────────────────────────
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Total compacto
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontSize: 11, color: _grey)),
                      Text(
                        _cop(_subtotal),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _pink),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _abrirCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Proceder al Pago',
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
            ),
    );
  }

  // ── Tarjeta de producto ───────────────────────────────────────────────────

  Widget _buildItem(int index) {
    final item = _cartItems[index];
    final price = item['price'] as int;
    final qty = item['quantity'] as int;

    return Dismissible(
      key: Key('cart_${index}_${item['name']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 100,
                  color: const Color(0xFFF8F0F5),
                  child: AdaptiveImage(
                    src: item['image'] ?? '',
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: const Center(
                      child: Icon(Icons.image_outlined,
                          color: Color(0xFFCCCCCC), size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _badge('Talla ${item['size']}'),
                        const SizedBox(width: 6),
                        _badge(item['color'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _cop(price),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _pink),
                        ),
                        // Cantidad
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _qtyBtn(Icons.remove,
                                  () => _updateQuantity(index, -1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _black),
                                ),
                              ),
                              _qtyBtn(
                                  Icons.add, () => _updateQuantity(index, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (qty > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Subtotal: ${_cop(price * qty)}',
                        style: const TextStyle(
                            fontSize: 11, color: _grey),
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
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: _pink,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: _black),
      ),
    );
  }

  // ── Resumen ───────────────────────────────────────────────────────────────

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Código descuento
          TextField(
            decoration: InputDecoration(
              hintText: 'Código de descuento',
              hintStyle: const TextStyle(color: _grey, fontSize: 13),
              prefixIcon: const Icon(Icons.local_offer_outlined,
                  color: _grey, size: 18),
              suffixIcon: TextButton(
                onPressed: () {},
                child: const Text('Aplicar',
                    style: TextStyle(color: _pink, fontWeight: FontWeight.bold)),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _pink, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          _resumenRow('Subtotal (${_cartItems.length} ítems)',
              _cop(_subtotal)),
          const SizedBox(height: 6),
          _resumenRow('Envío', 'Gratis', valueColor: Colors.green),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _black)),
              Text(_cop(_subtotal),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _pink)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumenRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _grey)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? _black)),
      ],
    );
  }

  // ── Carrito vacío ─────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 48, color: _pink),
            ),
            const SizedBox(height: 20),
            const Text('Tu bolsa está vacía',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _black)),
            const SizedBox(height: 8),
            const Text(
              'Explora la tienda y agrega\nlos productos que te gusten',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (r) => false),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Ir a la tienda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
