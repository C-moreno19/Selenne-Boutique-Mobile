import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    final exito = await auth.cambiarContrasena(
      actual: _actualController.text,
      nueva: _nuevaController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exito) {
      AppSnackBar.show(context, 'Contraseña actualizada correctamente');
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, auth.error ?? 'Error al cambiar la contraseña', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Contraseña actual
                TextFormField(
                  controller: _actualController,
                  obscureText: _obscureActual,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: const Icon(Icons.lock_outlined,
                        color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureActual
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureActual = !_obscureActual),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu contraseña actual' : null,
                ),

                const SizedBox(height: 20),

                // Nueva contraseña
                TextFormField(
                  controller: _nuevaController,
                  obscureText: _obscureNueva,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNueva
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNueva = !_obscureNueva),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirmar nueva contraseña
                TextFormField(
                  controller: _confirmarController,
                  obscureText: _obscureConfirmar,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirmar = !_obscureConfirmar),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma la nueva contraseña';
                    if (v != _nuevaController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar Cambios',
                          style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
