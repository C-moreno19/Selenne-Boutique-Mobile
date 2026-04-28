import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';

/// Modelo de Notificación
class AppNotificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final DateTime fecha;
  final bool leida;
  final String? referencia;

  AppNotificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fecha,
    this.leida = false,
    this.referencia,
  });

  AppNotificacion copyWith({bool? leida}) => AppNotificacion(
        id: id,
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
        fecha: fecha,
        leida: leida ?? this.leida,
        referencia: referencia,
      );
}

/// Provider para notificaciones — cargadas desde el backend
class NotificationProvider extends ChangeNotifier {
  List<AppNotificacion> _notificaciones = [];
  bool _cargando = false;

  List<AppNotificacion> get notificaciones => _notificaciones;
  bool get cargando => _cargando;

  int get contadorNoLeidas =>
      _notificaciones.where((n) => !n.leida).length;
  int get notificacionesNoLeidas => contadorNoLeidas;

  NotificationProvider();
  // Las notificaciones se cargan solo después de login exitoso

  /// Carga las notificaciones del usuario desde el backend
  Future<void> cargarNotificaciones() async {
    _cargando = true;
    notifyListeners();
    try {
      final data = await ApiService.get('/api/notificaciones');
      final List<dynamic> lista = data is List ? data : [];
      _notificaciones = lista.map((j) {
        final m = Map<String, dynamic>.from(j);
        return AppNotificacion(
          id: (m['notificacionID'] ?? m['NotificacionID'] ?? 0).toString(),
          titulo: (m['titulo'] ?? m['Titulo'] ?? '').toString(),
          mensaje: (m['mensaje'] ?? m['Mensaje'] ?? '').toString(),
          tipo: (m['tipo'] ?? m['Tipo'] ?? 'info').toString(),
          leida: m['leida'] ?? m['Leida'] ?? false,
          fecha: DateTime.tryParse(
                  (m['fechaCreacion'] ?? m['FechaCreacion'] ?? '').toString()) ??
              DateTime.now(),
          referencia:
              (m['referencia'] ?? m['Referencia'])?.toString(),
        );
      }).toList();
    } catch (_) {
      // Sin conexión — mantener lista vacía o la anterior
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Marca una notificación como leída (local + API)
  Future<void> marcarComoLeida(String notificacionId) async {
    final index =
        _notificaciones.indexWhere((n) => n.id == notificacionId);
    if (index < 0) return;
    _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
    notifyListeners();
    try {
      await ApiService.put(
          '/api/notificaciones/$notificacionId/marcar-leida', {});
    } catch (_) {}
  }

  /// Marca todas las notificaciones como leídas (local + API)
  Future<void> marcarTodasComoLeidas() async {
    _notificaciones = _notificaciones
        .map((n) => n.copyWith(leida: true))
        .toList();
    notifyListeners();
    try {
      await ApiService.post('/api/notificaciones/marcar-todas-leidas', {});
    } catch (_) {}
  }

  /// Agrega una notificación local (para mostrar confirmación inmediata
  /// antes de que el servidor envíe la real)
  void agregarLocal({
    required String titulo,
    required String mensaje,
    required String tipo,
    String? referencia,
  }) {
    _notificaciones.insert(
      0,
      AppNotificacion(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
        fecha: DateTime.now(),
        referencia: referencia,
      ),
    );
    notifyListeners();
  }

  /// Elimina una notificación de la lista local
  void eliminarNotificacion(String notificacionId) {
    _notificaciones.removeWhere((n) => n.id == notificacionId);
    notifyListeners();
  }

  /// Limpia todas las notificaciones locales
  void limpiarTodas() {
    _notificaciones.clear();
    notifyListeners();
  }
}
