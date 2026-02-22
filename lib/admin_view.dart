import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';

class AdminView extends StatelessWidget {
  AdminView({super.key});
  final Auth verificar = Auth();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      //AppBar Superior
      drawer: Drawer(
        width: 250,
        backgroundColor: const Color(0xFFE5853B),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                _sidebarItem(Icons.dashboard, "DashBoard", false),
                _sidebarItem(Icons.filter_list, "Gestionar Filtros", false),
                _sidebarItem(Icons.remove_red_eye, "Moderación", false),
            ],
          ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5853B),
        elevation: 0,
        title: const Text(
          "BookMet | Admin Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          FutureBuilder(
            future: verificar.getNombre(verificar.getUid()),
            builder: (context, asyncSnapshot) {
              String nombre = asyncSnapshot.data ?? "";
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SizedBox(
                    width: 200,
                    child: TextButton(
                      onPressed: (){},
                      child: Text(
                        "Admin: $nombre | Log Out",
                        style: TextStyle(color: Colors.white.withValues(), fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.account_circle, color: Colors.white, size: 30),
          ),
        ],
      ),
      body: Row(
        children: [
          //Sidebar (Barra Lateral)

          //Contenido Principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DashBoard",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  
                  //Métricas
                  Row(
                    children: [
                      _metricCard("Usuarios Activos", "null", const Color(0xFF3F85D5)),
                      const SizedBox(width: 20),
                      _metricCard("Intercambios del día", "null", const Color(0xFF59BBA3)),
                      const SizedBox(width: 20),
                      _metricCard("Intercambios pendientes", "null", const Color(0xFFE05555)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  //Gráfica y Filtros
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espacio para Gráfica
                      Expanded(
                        flex: 2,
                        child: _sectionContainer(
                          title: "Métricas de Demanda Académica",
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage('https://placeholder.com/graph'), // Placeholder
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(child: Text("Área de Gráfico Lineal")),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      //Gestión de Filtros
                      Expanded(
                        flex: 1,
                        child: _filterManager(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  //Moderación
                  _sectionContainer(
                    title: "Moderación de Publicaciones",
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F85D5),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text("Visualizar", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Widgets

  Widget _sidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      color: isActive ? Colors.black12 : Colors.transparent,
      child: SizedBox(
        height: 50,
        child: TextButton(
          onPressed: (){},
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16),textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sectionContainer({required String title, required Widget child}) {
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

  Widget _filterManager() {
    List<String> tags = ["Ing. Civil", "Psicología", "Ing. Química", "Derecho", "Administración"];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gestionar Filtros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...tags.map((tag) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5853B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const Icon(Icons.cancel_outlined, color: Color(0xFFE5853B), size: 20),
              ],
            ),
          )),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F85D5)),
              child: const Text("+ Añadir Carrera", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}