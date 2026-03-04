import 'package:bookmet/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/crear_producto.dart';
import 'package:bookmet/editar_perfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:bookmet/auth.dart';


class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) {
    final Auth verificar = Auth();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Color melocotón clarito del diseño
        backgroundColor: const Color(0xFFFFEAC5), 
        elevation: 0,
        toolbarHeight: 80,
        // LOGO ARRIBA A LA IZQUIERDA
        leadingWidth: 150, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset(
            'image/LogoBookmetMini.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {}, 
            child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearProducto()));

                      }, child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      
                      
          const SizedBox(width: 15),
          TextButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);}, 
            child: const Text('Inicio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          
          // BOTÓN DE LA PERSONITA 
          PopupMenuButton<String>(

            icon: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFEA983E), 
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            iconSize: 50,
            onSelected: (String value) {
        
              switch (value) {
                case 'perfil':
                  print("Navegar a Mi Perfil");
                  break;
                case 'editar':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfil()));
                  break;
                case 'cerrar_sesion':
                  verificar.signOut(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'perfil',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Mi Perfil'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar Perfil'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 30), 
        ],

      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),



// IMAGEN DEL CATÁLOGO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/catalogo.png', 
                  width: double.infinity,
                  height: 450, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
            

            
            const SizedBox(height: 40),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtros:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  
                  GestureDetector(
                    onTap: () {
                      // logica filtros
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAC5), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Selecciona los filtros....", 
                        style: TextStyle(color: Colors.black54)
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

          
           Padding(
  padding: const EdgeInsets.symmetric(horizontal: 40.0),
  child: StreamBuilder(
    
    stream: FirebaseFirestore.instance.collection('productos').snapshots(),
    builder: (context, snapshot) {
      
      if (!snapshot.hasData) return const CircularProgressIndicator();

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 25,
          mainAxisSpacing: 40,
          childAspectRatio: 0.7,
        ),

        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {

          var producto = snapshot.data!.docs[index];


          return _tarjetaProducto(
            producto['nombre'], 
            producto['autor_marca'], 
            producto['valor'], 
            producto['image_url']
          );
        },
      );
    },
  ),
),
            
            const SizedBox(height: 100),
          ]    
        ),
        
      ),
    );
  }
}
Widget _tarjetaProducto(String titulo, String autor, String precio, String foto) {
    return Column(
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
                    ? Image.network(foto, fit: BoxFit.cover) 
                    : const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.favorite_border, color: Color(0xFFC0834A), size: 30),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
        Text(autor, style: TextStyle(color: Colors.grey, fontSize: 12)),
        Text(precio, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE5853B))),
      ],
    );
  }