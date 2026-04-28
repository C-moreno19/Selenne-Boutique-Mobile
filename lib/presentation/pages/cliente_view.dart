import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/responsive.dart';
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
  const ClienteView({Key? key}) : super(key: key);

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
  // Controladores cambio de contraseña
  final _passActualCtrl = TextEditingController();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _perfilGuardando = false;
  bool _passGuardando = false;
  bool _perfilInicializado = false;

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

    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 130 : kToolbarHeight + 60),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Franja de marca rosada
              Container(
                height: 46,
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getHorizontalPadding(context)),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6FC8), Color(0xFFE91E8C), Color(0xFFA3145F)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Logo pequeño
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset('assets/icons/logo_selenne.png',
                          fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Selenne Boutique',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    // Icono campana (mobile)
                    if (isMobile)
                      Consumer<NotificationProvider>(
                        builder: (context, notif, _) => Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const NotificationsPage())),
                            ),
                            if (notif.notificacionesNoLeidas > 0)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text('${notif.notificacionesNoLeidas}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    // Icono carrito (solo desktop)
                    if (!isMobile)
                      Consumer<CarritoProvider>(
                        builder: (context, carrito, _) => Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white),
                              onPressed: _mostrarCarrito,
                            ),
                            if (carrito.itemCount > 0)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text('${carrito.itemCount}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (!isMobile)
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: Colors.white),
                        onPressed: () =>
                            setState(() => _vistaActual = 'perfil'),
                      ),
                  ],
                ),
              ),
              // Barra de búsqueda
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getHorizontalPadding(context),
                  vertical: 10,
                ),
                child: _buildSearchBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        context.read<TiendaProvider>().setBusqueda(value);
      },
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 12),
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  context.read<TiendaProvider>().setBusqueda('');
                },
                child: const Icon(Icons.close,
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
          color: const Color(0xFFE91E8C),
          onRefresh: () => tiendaProvider.cargarProductos(),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
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
                                gradient: hayFiltros
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFF6FC8), Color(0xFFE91E8C)],
                                      )
                                    : null,
                                color: hayFiltros ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE91E8C),
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
                                      color: hayFiltros
                                          ? Colors.white
                                          : const Color(0xFFE91E8C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    hayFiltros ? 'Filtros activos' : 'Filtrar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: hayFiltros
                                          ? Colors.white
                                          : const Color(0xFFE91E8C),
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
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6FC8), Color(0xFFE91E8C), Color(0xFFA3145F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E8C).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Nueva Colección',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Moda\nFemenina',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elegancia y estilo para ti',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ver colección',
                    style: TextStyle(
                        color: Color(0xFFE91E8C),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Decoración derecha
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.diamond_outlined,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer_outlined,
                    color: Colors.white70, size: 22),
              ),
            ],
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
                  items: [
                    const DropdownMenuItem(
                        value: 'destacados', child: Text('Destacados')),
                    const DropdownMenuItem(
                        value: 'precioMenor', child: Text('Precio menor')),
                    const DropdownMenuItem(
                        value: 'precioMayor', child: Text('Precio mayor')),
                    const DropdownMenuItem(
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
        if (tiendaProvider.filteredProductos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay productos disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final columns = Responsive.getGridColumns(context);
        final padding = Responsive.getHorizontalPadding(context);

        return Padding(
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
            itemCount: tiendaProvider.filteredProductos.length,
            itemBuilder: (context, index) {
              final producto = tiendaProvider.filteredProductos[index];
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
        );
      },
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6FC8), Color(0xFFE91E8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Favoritos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${productosFav.length} producto${productosFav.length != 1 ? 's' : ''} guardados',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13),
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
                            child: const Icon(Icons.favorite_outline,
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
            borderSide:
                const BorderSide(color: Color(0xFFE91E8C), width: 2)),
      );

  Widget _buildPerfil() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final usuario = auth.usuarioActual;

        if (!_perfilInicializado && usuario != null) {
          _nombreCtrl.text = usuario.nombre;
          _telefonoCtrl.text = usuario.telefono;
          _ciudadCtrl.text = usuario.ciudad ?? '';
          _perfilInicializado = true;
        }

        return Column(
          children: [
            // Tarjeta de usuario con degradado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF6FC8),
                    Color(0xFFE91E8C),
                    Color(0xFFA3145F)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Avatar con inicial
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2),
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
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usuario?.email ?? '',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13),
                        ),
                        if (usuario?.ciudad != null &&
                            usuario!.ciudad!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.7)),
                              const SizedBox(width: 3),
                              Text(
                                usuario.ciudad!,
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12),
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
                indicatorColor: const Color(0xFFE91E8C),
                indicatorWeight: 3,
                labelColor: const Color(0xFFE91E8C),
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
                        SizedBox(
                          height: 50,
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
                                    );
                                    if (mounted) {
                                      setState(
                                          () => _perfilGuardando = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(ok
                                            ? 'Perfil actualizado'
                                            : (auth.error ??
                                                'Error al guardar')),
                                        backgroundColor: ok
                                            ? const Color(0xFF2E7D32)
                                            : Colors.red,
                                      ));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
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
                              'Contraseña Actual', Icons.lock_outlined),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passNuevaCtrl,
                          obscureText: true,
                          decoration: _perfilInputDeco(
                              'Nueva Contraseña', Icons.lock_outline),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passConfirmCtrl,
                          obscureText: true,
                          decoration: _perfilInputDeco(
                              'Confirmar Contraseña', Icons.lock_outline),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _passGuardando
                                ? null
                                : () async {
                                    if (_passNuevaCtrl.text !=
                                        _passConfirmCtrl.text) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Las contraseñas no coinciden'),
                                        backgroundColor: Colors.red,
                                      ));
                                      return;
                                    }
                                    if (_passNuevaCtrl.text.length < 6) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text('Mínimo 6 caracteres'),
                                        backgroundColor: Colors.red,
                                      ));
                                      return;
                                    }
                                    setState(() => _passGuardando = true);
                                    final ok = await auth.cambiarContrasena(
                                      actual: _passActualCtrl.text,
                                      nueva: _passNuevaCtrl.text,
                                    );
                                    if (mounted) {
                                      setState(
                                          () => _passGuardando = false);
                                      if (ok) {
                                        _passActualCtrl.clear();
                                        _passNuevaCtrl.clear();
                                        _passConfirmCtrl.clear();
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(ok
                                            ? 'Contraseña actualizada'
                                            : (auth.error ??
                                                'Error al cambiar contraseña')),
                                        backgroundColor: ok
                                            ? const Color(0xFF2E7D32)
                                            : Colors.red,
                                      ));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
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
                                  const Color(0xFFE91E8C),
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
    const _pink = Color(0xFFE91E8C);

    int currentIndex = _vistaActual == 'tienda'
        ? 0
        : _vistaActual == 'favoritos'
            ? 1
            : _vistaActual == 'notificaciones'
                ? 2
                : _vistaActual == 'perfil'
                    ? 3
                    : 4;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -3)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: _pink,
        unselectedItemColor: const Color(0xFFAAAAAA),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 0
                ? Icons.home_rounded
                : Icons.home_outlined),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 1
                ? Icons.favorite_rounded
                : Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, notif, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(currentIndex == 2
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined),
                  if (notif.contadorNoLeidas > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                            color: _pink, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${notif.contadorNoLeidas > 9 ? '9+' : notif.contadorNoLeidas}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 3
                ? Icons.person_rounded
                : Icons.person_outline_rounded),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CarritoProvider>(
              builder: (context, carrito, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(currentIndex == 4
                      ? Icons.shopping_bag_rounded
                      : Icons.shopping_bag_outlined),
                  if (carrito.itemCount > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                            color: _pink, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${carrito.itemCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Carrito',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            setState(() => _vistaActual = 'tienda');
          } else if (index == 1) {
            setState(() => _vistaActual = 'favoritos');
          } else if (index == 2) {
            setState(() => _vistaActual = 'notificaciones');
          } else if (index == 3) {
            setState(() => _vistaActual = 'perfil');
          } else if (index == 4) {
            _mostrarCarrito();
          }
        },
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
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.94,
          builder: (_, scrollController) {
            return Consumer<CarritoProvider>(
              builder: (context, carrito, __) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                  child: Column(
                    children: [
                      // Header con degradado
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF6FC8),
                              Color(0xFFE91E8C),
                              Color(0xFFA3145F)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24)),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                width: 40, height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Text(
                                  'Mi Carrito',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (carrito.itemCount > 0) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${carrito.itemCount} ítem${carrito.itemCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Lista de items o estado vacío
                      Expanded(
                        child: carrito.items.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('Tu carrito está vacío',
                                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: carrito.items.length,
                                itemBuilder: (context, index) {
                                  final item = carrito.items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        // Imagen
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.producto.imagen,
                                            width: 70, height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 70, height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image_not_supported),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.producto.nombre,
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                  maxLines: 2),
                                              const SizedBox(height: 4),
                                              Text('Talla: ${item.talla} • ${item.color}',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                              const SizedBox(height: 6),
                                              Text(_formatCOP(item.producto.precio),
                                                  style: const TextStyle(
                                                      color: AppColors.primary, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        // Cantidad
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () => carrito.eliminarDelCarrito(item.id),
                                              child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () => carrito.actualizarCantidad(item.id, item.cantidad - 1),
                                                  child: const Icon(Icons.remove_circle_outline,
                                                      size: 22, color: AppColors.textSecondary),
                                                ),
                                                const SizedBox(width: 8),
                                                Text('${item.cantidad}',
                                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () => carrito.actualizarCantidad(item.id, item.cantidad + 1),
                                                  child: const Icon(Icons.add_circle_outline,
                                                      size: 22, color: AppColors.primary),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      // Resumen y botón
                      if (carrito.items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:', style: TextStyle(color: AppColors.textSecondary)),
                                  Text(_formatCOP(carrito.subtotal),
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Envío:', style: TextStyle(color: AppColors.textSecondary)),
                                  const Text('Gratis',
                                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(_formatCOP(carrito.total),
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(modalContext).pop();
                                    Future.delayed(const Duration(milliseconds: 200), showCheckoutModal);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Proceder al Pago',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ),
                );
              },
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
