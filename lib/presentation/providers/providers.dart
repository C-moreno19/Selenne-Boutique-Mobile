import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';

/// Provider para gestionar la tienda: filtros, búsqueda, ordenamiento
class TiendaProvider extends ChangeNotifier {
  List<Producto> _allProductos = [];
  List<Producto> _filteredProductos = [];

  // Filtros activos
  String _categoriaActiva = 'mujer';
  String _busqueda = '';
  String _ordenamiento =
      'destacados'; // destacados, precioMenor, precioMayor, nombre

  // Filtros avanzados
  final List<String> _tallasSeleccionadas = [];
  final List<String> _coloresSeleccionados = [];
  final List<String> _materialesSeleccionados = [];
  final List<String> _tiposSeleccionados = [];
  double _precioMin = 0;
  double _precioMax = 500;

  bool _cargando = false;
  String? _errorProductos;

  // Getters
  List<Producto> get allProductos => _allProductos;
  List<Producto> get filteredProductos => _filteredProductos;
  String get categoriaActiva => _categoriaActiva;
  String get busqueda => _busqueda;
  String get ordenamiento => _ordenamiento;
  List<String> get tallasSeleccionadas => _tallasSeleccionadas;
  List<String> get coloresSeleccionados => _coloresSeleccionados;
  List<String> get materialesSeleccionados => _materialesSeleccionados;
  List<String> get tiposSeleccionados => _tiposSeleccionados;
  double get precioMin => _precioMin;
  double get precioMax => _precioMax;
  bool get cargando => _cargando;
  String? get errorProductos => _errorProductos;

  TiendaProvider() {
    _allProductos = List.from(productosOriginalData);
    _aplicarFiltros();
    cargarProductos();
  }

  /// Carga el catálogo desde el backend. Mantiene los datos de ejemplo
  /// como fallback si la API no responde.
  Future<void> cargarProductos() async {
    _cargando = true;
    _errorProductos = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/api/productos', auth: false);
      final List<dynamic> lista = data is List
          ? data
          : (data is Map && data['data'] is List
              ? List<dynamic>.from(data['data'] as List)
              : []);
      if (lista.isNotEmpty) {
        _allProductos = lista
            .map((j) => Producto.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        // Actualizar rango de precio máximo según productos reales
        _precioMax = getPrecioMaximo();
        _aplicarFiltros();
      }
    } catch (_) {
      _errorProductos = 'No se pudo cargar el catálogo';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Establece todos los productos
  void setAllProductos(List<Producto> productos) {
    _allProductos = productos;
    _aplicarFiltros();
  }

  /// Cambia la categoría activa
  void setCategoriaActiva(String categoria) {
    _categoriaActiva = categoria;
    _aplicarFiltros();
    notifyListeners();
  }

  /// Actualiza el término de búsqueda
  void setBusqueda(String busqueda) {
    _busqueda = busqueda.toLowerCase();
    _aplicarFiltros();
    notifyListeners();
  }

  /// Cambia el criterio de ordenamiento
  void setOrdenamiento(String ordenamiento) {
    _ordenamiento = ordenamiento;
    _aplicarFiltros();
    notifyListeners();
  }

  /// Selecciona o deselecciona una talla
  void toggleTalla(String talla) {
    if (_tallasSeleccionadas.contains(talla)) {
      _tallasSeleccionadas.remove(talla);
    } else {
      _tallasSeleccionadas.add(talla);
    }
    _aplicarFiltros();
    notifyListeners();
  }

  /// Selecciona o deselecciona un color
  void toggleColor(String color) {
    if (_coloresSeleccionados.contains(color)) {
      _coloresSeleccionados.remove(color);
    } else {
      _coloresSeleccionados.add(color);
    }
    _aplicarFiltros();
    notifyListeners();
  }

  /// Selecciona o deselecciona un material
  void toggleMaterial(String material) {
    if (_materialesSeleccionados.contains(material)) {
      _materialesSeleccionados.remove(material);
    } else {
      _materialesSeleccionados.add(material);
    }
    _aplicarFiltros();
    notifyListeners();
  }

  /// Selecciona o deselecciona un tipo
  void toggleTipo(String tipo) {
    if (_tiposSeleccionados.contains(tipo)) {
      _tiposSeleccionados.remove(tipo);
    } else {
      _tiposSeleccionados.add(tipo);
    }
    _aplicarFiltros();
    notifyListeners();
  }

  /// Establece el rango de precio
  void setPrecioRange(double min, double max) {
    _precioMin = min;
    _precioMax = max;
    _aplicarFiltros();
    notifyListeners();
  }

  /// Limpia todos los filtros
  void limpiarFiltros() {
    _busqueda = '';
    _tallasSeleccionadas.clear();
    _coloresSeleccionados.clear();
    _materialesSeleccionados.clear();
    _tiposSeleccionados.clear();
    _precioMin = 0;
    _precioMax = getPrecioMaximo();
    _aplicarFiltros();
    notifyListeners();
  }

  /// Aplica todos los filtros y ordenamiento
  void _aplicarFiltros() {
    var productos = _allProductos;

    // Filtrar por categoría
    if (_categoriaActiva != 'todos') {
      if (_categoriaActiva == 'sale') {
        productos = productos
            .where((p) => p.categoria == 'sale' || p.hayDescuento)
            .toList();
      } else {
        productos = productos
            .where((p) => p.categoria == _categoriaActiva && !p.hayDescuento)
            .toList();
      }
    }

    // Filtrar por búsqueda
    if (_busqueda.isNotEmpty) {
      productos = productos
          .where((p) =>
              p.nombre.toLowerCase().contains(_busqueda) ||
              p.descripcion.toLowerCase().contains(_busqueda))
          .toList();
    }

    // Filtrar por tallas
    if (_tallasSeleccionadas.isNotEmpty) {
      productos = productos
          .where((p) => p.tallas.any((t) => _tallasSeleccionadas.contains(t)))
          .toList();
    }

    // Filtrar por colores
    if (_coloresSeleccionados.isNotEmpty) {
      productos = productos
          .where((p) => p.colores.any((c) => _coloresSeleccionados.contains(c)))
          .toList();
    }

    // Filtrar por materiales
    if (_materialesSeleccionados.isNotEmpty) {
      productos = productos
          .where((p) =>
              _materialesSeleccionados.any((m) => p.materiales.contains(m)))
          .toList();
    }

    // Filtrar por tipos
    if (_tiposSeleccionados.isNotEmpty) {
      productos = productos
          .where((p) => _tiposSeleccionados.contains(p.tipoProducto))
          .toList();
    }

    // Filtrar por rango de precio
    productos = productos
        .where((p) => p.precio >= _precioMin && p.precio <= _precioMax)
        .toList();

    // Ordenar
    switch (_ordenamiento) {
      case 'precioMenor':
        productos.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 'precioMayor':
        productos.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case 'nombre':
        productos.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'destacados':
      default:
        productos.sort((a, b) => b.rating.compareTo(a.rating));
    }

    _filteredProductos = productos;
  }

  /// Obtiene los filtros disponibles
  Set<String> getTallasDisponibles() {
    return _allProductos.expand((p) => p.tallas).toSet();
  }

  Set<String> getColoresDisponibles() {
    return _allProductos.expand((p) => p.colores).toSet();
  }

  Set<String> getMaterialesDisponibles() {
    return _allProductos.map((p) => p.materiales).toSet();
  }

  Set<String> getTiposDisponibles() {
    return _allProductos.map((p) => p.tipoProducto).toSet();
  }

  double getPrecioMaximo() {
    if (_allProductos.isEmpty) return 500;
    return _allProductos.map((p) => p.precio).reduce((a, b) => a > b ? a : b);
  }
}

/// Provider para gestionar el carrito de compras
class CarritoProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  static const String _carritoKey = 'carrito';
  static const double envioFijo = 10.0;

  List<CartItem> get items => _items;

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double calcularSubtotal() => subtotal;

  double get envio => subtotal > 0 ? envioFijo : 0;

  double get total {
    return subtotal + envio;
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.cantidad);
  }

