import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y soporte'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ayuda y soporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Si tienes alguna pregunta o necesitas ayuda, puedes:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('• Contactarnos a través de correo electrónico'),
            Text('• Llamarnos al número de soporte'),
            Text('• Visitar nuestro centro de ayuda en línea'),
          ],
        ),
      ),
    );
  }
}
