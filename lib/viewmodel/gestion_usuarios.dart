
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; 
class GestionUsuarios {
  
  static const Color naranjaMetro = Color(0xFFE5853B);
  
  static void mostrarDirectorio(BuildContext context, List<QueryDocumentSnapshot> usuarios) {
    String filtroNombre = "";
    showDialog(
      context: context,
      builder: (context) {
          return StatefulBuilder(builder:(context,setState) {
            return Dialog(
    
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Directorio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar por nombre...",
                          prefixIcon: const Icon(Icons.search, color: naranjaMetro),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: naranjaMetro),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filtroNombre = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('usuarios').orderBy('nombre').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      var docs = snapshot.data!.docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            // No mostramos admins y filtramos por nombre/apellido
                            bool esAdmin = data['admin'] == true;
                            String nombreCompleto = "${data['nombre']} ${data['apellido']}".toLowerCase();
                            return !esAdmin && nombreCompleto.contains(filtroNombre);
                          }).toList();

                          if (docs.isEmpty) {
                            return const Center(child: Text("No se encontraron usuarios"));
                          }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var user = docs[index];
                          var data = user.data() as Map<String, dynamic>;
                          bool estaActivo = data['activo'] ?? true;

                          return ListTile(
                            title: Text(
                              "${data['nombre']} ${data['apellido']}", 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${data['correo'] ?? ''}", style: const TextStyle(fontSize: 13)),
                                Text(
                                  estaActivo ? "● Activo" : "● Inactivo", 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: estaActivo ? Colors.green : Colors.red
                                  )
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: naranjaMetro),
                              onPressed: () => _opcionesUsuario(context, user),
                              child: const Text("Gestionar", style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  
 static void _opcionesUsuario(BuildContext context, QueryDocumentSnapshot user) {
    Map<String, dynamic> data = user.data() as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: naranjaMetro, child: Icon(Icons.manage_accounts, color: Colors.white)),
            const SizedBox(width: 10),
            const Text("Opciones de Usuario", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(Icons.person, "Nombre completo", "${data['nombre']} ${data['apellido']}"),
            _buildInfoRow(Icons.badge, "Carnet", data['carnet_id']),
            _buildInfoRow(Icons.school, "Carrera", data['carrera']),
            _buildInfoRow(Icons.email, "Correo", data['correo']),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _Editar_perfil(context, user);
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text("Editar", style: TextStyle(color: Colors.blue)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarInactivar(context, user),
                  icon: Icon(
      (data['activo'] ?? true) ? Icons.person_off : Icons.person_add, 
      color: (data['activo'] ?? true) ? Colors.orange : Colors.green
    ),
    label: Text(
      (data['activo'] ?? true) ? "Desactivar" : "Activar", 
      style: TextStyle(color: (data['activo'] ?? true) ? Colors.orange : Colors.green)
    ),
  ),
),
            ],
          )
        ],
      ),
    );
  }

  static void _Editar_perfil(BuildContext context, QueryDocumentSnapshot user) {
    Map<String, dynamic> data = user.data() as Map<String, dynamic>;
    
    
    final nomController = TextEditingController(text: data['nombre']);
    final apeController = TextEditingController(text: data['apellido']);
    final carnetController = TextEditingController(text: data['carnet_id']);
    final waController = TextEditingController(text: data['link_whatsapp']);
    String? carreraSeleccionada = data['carrera'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Actualizar Datos", style: TextStyle(fontWeight: FontWeight.bold, color: naranjaMetro)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputLabel("Nombre"),
                _buildTextField(nomController),
                _inputLabel("Apellido"),
                _buildTextField(apeController),
                _inputLabel("Carnet / ID"),
                _buildTextField(carnetController, isNumeric: true),
                _inputLabel("Carrera"),
                _buildCarreraDropdown(carreraSeleccionada, (val) => setState(() => carreraSeleccionada = val)),
                _inputLabel("WhatsApp (Link)"),
                _buildTextField(waController),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranjaMetro),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('usuarios').doc(user.id).update({
                  'nombre': nomController.text.trim(),
                  'apellido': apeController.text.trim(),
                  'carnet_id': carnetController.text.trim(),
                  'carrera': carreraSeleccionada,
                  'link_whatsapp': waController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Usuario actualizado con éxito!")));
              },
              child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }



  static Widget _buildInfoRow(IconData icon, String label, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: naranjaMetro),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${valor ?? 'No asignado'}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  static Widget _buildTextField(TextEditingController controller, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Widget _buildCarreraDropdown(String? selected, Function(String?) onChanged) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('carreras').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        var docs = snapshot.data!.docs;
        
       
        String? valorActual = docs.any((d) => d['nombre'] == selected) ? selected : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valorActual,
              isExpanded: true,
              hint: const Text("Seleccionar carrera"),
              items: docs.map((d) => DropdownMenuItem(value: d['nombre'] as String, child: Text(d['nombre']))).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }

  static void _confirmarInactivar(BuildContext context, QueryDocumentSnapshot user) {
  Map<String, dynamic> data = user.data() as Map<String, dynamic>;
  bool estaActivo = data['activo'] ?? true; 

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(estaActivo ? "Inactivar Usuario" : "Reactivar Usuario"),
      content: Text(estaActivo 
        ? "¿Estás seguro de que deseas desactivar a este usuario? No podrá iniciar sesión hasta que sea reactivado."
        : "¿Deseas activar nuevamente a este usuario?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: estaActivo ? Colors.red : Colors.green
          ),
          onPressed: () async {
            
            await FirebaseFirestore.instance.collection('usuarios').doc(user.id).update({
              'activo': !estaActivo,
            });
            
            Navigator.pop(context); 
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(estaActivo ? "Usuario inactivado" : "Usuario reactivado"),
              backgroundColor: estaActivo ? Colors.orange : Colors.green,
            ));
          },
          child: Text(estaActivo ? "Inactivar" : "Reactivar", style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  }
}