import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookmet/detalle_producto.dart';

class DialogoFavoritos extends StatelessWidget {
  const DialogoFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Sin redondeo, igual al Figma
      child: SizedBox(
        width: 550, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: const Color(0xFFEA983E), 
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "MIS FAVORITOS",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            // CONTENIDO BLANCO
            Padding(
              padding: const EdgeInsets.all(30),
              child: userId == null 
                ? const Text("Por favor, inicia sesión.")
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(userId)
                        .collection('favoritos')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var docs = snapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tienes ${docs.length} publicaciones guardadas",
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 25),
                          
                          // LISTA DE PRODUCTOS
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 400), 
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                var data = docs[index].data();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite_border, color: Colors.black54),
                                      const SizedBox(width: 15),
                                      // IMAGEN DEL LIBRO
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          data['image_url'] ?? '',
                                          width: 90, height: 60, fit: BoxFit.cover,
                                          errorBuilder: (context, e, s) => Container(width: 90, height: 60, color: Colors.grey[200]),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // TEXTO Y BOTÓN
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['nombre'] ?? 'Sin título',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                            ),
                                            const SizedBox(height: 5),
                                            SizedBox(
                                              height: 30,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFEA983E),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return DetalleProducto(
                                                        idProducto: data['idProducto'] ?? docs[index].id,
                                                        vendedorId: data['vendedor_id'] ?? '',
                                                        titulo: data['nombre'] ?? 'Sin título',
                                                        autor: data['autor_marca'] ?? 'Sin autor',
                                                        precio: data['valor'] ?? '0',
                                                        imageUrl: data['image_url'] ?? '',
                                                        descripcion: 'Este material está disponible para intercambio o venta. Contacta al vendedor para más detalles.',
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Text("Ver publicación", style: TextStyle(color: Colors.white, fontSize: 12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ICONO PAPELERA
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 28),
                                        onPressed: () {
                                          docs[index].reference.delete();
                                        },
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}