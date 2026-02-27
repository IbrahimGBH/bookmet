import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagRegistro extends StatefulWidget {
  const PagRegistro({super.key});
  @override
  State<PagRegistro> createState() => _PagRegistroState();
} 

class _PagRegistroState extends State<PagRegistro> {
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController carnetController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController correoController = TextEditingController();

  Map<String, bool> seleccionados = {
    "Ingeniería": false, "Psicología": false, "Idiomas": false, 
    "Turismo": false, "Comunicación": false, "Derecho": false, "Derecho": false, "Economía": false, "Administración": false, "Contaduría": false,"Otros": false
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: claveController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
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
              onPressed: () async {
                if (correoController.text.contains("unimet.edu.ve")) {
                  try {
                    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: correoController.text.trim(),
                      password: claveController.text.trim(), 
                    );

                    await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
                      'nombre': nombreController.text,
                      'apellido': apellidoController.text,
                      'carrera': carreraController.text,
                      'intereses': seleccionados.entries.where((e) => e.value).map((e) => e.key).toList(),
                      'correo':correoController.text,
                      'link_whatsapp':whatsappController.text,
                      'carnet_id':carnetController.text,
                      'correo_paypal': "",
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("¡Registrado en la nube!"), backgroundColor: Colors.green),
                    );

                    Future.delayed(const Duration(seconds: 1), () {
                      if (context.mounted) {
                        Navigator.pop(context); 
                      }
                    });

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("¡Error! Ingresa con tu correo UNIMET"), backgroundColor: Colors.red),
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
      value: seleccionados[titulo], 
      onChanged: (bool? valor) {
        setState(() {
          seleccionados[titulo] = valor!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}