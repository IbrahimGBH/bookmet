import 'package:bookmet/auth.dart';
import 'package:bookmet/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EditarPerfil extends StatefulWidget {
const EditarPerfil({super.key});
@override

State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {

Future<String> name = Auth.instance.getNombre(Auth.instance.getUid());
Future<String> lastname = Auth.instance.getApellido(Auth.instance.getUid());
Future<String> career = Auth.instance.getCarrera(Auth.instance.getUid());
Future<String> id = Auth.instance.getCarnet(Auth.instance.getUid());
Future<String> wAdress = Auth.instance.getWhatsapp(Auth.instance.getUid());

final TextEditingController apellidoController = TextEditingController();
final TextEditingController nombreController = TextEditingController();
final TextEditingController carnetController = TextEditingController();
final TextEditingController whatsappController = TextEditingController();

String? carreraSeleccionada;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: Column(
          children: [
            _buildProfileImagePicker(),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDatosPersonales()),
                      const SizedBox(width: 60),
                      Expanded(child: _buildDatosAcademicos()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDatosPersonales(),
                      const SizedBox(height: 40),
                      _buildDatosAcademicos(),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 60),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
bool esPersonalAcademico() {
  // Obtenemos el correo del usuario actual (asumiendo que Auth tiene el email)
  String email = Auth.instance.fAuth.currentUser?.email ?? "";
  
  // Si el correo NO tiene "correo." antes de "unimet", suele ser personal/profesor
  // O puedes basarte en el valor actual de 'carreraSeleccionada'
  return !email.contains("correo.unimet.edu.ve") || carreraSeleccionada == "Personal Académico";
}

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFDAB9),
      elevation: 0,
      title: const Text("Editar Perfil", style: TextStyle(color: Colors.black)),
      actions: [
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
          child: const Text("Inicio", style: TextStyle(color: Colors.black, fontSize: 18)),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 80,
            backgroundColor: Color(0xFFFFDAB9),
            child: Icon(Icons.person, size: 100, color: Color(0xFFE5853B)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5853B),
              radius: 25,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  //por implementar
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosPersonales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Datos personales", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField("Apellidos", apellidoController, lastname, formatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
        ]),
        _buildTextField("Nombres", nombreController, name, formatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
        ]),
        _buildTextField("Carnet/ID", carnetController, id, formatters: [
          FilteringTextInputFormatter.digitsOnly, // Solo acepta números
          LengthLimitingTextInputFormatter(11), // límite máximo de dígitos del carnet de la Unimet
        ]),
      ],
    );
  }


  


  Widget _buildDatosAcademicos(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Datos académicos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
       const Text("Carrera", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        
        FutureBuilder<String>(
  future: career,
  builder: (context, snapshotCareer) {
    if (snapshotCareer.connectionState == ConnectionState.waiting) {
      return const LinearProgressIndicator();
    }

    
    if (snapshotCareer.hasData && carreraSeleccionada == null) {
      carreraSeleccionada = snapshotCareer.data;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('carreras').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        // para que salgan solo las activas 
        final carrerasList = snapshot.data!.docs.where((doc) {
          bool activa = doc['activo'] == true;
          String nombre = doc['nombre'];
          if (!activa) return false;
          if (!esPersonalAcademico() && nombre == "Personal Académico") return false;
          return true;
        }).toList();

        //aqui te obliga que si el admin quito una carrera aparezca null y no el usuairo no la pueda volver a presionar
        bool existeEnLista = carrerasList.any((d) => d['nombre'] == carreraSeleccionada);
        String? valorFinal = existeEnLista ? carreraSeleccionada : null;

        return DropdownButtonFormField<String>(
          value: valorFinal,
          isExpanded: true,
          hint: const Text("Selecciona tu carrera"),
          onChanged: esPersonalAcademico()
              ? null
              : (nuevoValor) {
                  setState(() {
                    carreraSeleccionada = nuevoValor;
                  });
                },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: esPersonalAcademico(),
            fillColor: esPersonalAcademico() ? Colors.grey[200] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: carrerasList.map((doc) {
            String nombre = doc['nombre'];
            return DropdownMenuItem<String>(
              value: nombre,
              child: Text(nombre, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
        );
      },
    );
  },
),
              const SizedBox(height: 20),
      _buildTextField(
  "Link Whatsapp", 
  whatsappController, 
  wAdress,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'El link de WhatsApp es 100% obligatorio';
    }
    final regex = RegExp(r'(https?:\/\/)?(wa\.me\/|api\.whatsapp\.com\/send\?phone=)\d+');
    
    if (!regex.hasMatch(value)) {
      return 'Ingresa un link válido (ej: https://wa.me/584140000000)';
    }
    return null; 
  },
),
      
      ],
    );
  }


  Widget _buildTextField(String label, TextEditingController control, Future<String> futureString, {List<TextInputFormatter>? formatters, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFFE5853B), fontSize: 20, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: futureString,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasData && control.text.isEmpty) {
              control.text = asyncSnapshot.data!;
            }
              return TextFormField(
                controller: control,
                inputFormatters: formatters, 
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: validator,
              );
            }
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return SizedBox(
      width: 307,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          try{
          String userId = Auth.instance.getUid();
          await FirebaseFirestore.instance.collection('usuarios').doc(userId).set({
                      'nombre': nombreController.text,
                      'apellido': apellidoController.text,
                      'carrera': carreraSeleccionada,
                      'link_whatsapp':whatsappController.text,
                      'carnet_id':carnetController.text,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Perfil actualizado con éxito!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error al guardar: ${e.toString()}"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5853B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Guardar Cambios", 
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}