import 'package:flutter/foundation.dart';

/// Modelo de Tarjeta de Pago
class TarjetaPago {
  final String id;
  final String ultimosDigitos;
  final String marca; // visa, mastercard, amex
  final String titular;
  final bool esDefault;

  TarjetaPago({
    required this.id,
    required this.ultimosDigitos,
    required this.marca,
    required this.titular,
    required this.esDefault,
  });
}

/// Modelo de Transacción de Pago
class Transaccion {
  final String id;
  final double monto;
  final String estado; // pendiente, exitosa, fallida
  final String metodo; // tarjeta, paypal, transferencia
  final DateTime fecha;
  final String? codigoAutorizacion;
  final String? mensajeError;

  Transaccion({
    required this.id,
    required this.monto,
    required this.estado,
    required this.metodo,
    required this.fecha,
    this.codigoAutorizacion,
    this.mensajeError,
  });

  bool get exitosa => estado == 'exitosa';
}

/// Provider para gestionar pagos
class PaymentProvider extends ChangeNotifier {
  List<TarjetaPago> _tarjetas = [];
  List<Transaccion> _historialTransacciones = [];
  String? _metodoPagoSeleccionado;

  List<TarjetaPago> get tarjetas => _tarjetas;
  List<Transaccion> get historialTransacciones => _historialTransacciones;
  String? get metodoPagoSeleccionado => _metodoPagoSeleccionado;

  PaymentProvider() {
    _inicializarTarjetasDemo();
  }

  /// Inicializa tarjetas demo
  void _inicializarTarjetasDemo() {
    _tarjetas = [
      TarjetaPago(
        id: '1',
        ultimosDigitos: '4242',
        marca: 'visa',
        titular: 'Usuario Demo',
        esDefault: true,
      ),
      TarjetaPago(
        id: '2',
        ultimosDigitos: '5555',
        marca: 'mastercard',
        titular: 'Usuario Demo',
        esDefault: false,
      ),
    ];
  }

  /// Agrega una nueva tarjeta
  bool agregarTarjeta({
    required String numero,
    required String marca,
    required String titular,
    required String mes,
    required String anio,
    required String cvv,
  }) {
    // Validaciones básicas
    if (numero.isEmpty || numero.length < 13) {
      return false;
    }

    if (cvv.isEmpty || cvv.length < 3) {
      return false;
    }

    final nuevaTarjeta = TarjetaPago(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ultimosDigitos: numero.substring(numero.length - 4),
      marca: marca,
      titular: titular,
      esDefault: _tarjetas.isEmpty,
    );

    _tarjetas.add(nuevaTarjeta);
    notifyListeners();
    return true;
  }

  /// Elimina una tarjeta
  void eliminarTarjeta(String tarjetaId) {
    _tarjetas.removeWhere((t) => t.id == tarjetaId);
    if (_tarjetas.isNotEmpty && _tarjetas.every((t) => !t.esDefault)) {
      _tarjetas[0] = TarjetaPago(
        id: _tarjetas[0].id,
        ultimosDigitos: _tarjetas[0].ultimosDigitos,
        marca: _tarjetas[0].marca,
        titular: _tarjetas[0].titular,
        esDefault: true,
      );
    }
    notifyListeners();
  }

  /// Establece tarjeta como predeterminada
  void establecerTarjetaDefault(String tarjetaId) {
    for (int i = 0; i < _tarjetas.length; i++) {
      _tarjetas[i] = TarjetaPago(
        id: _tarjetas[i].id,
        ultimosDigitos: _tarjetas[i].ultimosDigitos,
        marca: _tarjetas[i].marca,
        titular: _tarjetas[i].titular,
        esDefault: _tarjetas[i].id == tarjetaId,
      );
    }
    notifyListeners();
  }

  /// Selecciona método de pago
  void seleccionarMetodoPago(String metodo) {
    _metodoPagoSeleccionado = metodo;
    notifyListeners();
  }

  /// Procesa un pago
  Future<Transaccion> procesarPago({
    required double monto,
    String metodo = 'tarjeta',
    String? tarjetaId,
    String? numeroTarjeta,
    String? nombreTarjeta,
    String? fechaExpiracion,
    String? cvv,
  }) async {
    try {
      // Validar tarjeta si se proporcionan los detalles
      if (numeroTarjeta != null && numeroTarjeta.isNotEmpty) {
        if (!validarNumeroTarjeta(numeroTarjeta)) {
          return Transaccion(
            id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            monto: monto,
            estado: 'fallida',
            metodo: metodo,
            fecha: DateTime.now(),
            mensajeError: 'Número de tarjeta inválido',
          );
        }
      }

      // Simulamos procesamiento
      await Future.delayed(const Duration(seconds: 2));

      // Validaciones
      if (monto <= 0) {
        return Transaccion(
          id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          monto: monto,
          estado: 'fallida',
          metodo: metodo,
          fecha: DateTime.now(),
          mensajeError: 'Monto inválido',
        );
      }

      // Simulamos éxito del 95% para demostración
      final esExitoso = DateTime.now().millisecond % 100 > 5;

      final transaccion = Transaccion(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        monto: monto,
        estado: esExitoso ? 'exitosa' : 'fallida',
        metodo: metodo,
        fecha: DateTime.now(),
        codigoAutorizacion: esExitoso
            ? 'AUTH-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}'
            : null,
        mensajeError: esExitoso ? null : 'Fondos insuficientes (demo)',
      );

      _historialTransacciones.insert(0, transaccion);
      notifyListeners();
      return transaccion;
    } catch (e) {
      return Transaccion(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        monto: monto,
        estado: 'fallida',
        metodo: metodo,
        fecha: DateTime.now(),
        mensajeError: 'Error procesando pago: $e',
      );
    }
  }

  /// Obtiene el historial de transacciones
  List<Transaccion> obtenerHistorial({int limite = 10}) {
    return _historialTransacciones.take(limite).toList();
  }

  /// Valida número de tarjeta (Luhn algorithm)
  bool validarNumeroTarjeta(String numero) {
    if (numero.isEmpty) return false;

    final digits = numero.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool isEven = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  /// Valida CVV
  bool validarCVV(String cvv) {
    return cvv.isNotEmpty &&
        cvv.length >= 3 &&
        cvv.length <= 4 &&
        int.tryParse(cvv) != null;
  }

  /// Valida fecha de expiración
  bool validarFechaExpiracion(String mes, String anio) {
    try {
      final m = int.parse(mes);
      final y = int.parse(anio);
      final now = DateTime.now();

      if (m < 1 || m > 12) return false;

      // Asume que anio es de 2 dígitos
      final expansion = y < 50 ? 2000 + y : 1900 + y;

      final fechaExp = DateTime(expansion, m + 1);
      return fechaExp.isAfter(now);
    } catch (e) {
      return false;
    }
  }
}
