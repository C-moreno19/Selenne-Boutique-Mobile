import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String _theme = 'Claro';
  String _unit = 'Métrico';
  bool _cookies = false;
  bool _twoFactor = false;

  final List<String> _themes = ['Claro', 'Oscuro', 'Automático'];
  final List<String> _units = ['Métrico', 'Imperial'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString('pref_theme') ?? 'Claro';
      _unit = prefs.getString('pref_unit') ?? 'Métrico';
      _cookies = prefs.getBool('pref_cookies') ?? false;
      _twoFactor = prefs.getBool('pref_2fa') ?? false;
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (c) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seleccionar Tema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._themes
                .map((t) => GestureDetector(
                      onTap: () {
                        setState(() => _theme = t);
                        _savePreference('pref_theme', t);
                        Navigator.pop(c);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t, style: const TextStyle(fontSize: 16)),
                            if (_theme == t)
                              const Icon(Icons.check, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showUnitPicker() {
    showModalBottomSheet(
      context: context,
      builder: (c) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unidades de Medida',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._units
                .map((u) => GestureDetector(
                      onTap: () {
                        setState(() => _unit = u);
                        _savePreference('pref_unit', u);
                        Navigator.pop(c);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(u, style: const TextStyle(fontSize: 16)),
                            if (_unit == u)
                              const Icon(Icons.check, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preferencias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('General'),
            const SizedBox(height: 12),
            _buildSettingTile(
              title: 'Tema de la aplicación',
              value: _theme,
              onTap: _showThemePicker,
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              title: 'Unidades de medida',
              value: _unit,
              onTap: _showUnitPicker,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacidad'),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Gestión de datos',
              subtitle: 'Controlar datos personales',
              value: false,
              onChanged: null,
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Consentimiento de cookies',
              subtitle: 'Opcional el consentimiento de cookies',
              value: _cookies,
              onChanged: (v) {
                setState(() => _cookies = v);
                _savePreference('pref_cookies', v);
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Seguridad'),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Cambiar contraseña',
              subtitle: 'Cambiar tu contraseña',
              value: false,
              onChanged: null,
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: 'Autenticación de dos factores',
              subtitle: 'Activa autenticación de dos factores',
              value: _twoFactor,
              onChanged: (v) {
                setState(() => _twoFactor = v);
                _savePreference('pref_2fa', v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (onChanged != null)
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
