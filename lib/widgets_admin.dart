
import 'package:bookmet/gestion_filtros.dart';
import 'package:bookmet/gestion_usuarios.dart';
import 'package:bookmet/pantalla_usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



Widget metricCard(String title, String value, Color color, BuildContext context) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        // Solo navegamos si es la tarjeta de Usuarios
        if (title == "Usuarios Activos") {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const PantallaUsuarios())
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
            
            // El icono de "más" solo lo mostramos si es clickeable
            if (title == "Usuarios Activos")
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
      padding: const EdgeInsets.all(25),
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
  // Busca tu función sidebarItem y reemplázala por esta:
Widget sidebarItem(IconData icon, String label, bool isActive, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    color: isActive ? Colors.black12 : Colors.transparent,
    child: SizedBox(
      height: 50,
      child: TextButton(
        onPressed: () async {
          if (label == "Detalle Usuarios") {
            Navigator.pop(context); 
            
           
            final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();
            
            
            GestionUsuarios.mostrarDirectorio(context, snapshot.docs);
          } 
          else if (label == "Gestionar Filtros") {
            Navigator.pop(context); // Cierra el sidebar
            
            // 3. Abrimos GestionFiltros envuelto en un Dialog para que no salga como pantalla nueva
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
            // Aquí podrías añadir un Navigator.push si no estás ya en AdminView
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