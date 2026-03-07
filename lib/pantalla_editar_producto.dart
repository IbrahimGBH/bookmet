import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaEditarProducto extends StatefulWidget {
  final String idProducto;
  final String tituloActual;
  final String autorActual;
  final String precioActual;
  final String descripcionActual;
  final String? categoriaActual;
  final String? estadoActual;
  final String? tipoTransaccionActual;

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

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    nombreController = TextEditingController(text: widget.tituloActual);
    autorMarcaController = TextEditingController(text: widget.autorActual);
    descripcionController = TextEditingController(text: widget.descripcionActual);
    valorController = TextEditingController(text: widget.precioActual);
    
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

  Future<void> _guardarCambiosFirebase() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Actualizamos en Firestore usando los nombres de campos de la base de datos
        await FirebaseFirestore.instance.collection('productos').doc(widget.idProducto).update({
          'nombre': nombreController.text.trim(),
          'autor_marca': autorMarcaController.text.trim(),
          'categoria': categoriaSeleccionada,
          'estado': estadoSeleccionado,
          'tipo_transaccion': tipoTransaccionSeleccionado,
          'valor': tipoTransaccionSeleccionado == 'Gratis' ? '0' : valorController.text.trim(),
          'descripcion': descripcionController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cambios guardados correctamente!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Regresa al catálogo
        }
      } catch (e) {
        print("Error al actualizar: $e");
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
    return Scaffold(
      body: Stack(
        children: [
          // FONDO 
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_crear_producto.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 600, 
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
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
                      const Text('Editar Publicación', 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC0834A))),
                      const SizedBox(height: 5), 
                      const Text('* modifica los campos necesarios', style: TextStyle(fontSize: 10, color: Colors.red)),
                      const SizedBox(height: 25),

                      // Campo Nombre
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Nombre'), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ), 
                      const SizedBox(height: 15),

                      // Campo Autor/Marca
                      TextFormField(
                        controller: autorMarcaController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Autor o Marca '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 15),

                      // Selector Categoría
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

                      // Radios Estado
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

                      // Radios Transacción
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
                               valorController.text = '0';
                            }))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Campo Valor
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

                      // Campo Descripción
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          label: Text.rich(TextSpan(children: [TextSpan(text: 'Descripción '), TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 30),

                      // Botón de Guardar
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
              )
            )
          ),

          // Botón flotante para cerrar/volver
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      )
    );
  }
}