  CarritoProvider() {
    _cargarDesdeStorage();
  }

  /// Agrega un producto al carrito
  void agregarAlCarrito(
      Producto producto, String talla, String color, int cantidad) {
    final itemId = '${producto.id}_${talla}_$color';
    final index = _items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      // Incrementar cantidad si ya existe
      _items[index] =
          _items[index].copyWith(cantidad: _items[index].cantidad + cantidad);
    } else {
      // Agregar nuevo item
      _items.add(CartItem(
        id: itemId,
        producto: producto,
        talla: talla,
        color: color,
        cantidad: cantidad,
      ));
    }

    _guardarEnStorage();
    notifyListeners();
  }

  /// Actualiza la cantidad de un item
  void actualizarCantidad(String itemId, int nuevaCantidad) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (nuevaCantidad <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
      }
      _guardarEnStorage();
      notifyListeners();
    }
  }

  /// Elimina un item del carrito
  void eliminarDelCarrito(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _guardarEnStorage();
    notifyListeners();
  }

  /// Limpia todo el carrito
  void limpiarCarrito() {
    _items.clear();
    _guardarEnStorage();
    notifyListeners();
  }

  /// Guarda el carrito en SharedPreferences (incluye datos del producto)
  Future<void> _guardarEnStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carritoData = jsonEncode(
        _items
            .map((item) => {
                  'id': item.id,
                  'talla': item.talla,
                  'color': item.color,
                  'cantidad': item.cantidad,
                  'producto': {
                    'id': item.producto.id,
                    'nombre': item.producto.nombre,
                    'precio': item.producto.precio,
                    'precioOriginal': item.producto.precioOriginal,
                    'imagen': item.producto.imagen,
                    'imagenes': item.producto.imagenes,
                    'tallas': item.producto.tallas,
                    'colores': item.producto.colores,
                    'colorHex': item.producto.colorHex,
                    'materiales': item.producto.materiales,
                    'tipoProducto': item.producto.tipoProducto,
                    'subcategoria': item.producto.subcategoria,
                    'categoria': item.producto.categoria,
                    'rating': item.producto.rating,
                    'reviewCount': item.producto.reviewCount,
                    'descripcion': item.producto.descripcion,
                  },
                })
            .toList(),
      );
      await prefs.setString(_carritoKey, carritoData);
    } catch (_) {}
  }

  /// Carga el carrito desde SharedPreferences
  Future<void> _cargarDesdeStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carritoJson = prefs.getString(_carritoKey);
      if (carritoJson != null) {
        final List<dynamic> datos = jsonDecode(carritoJson);
        _items = datos.map((item) {
          final p = item['producto'] as Map<String, dynamic>;
          final producto = Producto(
            id: p['id'].toString(),
            nombre: p['nombre'].toString(),
            precio: (p['precio'] as num).toDouble(),
            precioOriginal: p['precioOriginal'] != null
                ? (p['precioOriginal'] as num).toDouble()
                : null,
            imagen: p['imagen'].toString(),
            imagenes: List<String>.from(p['imagenes'] ?? []),
            tallas: List<String>.from(p['tallas'] ?? []),
            colores: List<String>.from(p['colores'] ?? []),
            colorHex: Map<String, String>.from(p['colorHex'] ?? {}),
            materiales: p['materiales'].toString(),
            tipoProducto: p['tipoProducto'].toString(),
            subcategoria: p['subcategoria'].toString(),
            categoria: p['categoria'].toString(),
            rating: (p['rating'] as num).toDouble(),
            reviewCount: p['reviewCount'] as int,
            descripcion: p['descripcion'].toString(),
          );
          return CartItem(
            id: item['id'].toString(),
            producto: producto,
            talla: item['talla'].toString(),
            color: item['color'].toString(),
            cantidad: item['cantidad'] as int,
          );
        }).toList();
        notifyListeners();
      }
    } catch (_) {}
  }
}

