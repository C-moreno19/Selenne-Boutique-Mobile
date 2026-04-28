import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../../core/widgets/nice_dialog.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key}); // ✅ FIX 1: Cambiar Key? por super.key

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _controller = TextEditingController();

  // ✅ FIX 2: Hacer la lista final (inmutable)
  final List<Map<String, String>> _shipments = [
    {
      'tracking': 'ABC123456',
      'carrier': 'DHL',
      'status': 'En tránsito',
      'eta': '2 días'
    },
    {
      'tracking': 'XYZ987654',
      'carrier': 'Correos',
      'status': 'Entregado',
      'eta': 'Entregado'
    },
  ];

  List<Map<String, String>> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List.from(_shipments);
  }

  void _search() {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() => _results = List.from(_shipments));
      return;
    }

    final found = _shipments
        .where((s) => s['tracking']!.toLowerCase().contains(q.toLowerCase()))
        .toList();
    setState(() => _results = found);
    if (found.isEmpty) {
      NiceDialog.show(
        context,
        title: const Text('No encontrado'),
        content: const Text('No se encontró ningún envío con ese número.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
    }
  }

  Widget _buildShipmentCard(Map<String, String> s) {
    final status = s['status'] ?? '';
    // ✅ FIX 3: Usar la variable statusColor que se calculó
    final Color statusColor;
    if (status.toLowerCase().contains('entregado')) {
      statusColor = Colors.green;
    } else if (status.toLowerCase().contains('transit') ||
        status.toLowerCase().contains('tránsito')) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.blueGrey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor, // ✅ Usar el color calculado
          child: Text(s['carrier']![0]),
        ),
        title: Text('${s['carrier']} • ${s['tracking']}'),
        subtitle: Text('Estado: ${s['status']} • ETA: ${s['eta']}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: s);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Envíos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Número de seguimiento',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No hay envíos para mostrar'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, i) =>
                        _buildShipmentCard(_results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
