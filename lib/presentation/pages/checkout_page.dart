import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/themes/colors.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/order_provider.dart';
import 'order_tracking_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de Compra
            _buildOrderSummary(),
            const SizedBox(height: 24),
            // Información de Envío
            _buildShippingInfo(),
            const SizedBox(height: 24),
            // Método de Pago
            _buildPaymentMethodSection(),
            const SizedBox(height: 24),
            // Detalles de Tarjeta
            _buildCardDetailsForm(),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // Botón Procesar
            ElevatedButton(
              onPressed: _isProcessing ? null : _procesarPago,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                disabledBackgroundColor: AppColors.textLight,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Procesar Pago', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, _) {
        final subtotal = carritoProvider.calcularSubtotal();
        final impuesto = subtotal * 0.10;
        double descuento = 0;
        for (var item in carritoProvider.items) {
          descuento += item.producto.precio *
              item.cantidad *
              (item.producto.descuentoPorcentaje / 100);
        }
        final total = subtotal + impuesto - descuento;

        return Card(
          elevation: 0,
          color: AppColors.backgroundLight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Resumen de Pedido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 14)),
                    Text('\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Impuesto (10%):', style: TextStyle(fontSize: 14)),
                    Text('\$${impuesto.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                if (descuento > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Descuento:', style: TextStyle(fontSize: 14)),
                      Text(
                        '-\$${descuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShippingInfo() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final usuario = authProvider.usuarioActual;
        if (usuario == null) return const SizedBox.shrink();

        return Card(
          elevation: 0,
          color: AppColors.backgroundLight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Información de Envío',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario.nombre,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.email,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.telefono,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.local_shipping,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Envío Estándar',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Entrega en 3-5 días hábiles',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Método de Pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RadioListTile<int>(
          value: 0,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value ?? 0),
          title: const Text('Tarjeta de Crédito/Débito'),
          subtitle: const Text('Visa, Mastercard'),
          activeColor: AppColors.primary,
        ),
        RadioListTile<int>(
          value: 1,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value ?? 0),
          title: const Text('Billetera Digital'),
          subtitle: const Text('PayPal, Apple Pay'),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildCardDetailsForm() {
    if (_selectedPaymentMethod != 0) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Detalles de la Tarjeta',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Número de Tarjeta
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta',
                hintText: '0000 0000 0000 0000',
                prefixIcon: const Icon(Icons.credit_card, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            // Nombre en Tarjeta
            TextField(
              controller: _cardNameController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))],
              decoration: InputDecoration(
                labelText: 'Nombre en la Tarjeta',
                prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Expiración y CVV
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                      labelText: 'MM/AA',
                      hintText: '12/24',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.lock, size: 16, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Tu pago es seguro y encriptado',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _procesarPago() async {
    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });

    try {
      // Validar campos
      if (_cardNumberController.text.isEmpty) {
        throw 'Ingresa el número de tarjeta';
      }
      if (_cardNameController.text.isEmpty) {
        throw 'Ingresa el nombre en la tarjeta';
      }
      if (_expiryController.text.isEmpty) {
        throw 'Ingresa la fecha de expiración';
      }
      if (_cvvController.text.isEmpty) {
        throw 'Ingresa el CVV';
      }

      final paymentProvider = context.read<PaymentProvider>();
      final carritoProvider = context.read<CarritoProvider>();
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<OrderProvider>();

      // Procesar pago
      final transaccion = await paymentProvider.procesarPago(
        metodo: 'tarjeta',
        numeroTarjeta: _cardNumberController.text,
        nombreTarjeta: _cardNameController.text,
        fechaExpiracion: _expiryController.text,
        cvv: _cvvController.text,
        monto: carritoProvider.calcularSubtotal() * 1.10,
      );

      if (!transaccion.exitosa) {
        throw 'La transacción fue rechazada. Intenta con otra tarjeta.';
      }

      // Crear pedido en el backend
      final usuario = authProvider.usuarioActual;
      await orderProvider.crearPedidoAPI(
        nombreCliente: usuario?.nombre ?? '',
        emailCliente: usuario?.email ?? '',
        telefonoCliente: usuario?.telefono ?? '',
        documento: usuario?.documento ?? '',
        direccionEnvio: usuario?.direccion ?? '',
        ciudad: usuario?.ciudad ?? '',
        metodoPago: 'tarjeta',
        items: carritoProvider.items,
        notas: 'Transacción: ${transaccion.id}',
      );

      // Limpiar carrito
      carritoProvider.limpiarCarrito();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = '$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
