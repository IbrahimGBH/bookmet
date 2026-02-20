import 'package:flutter/material.dart';

class PagRegistro extends StatelessWidget {
  const PagRegistro({super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController apellidoController = TextEditingController();
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController carnetController = TextEditingController();
    final TextEditingController carreraController = TextEditingController();
    final TextEditingController whatsappController = TextEditingController();
    final TextEditingController correoController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // Logo pedir foto a bettina
            // Image.asset('', height: ), 
            // en los '' es como se llama la foto dentro de esta carpeta y poner el height (it probando)
            
            const SizedBox(height: 20),
            const Text('Registrarse', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: apellidoController,
                        decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombres', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                        controller: carnetController,
                        decoration: const InputDecoration(labelText: 'Carnet / ID', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                        controller: correoController, 
                        decoration: const InputDecoration(labelText: 'Correo Institucional', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: carreraController, 
                        decoration: const InputDecoration(labelText: 'Carrera', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                        controller: whatsappController, 
                        decoration: const InputDecoration(labelText: 'Link Whatsapp', border: OutlineInputBorder())),
                      const SizedBox(height: 20),
                      const Text("Áreas de interés:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _crearCheck("Ingeniería"),
                            _crearCheck("Psicología"),
                            _crearCheck("Idiomas"),
                            _crearCheck("Turismo"),
                            _crearCheck("Comunicación"),
                            _crearCheck("Derecho"),
                            _crearCheck("Otros"),
                          ],
                        ),
                      
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (correoController.text.contains("unimet.edu.ve")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Correo válido"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Correo inválido: Usa el correo de la Unimet"), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("Registrarse", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

  }

    Widget _crearCheck(String titulo) {
    return CheckboxListTile(
      title: Text(titulo, style: const TextStyle(fontSize: 14)),
      value: false,
      onChanged: (bool? valor) {},
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
  }
