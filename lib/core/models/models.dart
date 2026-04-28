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

  /// Calcula el porcentaje de descuento
  double get descuentoPorcentaje {
    if (precioOriginal == null) return 0;
    return ((precioOriginal! - precio) / precioOriginal! * 100)
        .round()
        .toDouble();
  }

  /// Indica si el producto tiene descuento
  bool get hayDescuento => precioOriginal != null && precioOriginal! > precio;

  /// Construye un Producto desde el JSON que devuelve el backend
  static Producto fromJson(Map<String, dynamic> j) {
    final precioVenta = _toDouble(j['precioVenta'] ?? j['PrecioVenta'] ?? 0);
    final precioOfertaRaw = j['precioOferta'] ?? j['PrecioOferta'];
    final precioOferta =
        precioOfertaRaw != null ? _toDouble(precioOfertaRaw) : null;
    final precio = precioOferta ?? precioVenta;
    final precioOriginal = precioOferta != null ? precioVenta : null;

    final imagenPrincipal =
        (j['imagenPrincipal'] ?? j['ImagenPrincipal'] ?? '').toString();

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
      final hex =
          (c['codigoHex'] ?? c['CodigoHex'] ?? '#000000').toString();
      return MapEntry(nombre, hex);
    }));

    final List<dynamic> materialesJson =
        j['materiales'] ?? j['Materiales'] ?? [];
    final materiales = materialesJson.map((m) => m.toString()).join(', ');

    final categoriaNombre =
        (j['categoriaNombre'] ?? j['CategoriaNombre'] ?? '').toString().toLowerCase();
    String categoria;
    if (categoriaNombre.contains('accesorio')) {
      categoria = 'accesorios';
    } else if (categoriaNombre.contains('sale') ||
        categoriaNombre.contains('oferta')) {
      categoria = 'sale';
    } else {
      categoria = 'mujer';
    }

    return Producto(
      id: (j['productoID'] ?? j['ProductoID'] ?? 0).toString(),
      nombre: (j['nombre'] ?? j['Nombre'] ?? '').toString(),
      precio: precio,
      precioOriginal: precioOriginal,
      imagen: imagenPrincipal.isNotEmpty
          ? imagenPrincipal
          : 'https://via.placeholder.com/400',
      imagenes: imagenes.isNotEmpty
          ? imagenes
          : ['https://via.placeholder.com/400'],
      tallas: tallas.isNotEmpty ? tallas : ['S', 'M', 'L'],
      colores: colores.isNotEmpty ? colores : ['Negro'],
      colorHex: colorHex.isNotEmpty ? colorHex : {'Negro': '#000000'},
      materiales: materiales.isNotEmpty ? materiales : 'No especificado',
      tipoProducto: (j['tipoNombre'] ?? j['TipoNombre'] ?? '').toString(),
      subcategoria:
          (j['categoriaNombre'] ?? j['CategoriaNombre'] ?? '').toString(),
      categoria: categoria,
      rating: _toDouble(j['promedioValoracion'] ?? j['PromedioValoracion'] ?? 0),
      reviewCount: (j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0) is int
          ? j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0
          : int.tryParse((j['totalValoraciones'] ?? j['TotalValoraciones'] ?? 0).toString()) ?? 0,
      descripcion: (j['descripcion'] ??
              j['Descripcion'] ??
              j['descripcionCorta'] ??
              j['DescripcionCorta'] ??
              '')
          .toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  /// Crea una copia del producto con valores modificados
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

  /// Calcula el subtotal del item
  double get subtotal => producto.precio * cantidad;

  /// Crea una copia del item con valores modificados
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

/// Datos mock con 25+ productos para la tienda
final List<Producto> productosOriginalData = [
  Producto(
    id: '1',
    nombre: 'Vestido Elegante Algodón',
    precio: 89.99,
    precioOriginal: 120.00,
    imagen: 'https://via.placeholder.com/400?text=Vestido+Elegante',
    imagenes: [
      'https://via.placeholder.com/400?text=Vestido+1',
      'https://via.placeholder.com/400?text=Vestido+2',
      'https://via.placeholder.com/400?text=Vestido+3',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    colores: ['Azul', 'Negro', 'Blanco'],
    colorHex: {'Azul': '#0066FF', 'Negro': '#000000', 'Blanco': '#FFFFFF'},
    materiales: 'Algodón 100%',
    tipoProducto: 'Vestido',
    subcategoria: 'Vestidos Largos',
    categoria: 'mujer',
    rating: 4.5,
    reviewCount: 128,
    descripcion:
        'Vestido elegante perfecto para cualquier ocasión. Cómodo y elegante.',
  ),
  Producto(
    id: '2',
    nombre: 'Blusa Rose Premium',
    precio: 59.99,
    precioOriginal: 85.00,
    imagen: 'https://via.placeholder.com/400?text=Blusa+Rose',
    imagenes: [
      'https://via.placeholder.com/400?text=Blusa+1',
      'https://via.placeholder.com/400?text=Blusa+2',
    ],
    tallas: ['XS', 'S', 'M', 'L'],
    colores: ['Rosa', 'Blanco', 'Negro'],
    colorHex: {'Rosa': '#d65391', 'Blanco': '#FFFFFF', 'Negro': '#000000'},
    materiales: 'Seda 100%',
    tipoProducto: 'Blusa',
    subcategoria: 'Blusas',
    categoria: 'mujer',
    rating: 4.8,
    reviewCount: 95,
    descripcion: 'Blusa de seda premium con acabados delicados.',
  ),
  Producto(
    id: '3',
    nombre: 'Pantalón Ajustado Negro',
    precio: 74.99,
    precioOriginal: 100.00,
    imagen: 'https://via.placeholder.com/400?text=Pantalon+Negro',
    imagenes: [
      'https://via.placeholder.com/400?text=Pantalon+1',
      'https://via.placeholder.com/400?text=Pantalon+2',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Negro', 'Gris', 'Azul Marino'],
    colorHex: {'Negro': '#000000', 'Gris': '#808080', 'Azul Marino': '#001a33'},
    materiales: 'Algodón-Elastano',
    tipoProducto: 'Pantalón',
    subcategoria: 'Pantalones',
    categoria: 'mujer',
    rating: 4.6,
    reviewCount: 156,
    descripcion:
        'Pantalón ajustado con elasticidad. Perfecto para el día a día.',
  ),
  Producto(
    id: '4',
    nombre: 'Collar Dorado Elegante',
    precio: 39.99,
    imagen: 'https://via.placeholder.com/400?text=Collar+Dorado',
    imagenes: [
      'https://via.placeholder.com/400?text=Collar+1',
      'https://via.placeholder.com/400?text=Collar+2',
    ],
    tallas: ['Unitalla'],
    colores: ['Dorado', 'Plateado'],
    colorHex: {'Dorado': '#FFD700', 'Plateado': '#C0C0C0'},
    materiales: 'Aleación de zinc',
    tipoProducto: 'Collar',
    subcategoria: 'Collares',
    categoria: 'accesorios',
    rating: 4.7,
    reviewCount: 67,
    descripcion:
        'Collar dorado con colgante elegante. Perfecto para complementar.',
  ),
  Producto(
    id: '5',
    nombre: 'Bolso Tote Rosa',
    precio: 99.99,
    precioOriginal: 150.00,
    imagen: 'https://via.placeholder.com/400?text=Bolso+Rosa',
    imagenes: [
      'https://via.placeholder.com/400?text=Bolso+1',
      'https://via.placeholder.com/400?text=Bolso+2',
      'https://via.placeholder.com/400?text=Bolso+3',
    ],
    tallas: ['Unitalla'],
    colores: ['Rosa', 'Blanco', 'Negro'],
    colorHex: {'Rosa': '#d65391', 'Blanco': '#FFFFFF', 'Negro': '#000000'},
    materiales: 'Cuero sintético',
    tipoProducto: 'Bolso',
    subcategoria: 'Bolsos',
    categoria: 'accesorios',
    rating: 4.9,
    reviewCount: 203,
    descripcion: 'Bolso tote espacioso y elegante. Gran capacidad para el día.',
  ),
  Producto(
    id: '6',
    nombre: 'Zapatos Tacón Rosa',
    precio: 129.99,
    precioOriginal: 180.00,
    imagen: 'https://via.placeholder.com/400?text=Tacones+Rosa',
    imagenes: [
      'https://via.placeholder.com/400?text=Tacones+1',
      'https://via.placeholder.com/400?text=Tacones+2',
    ],
    tallas: ['34', '35', '36', '37', '38', '39', '40', '41'],
    colores: ['Rosa', 'Nude', 'Negro'],
    colorHex: {'Rosa': '#d65391', 'Nude': '#E8B4A8', 'Negro': '#000000'},
    materiales: 'Cuero y tacón sintético',
    tipoProducto: 'Zapatos',
    subcategoria: 'Tacones',
    categoria: 'mujer',
    rating: 4.4,
    reviewCount: 89,
    descripcion:
        'Zapatos de tacón elegantes y cómodos. Perfectos para cualquier evento.',
  ),
  Producto(
    id: '7',
    nombre: 'Cinturón Fino Negro',
    precio: 29.99,
    imagen: 'https://via.placeholder.com/400?text=Cinturon+Negro',
    imagenes: [
      'https://via.placeholder.com/400?text=Cinturon+1',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Negro', 'Marrón'],
    colorHex: {'Negro': '#000000', 'Marrón': '#8B4513'},
    materiales: 'Cuero sintético',
    tipoProducto: 'Cinturón',
    subcategoria: 'Cinturones',
    categoria: 'accesorios',
    rating: 4.3,
    reviewCount: 45,
    descripcion: 'Cinturón fino y elegante. Versátil para cualquier outfit.',
  ),
  Producto(
    id: '8',
    nombre: 'Cardigan Lana Blanco',
    precio: 69.99,
    precioOriginal: 95.00,
    imagen: 'https://via.placeholder.com/400?text=Cardigan+Blanco',
    imagenes: [
      'https://via.placeholder.com/400?text=Cardigan+1',
      'https://via.placeholder.com/400?text=Cardigan+2',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Blanco', 'Gris', 'Rosa'],
    colorHex: {'Blanco': '#FFFFFF', 'Gris': '#D3D3D3', 'Rosa': '#FFB6C1'},
    materiales: 'Lana 80%',
    tipoProducto: 'Cardigan',
    subcategoria: 'Suéteres',
    categoria: 'mujer',
    rating: 4.7,
    reviewCount: 112,
    descripcion:
        'Cardigan de lana suave y abrigado. Perfecto para el invierno.',
  ),
  Producto(
    id: '9',
    nombre: 'Pulsera Perlas',
    precio: 44.99,
    precioOriginal: 60.00,
    imagen: 'https://via.placeholder.com/400?text=Pulsera+Perlas',
    imagenes: [
      'https://via.placeholder.com/400?text=Pulsera+1',
    ],
    tallas: ['Unitalla'],
    colores: ['Blanco', 'Rosa'],
    colorHex: {'Blanco': '#FFFFFF', 'Rosa': '#FFB6C1'},
    materiales: 'Perlas sintéticas y metal',
    tipoProducto: 'Pulsera',
    subcategoria: 'Pulseras',
    categoria: 'accesorios',
    rating: 4.8,
    reviewCount: 78,
    descripcion: 'Pulsera de perlas elegante con cierre de seguridad.',
  ),
  Producto(
    id: '10',
    nombre: 'Falda Plisada Rosa',
    precio: 54.99,
    precioOriginal: 75.00,
    imagen: 'https://via.placeholder.com/400?text=Falda+Plisada',
    imagenes: [
      'https://via.placeholder.com/400?text=Falda+1',
      'https://via.placeholder.com/400?text=Falda+2',
    ],
    tallas: ['XS', 'S', 'M', 'L'],
    colores: ['Rosa', 'Blanco', 'Beige'],
    colorHex: {'Rosa': '#FFB6D9', 'Blanco': '#FFFFFF', 'Beige': '#F5F5DC'},
    materiales: 'Poliéster',
    tipoProducto: 'Falda',
    subcategoria: 'Faldas',
    categoria: 'mujer',
    rating: 4.5,
    reviewCount: 92,
    descripcion:
        'Falda plisada moderna y versátil. Combina con cualquier blusa.',
  ),
  Producto(
    id: '11',
    nombre: 'Shorts Denim Azul',
    precio: 44.99,
    precioOriginal: 65.00,
    imagen: 'https://via.placeholder.com/400?text=Shorts+Denim',
    imagenes: [
      'https://via.placeholder.com/400?text=Shorts+1',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Azul Claro', 'Azul Oscuro'],
    colorHex: {'Azul Claro': '#6495ED', 'Azul Oscuro': '#00008B'},
    materiales: 'Denim 100%',
    tipoProducto: 'Shorts',
    subcategoria: 'Shorts',
    categoria: 'mujer',
    rating: 4.4,
    reviewCount: 134,
    descripcion:
        'Shorts de denim cómodos y con estilo. Perfecto para el verano.',
  ),
  Producto(
    id: '12',
    nombre: 'Aros de Plata',
    precio: 34.99,
    imagen: 'https://via.placeholder.com/400?text=Aros+Plata',
    imagenes: [
      'https://via.placeholder.com/400?text=Aros+1',
    ],
    tallas: ['Unitalla'],
    colores: ['Plateado'],
    colorHex: {'Plateado': '#C0C0C0'},
    materiales: 'Plata esterlina',
    tipoProducto: 'Aros',
    subcategoria: 'Aros',
    categoria: 'accesorios',
    rating: 4.6,
    reviewCount: 56,
    descripcion: 'Aros elegantes de plata esterlina. Pendientes clásicos.',
  ),
  Producto(
    id: '13',
    nombre: 'Vestido Fiesta Brillante',
    precio: 149.99,
    precioOriginal: 220.00,
    imagen: 'https://via.placeholder.com/400?text=Vestido+Fiesta',
    imagenes: [
      'https://via.placeholder.com/400?text=Fiesta+1',
      'https://via.placeholder.com/400?text=Fiesta+2',
      'https://via.placeholder.com/400?text=Fiesta+3',
    ],
    tallas: ['XS', 'S', 'M', 'L'],
    colores: ['Negro', 'Dorado', 'Plata'],
    colorHex: {'Negro': '#000000', 'Dorado': '#FFD700', 'Plata': '#C0C0C0'},
    materiales: 'Poliéster con lentejuelas',
    tipoProducto: 'Vestido',
    subcategoria: 'Vestidos de Fiesta',
    categoria: 'sale',
    rating: 4.9,
    reviewCount: 201,
    descripcion: 'Vestido de fiesta con lentejuelas. Luz y brillo garantizado.',
  ),
  Producto(
    id: '14',
    nombre: 'Chaqueta Cuero Rosa',
    precio: 119.99,
    precioOriginal: 170.00,
    imagen: 'https://via.placeholder.com/400?text=Chaqueta+Rosa',
    imagenes: [
      'https://via.placeholder.com/400?text=Chaqueta+1',
      'https://via.placeholder.com/400?text=Chaqueta+2',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Rosa', 'Negro'],
    colorHex: {'Rosa': '#d65391', 'Negro': '#000000'},
    materiales: 'Cuero sintético',
    tipoProducto: 'Chaqueta',
    subcategoria: 'Chaquetas',
    categoria: 'mujer',
    rating: 4.7,
    reviewCount: 178,
    descripcion: 'Chaqueta de cuero rosa. Moderna y versátil.',
  ),
  Producto(
    id: '15',
    nombre: 'Sombrero Paja',
    precio: 34.99,
    imagen: 'https://via.placeholder.com/400?text=Sombrero+Paja',
    imagenes: [
      'https://via.placeholder.com/400?text=Sombrero+1',
    ],
    tallas: ['Unitalla'],
    colores: ['Natural', 'Negro'],
    colorHex: {'Natural': '#D4A574', 'Negro': '#000000'},
    materiales: 'Paja natural',
    tipoProducto: 'Sombrero',
    subcategoria: 'Sombreros',
    categoria: 'accesorios',
    rating: 4.5,
    reviewCount: 63,
    descripcion: 'Sombrero de paja para el verano. Protección y estilo.',
  ),
  Producto(
    id: '16',
    nombre: 'Leggings Negro Premium',
    precio: 39.99,
    precioOriginal: 55.00,
    imagen: 'https://via.placeholder.com/400?text=Leggings+Negro',
    imagenes: [
      'https://via.placeholder.com/400?text=Leggings+1',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Negro', 'Gris'],
    colorHex: {'Negro': '#000000', 'Gris': '#808080'},
    materiales: 'Elastano 85%',
    tipoProducto: 'Leggings',
    subcategoria: 'Leggings',
    categoria: 'mujer',
    rating: 4.6,
    reviewCount: 145,
    descripcion: 'Leggings deportivo de alta calidad. Cómodo y resistente.',
  ),
  Producto(
    id: '17',
    nombre: 'Bufanda Seda Rose',
    precio: 49.99,
    precioOriginal: 70.00,
    imagen: 'https://via.placeholder.com/400?text=Bufanda+Rose',
    imagenes: [
      'https://via.placeholder.com/400?text=Bufanda+1',
    ],
    tallas: ['Unitalla'],
    colores: ['Rosa', 'Blanco', 'Múltiples'],
    colorHex: {'Rosa': '#d65391', 'Blanco': '#FFFFFF', 'Múltiples': '#E8A8B5'},
    materiales: 'Seda 100%',
    tipoProducto: 'Bufanda',
    subcategoria: 'Accesorios Invierno',
    categoria: 'accesorios',
    rating: 4.8,
    reviewCount: 87,
    descripcion: 'Bufanda de seda suave. Elegante y abrigada.',
  ),
  Producto(
    id: '18',
    nombre: 'Mochila Viaje Negro',
    precio: 89.99,
    precioOriginal: 130.00,
    imagen: 'https://via.placeholder.com/400?text=Mochila+Viaje',
    imagenes: [
      'https://via.placeholder.com/400?text=Mochila+1',
      'https://via.placeholder.com/400?text=Mochila+2',
    ],
    tallas: ['Unitalla'],
    colores: ['Negro', 'Gris'],
    colorHex: {'Negro': '#000000', 'Gris': '#505050'},
    materiales: 'Poliéster impermeable',
    tipoProducto: 'Mochila',
    subcategoria: 'Mochilas',
    categoria: 'accesorios',
    rating: 4.7,
    reviewCount: 112,
    descripcion: 'Mochila de viaje con múltiples compartimentos. Impermeable.',
  ),
  Producto(
    id: '19',
    nombre: 'Anillo Diamante Plateado',
    precio: 59.99,
    precioOriginal: 85.00,
    imagen: 'https://via.placeholder.com/400?text=Anillo+Diamante',
    imagenes: [
      'https://via.placeholder.com/400?text=Anillo+1',
    ],
    tallas: ['5', '6', '7', '8', '9'],
    colores: ['Plateado'],
    colorHex: {'Plateado': '#C0C0C0'},
    materiales: 'Aleación de zinc con cristales',
    tipoProducto: 'Anillo',
    subcategoria: 'Anillos',
    categoria: 'accesorios',
    rating: 4.9,
    reviewCount: 98,
    descripcion:
        'Anillo elegante con cristales. Perfecto para cualquier ocasión.',
  ),
  Producto(
    id: '20',
    nombre: 'Blusa Elegante Encaje',
    precio: 64.99,
    precioOriginal: 90.00,
    imagen: 'https://via.placeholder.com/400?text=Blusa+Encaje',
    imagenes: [
      'https://via.placeholder.com/400?text=Blusa+Encaje+1',
      'https://via.placeholder.com/400?text=Blusa+Encaje+2',
    ],
    tallas: ['XS', 'S', 'M', 'L', 'XL'],
    colores: ['Blanco', 'Negro', 'Rosa'],
    colorHex: {'Blanco': '#FFFFFF', 'Negro': '#000000', 'Rosa': '#FFB6D9'},
    materiales: 'Algodón con encaje',
    tipoProducto: 'Blusa',
    subcategoria: 'Blusas',
    categoria: 'mujer',
    rating: 4.8,
    reviewCount: 167,
    descripcion: 'Blusa con encaje delicado. Sofisticada y elegante.',
  ),
  Producto(
    id: '21',
    nombre: 'Jeans Skinny Azul',
    precio: 64.99,
    precioOriginal: 90.00,
    imagen: 'https://via.placeholder.com/400?text=Jeans+Skinny',
    imagenes: [
      'https://via.placeholder.com/400?text=Jeans+1',
      'https://via.placeholder.com/400?text=Jeans+2',
    ],
    tallas: ['24', '25', '26', '27', '28', '29', '30'],
    colores: ['Azul Claro', 'Azul Oscuro'],
    colorHex: {'Azul Claro': '#87CEEB', 'Azul Oscuro': '#00008B'},
    materiales: 'Denim 100%',
    tipoProducto: 'Jeans',
    subcategoria: 'Jeans',
    categoria: 'mujer',
    rating: 4.6,
    reviewCount: 189,
    descripcion: 'Jeans skinny con estilo. Cómodo y moderno.',
  ),
  Producto(
    id: '22',
    nombre: 'Bikini Rose',
    precio: 54.99,
    precioOriginal: 75.00,
    imagen: 'https://via.placeholder.com/400?text=Bikini+Rose',
    imagenes: [
      'https://via.placeholder.com/400?text=Bikini+1',
    ],
    tallas: ['XS', 'S', 'M', 'L'],
    colores: ['Rosa', 'Negro'],
    colorHex: {'Rosa': '#d65391', 'Negro': '#000000'},
    materiales: 'Poliéster/Elastano',
    tipoProducto: 'Bikini',
    subcategoria: 'Swimwear',
    categoria: 'mujer',
    rating: 4.4,
    reviewCount: 76,
    descripcion: 'Bikini moderno con soporte. Comod para la playa.',
  ),
  Producto(
    id: '23',
    nombre: 'Pañuelo Cabeza Seda',
    precio: 29.99,
    imagen: 'https://via.placeholder.com/400?text=Panuelo+Seda',
    imagenes: [
      'https://via.placeholder.com/400?text=Panuelo+1',
    ],
    tallas: ['Unitalla'],
    colores: ['Rosa', 'Negro', 'Blanco', 'Azul'],
    colorHex: {
      'Rosa': '#FFB6D9',
      'Negro': '#000000',
      'Blanco': '#FFFFFF',
      'Azul': '#0066FF'
    },
    materiales: 'Seda 100%',
    tipoProducto: 'Pañuelo',
    subcategoria: 'Pañuelos',
    categoria: 'accesorios',
    rating: 4.5,
    reviewCount: 54,
    descripcion: 'Pañuelo de seda versátil. Úsalo de varias formas.',
  ),
  Producto(
    id: '24',
    nombre: 'Zapatos Ballet Plano',
    precio: 49.99,
    precioOriginal: 70.00,
    imagen: 'https://via.placeholder.com/400?text=Ballet+Plano',
    imagenes: [
      'https://via.placeholder.com/400?text=Ballet+1',
    ],
    tallas: ['34', '35', '36', '37', '38', '39', '40', '41'],
    colores: ['Rosa', 'Negro', 'Bordo'],
    colorHex: {'Rosa': '#FFB6D9', 'Negro': '#000000', 'Bordo': '#8B0000'},
    materiales: 'Cuero nobuck',
    tipoProducto: 'Zapatos',
    subcategoria: 'Zapatos Planos',
    categoria: 'mujer',
    rating: 4.7,
    reviewCount: 143,
    descripcion: 'Zapatos ballet plano cómodos. Perfectos para el día.',
  ),
  Producto(
    id: '25',
    nombre: 'Gafas Sol Oversized',
    precio: 79.99,
    precioOriginal: 120.00,
    imagen: 'https://via.placeholder.com/400?text=Gafas+Sol',
    imagenes: [
      'https://via.placeholder.com/400?text=Gafas+1',
      'https://via.placeholder.com/400?text=Gafas+2',
    ],
    tallas: ['Unitalla'],
    colores: ['Negro', 'Marrón'],
    colorHex: {'Negro': '#000000', 'Marrón': '#A0522D'},
    materiales: 'Plástico y vidrio UV',
    tipoProducto: 'Gafas',
    subcategoria: 'Gafas de Sol',
    categoria: 'accesorios',
    rating: 4.8,
    reviewCount: 178,
    descripcion:
        'Gafas de sol oversized. Protección UV 100%. Estilo garantizado.',
  ),
  Producto(
    id: '26',
    nombre: 'Reloj Oro Rose',
    precio: 159.99,
    precioOriginal: 240.00,
    imagen: 'https://via.placeholder.com/400?text=Reloj+Oro+Rose',
    imagenes: [
      'https://via.placeholder.com/400?text=Reloj+1',
      'https://via.placeholder.com/400?text=Reloj+2',
    ],
    tallas: ['Unitalla'],
    colores: ['Oro Rose', 'Plata'],
    colorHex: {'Oro Rose': '#B76E79', 'Plata': '#C0C0C0'},
    materiales: 'Acero inoxidable',
    tipoProducto: 'Reloj',
    subcategoria: 'Relojes',
    categoria: 'accesorios',
    rating: 4.9,
    reviewCount: 212,
    descripcion:
        'Reloj elegante de oro rose. Pulsera ajustable. Resistente al agua.',
  ),
];
