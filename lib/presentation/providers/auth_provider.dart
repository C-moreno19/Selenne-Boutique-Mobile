import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';

/// Modelo de Usuario (mapeado desde el backend)
class Usuario {
  final int usuarioID;
  final String nombre;
  final String email;
  final String telefono;
  final String? direccion;
  final String? ciudad;
  final String? documento;
  final String rol; // 'Cliente', 'Admin', etc.

  Usuario({
    required this.usuarioID,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.direccion,
    this.ciudad,
    this.documento,
    required this.rol,
  });

  Map<String, dynamic> toJson() => {
        'usuarioID': usuarioID,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'ciudad': ciudad,
        'documento': documento,
        'rol': rol,
      };

  static Usuario fromJson(Map<String, dynamic> j) => Usuario(
        usuarioID: j['usuarioID'] ?? j['UsuarioID'] ?? 0,
        nombre: j['nombreCompleto'] ?? j['NombreCompleto'] ?? j['nombre'] ?? '',
        email: j['email'] ?? j['Email'] ?? '',
        telefono: j['telefono'] ?? j['Telefono'] ?? '',
        direccion: j['direccion'] ?? j['Direccion'],
        ciudad: j['ciudad'] ?? j['Ciudad'],
        documento: j['documento'] ?? j['Documento'],
        rol: j['rol'] ?? j['Rol'] ?? j['rolNombre'] ?? 'Cliente',
      );

  Usuario copyWith({
    String? nombre,
    String? telefono,
    String? direccion,
    String? ciudad,
    String? documento,
  }) =>
      Usuario(
        usuarioID: usuarioID,
        nombre: nombre ?? this.nombre,
        email: email,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
        ciudad: ciudad ?? this.ciudad,
        documento: documento ?? this.documento,
        rol: rol,
      );
}

const String _usuarioKey = 'usuario_actual';

/// Provider de autenticación conectado al backend
class AuthProvider extends ChangeNotifier {
  Usuario? _usuarioActual;
  bool _isLoggedIn = false;
  bool _cargando = false;
  bool _inicializando = true;
  String? _error;

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoggedIn => _isLoggedIn;
  bool get cargando => _cargando;
  bool get inicializando => _inicializando;
  String? get error => _error;

