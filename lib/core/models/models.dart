/// Modelo para representar un producto en la tienda
class Producto {
  final String id;
  final String nombre;
  final double precio;
  final double? precioOriginal;
  final String imagen;
  final List<String> imagenes;
  final List<String> tallas;
  final List<String> colores;
  final Map<String, String> colorHex;
  final String materiales;
  final String tipoProducto;
  final String subcategoria;
  final String categoria; // 'mujer', 'accesorios', 'sale'
  final double rating;
  final int reviewCount;
  final String descripcion;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.precioOriginal,
    required this.imagen,
    required this.imagenes,
    required this.tallas,
    required this.colores,
    required this.colorHex,
    required this.materiales,
    required this.tipoProducto,
    required this.subcategoria,
    required this.categoria,
    required this.rating,
    required this.reviewCount,
    required this.descripcion,
  });

  double get descuentoPorcentaje {
    if (precioOriginal == null) return 0;
    return ((precioOriginal! - precio) / precioOriginal! * 100).round().toDouble();
  }

  bool get hayDescuento => precioOriginal != null && precioOriginal! > precio;

  static Producto fromJson(Map<String, dynamic> j) {
    final precioVenta = _toDouble(j['precioVenta'] ?? j['PrecioVenta'] ?? 0);
    final precioOfertaRaw = j['precioOferta'] ?? j['PrecioOferta'];
    final precioOferta = precioOfertaRaw != null ? _toDouble(precioOfertaRaw) : null;
    final precio = precioOferta ?? precioVenta;
    final precioOriginal = precioOferta != null ? precioVenta : null;

    final imagenPrincipal = (j['imagenPrincipal'] ?? j['ImagenPrincipal'] ?? '').toString();

    final List<dynamic> imagenesJson = j['imagenes'] ?? j['Imagenes'] ?? [];
    var imagenes = imagenesJson
        .map((i) => (i['url'] ?? i['URL'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();
    if (imagenes.isEmpty && imagenPrincipal.isNotEmpty) {
      imagenes = [imagenPrincipal];
    }

    final List<dynamic> tallasJson = j['tallas'] ?? j['Tallas'] ?? [];
    final tallas = tallasJson
        .map((t) => (t['nombre'] ?? t['Nombre'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<dynamic> coloresJson = j['colores'] ?? j['Colores'] ?? [];
    final colores = coloresJson
        .map((c) => (c['nombre'] ?? c['Nombre'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();
    final colorHex = Map.fromEntries(coloresJson.map((c) {
      final nombre = (c['nombre'] ?? c['Nombre'] ?? '').toString();
      final hex = (c['codigoHex'] ?? c['CodigoHex'] ?? '#000000').toString();
      return MapEntry(nombre, hex);
    }));

    final List<dynamic> materialesJson = j['materiales'] ?? j['Materiales'] ?? [];
    final materiales = materialesJson.map((m) => m.toString()).join(', ');

    final categoriaNombre =
        (j['categoriaNombre'] ?? j['CategoriaNombre'] ?? '').toString().toLowerCase();
    String categoria;
    if (categoriaNombre.contains('accesorio')) {
      categoria = 'accesorios';
    } else if (categoriaNombre.contains('sale') || categoriaNombre.contains('oferta')) {
      categoria = 'sale';
    } else {
      categoria = 'mujer';
    }

    return Producto(
      id: (j['productoID'] ?? j['ProductoID'] ?? 0).toString(),
      nombre: (j['nombre'] ?? j['Nombre'] ?? '').toString(),
      precio: precio,
      precioOriginal: precioOriginal,
      imagen: imagenPrincipal.isNotEmpty ? imagenPrincipal : (imagenes.isNotEmpty ? imagenes[0] : ''),
      imagenes: imagenes.isNotEmpty ? imagenes : (imagenPrincipal.isNotEmpty ? [imagenPrincipal] : []),
      tallas: tallas.isNotEmpty ? tallas : [],
      colores: colores.isNotEmpty ? colores : [],
      colorHex: colorHex,
      materiales: materiales.isNotEmpty ? materiales : '',
      tipoProducto: (j['tipoNombre'] ?? j['TipoNombre'] ?? '').toString(),
      subcategoria: (j['categoriaNombre'] ?? j['CategoriaNombre'] ?? '').toString(),
      categoria: categoria,
      rating: _toDouble(j['promedioValoracion'] ?? j['PromedioValoracion'] ?? 0),
      reviewCount: (j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0) is int
          ? j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0
          : int.tryParse((j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0).toString()) ?? 0,
      descripcion: (j['descripcion'] ?? j['Descripcion'] ?? j['descripcionCorta'] ?? j['DescripcionCorta'] ?? '')
          .toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Producto copyWith({
    String? id,
    String? nombre,
    double? precio,
    double? precioOriginal,
    String? imagen,
    List<String>? imagenes,
    List<String>? tallas,
    List<String>? colores,
    Map<String, String>? colorHex,
    String? materiales,
    String? tipoProducto,
    String? subcategoria,
    String? categoria,
    double? rating,
    int? reviewCount,
    String? descripcion,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      imagen: imagen ?? this.imagen,
      imagenes: imagenes ?? this.imagenes,
      tallas: tallas ?? this.tallas,
      colores: colores ?? this.colores,
      colorHex: colorHex ?? this.colorHex,
      materiales: materiales ?? this.materiales,
      tipoProducto: tipoProducto ?? this.tipoProducto,
      subcategoria: subcategoria ?? this.subcategoria,
      categoria: categoria ?? this.categoria,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

/// Modelo para representar un item en el carrito de compras
class CartItem {
  final String id;
  final Producto producto;
  final String talla;
  final String color;
  int cantidad;

  CartItem({
    required this.id,
    required this.producto,
    required this.talla,
    required this.color,
    required this.cantidad,
  });

  double get subtotal => producto.precio * cantidad;

  CartItem copyWith({
    String? id,
    Producto? producto,
    String? talla,
    String? color,
    int? cantidad,
  }) {
    return CartItem(
      id: id ?? this.id,
      producto: producto ?? this.producto,
      talla: talla ?? this.talla,
      color: color ?? this.color,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

/// Lista vacía — los productos se cargan desde el backend
final List<Producto> productosOriginalData = [];
