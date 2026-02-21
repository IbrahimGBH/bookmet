import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            // BARRA SUPERIOR 
            Container(
              color: const Color(0xFFFFDAB9), // Color de fondo del panel superior
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo_bookmet.png', height: 40), 
                  
                  // Botones de la barra superior
                  Row(
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {}, child: const Text('Catálogo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {}, child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 30),
                      const Icon(Icons.account_circle, size: 45, color: Color(0xFFE5853B)), // Ícono de perfil
                    ],
                  )
                ],
              ),
            ),

            // BANNER PRINCIPAL
            Image.asset('assets/images/imagen_inicial.png', width: double.infinity, fit: BoxFit.cover),

            const SizedBox(height: 60),

            // SECCIÓN DE BIENVENIDA Y BOTONES
            Center(
              child: Column(
                children: [
                  const Text(
                    '¡Bienvenidos a BookMet!',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 200),
                    child: Text(
                      'La plataforma diseñada por y para la comunidad unimetana. Aquí podrás conectar con otros estudiantes y docentes para intercambiar o adquirir libros y material académico de forma rápida y segura. Centraliza tus recursos, ahorra tiempo y dale una segunda vida a tus libros dentro de la Unimet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5853B), 
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFDAB9), 
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        child: const Text('Crear cuenta', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
            const Center(child: Text("Aquí irá la parte de Escoge la opción para abajo, en un rato la haago", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

