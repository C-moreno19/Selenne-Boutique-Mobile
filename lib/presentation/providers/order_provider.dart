import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';

/// Modelo de Pedido (espejo del PedidoDto del backend)
class Pedido {
  final String id;
  final String usuarioId;
  final List<CartItem> items;
  final double subtotal;
  final double envio;
  final double total;
  final double? montoTotal;
  final String estado;
  final String metodoPago;
  final DateTime fechaCreacion;
  final DateTime? fechaEntrega;
  final String direccionEnvio;
  final String? numeroSeguimiento;
  final String? nombreCliente;
  final String? emailCliente;

  Pedido({
    required this.id,
    required this.usuarioId,
    required this.items,
    required this.subtotal,
    required this.envio,
    required this.total,
    this.montoTotal,
    required this.estado,
    required this.metodoPago,
    required this.fechaCreacion,
    this.fechaEntrega,
    required this.direccionEnvio,
    this.numeroSeguimiento,
    this.nombreCliente,
    this.emailCliente,
  });

  int get progreso {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 25;
      case 'aprobado':
      case 'en proceso':
        return 50;
      case 'completado':
        return 100;
      case 'cancelado':
      case 'rechazado':
        return 0;
      default:
        return 10;
    }
  }

  String get estadoTexto {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente de revisión';
      case 'aprobado':
        return 'Aprobado — en preparación';
      case 'en proceso':
        return 'En proceso de envío';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }
}

/// Provider para gestionar pedidos conectado al backend
class OrderProvider extends ChangeNotifier {
  List<Pedido> _pedidos = [];
  bool _cargando = false;
  String? _error;

  List<Pedido> get pedidos => _pedidos;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Carga los pedidos del usuario desde la API
  Future<void> cargarPedidos(int userId) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/api/pedidos');
      final List<dynamic> lista = data is List ? data : [];
      final filtrados = lista
          .map((j) => _fromJson(Map<String, dynamic>.from(j)))
          .where((p) =>
              p.usuarioId == userId.toString() || p.usuarioId == '0')
          .toList();

      // Sort oldest-first to assign sequential per-client numbers
      filtrados.sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));

      // Assign sequential numbers (1, 2, 3...) then reverse for newest-first display
      _pedidos = filtrados.asMap().entries.map((e) {
        final p = e.value;
        return Pedido(
          id: (e.key + 1).toString(),
          usuarioId: p.usuarioId,
          items: p.items,
          subtotal: p.subtotal,
          envio: p.envio,
          total: p.total,
          montoTotal: p.montoTotal,
          estado: p.estado,
          metodoPago: p.metodoPago,
          fechaCreacion: p.fechaCreacion,
          fechaEntrega: p.fechaEntrega,
          direccionEnvio: p.direccionEnvio,
          numeroSeguimiento: p.numeroSeguimiento,
          nombreCliente: p.nombreCliente,
          emailCliente: p.emailCliente,
        );
      }).toList().reversed.toList();
    } catch (e) {
      _error = 'No se pudieron cargar los pedidos';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo pedido en el backend
  Future<Pedido?> crearPedidoAPI({
    required String nombreCliente,
    required String emailCliente,
    required String telefonoCliente,
    required String documento,
    required String direccionEnvio,
    required String ciudad,
    required String metodoPago,
    required List<CartItem> items,
    String? banco,
    String? numeroCuenta,
    String? nombreTitular,
    String? tipoCuenta,
    String? notas,
    String? comprobantePago,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final itemsJson = items
          .map((item) => {
                'ProductoID': int.tryParse(item.producto.id) ?? 0,
                'Cantidad': item.cantidad,
                'TallaNombre': item.talla,
                'ColorNombre': item.color,
              })
          .toList();

      final body = {
        'NombreCliente': nombreCliente,
        'EmailCliente': emailCliente,
        'TelefonoCliente': telefonoCliente,
        'DocumentoCliente': documento,
        'DireccionEnvio': direccionEnvio,
        'Ciudad': ciudad,
        'MetodoPago': metodoPago,
        if (banco != null) 'Banco': banco,
        if (numeroCuenta != null) 'NumeroCuenta': numeroCuenta,
        if (nombreTitular != null) 'NombreTitular': nombreTitular,
        if (tipoCuenta != null) 'TipoCuenta': tipoCuenta,
        if (notas != null) 'Notas': notas,
        if (comprobantePago != null) 'ComprobantePago': comprobantePago,
        'Items': itemsJson,
      };

      final res = await ApiService.post('/api/pedidos', body);
      final numeroPedidoCliente =
          (res['numeroPedidoCliente'] ?? res['pedidoId'] ?? res['PedidoID'] ?? 0).toString();
      final total = _toDouble(res['total'] ?? res['Total'] ?? 0);

      final pedido = Pedido(
        id: numeroPedidoCliente,
        usuarioId: '0',
        items: items,
        subtotal: total,
        envio: 0,
        total: total,
        estado: 'Pendiente',
        metodoPago: metodoPago,
        fechaCreacion: DateTime.now(),
        direccionEnvio: direccionEnvio,
        nombreCliente: nombreCliente,
        emailCliente: emailCliente,
      );
      _pedidos.insert(0, pedido);
      notifyListeners();
      return pedido;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } on TimeoutException {
      _error = 'Sin conexión al servidor. Verifica tu red e intenta de nuevo.';
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'No se pudo crear el pedido. Verifica tu conexión.';
      notifyListeners();
      return null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Obtiene pedidos del usuario (filtrado local)
  List<Pedido> getPedidosUsuario(String usuarioId) {
    return _pedidos.where((p) => p.usuarioId == usuarioId).toList();
  }

  /// Obtiene un pedido específico por ID
  Pedido? obtenerPedido(String pedidoId) {
    try {
      return _pedidos.firstWhere((p) => p.id == pedidoId);
    } catch (_) {
      return null;
    }
  }

  void limpiar() {
    _pedidos.clear();
    _error = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  static Pedido _fromJson(Map<String, dynamic> j) {
    return Pedido(
      id: (j['pedidoID'] ?? j['PedidoID'] ?? 0).toString(),
      usuarioId: (j['clienteID'] ?? j['ClienteID'] ?? 0).toString(),
      items: const [],
      subtotal: _toDouble(j['subtotal'] ?? j['Subtotal'] ?? 0),
      envio: _toDouble(j['envio'] ?? j['Envio'] ?? 0),
      total: _toDouble(j['total'] ?? j['Total'] ?? 0),
      estado: (j['estado'] ?? j['Estado'] ?? 'Pendiente').toString(),
      metodoPago:
          (j['metodoPago'] ?? j['MetodoPago'] ?? '').toString(),
      fechaCreacion: DateTime.tryParse(
              (j['fechaPedido'] ?? j['FechaPedido'] ?? '').toString()) ??
          DateTime.now(),
      direccionEnvio:
          (j['direccionEnvio'] ?? j['DireccionEnvio'] ?? '').toString(),
      numeroSeguimiento:
          (j['numeroGuia'] ?? j['NumeroGuia'])?.toString(),
      nombreCliente:
          (j['nombreCliente'] ?? j['NombreCliente'])?.toString(),
      emailCliente:
          (j['emailCliente'] ?? j['EmailCliente'])?.toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
