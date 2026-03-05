import 'package:flutter/material.dart';
import 'chat_screen.dart';

class DetalleProducto extends StatelessWidget {
  final String titulo;
  final String autor;
  final String precio;
  final String foto;

  const DetalleProducto({
    super.key,
    required this.titulo,
    required this.autor,
    required this.precio,
    required this.foto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: foto.isNotEmpty
                  ? Image.network(foto, height: 300, fit: BoxFit.cover)
                  : const Icon(Icons.book, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(autor, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(precio, style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Descripción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Este material está disponible para intercambio o venta. Contacta al vendedor para más detalles."),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                   MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('Chat en construcción 🚧')))),
                  );
                },
                child: const Text("Solicitar Intercambio", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}