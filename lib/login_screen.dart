import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí puedes cambiar el color principal por el hexadecimal de tu Figma
    const Color colorPrincipal = Color(0xFF2A5298); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo de la App
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Asegúrate de tener tu logo aquí
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.book_online, 
                    size: 100, 
                    color: colorPrincipal,
                  ), // Icono de respaldo si no hay imagen
                ),
              ),
              const SizedBox(height: 30),
              
              // Texto de Bienvenida
              Text(
                '¡Bienvenido a bookmet!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),

              // Campo de Correo Electrónico
              TextFormField(
                // TODO: Integrante 2 - Conectar el controller del email aquí
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.email_outlined, color: colorPrincipal),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: colorPrincipal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextFormField(
                // TODO: Integrante 2 - Conectar el controller de la contraseña aquí
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline, color: colorPrincipal),
                  suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: colorPrincipal, width: 2),
                  ),
                ),
              ),
              
              // Olvidé mi contraseña (Para el Integrante 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Integrante 3 - Navegar a Recuperar Contraseña
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: GoogleFonts.poppins(color: colorPrincipal),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Iniciar Sesión
              ElevatedButton(
                onPressed: () {
                  // TODO: Integrante 2 - Agregar lógica de inicio de sesión con Firebase
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'INICIAR SESIÓN',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ir a Registro (Para el Integrante 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Integrante 1 - Navegar a pantalla de Registro
                    },
                    child: Text(
                      'Regístrate',
                      style: GoogleFonts.poppins(
                        color: colorPrincipal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}