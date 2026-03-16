
import 'package:bookmet/gestion_filtros.dart';
import 'package:bookmet/gestion_usuarios.dart';
import 'package:bookmet/pantalla_tdia.dart';
import 'package:bookmet/pantalla_mod_publicaciones.dart';
import 'package:bookmet/pantalla_usuarios.dart';
import 'package:bookmet/tarjeta_builder.dart';
import 'package:bookmet/tarjeta_producto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



Widget metricCard(String title, String value, Color color, BuildContext context) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        // Solo navegamos si es la tarjeta de Usuarios
        if (title == "Total Usuarios") {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const PantallaUsuarios())
          );
        }
        if (title == "Transacciones del día"||title =="Transacciones pendientes") {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const PantallaTdia())
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Stack( 
          children: [
            // Centramos el contenido de la columna
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Para que no ocupe todo el alto del Stack
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                    value, 
                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),

              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.add_circle_outline, color: Colors.white70, size: 22),
              ),
          ],
        ),
      ),
    ),
  );
}

 Widget sectionContainer({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.only(
      top: title.isEmpty ? 5 : 25, 
      left: 25, 
      right: 25, 
      bottom: 25
    ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }


Widget filterManager(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Carreras", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

Expanded(child: 
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('carreras').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  bool estaActiva = doc['activo'] ?? false;
                  String nombreCarrera = doc['nombre'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCarrera,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .where('carrera', isEqualTo: nombreCarrera)
                                    .snapshots(),
                                builder: (context, userSnap) {
                                  int count = userSnap.hasData ? userSnap.data!.docs.length : 0;
                                  return Text(
                                    "$count usuarios",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),


                        Icon(
                          estaActiva ? Icons.check_circle : Icons.cancel,
                          color: estaActiva ? Colors.green : Colors.red,
                          size: 22,
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          ),
        ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {

                showDialog(
                context: context,
                builder: (context) => const Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),),

                  child: GestionFiltros(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F85D5)),
            child: const Text("Gestionar Todo", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}

Widget sidebarItem(IconData icon, String label, bool isActive, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    color: isActive ? Colors.black12 : Colors.transparent,
    child: SizedBox(
      height: 50,
      child: TextButton(
        onPressed: () async {
          if (label == "Directorio Usuarios") {
            Navigator.pop(context); 


            final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();


            GestionUsuarios.mostrarDirectorio(context, snapshot.docs);
          } 
          else if (label == "Gestionar Carreras") {
            Navigator.pop(context); // Cierra el sidebar

            
            showDialog(
              context: context,
              builder: (context) => const Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: GestionFiltros(), // Tu widget de filtros
              ),
            );
          }
          else if (label == "DashBoard") {
            Navigator.pop(context);
           
          }
          else if (label == "Moderación") {
            Navigator.pop(context);
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => const PantallaModPublicaciones())
            );
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 15),
            Text(
              label, 
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget ultimasPublicacionesModeracion() {
  return StreamBuilder<QuerySnapshot>(
    
    stream: FirebaseFirestore.instance
        .collection('productos')
        .orderBy('fecha', descending: true)
        .limit(3) 
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: LinearProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No hay publicaciones recientes."));
      }

      
      var docs = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

      return TarjetaBuilder(
        filtro: [docs],
        cantidadColumnas: 3, 
        tarjetaSize: 400,    
        smallVersion: true,  
        isScrollable: false, 
      );
    },
  );
}