/// Provider para gestionar los favoritos (sincronizado con la API)
class FavoritosProvider extends ChangeNotifier {
  Set<String> _favoritosIds = {};
  static const String _favoritosKey = 'favoritos';

  // Referencia a todos los productos (se actualiza desde TiendaProvider)
  List<Producto> _allProductos = productosOriginalData;

  Set<String> get favoritosIds => _favoritosIds;

  List<Producto> get favoritos {
    return _allProductos.where((p) => _favoritosIds.contains(p.id)).toList();
  }

  /// Actualiza la lista de todos los productos (para que favoritos muestre
  /// la información real cuando se carga el catálogo desde la API).
  void actualizarProductos(List<Producto> productos) {
    _allProductos = productos;
    notifyListeners();
  }

  FavoritosProvider() {
    _cargarDesdeStorage();
  }

  /// Verifica si un producto es favorito
  bool isFavorito(String id) => _favoritosIds.contains(id);

  /// Alterna el estado de favorito y sincroniza con la API
  void toggleFavorito(String id) {
    if (_favoritosIds.contains(id)) {
      _favoritosIds.remove(id);
      _apiRemover(id);
    } else {
      _favoritosIds.add(id);
      _apiAgregar(id);
    }
    _guardarEnStorage();
    notifyListeners();
  }

  /// Agrega a favoritos
  void agregarFavorito(String id) {
    _favoritosIds.add(id);
    _apiAgregar(id);
    _guardarEnStorage();
    notifyListeners();
  }

  /// Elimina de favoritos
  void eliminarFavorito(String id) {
    _favoritosIds.remove(id);
    _apiRemover(id);
    _guardarEnStorage();
    notifyListeners();
  }

  /// Limpia los favoritos al cerrar sesión
  void limpiar() {
    _favoritosIds.clear();
    _guardarEnStorage();
    notifyListeners();
  }

  /// Sincroniza favoritos con el servidor (llámalo al iniciar sesión)
  Future<void> sincronizarConAPI() async {
    try {
      final data = await ApiService.get('/api/favoritos');
      final List<dynamic> ids = data is List ? data : [];
      _favoritosIds = ids.map((id) => id.toString()).toSet();
      _guardarEnStorage();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _apiAgregar(String id) async {
    try {
      await ApiService.post('/api/favoritos/$id', {});
    } catch (_) {}
  }

  Future<void> _apiRemover(String id) async {
    try {
      await ApiService.delete('/api/favoritos/$id');
    } catch (_) {}
  }

  Future<void> _guardarEnStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritosKey, _favoritosIds.toList());
    } catch (_) {}
  }

  Future<void> _cargarDesdeStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lista = prefs.getStringList(_favoritosKey) ?? [];
      _favoritosIds = Set.from(lista);
      notifyListeners();
    } catch (_) {}
    // sincronizarConAPI() se llama explícitamente desde login_page.dart
    // para evitar peticiones autenticadas antes de iniciar sesión
  }
}