  AuthProvider() {
    _cargarSesionGuardada();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _error = null;
    _cargando = true;
    notifyListeners();

    try {
      final data = await ApiService.post(
        '/api/auth/login',
        {'Email': email.trim(), 'Contrasena': password},
        auth: false,
      );

      // Guardar token
      final token = data['token'] ?? data['accessToken'] ?? '';
      await ApiService.saveToken(token.toString());

      // Mapear usuario (el login ya incluye telefono, direccion, ciudad, documento)
      final userJson = data['user'] ?? data['usuario'] ?? data;
      _usuarioActual = Usuario.fromJson(Map<String, dynamic>.from(userJson));
      _isLoggedIn = true;

      // Refrescar perfil completo desde la API para garantizar datos actualizados
      try {
        final perfil = await ApiService.get('/api/usuarios/${_usuarioActual!.usuarioID}');
        _usuarioActual = Usuario.fromJson(Map<String, dynamic>.from(perfil));
      } catch (_) {}

      await _guardarSesion();
      return true;
    } on ApiException catch (e) {
      _error = e.statusCode == 400
          ? 'Por favor ingresa tu email y contraseña correctamente'
          : e.statusCode == 401
              ? 'Email o contraseña incorrectos'
              : e.statusCode == 500
                  ? 'Error en el servidor. Intenta de nuevo.'
                  : e.message;
      return false;
    } catch (_) {
      _error = 'No se pudo conectar al servidor. Verifica tu conexión.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Registro ─────────────────────────────────────────────────────────────

  Future<bool> register({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String confirmPassword,
    String? documento,
  }) async {
    if (password != confirmPassword) {
      _error = 'Las contraseñas no coinciden';
      notifyListeners();
      return false;
    }

    _error = null;
    _cargando = true;
    notifyListeners();

    try {
      await ApiService.post(
        '/api/auth/signup',
        {
          'NombreCompleto': nombre.trim(),
          'Email': email.trim().toLowerCase(),
          'Contrasena': password,
          'Telefono': telefono.trim(),
          if (documento != null && documento.trim().isNotEmpty)
            'Documento': documento.trim(),
        },
        auth: false,
      );

      // Registro exitoso → hacer login automático
      return await login(email, password);
    } on ApiException catch (e) {
      _error = e.statusCode == 409
          ? 'Este email ya está registrado'
          : e.statusCode == 400
              ? 'Por favor completa todos los campos correctamente'
              : e.message;
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'No se pudo conectar al servidor';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Actualizar perfil ────────────────────────────────────────────────────

  Future<bool> actualizarPerfil({
    String? nombre,
    String? telefono,
    String? direccion,
    String? ciudad,
    String? documento,
  }) async {
    if (_usuarioActual == null) return false;
    _cargando = true;
    notifyListeners();

    try {
      await ApiService.put(
        '/api/usuarios/${_usuarioActual!.usuarioID}',
        {
          if (nombre != null) 'NombreCompleto': nombre,
          if (telefono != null) 'Telefono': telefono,
          if (direccion != null) 'Direccion': direccion,
          if (ciudad != null) 'Ciudad': ciudad,
          if (documento != null) 'Documento': documento,
        },
      );

      _usuarioActual = _usuarioActual!.copyWith(
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
        ciudad: ciudad,
        documento: documento,
      );

      await _guardarSesion();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error actualizando perfil';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _usuarioActual = null;
    _isLoggedIn = false;
    _error = null;
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usuarioKey);
    notifyListeners();
  }

  // ─── Persistencia local ───────────────────────────────────────────────────

  Future<void> _guardarSesion() async {
    if (_usuarioActual == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usuarioKey, jsonEncode(_usuarioActual!.toJson()));
  }

  Future<void> _cargarSesionGuardada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_usuarioKey);
      final token = await ApiService.getToken();

      if (raw != null && token != null) {
        _usuarioActual = Usuario.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw)));
        _isLoggedIn = true;
        _inicializando = false;
        notifyListeners();

        // Refrescar perfil en background para tener datos siempre actualizados
        try {
          final perfil = await ApiService.get('/api/usuarios/${_usuarioActual!.usuarioID}');
          _usuarioActual = Usuario.fromJson(Map<String, dynamic>.from(perfil));
          await _guardarSesion();
          notifyListeners();
        } catch (_) {}
        return;
      }
    } catch (_) {}
    _inicializando = false;
    notifyListeners();
  }

  // ─── Recuperar contraseña ─────────────────────────────────────────────────

  Future<bool> solicitarRecuperacion(String email) async {
    _error = null;
    _cargando = true;
    notifyListeners();
    try {
      await ApiService.post(
        '/api/auth/forgot-password',
        {'Email': email.trim()},
        auth: false,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No se pudo conectar al servidor';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> resetearContrasena(String token, String nuevaContrasena) async {
    _error = null;
    _cargando = true;
    notifyListeners();
    try {
      await ApiService.post(
        '/api/auth/reset-password',
        {'Token': token.trim(), 'NuevaContrasena': nuevaContrasena},
        auth: false,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message.contains('invalido') || e.message.contains('expirado')
          ? 'El código es incorrecto o ya expiró'
          : e.message;
      return false;
    } catch (_) {
      _error = 'No se pudo conectar al servidor';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Cambiar contraseña (autenticado) ─────────────────────────────────────

  Future<bool> cambiarContrasena({
    required String actual,
    required String nueva,
  }) async {
    _error = null;
    _cargando = true;
    notifyListeners();
    try {
      await ApiService.post('/api/auth/change-password', {
        'ContrasenaActual': actual,
        'NuevaContrasena': nueva,
      });
      return true;
    } on ApiException catch (e) {
      _error = e.statusCode == 400
          ? 'La contraseña actual es incorrecta'
          : e.message;
      return false;
    } catch (_) {
      _error = 'Error al cambiar contraseña';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
