import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';


class InicioSesion extends StatelessWidget {
  InicioSesion({super.key});
  final controllerUser = TextEditingController();
  final controllerPassword = TextEditingController();
  final Auth verificar = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDAB9),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Icon(Icons.book, size: 32, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Inicio', style: TextStyle(color: Colors.black, fontSize: 20)),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.account_circle, size: 40, color: Color(0xFFEA983E)),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo Central
              Center(
                child: Container(
                  height: 158,
                  width: 474,
                  color: Colors.grey[200],
                  child: const Center(child: Text('BOOKMET LOGO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 50),

              _buildInputField(label: 'Correo electrónico', controller: controllerUser),
              const SizedBox(height: 30),
              
              _buildInputField(label: 'Contraseña', isObscure: true, controller: controllerPassword),
              const SizedBox(height: 40),

              SizedBox(
                width: 307,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = controllerUser.text.trim();
                    final password = controllerPassword.text;
                    final messenger = ScaffoldMessenger.of(context);
                    if (email.isEmpty || password.isEmpty) {
                      messenger.showSnackBar(const SnackBar(content: Text('Por favor complete todos los campos')));
                      return;
                    }
                    messenger.showSnackBar(const SnackBar(content: Text('Iniciando sesión...')));
                    try {
                      final cred = await verificar.signInWithEmail(context, email, password);
                      if (cred == null) {
                        messenger.showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
                      }
                    } catch (e) {
                      messenger.showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5853B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 100),
              const Divider(color: Color(0xFF666666), thickness: 1),
              const SizedBox(height: 40),

              // Sección de Registro
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                children: [
                  const Text(
                    '¿No tienes una cuenta de BookMet?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFDAB9),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                    ),
                    child: const Text('Regístrate ahora', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, bool isObscure = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: 695,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
