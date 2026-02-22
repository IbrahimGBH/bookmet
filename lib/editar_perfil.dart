import 'package:bookmet/auth.dart';
import 'package:bookmet/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
   Map<String, bool> seleccionados = {
    "Ingeniería": false, "Psicología": false, "Idiomas": false, 
    "Turismo": false, "Comunicación": false, "Derecho": false, "Otros": false
  };
  //final Set<String> _selectedIntereses = {};
  Future<String> name = Auth().getNombre(Auth().getUid());
  Future<String> lastname = Auth().getApellido(Auth().getUid());
  Future<String> career = Auth().getCarrera(Auth().getUid());
  Future<String> id = Auth().getCarnet(Auth().getUid());
  Future<String> pAdress = Auth().getPaypal(Auth().getUid());
  Future<String> wAdress = Auth().getWhatsapp(Auth().getUid());
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController carnetController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController paypalController = TextEditingController();


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
        _buildTextField("Apellidos", apellidoController, lastname),
        _buildTextField("Nombres", nombreController, name),
        _buildTextField("Carnet/ID",carnetController, id),
        _buildTextField("Correo Paypal", paypalController, pAdress),
      ],
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

  Widget _buildDatosAcademicos(){
    return Column(
      children: [
        const Text("Datos académicos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField("Carrera", carreraController, career),
        _buildTextField("Link Whatsapp", whatsappController, wAdress),
        const SizedBox(height: 20),
        _crearCheck("Ingeniería"),
        _crearCheck("Psicología"),
        _crearCheck("Idiomas"),
        _crearCheck("Turismo"),
        _crearCheck("Comunicación"),
        _crearCheck("Derecho"),
        _crearCheck("Otros"),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController control, Future<String> futureString) {
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
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
          String userId = Auth().getUid();
          await FirebaseFirestore.instance.collection('usuarios').doc(userId).set({
                      'nombre': nombreController.text,
                      'apellido': apellidoController.text,
                      'carrera': carreraController.text,
                      'intereses': seleccionados.entries.where((e) => e.value).map((e) => e.key).toList(),
                      'link_whatsapp':whatsappController.text,
                      'carnet_id':carnetController.text,
                      'correo_paypal':paypalController.text,
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