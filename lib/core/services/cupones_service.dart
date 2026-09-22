import 'api_service.dart';

class CuponValido {
  final String codigo;
  final double montoDescuento;
  CuponValido({required this.codigo, required this.montoDescuento});
}

class CuponesService {
  /// Lanza [ApiException] con el motivo si el cupón no es válido.
  static Future<CuponValido> validar(String codigo, double subtotal) async {
    final data = await ApiService.post(
      '/api/cupones/validar',
      {'Codigo': codigo, 'Subtotal': subtotal},
      auth: false,
    );
    return CuponValido(
      codigo: (data['codigo'] ?? data['Codigo'] ?? codigo).toString(),
      montoDescuento: _toDouble(data['montoDescuento'] ?? data['MontoDescuento']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
