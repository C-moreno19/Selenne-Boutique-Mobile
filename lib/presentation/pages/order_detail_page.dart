import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/orders_service.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/adaptive_image.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _receiptUploaded = false;
  String? _userEmail;
  String? _receiptBase64;

  Future<void> _initUser() async {
    final u = await AuthService.getCurrentUser();
    // ✅ FIX 1: Envolver el if en llaves {}
    if (u != null && mounted) {
      setState(() => _userEmail = u['email'] as String?);
    }
  }

  Widget _statusRow(Widget labelWidget, String date, bool done) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: done ? AppColors.primary : Colors.grey.shade300),
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  child: labelWidget),
              const SizedBox(height: 4),
              Text(date,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showFullScreenReceipt(String base64Data) async {
    final order =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final payment = order?['payment'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          // ✅ FIX 2: Reemplazar withOpacity() por withValues(alpha:)
          color: Colors.black.withValues(alpha: 0.9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                title: const Text('Comprobante',
                    style: TextStyle(color: Colors.white)),
                centerTitle: true,
              ),
              Expanded(
                child: Center(
                  child: Image.memory(
                    base64Decode(base64Data),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                // ✅ FIX 3: Reemplazar withOpacity() por withValues(alpha:)
                color: Colors.black.withValues(alpha: 0.8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Reemplazar'),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                          withData: true,
                        );
                        if (result == null) return;
                        final file = result.files.first;
                        final bytes = file.bytes;
                        if (bytes == null) return;
                        final base64str = base64Encode(bytes);
                        setState(() => _receiptBase64 = base64str);
                        if (_userEmail != null && order != null) {
                          final updated = Map<String, dynamic>.from(order);
                          updated['payment'] =
                              Map<String, dynamic>.from(payment ?? {});
                          updated['payment']['receipt_base64'] = base64str;
                          updated['payment']['receipt_name'] = file.name;
                          await OrdersService.updateOrderForUser(
                            _userEmail!,
                            order['order'] ?? '',
                            updated,
                          );
                        }
                        Navigator.pop(dialogContext);
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      onPressed: () async {
                        setState(() => _receiptBase64 = null);
                        if (_userEmail != null && order != null) {
                          final updated = Map<String, dynamic>.from(order);
                          updated['payment'] =
                              Map<String, dynamic>.from(payment ?? {});
                          updated['payment']['receipt_uploaded'] = false;
                          updated['payment'].remove('receipt_base64');
                          updated['payment'].remove('receipt_name');
                          await OrdersService.updateOrderForUser(
                            _userEmail!,
                            order['order'] ?? '',
                            updated,
                          );
                        }
                        setState(() => _receiptUploaded = false);
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  Widget build(BuildContext context) {
    final order =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detalle del pedido',
              style: TextStyle(color: AppColors.textPrimary)),
        ),
        body: const Center(child: Text('Pedido no encontrado')),
      );
    }

    // Fallbacks for fields that may not exist in the order map
    final orderNumber = order['order'] ?? '#0000000';
    final orderDate = order['date'] ?? '';
    final status = order['status'] ?? '';
    final total = order.containsKey('total') ? '\$${order['total']}' : '-';
    final items =
        (order['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final shipping = order['shipping'] as Map<String, dynamic>?;
    final payment = order['payment'] as Map<String, dynamic>?;

    // If the order already has a receipt stored, initialize state to show it
    if (_receiptBase64 == null &&
        payment != null &&
        payment['receipt_base64'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _receiptBase64 = payment['receipt_base64'] as String?;
          _receiptUploaded = true;
        });
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pedido $orderNumber',
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(orderNumber,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('Fecha: $orderDate',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 18),

            // Items list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Productos',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Text('No hay productos en este pedido',
                        style: TextStyle(color: Colors.grey.shade600))
                  else
                    ...items.map((it) {
                      final name = it['name'] ?? it['title'] ?? 'Producto';
                      final qty = (it['quantity'] is int)
                          ? it['quantity'] as int
                          : int.tryParse('${it['quantity']}') ?? 1;
                      final price = (it['price'] is int)
                          ? it['price'] as int
                          : int.tryParse('${it['price']}') ?? 0;
                      final image = it['image'] ?? it['url'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            if (image.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AdaptiveImage(
                                  src: image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.shopping_bag,
                                    color: Colors.grey.shade400),
                              ),
                            const SizedBox(width: 12),
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cantidad: $qty',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700)),
                                      Text('\$$price',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(total,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),

            // Status timeline (simple vertical list)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _statusRow(
                      const Text('Pedido realizado'),
                      orderDate,
                      status.toLowerCase().contains('realizado') ||
                          status.toLowerCase().contains('en proceso') ||
                          status.toLowerCase().contains('entregado')),
                  const SizedBox(height: 12),
                  _statusRow(
                    (_receiptUploaded ||
                            (payment != null &&
                                payment['receipt_base64'] != null))
                        ? Row(children: [
                            if (_receiptBase64 != null) ...[
                              GestureDetector(
                                onTap: () =>
                                    _showFullScreenReceipt(_receiptBase64!),
                                child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.memory(
                                        base64Decode(_receiptBase64!),
                                        fit: BoxFit.cover)),
                              ),
                              const SizedBox(width: 6),
                            ] else if (payment != null &&
                                payment['receipt_base64'] != null) ...[
                              GestureDetector(
                                onTap: () => _showFullScreenReceipt(
                                    payment['receipt_base64']!),
                                child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.memory(
                                        base64Decode(
                                            payment['receipt_base64']!),
                                        fit: BoxFit.cover)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 6),
                            const Text('Comprobante subido')
                          ])
                        : GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                      withData: true);
                              if (result == null) return;
                              final file = result.files.first;
                              final bytes = file.bytes;
                              if (bytes == null) return;
                              final base64str = base64Encode(bytes);
                              setState(() {
                                _receiptBase64 = base64str;
                                _receiptUploaded = true;
                              });
                              if (_userEmail != null) {
                                final updated =
                                    Map<String, dynamic>.from(order);
                                updated['payment'] =
                                    Map<String, dynamic>.from(payment ?? {});
                                updated['payment']['receipt_uploaded'] = true;
                                updated['payment']['receipt_base64'] =
                                    base64str;
                                updated['payment']['receipt_name'] = file.name;
                                await OrdersService.updateOrderForUser(
                                    _userEmail!, order['order'] ?? '', updated);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                  'Click para subir comprobante (PNG, JPG, <5MB)'),
                            ),
                          ),
                    '',
                    (_receiptUploaded ||
                        (payment != null && payment['receipt_base64'] != null)),
                  ),
                ],
              ),
            ),

            // Shipping info
            const Text('Información de envío',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: shipping == null
                  ? Text('Dirección de envío no disponible',
                      style: TextStyle(color: Colors.grey.shade700))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shipping['address'] ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                      '${shipping['city'] ?? ''}${shipping['postal'] != null ? ', ${shipping['postal']}' : ''}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                  if (shipping['receiver'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text('Receptor: ${shipping['receiver']}',
                                        style: TextStyle(
                                            color: Colors.grey.shade700)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Payment info (detailed view)
            const Text('Información de pago',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: payment == null
                  ? Text('Método de pago no disponible',
                      style: TextStyle(color: Colors.grey.shade700))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment method choices (styled as cards)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: payment['method'] ==
                                              'Pago Contra Entrega'
                                          ? AppColors.primary
                                          : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      payment['method'] == 'Pago Contra Entrega'
                                          // ✅ FIX 4: Reemplazar withOpacity()
                                          ? AppColors.primary
                                              .withValues(alpha: 0.05)
                                          : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delivery_dining, size: 18),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                        child: Text('Pago Contra Entrega')),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: payment['method'] ==
                                              'Transferencia Bancaria'
                                          ? AppColors.primary
                                          : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: payment['method'] ==
                                          'Transferencia Bancaria'
                                      // ✅ FIX 5: Reemplazar withOpacity()
                                      ? AppColors.primary
                                          .withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance, size: 18),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                        child: Text('Transferencia Bancaria')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // If transfer, show transfer details box
                        if (payment['method'] != null &&
                            payment['method']
                                .toString()
                                .toLowerCase()
                                .contains('transfer')) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Datos para Transferencia',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    'Banco: ${payment['bank'] ?? 'Banco XYZ'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Tipo de Cuenta: ${payment['account_type'] ?? 'Ahorros'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Número de Cuenta: ${payment['account_number'] ?? '1234567890'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Titular: ${payment['holder'] ?? 'Selenne Boutique SAS'}'),
                                const SizedBox(height: 8),
                                Text('Monto a Transferir: $total',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // QR placeholder
                                    Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.shade100,
                                      child: payment['qr'] != null
                                          ? AdaptiveImage(
                                              src: payment['qr'] ?? '',
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.qr_code,
                                              size: 48, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Comprobante de Pago',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          _receiptUploaded
                                              ? Row(children: [
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.green),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                      'Comprobante subido')
                                                ])
                                              : GestureDetector(
                                                  onTap: () async {
                                                    // Simulate upload: mark as uploaded and persist change
                                                    setState(() =>
                                                        _receiptUploaded =
                                                            true);
                                                    if (_userEmail != null) {
                                                      final updated = Map<
                                                          String,
                                                          dynamic>.from(order);
                                                      updated['payment'] = Map<
                                                              String,
                                                              dynamic>.from(
                                                          payment);
                                                      updated['payment'][
                                                              'receipt_uploaded'] =
                                                          true;
                                                      await OrdersService
                                                          .updateOrderForUser(
                                                              _userEmail!,
                                                              order['order'] ??
                                                                  '',
                                                              updated);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300,
                                                          style: BorderStyle
                                                              .solid),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Text(
                                                        'Click para subir comprobante (PNG, JPG, <5MB)'),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: const Color(0xFFFFF6E0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                          'Importante: Tu pedido quedará en estado "Pendiente" hasta que el administrador confirme tu pago.'),
                                      SizedBox(height: 4),
                                      Text(
                                          'Recibirás una notificación cuando sea aprobado.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        // Compra Segura box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE6F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Compra Segura',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              const Text(
                                  'Envío gratis con compras superiores a \$150.000'),
                              const SizedBox(height: 4),
                              const Text(
                                  'Devoluciones gratuitas dentro de 30 días'),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Support button and back to orders
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Placeholder: abrir soporte
              },
              child: const Text('Contactar soporte'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a mis pedidos'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
