import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GestionFiltros extends StatefulWidget{
  const GestionFiltros({super.key}); 

  @override 
  State<GestionFiltros> createState() => _GestionFiltrosState(); 
}

class _GestionFiltrosState extends State<GestionFiltros>{
  final TextEditingController _carreraController = TextEditingController(); 
// esto es para agregar una carrera 
 void _mostrarNuevaCarrera() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Carrera"),
        content: TextField(
          controller: _carreraController,
          decoration: const InputDecoration(hintText: "Nombre de la carrera"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_carreraController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('carreras').add({
                  'nombre': _carreraController.text.trim(),
                  'activo': true,
                });
                _carreraController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Gestionar Carreras", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          // Puse esto asi para que la BDD no se nos dañe al eliminar alguna de las carreras, si alguna esta inactiva simplemente no le va a salir a una persona al registrarse. 
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('carreras').orderBy('nombre').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var activas = snapshot.data!.docs.where((doc) => (doc.data() as Map)['activo'] == true).toList();
                var inactivas = snapshot.data!.docs.where((doc) => (doc.data() as Map)['activo'] == false).toList();
                return ListView(
                  children: [
                     const Padding(
                     padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("CARRERAS ACTIVAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                     ), 
                    ...activas.map((doc) => ListTile(
            title: Text(doc['nombre']),
            trailing: IconButton(
              icon: const Icon(Icons.visibility_off, color: Colors.orange),
              onPressed: () => _confirmarCambioEstado(
                context, 
                doc, false, "Desea desactivar la carrera", "Esta carrera ya no aparecera en el registro de nuevos usuarios"
              ),
               
            ),
          )),

          const Divider(thickness: 2, height: 40), 


          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("CARRERAS INACTIVAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...inactivas.map((doc) => ListTile(
            title: Text(doc['nombre'], style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.restore, color: Colors.blue), 
              onPressed: () => _confirmarCambioEstado(
                context, 
                doc, true, "Desea reactivar la carrera", "Esta carrera volvera a estar disponible para todos los estudiantes"
              ),
            ),
          )),
        ],
      );
    },
  ),
),

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mostrarNuevaCarrera,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Añadir Nueva", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          )
        ],
      ),
    );
  }
  void _confirmarCambioEstado(BuildContext context, DocumentSnapshot doc, bool nuevoEstado, String titulo, String mensaje) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(titulo),
      content: Text(mensaje),
      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: nuevoEstado ? Colors.blue : Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            await doc.reference.update({'activo': nuevoEstado});
            if (context.mounted) Navigator.pop(context); 
          },
          child: Text(nuevoEstado ? "Reactivar" : "Desactivar", 
            style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}