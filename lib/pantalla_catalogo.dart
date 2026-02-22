import 'package:bookmet/home_screen.dart';
import 'package:flutter/material.dart';

class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) {
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
          TextButton(
            onPressed: () {}, 
            child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          TextButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);}, 
            child: const Text('Inicio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          
          // BOTÓN DE LA PERSONITA 
          InkWell(
            onTap: () {
              //enviar a perfil
            },
            borderRadius: BorderRadius.circular(50),
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFEA983E), 
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
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
                        child: Text("Revisa que en pubspec.yaml diga: - assets/images/"),
                      ),
                    );
                  },
                ),
              ),
            ),
            

            // Aquí se puede poner los libros mas abajo
            const SizedBox(height: 40),
            const Text("Explora nuestros libros", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}