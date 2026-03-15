import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagRegistro extends StatefulWidget {
  const PagRegistro({super.key});
  @override
  State<PagRegistro> createState() => _PagRegistroState();
} 

class _PagRegistroState extends State<PagRegistro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController carnetController = TextEditingController();
  String? carreraSeleccionada;
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController correoController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('Registrarse', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 5),
              const Text('* campos obligatorios', style: TextStyle(fontSize:10, color: Colors.red)),
              const SizedBox(height: 25),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: apellidoController,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                                return 'Solo letras';
                              }
                            }
                            return null;
                          },
                            decoration: const InputDecoration(
                              label: Text.rich(TextSpan(children: [
                                TextSpan(text: 'Apellidos '),
                              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                    ]
                                    )
                                    ),
                               border: OutlineInputBorder(),
                             ),
                          ),
                            
                  
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: nombreController,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                                return 'Solo letras';
                              }
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [
                             TextSpan(text: 'Nombres '),
                            TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                         ]
                         )
                         ),
                          border: OutlineInputBorder(),
                           ),
                          ),
                        const SizedBox(height: 10),
                        
                        TextFormField(
                          controller: carnetController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Solo números';
                              }
                            }
                            return null;
                          },
                            decoration: const InputDecoration(
                              label: Text.rich(TextSpan(children: [
                              TextSpan(text: 'Carnet / ID '),
                                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                              ]
                              )
                              ),
                            border: OutlineInputBorder(),
                      ),),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: correoController, 
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.endsWith('unimet.edu.ve')) {
                                return 'Error. Usa tu correo UNIMET';
                              }
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            label: Text.rich(TextSpan(children: [
                          TextSpan(text: 'Correo Institucional '),
                              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                            ])),
                            border: OutlineInputBorder(),
                          ),),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: claveController,
                          obscureText: true,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [
                          TextSpan(text: 'Contraseña '),
                        TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                            ])),
                        border: OutlineInputBorder(),
                            ),),
                      ]
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('carreras').where('activo', isEqualTo: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Text("Error al cargar");
                          if (!snapshot.hasData) return const LinearProgressIndicator();

                          
                          return DropdownButtonFormField<String>(
                            value: carreraSeleccionada,
                            decoration: const InputDecoration(
                              label: Text.rich(TextSpan(children: [
                                TextSpan(text: 'Carrera '),
                                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                              ])),
                              border: OutlineInputBorder(),
                            ),
                            items: snapshot.data!.docs.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc['nombre'], 
                                child: Text(doc['nombre'], style: const TextStyle(fontSize: 15)),
                              );
                            }).toList(),
                            onChanged: (nuevoValor) {
                              setState(() {
                                carreraSeleccionada = nuevoValor;
                              });
                            },
                            validator: (value) => value == null ? 'Selecciona tu carrera' : null,
                          );
                        },
                      ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: whatsappController, 
                          decoration: const InputDecoration(labelText: 'Link Whatsapp', border: OutlineInputBorder())),
                        const SizedBox(height: 20),
                      
                          
                      ],
                    ),
                  ),
                ],
              ),
              
                
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  // Validamos los formatos antes de proceder
                  if (_formKey.currentState!.validate()) {
                    
                    if( apellidoController.text.isEmpty || nombreController.text.isEmpty || carnetController.text.isEmpty || correoController.text.isEmpty || claveController.text.isEmpty || carreraSeleccionada == null){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Porfavor llenar los campos obligatorios"),
                          backgroundColor: Colors.red,
                        ),
                      ); return;
                    }
                    String email = correoController.text.trim().toLowerCase();
                  String carrera = carreraSeleccionada!.trim();

                 bool esEstudiante = email.endsWith('@correo.unimet.edu.ve');
    // Es profesor si es unimet pero NO tiene el ".correo"
                    bool esProfesor = email.endsWith('@unimet.edu.ve') && !esEstudiante;

                    // Validación Estudiante
                    if (esEstudiante && carrera == "Personal Académico") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Opción inválida para estudiantes, debe colocar su carrera"), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    // Validación Profesor
                    if (esProfesor && carrera != "Personal Académico") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Como profesor, debe seleccionar 'Personal Académico'"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    try {
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: correoController.text.trim(),
                        password: claveController.text.trim(), 
                      );

                      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
                        'nombre': nombreController.text,
                        'apellido': apellidoController.text,
                        'carrera': carreraSeleccionada,
                      
                        'correo':correoController.text,
                        'link_whatsapp':whatsappController.text,
                        'carnet_id':carnetController.text,
                        'correo_paypal': "",
                        'rating_puntos': 0,
                        'rating_votos': 0,
                        'fecha_registro': FieldValue.serverTimestamp(),
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
                  }
                }, 
                child: const Text("Registrarse", style: TextStyle(color: Colors.white)),
              ),
                ],
              ),
            
      ),
      ),
    );
  }
}
            
    