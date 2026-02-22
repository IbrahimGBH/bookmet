import 'package:bookmet/editar_perfil.dart';
import 'package:bookmet/pantalla_catalogo.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';
import 'package:bookmet/registrarse.dart';
import 'package:bookmet/inicio_sesion.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final Auth verificar = Auth();

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
                    children: verificar.chequearUsuario()==false ? [SizedBox(width: 20)] : [
                      TextButton(onPressed: () {}, child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaCatalogo()));}, child: const Text('Catálogo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {}, child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 30),
                      IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfil()));} , icon: const Icon(Icons.account_circle, size: 45, color: Color(0xFFE5853B))), // Ícono de perfil
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
                    children: verificar.chequearUsuario()==true ? 
                      [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5853B), 
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {verificar.signOut(context);},
                        child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                      ] : 
                      [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5853B), 
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => InicioSesion()),);},
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
                        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => PagRegistro()),);},
                        child: const Text('Crear cuenta', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // SECCIÓN: ESCOGE LA OPCIÓN 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escoge la opción:',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 40),
                  // Row para poner los dos botones uno al lado del otro
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón 1: Publicar
                      _buildOptionButton(
                        image: 'assets/images/Escoge la opcion 2.png', 
                        title: 'Publicar',
                        description: 'Sube tus libros, guías, apuntes o materiales y dales una segunda vida. Gestiona tus recursos de forma sencilla.',
                        onTap: () { print("Click en Publicar"); },
                      ),
                      const SizedBox(width: 40), // Espacio entre botones

                      // Botón 2: Explorar Catálogo
                      _buildOptionButton(
                        image: 'assets/images/Escoge la opcion 1.png', 
                        title: 'Explorar catálogo',
                        description: 'Encuentra el material académico que necesitas. Filtra por carrera, materia o área de conocimiento.',
                        onTap: () { print("Click en Catálogo"); },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),

            // SECCIÓN: MISIÓN Y VISIÓN 
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
              color: const Color.fromARGB(255, 254, 248, 248), 
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoCardWhite(
                      image: 'assets/images/titulo mision.png',
                      text: 'La misión de BookMET es facilitar el intercambio de libros y material académico entre los miembros de la Universidad Metropolitana, a través de una plataforma web y móvil que permite publicar, buscar y gestionar recursos académicos de forma organizada, segura y accesible. El sistema busca aprovechar los materiales disponibles dentro de la universidad, fomentando la colaboración entre estudiantes y docentes y contribuyendo a una experiencia académica eficiente y equitativa entre las personas involucradas.',
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _buildInfoCardWhite(
                      image: 'assets/images/titulo Vision.png',
                      text: 'La visión de BookMET es convertirse en la plataforma digital para el intercambio de material académico dentro de la Universidad Metropolitana, promoviendo la colaboración entre usuarios, reutilización de recursos y acceso equitativo al conocimiento, apoyando así el desarrollo académico y tecnológico dentro de la universidad.',
                    ),
                  ),
                ],
              ),
            ),


            // PANEL FINAL (FOOTER)
            Image.asset('assets/images/panel de abajo.png', width: double.infinity, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  // FUNCIONES DE AYUDA MEJORADAS

  // Función para los BOTONES de Comprar/Vender (Con título y descripción abajo)
  Widget _buildOptionButton({
    required String image, 
    required String title, 
    required String description,
    required VoidCallback onTap, // Para que el botón haga algo al darle click (por ahora nada)
  }) {
    return Expanded(
      child: InkWell( // InkWell hace que se pueda dar click y muestra una animación
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             // Un borde muy sutil 
             border: Border.all(color: const Color.fromARGB(255, 235, 222, 222)) 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // Ajuste de la altura de las imagenes para que se vea bien 
                child: Image.asset(image, width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  // Función para las tarjetas de Misión y Visión (Con sombra)
  Widget _buildInfoCardWhite({required String image, required String text}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 131, 130, 130).withOpacity(0.15), // Color de la sombra suave
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5), // Posición de la sombra
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(image, height: 70), // Títulos (MISION/VISION)
          const SizedBox(height: 30),
          Text(
            text, 
            textAlign: TextAlign.center, 
            // Tamaño y el interlineado para el texto largo
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)
          ),
        ],
      ),
    );
  }
}