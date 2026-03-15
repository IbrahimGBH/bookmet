
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';
import 'package:bookmet/widgets_admin.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      //AppBar Superior
        drawer: Drawer(
    width: 250,
    backgroundColor: const Color(0xFFE5853B),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
       
        sidebarItem(Icons.dashboard, "DashBoard", false, context),
         sidebarItem(Icons.people, "Directorio Usuarios", false, context),
        sidebarItem(Icons.filter_list, "Gestionar Filtros", false, context),
        sidebarItem(Icons.remove_red_eye, "Moderación", false, context),
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
            future: Auth.instance.getNombre(Auth.instance.getUid()),
            builder: (context, asyncSnapshot) {
              String nombre = asyncSnapshot.data ?? "";
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SizedBox(
                    width: 200,
                    child: TextButton(
                      onPressed: (){Auth.instance.signOut(context);},
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
                  StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
  builder: (context, snapshot) {
    
    // Aquí hacemos la resta simple
    String totalUsuarios = "...";
    if (snapshot.hasData) {
      // Tomamos el total y le restamos 1 (tu cuenta de admin)
      int calculo = snapshot.data!.docs.length - 1;
      totalUsuarios = calculo.toString();
    }
                    
                    return Row(
                      children: [
                        
                        metricCard("Usuarios Activos", totalUsuarios, const Color(0xFF3F85D5), context),
                        const SizedBox(width: 20),
                        
                        metricCard("Intercambios del día", "0", const Color(0xFF59BBA3), context),
                        const SizedBox(width: 20),
                        metricCard("Intercambios pendientes", "0", const Color(0xFFE05555), context),
                      ],
                    );
                  },
                ),
                  
                  const SizedBox(height: 40),
                  
                  //Gráfica y Filtros
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espacio para Gráfica
                      Expanded(
                        flex: 2,
                        child: sectionContainer(
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
                        child: filterManager(context)),
                      
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  //Moderación
                  sectionContainer(
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



}