import 'package:bookmet/viewmodel/gestion_usuarios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  int touchedIndex = -1;

 
  List<Widget> _generarLeyendaCarreras(Map<String, int> conteo) {
    List<Widget> leyenda = [];
    int i = 0;
    conteo.forEach((carrera, cantidad) {
      final color = Colors.primaries[i % Colors.primaries.length];
      leyenda.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  carrera,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
      i++;
    });
    return leyenda;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5853B),
        title: const Text("Detalle de Usuarios", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs.where((doc) {
             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['admin'] != true; // Excluimos a los administradores
               }).toList();
          // var docs = snapshot.data!.docs;
          int total = docs.length;
          if (total == 0) {
              return const Center(child: Text("No hay usuarios registrados"));
        }

        int activos = docs.where((d){Map<String, dynamic> data = d.data() as Map<String, dynamic>;
           return data['activo'] == true;}).length; 
            int inactivos = total - activos;
          int profesores = docs.where((d) => d['carrera'] == "Personal Académico").length;
          int alumnos = total - profesores;

          Map<String, int> carreraConteo = {};
          for (var doc in docs) {
            String carrera = doc['carrera'] ?? 'Sin Carrera';
            carreraConteo[carrera] = (carreraConteo[carrera] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
           child: Column(
              children: [
                // Fila 1: Totales Principales
                Row(
                  children: [
                    _cardMini("Total Usuarios", total.toString(), const Color(0xFF3F85D5)),
                    const SizedBox(width: 10),
                    _cardMini("Usuarios Activos", activos.toString(), const Color(0xFF59BBA3)),
                    const SizedBox(width: 10),
                    _cardMini("Usuarios Inactivos", inactivos.toString(), const Color(0xFFE05555)),
                  
                  
                  ],
                ),
                
                const SizedBox(height: 15),
                // Fila 2: Roles
                Row(
                  children: [
                    _cardMini("Alumnos", alumnos.toString(), const Color(0xFFE5853B)),
                    const SizedBox(width: 10),
                    _cardMini("Profesores", profesores.toString(), const Color(0xFF3F85D5)),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                const SizedBox(height: 30),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _chartContainer(
                        title: "Por Rol",
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: _mostrarSeccionesRol(alumnos, profesores, total),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _chartContainer(
                        title: "Por Carreras",
                        child: Row( 
                          children: [
                            Expanded(
                              flex: 6,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: _mostrarSeccionesCarrera(carreraConteo, total),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 4,
                              child: ListView(
                                shrinkWrap: true, 
                                children: _generarLeyendaCarreras(carreraConteo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
  
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Registros Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => GestionUsuarios.mostrarDirectorio(context, docs),
                        child: const Text("Ver todos", style: TextStyle(color: Color(0xFF3F85D5))),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 5 ? 5 : docs.length,
                  itemBuilder: (context, index) {
                    var user = docs[index];
                    bool esProfe = user['carrera'] == "Personal Académico";
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esProfe ? const Color(0xFF3F85D5) : const Color(0xFFE5853B),
                          child: Icon(esProfe ? Icons.school : Icons.person, color: Colors.white),
                        ),
                        title: Text("${user['nombre']} ${user['apellido']}"),
                        subtitle: Text(user['carrera'] ?? ""),
                      
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _chartContainer({required String title, required Widget child}) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<PieChartSectionData> _mostrarSeccionesRol(int alumnos, int profesores, int total) {
    return [
      PieChartSectionData(
        color: const Color(0xFFE5853B),
        value: alumnos.toDouble(),
        title: alumnos > 0 ? '${((alumnos/total)*100).round()}%' : '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: const Color(0xFF3F85D5),
        value: profesores.toDouble(),
        title: profesores > 0 ? '${((profesores/total)*100).round()}%' : '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<PieChartSectionData> _mostrarSeccionesCarrera(Map<String, int> conteo, int total) {
    List<PieChartSectionData> secciones = [];
    int i = 0;
    conteo.forEach((carrera, cantidad) {
      final color = Colors.primaries[i % Colors.primaries.length];
      secciones.add(PieChartSectionData(
        color: color,
        value: cantidad.toDouble(),
        title: '${((cantidad/total)*100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    });
    return secciones;
  }

  Widget _cardMini(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 