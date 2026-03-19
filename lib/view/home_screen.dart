import 'package:bookmet/viewmodel/dialogo_favoritos.dart';
import 'package:bookmet/viewmodel/editar_perfil.dart';
import 'package:bookmet/viewmodel/mi_perfil.dart';
import 'package:bookmet/view/pantalla_catalogo.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/model/auth.dart';
import 'package:bookmet/view/registrarse.dart';
import 'package:bookmet/view/inicio_sesion.dart';
import 'package:bookmet/viewmodel/crear_producto.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

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
                  
                  Row(
                    children: Auth.instance.chequearUsuario()==false ? [const SizedBox(width: 20)] : [
                      TextButton(onPressed: () {showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const DialogoFavoritos();
                        },);
                      },
                      child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCatalogo()));}, child: const Text('Catálogo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 20),
                      TextButton(onPressed: () {
                        // CAMBIO AQUÍ, abre como Diálogo con fondo oscuro
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (BuildContext context) => const CrearProducto(),
                        );
                      }, child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 30),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.account_circle, size: 45, color: Color(0xFFE5853B)),
                        onSelected: (String value) {
                          switch (value) {
                            case 'perfil':
                              //TODO: revisar esta parte del código para asegurarse que no hayan errores
                              showDialog(
                                context: context,
                                builder: (context){       
                                  Size? screenSize =  MediaQuery.of(context).size;
                                  final double dialogWidth = screenSize.width * 0.9;
                                  final double dialogHeight = screenSize.height * 0.85;
                                  return MiPerfil(dialogWidth: dialogWidth, dialogHeight: dialogHeight); }
                              );
                              break;
                            case 'editar':
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarPerfil()));
                              break;
                            case 'cerrar_sesion':
                              Auth.instance.signOut(context);
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
                  
                  // Botones de Inicio de Sesión y Registro (Solo se muestran si NO está logueado)
                  if (!Auth.instance.chequearUsuario())
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5853B), 
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const InicioSesion()),);},
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
                          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const PagRegistro()),);},
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOptionButton(
                        image: 'assets/images/Escoge la opcion 2.png', 
                        title: 'Publicar',
                        description: 'Sube tus libros, guías, apuntes o materiales y dales una segunda vida. Gestiona tus recursos de forma sencilla.',
                        onTap: () {
                          if (Auth.instance.chequearUsuario()) {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (BuildContext context) => const CrearProducto(),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Debes iniciar sesión para publicar un material"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const InicioSesion()));
                          }
                        },
                      ),
                      const SizedBox(width: 40), 
                      _buildOptionButton(
                        image: 'assets/images/Escoge la opcion 1.png', 
                        title: 'Explorar catálogo',
                        description: 'Encuentra el material académico que necesitas. Filtra por carrera, materia o área de conocimiento.',
                        onTap: () {
                          if (Auth.instance.chequearUsuario()) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCatalogo()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Debes iniciar sesión para explorar el catálogo"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const InicioSesion()));
                          }
                        },
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

            // FOOTER REDISEÑADO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 80),
              decoration: const BoxDecoration(
                color: Color(0xFFFFDAB9), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)), 
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PARTE IZQUIERDA: Marca y Copyright
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BookMet',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '© 2026 Universidad Metropolitana\nTodos los derechos reservados.',
                            style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                      // PARTE DERECHA: Contacto con Iconos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildFooterItem(Icons.email_outlined, 'bookmet@correo.unimet.edu.ve'),
                          const SizedBox(height: 15),
                          _buildFooterItem(Icons.phone_iphone_outlined, '+58 412 1234567'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'Hecho para la comunidad Unimetana',
                    style: TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNCIONES DE AYUDA

  //  auxiliar para los elementos del footer con iconos
  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 22, color: const Color(0xFFE5853B)), // Icono naranja
      ],
    );
  }

  Widget _buildOptionButton({
    required String image, 
    required String title, 
    required String description,
    required VoidCallback onTap, 
  }) {
    return Expanded(
      child: InkWell( 
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             border: Border.all(color: const Color.fromARGB(255, 235, 222, 222)) 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
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

  Widget _buildInfoCardWhite({required String image, required String text}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 131, 130, 130).withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(image, height: 70),
          const SizedBox(height: 30),
          Text(
            text, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)
          ),
        ],
      ),
    );
  }
}