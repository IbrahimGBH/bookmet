import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearProducto extends StatefulWidget {
  const CrearProducto({super.key});
  @override
  State<CrearProducto> createState() => _CrearProductoState();
}

class _CrearProductoState extends State<CrearProducto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController autorMarcaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController urlImagenController = TextEditingController();

  String? categoriaSeleccionada;
  String? estadoSeleccionado;
  String? tipoTransaccionSeleccionado;

  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  // Función para seleccionar imagen de la galería
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }

  // Función para subir la imagen a Supabase
  Future<String?> _uploadImage() async {
    if (_webImageBytes == null) return null;

    try {
      final supabase = Supabase.instance.client;
      final String fileName = 'productos/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('imagen_producto').uploadBinary(
            fileName,
            _webImageBytes!,
            fileOptions: const FileOptions(
                cacheControl: '3600', upsert: false, contentType: 'image/jpeg'),
          );

      final String publicUrl =
          supabase.storage.from('imagen_producto').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el ancho igual que en MiPerfil
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 581 ? 581 : screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent, // Transparente 
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        width: dialogWidth,
        
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco sólido para el formulario
          borderRadius: BorderRadius.circular(25),
          //Borde naranja igual al de MiPerfil
          border: Border.all(color: const Color(0xFFE5853B), width: 12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13), 
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      const Text('Publicar un nuevo articulo', 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE5853B))),
                      const SizedBox(height: 5), 
                      const Text('* campos obligatorios', 
                        style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                      const SizedBox(height: 25),

                      // Nombre
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ), 
                      const SizedBox(height: 15),

                      // Marca/Autor
                      TextFormField(
                        controller: autorMarcaController,
                        decoration: const InputDecoration(
                          labelText: 'Autor o Marca *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 15),

                      // Categoría 
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                          border: OutlineInputBorder(),
                        ),
                        value: categoriaSeleccionada,
                        items: ['Libros', 'Guías', 'Material Lab', 'Equipos', 'Otros']
                            .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                            .toList(),
                        onChanged: (value) => setState(() => categoriaSeleccionada = value),
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
                      ),
                      const SizedBox(height: 25),

                      const Text("Estado de conservación:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Theme(
                        data: Theme.of(context).copyWith(
                          radioTheme: RadioThemeData(
                            fillColor: WidgetStateProperty.all(const Color(0xFFC0834A)), 
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: RadioListTile<String>(title: const Text("Nuevo", style: TextStyle(fontSize: 10)), value: "Nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Como nuevo", style: TextStyle(fontSize: 10)), value: "Como nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Desgastado", style: TextStyle(fontSize: 10)), value: "Desgastado", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text("Tipo de transacción:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Theme(
                        data: Theme.of(context).copyWith(
                          radioTheme: RadioThemeData(
                            fillColor: WidgetStateProperty.all(const Color(0xFFC0834A)), 
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: RadioListTile<String>(title: const Text("Intercambio", style: TextStyle(fontSize: 10)), value: "Intercambio", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Venta", style: TextStyle(fontSize: 10)), value: "Venta", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Gratis", style: TextStyle(fontSize: 10)), value: "Gratis", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Valor/Precio
                      TextFormField(
                        controller: valorController,
                        decoration: InputDecoration(
                          labelText: 'Valor / Precio *',
                          border: const OutlineInputBorder(),
                          enabled: tipoTransaccionSeleccionado != 'Gratis', 
                          hintText: tipoTransaccionSeleccionado == 'Gratis' ? 'No aplica' : '',
                        ),
                        keyboardType: tipoTransaccionSeleccionado == 'Venta' 
                            ? TextInputType.number 
                            : TextInputType.text,
                        validator: (value) {
                          if (tipoTransaccionSeleccionado == 'Gratis') return null;
                          if (value!.isEmpty) return 'Campo requerido';
                          if (tipoTransaccionSeleccionado == 'Venta' && double.tryParse(value) == null) {
                            return 'Debe ser un número';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      // Descripción
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 25),

                      // Selector de Imagen
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade50,
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator()) 
                              : _webImageBytes == null
                                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                                  : Image.memory(_webImageBytes!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Botón Publicar 
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5853B), 
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _publicarProducto,
                          child: const Text("Publicar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón X para cerrar (Posicionado igual que en MiPerfil)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFE5853B), size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lógica para enviar a Firebase 
  void _publicarProducto() async {
    if (_formKey.currentState!.validate()) {
      if (estadoSeleccionado == null || tipoTransaccionSeleccionado == null){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Por favor selecciona estado y tipo de transacción"), backgroundColor: Colors.red),
          );
          return;
        }

        setState(() {
          _isUploading = true;
        });

        try {
          String? imageUrl;
          if (_webImageBytes != null) {
            imageUrl = await _uploadImage();
            if (imageUrl == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error al subir la imagen."), backgroundColor: Colors.red),
                );
              }
              return; 
            }
          }
         
          await FirebaseFirestore.instance.collection('productos').add({
            'nombre': nombreController.text,
            'autor_marca': autorMarcaController.text,
            'categoria': categoriaSeleccionada,
            'estado': estadoSeleccionado,
            'tipo_transaccion': tipoTransaccionSeleccionado,
            'valor': tipoTransaccionSeleccionado == 'Gratis' ? '0' : valorController.text,
            'descripcion': descripcionController.text,
            'vendedor_id': FirebaseAuth.instance.currentUser?.uid,
            'fecha': Timestamp.now(), 
            'image_url': imageUrl ?? "",
            'disponibilidad': 'disponible',
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Producto publicado con éxito"), backgroundColor: Colors.green),
            );
            Navigator.pop(context); 
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error al publicar el producto"), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
          }
        }
      } else if (nombreController.text.isEmpty || autorMarcaController.text.isEmpty || descripcionController.text.isEmpty || (tipoTransaccionSeleccionado != 'Gratis' && valorController.text.isEmpty || categoriaSeleccionada == null)) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Por favor completa todos los campos obligatorios"), backgroundColor: Colors.red),
          );
          return;
        }
    }
  }
}
