import '../models/models.dart';
import 'api_service.dart';

class ValoracionesService {
  static Future<List<Valoracion>> getPorProducto(String productoId) async {
    final data = await ApiService.get(
      '/api/valoraciones/producto/$productoId',
      auth: false,
    );
    final List<dynamic> lista = data is List ? data : [];
    return lista
        .map((j) => Valoracion.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }

  /// Lanza [ApiException] si el usuario no compró el producto o ya lo reseñó.
  static Future<void> crear({
    required int productoId,
    required int puntuacion,
    String? comentario,
  }) async {
    await ApiService.post('/api/valoraciones', {
      'ProductoID': productoId,
      'Puntuacion': puntuacion,
      'Comentario': comentario,
    });
  }
}
