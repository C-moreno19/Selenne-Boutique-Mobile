import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/snackbar.dart';
// ✅ FIX: Remover import no usado
// import '../../core/services/auth_service.dart';
import 'address_form_page.dart';
import '../../core/widgets/nice_dialog.dart';

class AddressesPage extends StatefulWidget {
  final bool selectMode;

  const AddressesPage({super.key, this.selectMode = false});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  // ✅ FIX 1: Remover _userEmail ya que no se usa en ningún lugar
  // String? _userEmail;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    // ✅ FIX 2: Remover llamada a _loadUser() ya que no se necesita
    // _loadUser();
    _loadAddresses();
  }

  // ✅ FIX 3: Remover método _loadUser() completo ya que no se usa _userEmail
  // Future<void> _loadUser() async {
  //   final u = await AuthService.getCurrentUser();
  //   if (u != null && mounted) {
  //     setState(() => _userEmail = u['email'] as String?);
  //   }
  // }

  Future<void> _loadAddresses() async {
    // Mock data for addresses (in a real app, would load from shared_preferences or backend)
    setState(() {
      _addresses = [
        {
          'type': 'Casa',
          'address': 'Calle Principal 123, Ciudad Estado 12345',
        },
        {
          'type': 'Trabajo',
          'address': 'Avenida Central 456, Ciudad Estado 67890',
        },
        {
          'type': 'Apartamento',
          'address': 'Calle Secundaria 789, Ciudad Estado 10112',
        },
      ];
    });
  }

  void _editAddress(int index) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
          builder: (_) => AddressFormPage(initial: _addresses[index])),
    );
    if (updated != null && mounted) {
      setState(() {
        _addresses[index] = {
          'type': updated['label'] ?? 'Casa',
          'address': updated['address'] ?? '',
          ...updated,
        };
      });
    }
  }

  void _addNewAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddressFormPage()),
    );
    if (result != null && mounted) {
      setState(() {
        _addresses.insert(0, {
          'type': result['label'] ?? 'Casa',
          'address': result['address'] ?? '',
          ...result,
        });
      });
    }
  }

  void _deleteAddress(int index) async {
    // Use central dialog helper
    final res = await NiceDialog.show<bool>(
      context,
      title: const Text('Eliminar dirección'),
      content: Text(
          '¿Estás seguro de que deseas eliminar "${_addresses[index]['type']}"?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    if (res == true && mounted) {
      setState(() => _addresses.removeAt(index));
      if (mounted) {
        AppSnackBar.show(context, 'Dirección eliminada', type: SnackType.info);
      }
    }
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
          'Mis Direcciones',
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
            ..._addresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              return _buildAddressCard(
                type: address['type'] as String,
                addressText: address['address'] as String,
                onEdit: () => _editAddress(index),
                onDelete: () => _deleteAddress(index),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Añadir Nueva Dirección',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAddressCard({
    required String type,
    required String addressText,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              widget.selectMode
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: const Text(
                            'Editar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            addressText,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    if (widget.selectMode) {
      return GestureDetector(
        onTap: () =>
            Navigator.pop(context, {'type': type, 'address': addressText}),
        child: card,
      );
    }

    return card;
  }
}
