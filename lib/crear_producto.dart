import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart'; 

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
    File? _imageFile;

  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }
 
Future<String?> _uploadImage() async {
    if (_webImageBytes == null) return null;
    
    try {
      if (!mounted) return null;
      setState(() => _isUploading = true);
      

      Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        _webImageBytes!,
        minHeight: 1000, 
        minWidth: 1000,
        quality: 50, 
      );

      String fileName = 'productos/${DateTime.now().millisecondsSinceEpoch}.png';
      

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putData(compressedBytes);
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error detallado subiendo imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al subir la imagen: $e"), backgroundColor: Colors.red),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fondo_crear_producto.png'), 
          fit: BoxFit.cover, 
        ),
      ),
        child: Center(
        child: SingleChildScrollView(
          child:Container(
            width: 600, 
          margin: const EdgeInsets.all(20),
        padding:  const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
        child: Form(
          key: _formKey, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               
              const Text('Publicar un nuevo articulo', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 5), 
              const Text('* campos obligatorios', style: TextStyle(fontSize: 10, color: Colors.red)),
              const SizedBox(height: 25),
              //nombre
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(label: Text.rich(TextSpan(children: [TextSpan(text: 'Nombre'),
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),])),
                border: OutlineInputBorder(),
                ),
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ), 
              const SizedBox(height: 10),
              // marca/autor
              TextFormField(
                controller: autorMarcaController,
                decoration: const InputDecoration(
                  label: Text.rich(TextSpan(children: [
                    TextSpan(text: 'Autor o Marca '),
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ])),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),

            
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  label: Text.rich(TextSpan(children: [
                    TextSpan(text: 'Categoría '),
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ])),
                  border: OutlineInputBorder(),
                ),
                value: categoriaSeleccionada,
                items: ['Libros', 'Guías', 'Material Lab', 'Equipos', 'Otros']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => categoriaSeleccionada = value),
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 20),
              const Text("Estado de conservación:", style: TextStyle(fontWeight: FontWeight.bold)),
              Theme(
            data: Theme.of(context).copyWith(
                 radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(const Color(0xFFC0834A)), 
            ),
          ),
              child: Row(
                children: [
                  Expanded(child: RadioListTile<String>(title: const Text("Nuevo"), value: "Nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                  Expanded(child: RadioListTile<String>(title: const Text("Como nuevo"), value: "Como nuevo", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                  Expanded(child: RadioListTile<String>(title: const Text("Desgastado"), value: "Desgastado", groupValue: estadoSeleccionado, onChanged: (v) => setState(() => estadoSeleccionado = v!))),
                ],
              ),
              ),
              const SizedBox(height: 10),

              const Text("Tipo de transacción:", style: TextStyle(fontWeight: FontWeight.bold)),
              Theme(
  data: Theme.of(context).copyWith(
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(const Color(0xFFC0834A)), 
    ),
  ),
  child: Row(
                children: [
                  Expanded(child: RadioListTile<String>(title: const Text("Intercambio"), value: "Intercambio", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                  Expanded(child: RadioListTile<String>(title: const Text("Venta"), value: "Venta", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                  Expanded(child: RadioListTile<String>(title: const Text("Gratis"), value: "Gratis", groupValue: tipoTransaccionSeleccionado, onChanged: (v) => setState(() => tipoTransaccionSeleccionado = v!))),
                ],
              ),
              ),
              const SizedBox(height: 10),
              //valor
              TextFormField(
                controller: valorController,
                decoration: InputDecoration(
                  label: const Text.rich(TextSpan(children: [
                    TextSpan(text: 'Valor / Precio '),
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ])),
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
              const SizedBox(height: 10),
                TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  label: Text.rich(TextSpan(children: [
                    TextSpan(text: 'Descripción '),
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ])),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

     

            GestureDetector(
                onTap: _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
                          child: _isUploading
            ? const Center(child: CircularProgressIndicator()) 
            : _webImageBytes == null
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                : Image.memory(_webImageBytes!, fit: BoxFit.cover),
      ),
    ),
                      const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0834A), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                  onPressed: _publicarProducto,
                  child: const Text("Publicar", style: TextStyle(fontSize: 16)),
              ),
              ),
            ],
          )
        )
        )
      )
        ),
        )
    );
  }
  void _publicarProducto() async {
  if (_formKey.currentState!.validate()) {
    if (estadoSeleccionado == null || tipoTransaccionSeleccionado == null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor selecciona estado y tipo de transacción"), backgroundColor: Colors.red),
        );
        return;
      }
      if (_webImageBytes == null) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor selecciona una imagen"), backgroundColor: Colors.red),
        );
        return;
      }

     try {
   
      String? imageUrl = await _uploadImage();
      

      if (imageUrl == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir la imagen. Intenta de nuevo."), backgroundColor: Colors.red),
        );
        return; 
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
          'image_url': imageUrl, 
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto publicado"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error"), backgroundColor: Colors.red),
        );
      }
    }
  }
}