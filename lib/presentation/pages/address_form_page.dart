import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddressFormPage extends StatefulWidget {
  final Map<String, dynamic>? initial;

  const AddressFormPage({super.key, this.initial});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _postalCtrl;
  late TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? {};
    _fullNameCtrl = TextEditingController(text: i['fullName'] as String? ?? '');
    _phoneCtrl = TextEditingController(text: i['phone'] as String? ?? '');
    _addressCtrl =
        TextEditingController(text: i['addressLine'] as String? ?? '');
    _cityCtrl = TextEditingController(text: i['city'] as String? ?? '');
    _departmentCtrl =
        TextEditingController(text: i['department'] as String? ?? '');
    _postalCtrl = TextEditingController(text: i['postalCode'] as String? ?? '');
    _labelCtrl = TextEditingController(text: i['label'] as String? ?? 'Casa');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _departmentCtrl.dispose();
    _postalCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final result = {
      'label': _labelCtrl.text.trim().isEmpty ? 'Casa' : _labelCtrl.text.trim(),
      'fullName': _fullNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'addressLine': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'department': _departmentCtrl.text.trim(),
      'postalCode': _postalCtrl.text.trim(),
      'address':
          '${_fullNameCtrl.text.trim()}\n${_addressCtrl.text.trim()}\n${_cityCtrl.text.trim()}, ${_departmentCtrl.text.trim()}\n${_postalCtrl.text.trim()}',
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Editar Dirección' : 'Añadir Nueva Dirección',
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('Nombre completo',
                  controller: _fullNameCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              _buildField('Teléfono',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              _buildField('Dirección completa',
                  controller: _addressCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              _buildField('Ciudad',
                  controller: _cityCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              _buildField('Departamento', controller: _departmentCtrl),
              const SizedBox(height: 12),
              _buildField('Código Postal',
                  controller: _postalCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildField('Nombre de la dirección (opcional)',
                  controller: _labelCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                      isEditing ? 'Guardar Cambios' : 'Guardar Dirección',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label,
      {required TextEditingController controller,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
