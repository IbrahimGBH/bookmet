import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Importado para manejar bytes de imagen de forma compatible
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaEditarProducto extends StatefulWidget {
  final String idProducto;
  final String tituloActual;
  final String autorActual;
  final String precioActual;
  final String descripcionActual;
  final String? categoriaActual;
  final String? estadoActual;
  final String? tipoTransaccionActual;
  final String? imagenActual; // Recibimos la URL de la imagen actual

  const PantallaEditarProducto({
    super.key,
    required this.idProducto,
    required this.tituloActual,
    required this.autorActual,
    required this.precioActual,
    required this.descripcionActual,
    this.categoriaActual,
    this.estadoActual,
    this.tipoTransaccionActual,
    this.imagenActual,
  });

  @override
  State<PantallaEditarProducto> createState() => _PantallaEditarProductoState();
}

class _PantallaEditarProductoState extends State<PantallaEditarProducto> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nombreController;
  late TextEditingController autorMarcaController;
  late TextEditingController descripcionController;
  late TextEditingController valorController;

  String? categoriaSeleccionada;
  String? estadoSeleccionado;
  String? tipoTransaccionSeleccionado;

  Uint8List? _nuevaImagenBytes; // Para guardar bytes de una nueva imagen seleccionada
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializamos controladores con datos actuales
    nombreController = TextEditingController(text: widget.tituloActual);
    autorMarcaController = TextEditingController(text: widget.autorActual);
    descripcionController = TextEditingController(text: widget.descripcionActual);
    valorController = TextEditingController(text: widget.precioActual);
    
    // Inicializamos selectores con datos actuales o valores por defecto
    categoriaSeleccionada = widget.categoriaActual ?? 'Libros';
    estadoSeleccionado = widget.estadoActual ?? 'Nuevo';
    tipoTransaccionSeleccionado = widget.tipoTransaccionActual ?? 'Venta';
  }

  @override
  void dispose() {
    nombreController.dispose();
    autorMarcaController.dispose();
    descripcionController.dispose();
    valorController.dispose();
    super.dispose();
  }

  // Función para seleccionar nueva imagen de la galería
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      setState(() {
        _nuevaImagenBytes = bytes;
      });
    }
  }

  // Función para subir la nueva imagen a Supabase (mismo bucket de creación)
  Future<String?> _uploadImage() async {
    if (_nuevaImagenBytes == null) return null;

    try {
      final supabase = Supabase.instance.client;
      // Creamos un nombre de archivo único
      final String fileName = 'productos/edit_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('imagen_producto').uploadBinary(
            fileName,
            _nuevaImagenBytes!,
            fileOptions: const FileOptions(
                cacheControl: '3600', upsert: false, contentType: 'image/jpeg'),
          );

      // Obtenemos la URL pública
      final String publicUrl = supabase.storage.from('imagen_producto').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error al subir a Supabase: $e");
      return null;
    }
  }

  Future<void> _guardarCambiosFirebase() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Preparamos los datos base a actualizar
        Map<String, dynamic> datosActualizar = {
          'nombre': nombreController.text.trim(),
          'autor_marca': autorMarcaController.text.trim(),
          'categoria': categoriaSeleccionada,
          'estado': estadoSeleccionado,
          'tipo_transaccion': tipoTransaccionSeleccionado,
          'valor': tipoTransaccionSeleccionado == 'Gratis' ? '0' : valorController.text.trim(),
          'descripcion': descripcionController.text.trim(),
        };

        // Lógica de Imagen: Si hay nueva imagen, la subimos y actualizamos la URL
        if (_nuevaImagenBytes != null) {
          String? nuevaImageUrl = await _uploadImage();
          if (nuevaImageUrl != null) {
            datosActualizar['image_url'] = nuevaImageUrl;
          } else {
            // Manejar error al subir imagen
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al subir la nueva imagen'), backgroundColor: Colors.red),
              );
            }
            setState(() => _isUploading = false);
            return; // No guardamos los demás datos si falla la imagen
          }
        }

        // Actualizamos en Firestore usando el ID del producto
        await FirebaseFirestore.instance.collection('productos').doc(widget.idProducto).update(datosActualizar);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cambios guardados correctamente!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Cerramos el diálogo y regresamos al detalle
        }
      } catch (e) {
        print("Error al actualizar Firestore: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar los cambios'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el ancho igual que en crear_producto para pantallas grandes
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 581 ? 581 : screenWidth * 0.9;

    return Dialog(
      // Estilo del Diálogo: Transparente para usar nuestro Container estilizado
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        width: dialogWidth,
        // Mantener una altura proporcional
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para el contenido
          borderRadius: BorderRadius.circular(25), // Bordes muy redondeados
          // Borde naranja grueso característico
          border: Border.all(color: const Color(0xFFE5853B), width: 12),
        ),
        // ClipRRect para que el contenido no se salga de los bordes redondeados
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13), // Radio interno: Radio_Dialogo - Width_Border
          child: Stack(
            children: [
              // Contenido principal dentro de un scroll
              SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      const Text('Editar Publicación', 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC0834A))),
                      const SizedBox(height: 5), 
                      const Text('* modifica los campos necesarios', style: TextStyle(fontSize: 10, color: Colors.red)),
                      const SizedBox(height: 25),

                      // Campo Nombre (Requerido)
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Nombre'), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ), 
                      const SizedBox(height: 15),

                      // Campo Autor o Marca (Requerido)
                      TextFormField(
                        controller: autorMarcaController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Autor o Marca '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 15),

                      // Selector de Categoría (Requerido)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Categoría '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        value: categoriaSeleccionada,
                        items: ['Libros', 'Guías', 'Material Lab', 'Equipos', 'Otros']
                            .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                            .toList(),
                        onChanged: (value) => setState(() => categoriaSeleccionada = value),
                      ),
                      const SizedBox(height: 20),

                      // Estado de conservación: Radios
                      const Align(alignment: Alignment.centerLeft, child: Text("Estado de conservación:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Theme(
                        data: Theme.of(context).copyWith(
                          radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(const Color(0xFFC0834A))), 
                        ),
                        child: Row(
                          children: [
                            Expanded(child: RadioListTile<String>(title: const Text("Nuevo", style: TextStyle(fontSize: 12)), value: "Nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Como nuevo", style: TextStyle(fontSize: 12)), value: "Como nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Desgastado", style: TextStyle(fontSize: 12)), value: "Desgastado", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tipo de transacción: Radios
                      const Align(alignment: Alignment.centerLeft, child: Text("Tipo de transacción:", style: TextStyle(fontWeight: FontWeight.bold))),
                      Theme(
                        data: Theme.of(context).copyWith(
                          radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(const Color(0xFFC0834A))), 
                        ),
                        child: Row(
                          children: [
                            Expanded(child: RadioListTile<String>(title: const Text("Intercambio", style: TextStyle(fontSize: 12)), value: "Intercambio", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Venta", style: TextStyle(fontSize: 12)), value: "Venta", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                            Expanded(child: RadioListTile<String>(title: const Text("Gratis", style: TextStyle(fontSize: 12)), value: "Gratis", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() {
                               tipoTransaccionSeleccionado = v!;
                               valorController.text = '0'; // Forzar precio a 0 si es gratis
                            }))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Campo Valor o Precio (Requerido condicionalmente)
                      TextFormField(
                        controller: valorController,
                        decoration: InputDecoration(
                          label: const Text.rich(TextSpan(children: [TextSpan(text: 'Valor / Precio '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: const OutlineInputBorder(),
                          enabled: tipoTransaccionSeleccionado != 'Gratis',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => (tipoTransaccionSeleccionado != 'Gratis' && value!.isEmpty) ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 15),

                      // Campo Descripción (Requerido)
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Descripción '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      
                      const SizedBox(height: 25), // Espacio antes del selector de imagen

                      // MOVED: Selector de Imagen (Ahora abajo, antes del botón)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade50,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            // Lógica para mostrar imagen: Nueva > Actual > Icono
                            child: _isUploading && _nuevaImagenBytes != null
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC0834A)))
                                : _nuevaImagenBytes != null
                                    ? Image.memory(_nuevaImagenBytes!, fit: BoxFit.cover) // Mostramos nueva seleccionada
                                    : (widget.imagenActual != null && widget.imagenActual!.isNotEmpty)
                                        ? Image.network(widget.imagenActual!, fit: BoxFit.cover) // Mostramos la actual de la DB
                                        : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                              Text("Cambiar foto", style: TextStyle(fontSize: 12, color: Colors.grey))
                                            ],
                                          ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30), // Espacio antes del botón de guardar

                      // Botón de Guardar Cambios
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isUploading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC0834A)))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC0834A), 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _guardarCambiosFirebase,
                              child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                      ),
                    ],
                  )
                )
              ),
              
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFC0834A), size: 30),
                  onPressed: () => Navigator.pop(context), // Cerramos el diálogo
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}