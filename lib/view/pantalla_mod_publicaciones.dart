import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/viewmodel/tarjeta_builder.dart';

class PantallaModPublicaciones extends StatefulWidget {
  const PantallaModPublicaciones({super.key});

  @override
  State<PantallaModPublicaciones> createState() => _PantallaModPublicacionesState();
}

class _PantallaModPublicacionesState extends State<PantallaModPublicaciones> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5853B),
        title: const Text("Moderar Publicaciones", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay publicaciones para moderar."));
          }
          var docs = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: TarjetaBuilder(
              filtro: [docs],
              cantidadColumnas: 3,
              tarjetaSize: 340,
              smallVersion: false,
              isScrollable: true,
            ),
          );
        },
      ),
    );
  }
}