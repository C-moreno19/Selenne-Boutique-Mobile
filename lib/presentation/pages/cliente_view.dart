import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/snackbar.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import 'checkout_modal_content.dart';
import 'orders_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla principal de la tienda
class ClienteView extends StatefulWidget {
  const ClienteView({super.key});

  @override
  State<ClienteView> createState() => _ClienteViewState();
}


class _ClienteViewState extends State<ClienteView>
    with SingleTickerProviderStateMixin {
  String _vistaActual = 'tienda'; // tienda, favoritos, notificaciones, perfil
  final _searchController = TextEditingController();
  late TabController _perfilTabController;

  // Controladores perfil
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  // Controladores cambio de contraseña
  final _passActualCtrl = TextEditingController();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _perfilGuardando = false;
  bool _passGuardando = false;
  bool _perfilInicializado = false;
  bool _searchVisible = false;

  int _paginaActual = 1;
  static const int _productosPorPagina = 6;

  String _formatCOP(double valor) {
    final partes = valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\$$partes';
  }

  @override
  void initState() {
    super.initState();
    _perfilTabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restaurarSesion());
  }

  void _restaurarSesion() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.usuarioActual != null) {
      context.read<OrderProvider>().cargarPedidos(auth.usuarioActual!.usuarioID);
      context.read<NotificationProvider>().cargarNotificaciones();
      context.read<FavoritosProvider>().sincronizarConAPI();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _perfilTabController.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _ciudadCtrl.dispose();
    _documentoCtrl.dispose();
    _direccionCtrl.dispose();
    _passActualCtrl.dispose();
    _passNuevaCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: null,
      bottomNavigationBar:
          Responsive.isMobile(context) ? _buildBottomNav() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isMobile = Responsive.isMobile(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: const Color(0x14000000),
      titleSpacing: 16,
      title: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Image.asset('assets/icons/logo_selenne.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Text(
            'Selenne Boutique',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        // Buscar
        IconButton(
          icon: Icon(
            _searchVisible ? Icons.search_off_outlined : Icons.search_outlined,
            color: const Color(0xFF1A1A1A),
          ),
          onPressed: () {
            setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) {
                _searchController.clear();
                context.read<TiendaProvider>().setBusqueda('');
              }
            });
          },
        ),
        // Campana (mobile)
        if (isMobile)
          Consumer<NotificationProvider>(
            builder: (context, notif, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1A)),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotificationsPage())),
                ),
                if (notif.notificacionesNoLeidas > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 15, height: 15,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${notif.notificacionesNoLeidas}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Carrito (desktop)
        if (!isMobile)
          Consumer<CarritoProvider>(
            builder: (context, carrito, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1A1A1A)),
                  onPressed: _mostrarCarrito,
                ),
                if (carrito.itemCount > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 15, height: 15,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${carrito.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF1A1A1A)),
            onPressed: () => setState(() => _vistaActual = 'perfil'),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        context.read<TiendaProvider>().setBusqueda(value);
        setState(() => _paginaActual = 1);
      },
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  context.read<TiendaProvider>().setBusqueda('');
                },
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary, size: 20),
              )
            : null,
        filled: true,
        fillColor: AppColors.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildBody() {
    if (_vistaActual == 'tienda') {
      return _buildTienda();
    } else if (_vistaActual == 'favoritos') {
      return _buildFavoritos();
    } else if (_vistaActual == 'notificaciones') {
      return const NotificationsPage();
    } else {
      return _buildPerfil();
    }
  }

  Widget _buildTienda() {
    return Consumer<TiendaProvider>(
      builder: (context, tiendaProvider, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => tiendaProvider.cargarProductos(),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Barra de búsqueda colapsable
              if (_searchVisible)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: _buildSearchBar(),
                ),
              // Banner principal estilo colección
              _buildHeroBanner(),
              const SizedBox(height: 12),
              // Categorías
              _buildCategorias(),
              // Barra resultados + filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${tiendaProvider.filteredProductos.length} productos encontrados',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    if (Responsive.isMobile(context))
                      Consumer<TiendaProvider>(
                        builder: (context, tp, _) {
                          final hayFiltros =
                              tp.tallasSeleccionadas.isNotEmpty ||
                              tp.coloresSeleccionados.isNotEmpty ||
                              tp.tiposSeleccionados.isNotEmpty;
                          return GestureDetector(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const FiltrosDrawer(),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: hayFiltros ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: hayFiltros ? 0 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tune_rounded,
                                      size: 16,
                                      color: hayFiltros ? Colors.white : AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    hayFiltros ? 'Filtros activos' : 'Filtrar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: hayFiltros ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    if (!Responsive.isMobile(context)) Flexible(child: _buildOrdenamiento()),
                  ],
                ),
              ),
              // Aviso cuando el catálogo carga desde datos de muestra
              if (tiendaProvider.errorProductos != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sin conexión al servidor. Mostrando catálogo de muestra. Desliza hacia abajo para reintentar.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              // Grid de productos
              _buildGridProductos(),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8E5)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NUEVA COLECCIÓN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Moda\nFemenina',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elegancia y estilo para ti',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D1B24), Color(0xFF7A3350), AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Ver colección',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diamond_outlined, color: AppColors.primary, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return Consumer<TiendaProvider>(
      builder: (context, tiendaProvider, _) {
        final categorias = [
          {'label': 'Todos', 'value': 'todos'},
          {'label': 'Mujer', 'value': 'mujer'},
          {'label': 'Accesorios', 'value': 'accesorios'},
          {'label': 'Sale', 'value': 'sale'},
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: categorias.map((cat) {
                final isActive = tiendaProvider.categoriaActiva == cat['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      tiendaProvider.setCategoriaActiva(cat['value']!);
                      setState(() => _paginaActual = 1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isActive ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdenamiento() {
    return Consumer<TiendaProvider>(
      builder: (context, tiendaProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text(
                'Ordenar por:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: tiendaProvider.ordenamiento,
                  isExpanded: true,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(
                        value: 'destacados', child: Text('Destacados')),
                    DropdownMenuItem(
                        value: 'precioMenor', child: Text('Precio menor')),
                    DropdownMenuItem(
                        value: 'precioMayor', child: Text('Precio mayor')),
                    DropdownMenuItem(
                        value: 'nombre', child: Text('Nombre')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      tiendaProvider.setOrdenamiento(value);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridProductos() {
    return Consumer<TiendaProvider>(
      builder: (context, tiendaProvider, _) {
        final todos = tiendaProvider.filteredProductos;

        if (todos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textLight),
                SizedBox(height: 16),
                Text('No hay productos disponibles',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final totalPaginas = (todos.length / _productosPorPagina).ceil().clamp(1, 9999);
        final paginaSegura = _paginaActual.clamp(1, totalPaginas);
        if (paginaSegura != _paginaActual) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _paginaActual = paginaSegura);
          });
        }

        final inicio = (paginaSegura - 1) * _productosPorPagina;
        final fin = (inicio + _productosPorPagina).clamp(0, todos.length);
        final productosEnPagina = todos.sublist(inicio, fin);

        final columns = Responsive.getGridColumns(context);
        final padding = Responsive.getHorizontalPadding(context);

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: productosEnPagina.length,
                itemBuilder: (context, index) {
                  final producto = productosEnPagina[index];
                  return ProductCard(
                    producto: producto,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => DetalleProductoModal(producto: producto),
                      );
                    },
                  );
                },
              ),
            ),
            if (totalPaginas > 1) _buildPaginador(paginaSegura, totalPaginas),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildPaginador(int pagina, int totalPaginas) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _paginadorBtn(
            icon: Icons.chevron_left_rounded,
            enabled: pagina > 1,
            onTap: () => setState(() => _paginaActual = pagina - 1),
          ),
          const SizedBox(width: 6),
          ..._paginaChips(pagina, totalPaginas),
          const SizedBox(width: 6),
          _paginadorBtn(
            icon: Icons.chevron_right_rounded,
            enabled: pagina < totalPaginas,
            onTap: () => setState(() => _paginaActual = pagina + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _paginaChips(int pagina, int total) {
    final chips = <Widget>[];
    int start = (pagina - 2).clamp(1, total);
    int end = (start + 4).clamp(1, total);
    if (end - start < 4) start = (end - 4).clamp(1, total);

    if (start > 1) {
      chips.add(_paginaNum(1, pagina));
      if (start > 2) {
        chips.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
        ));
      }
    }
    for (int i = start; i <= end; i++) {
      chips.add(_paginaNum(i, pagina));
    }
    if (end < total) {
      if (end < total - 1) {
        chips.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
        ));
      }
      chips.add(_paginaNum(total, pagina));
    }
    return chips;
  }

  Widget _paginaNum(int num, int actual) {
    final isActive = num == actual;
    return GestureDetector(
      onTap: () => setState(() => _paginaActual = num),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE0E0E0),
          ),
        ),
        child: Center(
          child: Text(
            '$num',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? Colors.white : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paginadorBtn({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildFavoritos() {
    return Consumer2<FavoritosProvider, TiendaProvider>(
      builder: (context, favoritosProvider, tiendaProvider, _) {
        final productosFav = tiendaProvider.allProductos
            .where((p) => favoritosProvider.isFavorito(p.id))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado sección
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Favoritos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${productosFav.length} producto${productosFav.length != 1 ? 's' : ''} guardados',
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: productosFav.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_border_rounded,
                                size: 44, color: AppColors.primary),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Sin favoritos aún',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toca el corazón en cualquier producto\npara guardarlo aquí',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF888888), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(
                          Responsive.getHorizontalPadding(context)),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            Responsive.getGridColumns(context),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.55,
                      ),
                      itemCount: productosFav.length,
                      itemBuilder: (context, index) {
                        final producto =
                            productosFav[index];
                        return ProductCard(
                          producto: producto,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  DetalleProductoModal(producto: producto),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _perfilInputDeco(String label, IconData icon,
          {bool readOnly = false}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        prefixIcon:
            Icon(icon, color: const Color(0xFF888888), size: 20),
        filled: true,
        fillColor:
            readOnly ? const Color(0xFFF5F5F5) : const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      );

  Widget _buildPerfil() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final usuario = auth.usuarioActual;

        if (!_perfilInicializado && usuario != null) {
          _nombreCtrl.text = usuario.nombre;
          _telefonoCtrl.text = usuario.telefono;
          _ciudadCtrl.text = usuario.ciudad ?? '';
          _documentoCtrl.text = usuario.documento ?? '';
          _direccionCtrl.text = usuario.direccion ?? '';
          _perfilInicializado = true;
        }

        return Column(
          children: [
            // Tarjeta de usuario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  // Avatar con inicial
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2D1B24), Color(0xFF7A3350), AppColors.primary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33D65391),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (usuario?.nombre.isNotEmpty == true)
                            ? usuario!.nombre[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nombre ?? 'Usuario',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usuario?.email ?? '',
                          style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
                        ),
                        if (usuario?.ciudad != null &&
                            usuario!.ciudad!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: Color(0xFF888888)),
                              const SizedBox(width: 3),
                              Text(
                                usuario.ciudad!,
                                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
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
            // TabBar sobre fondo blanco
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _perfilTabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF888888),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Información'),
                  Tab(text: 'Seguridad'),
                  Tab(text: 'Cuenta'),
                ],
              ),
            ),
            // Contenido tabs
            Expanded(
              child: TabBarView(
                controller: _perfilTabController,
                children: [
                  // Tab 1: Información Personal
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        TextField(
                          controller: _nombreCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _perfilInputDeco(
                              'Nombre Completo', Icons.person_outline),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: usuario?.email ?? ''),
                          decoration: _perfilInputDeco(
                              'Correo Electrónico', Icons.email_outlined,
                              readOnly: true),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: _perfilInputDeco(
                              'Teléfono', Icons.phone_outlined),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _ciudadCtrl,
                          decoration: _perfilInputDeco(
                              'Ciudad', Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _documentoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _perfilInputDeco(
                              'Documento', Icons.badge_outlined),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _direccionCtrl,
                          decoration: _perfilInputDeco(
                              'Dirección', Icons.home_outlined),
                        ),
                        const SizedBox(height: 6),
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD64545)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFD64545)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Text(auth.error!,
                                  style: const TextStyle(
                                      color: Color(0xFFD64545),
                                      fontSize: 13)),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: _perfilGuardando
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFF2D1B24), Color(0xFF7A3350), AppColors.primary],
                                  ),
                            color: _perfilGuardando ? const Color(0xFFDDDDDD) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: _perfilGuardando
                                ? null
                                : () async {
                                    setState(
                                        () => _perfilGuardando = true);
                                    final ok = await auth.actualizarPerfil(
                                      nombre: _nombreCtrl.text.trim(),
                                      telefono: _telefonoCtrl.text.trim(),
                                      ciudad: _ciudadCtrl.text.trim(),
                                      documento: _documentoCtrl.text.trim(),
                                      direccion: _direccionCtrl.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    setState(
                                        () => _perfilGuardando = false);
                                    AppSnackBar.show(context,
                                        ok ? 'Perfil actualizado' : (auth.error ?? 'Error al guardar'),
                                        type: ok ? SnackType.success : SnackType.error);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: const Color(0xFF999999),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: _perfilGuardando
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Guardar Cambios',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Seguridad
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        TextField(
                          controller: _passActualCtrl,
                          obscureText: true,
                          decoration: _perfilInputDeco(
                              'Contraseña Actual', Icons.lock_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passNuevaCtrl,
                          obscureText: true,
                          decoration: _perfilInputDeco(
                              'Nueva Contraseña', Icons.lock_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passConfirmCtrl,
                          obscureText: true,
                          decoration: _perfilInputDeco(
                              'Confirmar Contraseña', Icons.lock_outline_rounded),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: _passGuardando
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFF2D1B24), Color(0xFF7A3350), AppColors.primary],
                                  ),
                            color: _passGuardando ? const Color(0xFFDDDDDD) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: _passGuardando
                                ? null
                                : () async {
                                    if (_passNuevaCtrl.text !=
                                        _passConfirmCtrl.text) {
                                      AppSnackBar.show(context, 'Las contraseñas no coinciden', type: SnackType.error);
                                      return;
                                    }
                                    if (_passNuevaCtrl.text.length < 6) {
                                      AppSnackBar.show(context, 'Mínimo 6 caracteres', type: SnackType.error);
                                      return;
                                    }
                                    setState(() => _passGuardando = true);
                                    final ok = await auth.cambiarContrasena(
                                      actual: _passActualCtrl.text,
                                      nueva: _passNuevaCtrl.text,
                                    );
                                    if (!context.mounted) return;
                                    setState(
                                        () => _passGuardando = false);
                                    if (ok) {
                                      _passActualCtrl.clear();
                                      _passNuevaCtrl.clear();
                                      _passConfirmCtrl.clear();
                                    }
                                    AppSnackBar.show(context,
                                        ok ? 'Contraseña actualizada' : (auth.error ?? 'Error al cambiar contraseña'),
                                        type: ok ? SnackType.success : SnackType.error);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: const Color(0xFF999999),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: _passGuardando
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Actualizar Contraseña',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab 3: Cuenta
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Card opciones de cuenta
                        Container(
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
                          child: Column(
                            children: [
                              _cuentaOpcion(
                                  Icons.shopping_bag_outlined,
                                  'Mis Pedidos',
                                  'Ver historial de compras',
                                  AppColors.primary,
                                  () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const OrdersPage()),
                                      )),
                              const Divider(height: 1, indent: 60),
                              _cuentaOpcion(
                                  Icons.notifications_outlined,
                                  'Notificaciones',
                                  'Gestionar alertas',
                                  const Color(0xFF1565C0),
                                  () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const NotificationsPage()),
                                      )),
                              const Divider(height: 1, indent: 60),
                              _cuentaOpcion(
                                  Icons.help_outline,
                                  'Ayuda',
                                  'Escríbenos por WhatsApp',
                                  const Color(0xFF2E7D32),
                                  () async {
                                    const numero = '573042928493';
                                    const mensaje = 'Hola, necesito ayuda con mi pedido en Selenne Boutique.';
                                    final uri = Uri.parse(
                                        'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Botón cerrar sesión
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              context
                                  .read<FavoritosProvider>()
                                  .limpiar();
                              context
                                  .read<NotificationProvider>()
                                  .limpiarTodas();
                              context.read<OrderProvider>().limpiar();
                              await context
                                  .read<AuthProvider>()
                                  .logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout_outlined),
                            label: const Text('Cerrar Sesión',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cuentaOpcion(IconData icon, String titulo, String subtitulo,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitulo,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final currentIndex = _vistaActual == 'tienda'
        ? 0
        : _vistaActual == 'favoritos'
            ? 1
            : _vistaActual == 'notificaciones'
                ? 2
                : _vistaActual == 'perfil'
                    ? 3
                    : -1; // carrito no es una vista, no resalta ninguno

    void onTap(int index) {
      if (index == 0) { setState(() => _vistaActual = 'tienda'); }
      else if (index == 1) { setState(() => _vistaActual = 'favoritos'); }
      else if (index == 2) { setState(() => _vistaActual = 'notificaciones'); }
      else if (index == 3) { setState(() => _vistaActual = 'perfil'); }
      else if (index == 4) { _mostrarCarrito(); }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              // ── Tienda ──────────────────────────────────────────────────────
              _navPill(
                index: 0,
                current: currentIndex,
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: 'Tienda',
                onTap: onTap,
              ),
              // ── Favoritos ───────────────────────────────────────────────────
              _navPill(
                index: 1,
                current: currentIndex,
                activeIcon: Icons.favorite_rounded,
                inactiveIcon: Icons.favorite_border_rounded,
                label: 'Favoritos',
                onTap: onTap,
              ),
              // ── Alertas (con badge) ─────────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<NotificationProvider>(
                        builder: (context, notif, _) {
                          final isActive = currentIndex == 2;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  isActive
                                      ? Icons.notifications_rounded
                                      : Icons.notifications_none_rounded,
                                  color: isActive ? Colors.white : const Color(0xFFAAAAAA),
                                  size: 22,
                                ),
                              ),
                              if (notif.contadorNoLeidas > 0)
                                Positioned(
                                  top: -3,
                                  right: isActive ? -2 : -6,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFE53935),
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        notif.contadorNoLeidas > 9
                                            ? '9+'
                                            : '${notif.contadorNoLeidas}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: currentIndex == 2
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: currentIndex == 2
                              ? AppColors.primary
                              : const Color(0xFFAAAAAA),
                        ),
                        child: const Text('Alertas'),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Perfil ──────────────────────────────────────────────────────
              _navPill(
                index: 3,
                current: currentIndex,
                activeIcon: Icons.account_circle_rounded,
                inactiveIcon: Icons.account_circle_outlined,
                label: 'Perfil',
                onTap: onTap,
              ),
              // ── Carrito (sin cambios en el ícono) ───────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(4),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<CarritoProvider>(
                        builder: (context, carrito, _) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFFAAAAAA),
                                size: 22,
                              ),
                            ),
                            if (carrito.itemCount > 0)
                              Positioned(
                                top: -3,
                                right: -6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      '${carrito.itemCount}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Carrito',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFAAAAAA)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navPill({
    required int index,
    required int current,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required void Function(int) onTap,
  }) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? Colors.white : const Color(0xFFAAAAAA),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : const Color(0xFFAAAAAA),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCarrito() {
    // Reemplazamos el modal por el modal personalizado del carrito
    showCartModal();
  }

  // Muestra el carrito como bottom sheet usando CarritoProvider
  void showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Consumer<CarritoProvider>(
          builder: (context, carrito, __) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Handle + Header ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                width: 36, height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text('Mi Carrito',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A1A),
                                    )),
                                const Spacer(),
                                if (carrito.itemCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFd65391).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${carrito.itemCount} ítem${carrito.itemCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                          color: Color(0xFFd65391),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),

                      // ── Lista o vacío ─────────────────────────────────────
                      if (carrito.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_bag_outlined,
                                    size: 36, color: Color(0xFFCCCCCC)),
                              ),
                              const SizedBox(height: 16),
                              const Text('Tu carrito está vacío',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A))),
                              const SizedBox(height: 6),
                              const Text('Agrega productos para continuar',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            itemCount: carrito.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = carrito.items[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFF0F0F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Imagen
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: item.producto.imagen,
                                        width: 78, height: 88,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 78, height: 88,
                                          color: const Color(0xFFF5F5F5),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 78, height: 88,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.image_not_supported,
                                              color: Color(0xFFCCCCCC)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(item.producto.nombre,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF1A1A1A))),
                                              ),
                                              const SizedBox(width: 4),
                                              GestureDetector(
                                                onTap: () => carrito.eliminarDelCarrito(item.id),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.close_rounded,
                                                      size: 14, color: Color(0xFF888888)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              if (item.talla.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('Talla ${item.talla}',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0xFF666666))),
                                                ),
                                              if (item.color.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(item.color,
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0xFF666666))),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_formatCOP(item.producto.precio * item.cantidad),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFFd65391))),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF5F5F5),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => carrito.actualizarCantidad(
                                                          item.id, item.cantidad - 1),
                                                      child: Container(
                                                        width: 30, height: 30,
                                                        alignment: Alignment.center,
                                                        child: const Icon(Icons.remove_rounded,
                                                            size: 16, color: Color(0xFF555555)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 28,
                                                      child: Text('${item.cantidad}',
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 13)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => carrito.actualizarCantidad(
                                                          item.id, item.cantidad + 1),
                                                      child: Container(
                                                        width: 30, height: 30,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFd65391),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: const Icon(Icons.add_rounded,
                                                            size: 16, color: Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // ── Resumen + Botón ───────────────────────────────────
                      if (carrito.items.isNotEmpty)
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              20, 16, 20, MediaQuery.of(context).viewPadding.bottom + 16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                                  Text(_formatCOP(carrito.subtotal),
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Envío',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                                  Text('Gratis',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32))),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total',
                                      style: TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w800,
                                          color: Color(0xFF1A1A1A))),
                                  Text(_formatCOP(carrito.total),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFd65391))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2D1B24),
                                      Color(0xFF7A3350),
                                      Color(0xFFD65391),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(modalContext).pop();
                                    Future.delayed(
                                        const Duration(milliseconds: 200), showCheckoutModal);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_outline_rounded,
                                          size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Proceder al Pago',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15)),
                                    ],
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
            );
          },
        );
      },
    );
  }

  // Muestra el checkout como un bottom sheet
  void showCheckoutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.95,
            child: const CheckoutModalContent(),
          ),
        );
      },
    );
  }
}
