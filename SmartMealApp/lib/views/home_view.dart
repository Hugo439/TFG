import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartMeal - Prueba Firebase')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirestoreService().guardarPrueba();
            final data = await FirestoreService().leerPrueba();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dato leído: $data')),
            );
          },
          child: const Text('Probar Firestore'),
        ),
      ),
    );
  }
}
