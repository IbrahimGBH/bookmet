import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaGestionarFiltros extends StatefulWidget {
  const PantallaGestionarFiltros({super.key});

  @override
  State<PantallaGestionarFiltros> createState() => _PantallaGestionarFiltrosState();
}

class _PantallaGestionarFiltrosState extends State<PantallaGestionarFiltros> {
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _condicionController = TextEditingController();

  // Función para agregar a Firebase
  void _agregarFiltro(String coleccion, TextEditingController controlador) async {
    if (controlador.text.trim().isEmpty) return;
    
    await FirebaseFirestore.instance.collection(coleccion).add({
      'nombre': controlador.text.trim(),
    });
    
    controlador.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agregado con éxito')),
    );
  }

  // Función para eliminar de Firebase
  void _eliminarFiltro(String coleccion, String id) async {
    await FirebaseFirestore.instance.collection(coleccion).doc(id).delete();
  }

  // Plantilla visual para la lista
  Widget _construirLista(String coleccion, TextEditingController controlador, String titulo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controlador,
                  decoration: InputDecoration(
                    labelText: 'Nueva $titulo',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _agregarFiltro(coleccion, controlador),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Color de tu app
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Agregar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(coleccion).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var documentos = snapshot.data!.docs;
                if (documentos.isEmpty) {
                  return const Center(child: Text('Aún no hay elementos.'));
                }

                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    var doc = documentos[index];
                    return Card(
                      child: ListTile(
                        title: Text(doc['nombre']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarFiltro(coleccion, doc.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestionar Filtros', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.star_border), text: 'Condiciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _construirLista('categorias', _categoriaController, 'Categoría'),
            _construirLista('condiciones', _condicionController, 'Condición'),
          ],
        ),
      ),
    );
  }
}