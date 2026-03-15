import 'package:flutter/material.dart';
import 'package:bookmet/detalle_producto.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookmet/auth.dart';  

class TarjetaProducto extends StatelessWidget {
  final String idProducto; // NUEVO
  final String vendedorId; // NUEVO
  final String titulo;
  final String autor;
  final String precio;
  final String foto;
  final String descripcion;

  const TarjetaProducto({
    super.key,
    required this.idProducto, // NUEVO
    required this.vendedorId, // NUEVO
    required this.titulo,
    required this.autor,
    required this.precio,
    required this.foto,
    required this.descripcion,
  });

  //FUNCIÓN QUE AGREGA A FAVORITOS
  Future<void> _presionarCorazon(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('favoritos')
        .doc(titulo); // Guardamos usando el título como ID

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete(); // Si ya existe, lo quita
    } else {
      await docRef.set({
        'nombre': titulo,
//        'autor_marca': autor,
//        'valor': precio,
        'image_url': foto,
        'id_producto': idProducto,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DetalleProducto(
              idProducto: idProducto, // NUEVO
              vendedorId: vendedorId, // NUEVO
              titulo: titulo,
              autor: autor,
              precio: precio,
              imageUrl: foto,
              descripcion: descripcion,
            );
          },
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
                      ? Image.network(
                        foto, 
                        fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 50, color: Colors.grey),
                ),
              ),
              
              FutureBuilder<bool>(
                future: user != null ? Auth.instance.isAdmin(user.uid) : Future.value(false),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.data == true) return const SizedBox();

                  return Positioned(
                    top: 10,
                    right: 10,
                    child: user == null 
                      ? const Icon(Icons.favorite_border, color: Color(0xFFC0834A), size: 30)
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(user.uid)
                              .collection('favoritos')
                              .doc(titulo)
                              .snapshots(),
                          builder: (context, snapshot) {
                            bool esFavorito = snapshot.hasData && snapshot.data!.exists;
                            return IconButton(
                              icon: Icon(
                                esFavorito ? Icons.favorite : Icons.favorite_border, 
                                color: const Color(0xFFC0834A), 
                                size: 30
                              ),
                              onPressed: () => _presionarCorazon(context),
                            );
                          },
                        ),
                  );
                }
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