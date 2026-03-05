import 'package:flutter/material.dart';
import 'package:bookmet/detalle_producto.dart';

class TarjetaProducto extends StatelessWidget {
  final String titulo;
  final String autor;
  final String precio;
  final String foto;

  const TarjetaProducto({
    super.key,
    required this.titulo,
    required this.autor,
    required this.precio,
    required this.foto,
  });

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleProducto(
            titulo: titulo,
            autor: autor,
            precio: precio,
            foto: foto,
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: foto != "" 
                    ? Image.network(foto, fit: BoxFit.cover) 
                    : const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.favorite_border, color: Color(0xFFC0834A), size: 30),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
        Text(autor, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(precio, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      ],
    ),
  );
  }
}