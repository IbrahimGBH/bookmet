import 'package:bookmet/auth.dart';
import 'package:bookmet/dialogo_transaccion.dart';
import 'package:bookmet/dialogo_vendedor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_editar_producto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DetalleProducto extends StatelessWidget {
  final String idProducto; 
  final String vendedorId;
  final String titulo;
  final String autor;
  final String precio;
  final String descripcion;
  final String? imageUrl;

  const DetalleProducto({
    super.key,
    required this.idProducto, 
    required this.vendedorId,
    required this.titulo,
    required this.autor,
    required this.precio,
    required this.descripcion,
    this.imageUrl,
  });

  // Función para mostrar la alerta de confirmación
  void _mostrarDialogoEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Eliminar publicación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(), // Cierra la alerta
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (imageUrl != null && imageUrl!.isNotEmpty) {
                    final supabase = Supabase.instance.client;
                    final uri = Uri.parse(imageUrl!);
                    final pathSegments = uri.pathSegments;
                    final bucketIndex = pathSegments.indexOf('imagen_producto');

                    if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
                      final imagePath = pathSegments.sublist(bucketIndex + 1).join('/');
                      await supabase.storage.from('imagen_producto').remove([imagePath]);
                    }
                  }

                  await FirebaseFirestore.instance.collection('productos').doc(idProducto).delete();
                  
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop(); 
                  Navigator.of(context).pop(); 
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada'), backgroundColor: Colors.red),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el producto o su imagen: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference fbase = FirebaseFirestore.instance.collection('productos').doc(idProducto);
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    bool esMiPublicacion = (currentUserId != null && currentUserId == vendedorId);

    // Widget to show when product is in exchange
    Widget intercambioEnCursoWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Este producto está actualmente en intercambio. No se puede editar ni eliminar hasta que finalice la transacción.',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 60, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FutureBuilder<List<String>>(
                    future: Future.wait([
                      Auth.instance.getNombre(vendedorId),
                      Auth.instance.getApellido(vendedorId)
                    ]),
                    builder: (context, asyncSnapshot) {
                      return TextButton(onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            Size? screenSize = MediaQuery.of(context).size;
                            final double dialogWidth = screenSize.width * 0.9;
                            final double dialogHeight = screenSize.height * 0.85;
                            return VendedorDialog(
                              vendedorId: vendedorId,
                              dialogWidth: dialogWidth,
                              dialogHeight: dialogHeight,
                            );
                          },
                        );}, child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.person, size: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            (asyncSnapshot.hasData && asyncSnapshot.data!.length == 2)
                              ? 'Vendedor: ${asyncSnapshot.data![0]} ${asyncSnapshot.data![1]}'
                              : 'Cargando vendedor...',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                          ),
                        ],
                      ));
                    }
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Por: $autor',
                style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detalles del artículo:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),
              ),
              FutureBuilder(
                future: fbase.get(),
                builder: (context, asyncSnapshot) {
                  return Text(
                    asyncSnapshot.hasData ? 'Estado de conservación: ${asyncSnapshot.data!.get('estado')}' : 'Estado de conservación: Cargando...',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  );
                }
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipo de transacción:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              FutureBuilder<DocumentSnapshot>(
                future: fbase.get(),
                builder: (context, snapshot) {
                  String displayText = 'Cargando...';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null) {
                      final tipo = data['tipo_transaccion'] as String? ?? '';
                      final valor = data['valor'] as String? ?? '';
                      if (tipo == 'Venta') {
                        displayText = 'Venta: $valor\$';
                      } else {
                        displayText = tipo; // Handles 'Gratis' and 'Intercambio'
                      }
                    }
                  }
                  return Text(displayText,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[800]));
                },
              ),
              const SizedBox(height: 24),

              if (esMiPublicacion)
                FutureBuilder<DocumentSnapshot>(
                  future: fbase.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var data = snapshot.data!.data() as Map<String, dynamic>?;
                    String disponibilidad = data != null && data.containsKey('disponibilidad') ? (data['disponibilidad'] ?? '') : '';
                    if (disponibilidad == 'en transaccion') {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('transacciones')
                            .where('id_producto', isEqualTo: idProducto)
                            .where('estado', isEqualTo: 'pendiente')
                            .get(),
                        builder: (context, txSnapshot) {
                          if (!txSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final docs = txSnapshot.data!.docs;
                          bool aceptada = false;
                          if (docs.isNotEmpty) {
                            final txData = docs.first.data() as Map<String, dynamic>;
                            aceptada = txData['aceptada'] == true;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => TDialog(idProducto: idProducto, vendedorId: vendedorId),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: aceptada ? Colors.green[100] : Colors.orange[200],
                                    foregroundColor: aceptada ? Colors.green[900] : Colors.orange[900],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: Text(
                                    aceptada ? 'Opciones de transacción' : 'Alguien ha solicitado una transacción',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(child: intercambioEnCursoWidget),
                            ],
                          );
                        },
                      );
                    }
                    // Mostrar botones solo si NO está en intercambio
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PantallaEditarProducto(
                                  idProducto: idProducto,
                                  tituloActual: titulo,
                                  autorActual: autor,
                                  precioActual: precio,
                                  descripcionActual: descripcion,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[900],
                            elevation: 0,
                          ),
                          child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _mostrarDialogoEliminar(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[100],
                            foregroundColor: Colors.red[900],
                            elevation: 0,
                          ),
                          child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  },
                )

              else
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('transacciones')
                      .where('id_producto', isEqualTo: idProducto)
                      .where('comprador_id', isEqualTo: currentUserId)
                      .where('estado', isEqualTo: 'pendiente')
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    bool alreadyRequested = false;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      alreadyRequested = true;
                    }
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TDialog(idProducto: idProducto, vendedorId: vendedorId);
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[200],
                          foregroundColor: Colors.orange[900],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          alreadyRequested ? 'Intercambio solicitado' : 'Solicitar Transacción',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),


              const SizedBox(height: 8),
              FutureBuilder(
                future: fbase.get(),
                builder: (context, asyncSnapshot) {
                  return Center(
                    child: Text(
                      asyncSnapshot.hasData ? '${asyncSnapshot.data!.get('disponibilidad')}' : 'Cargando...',
                      style: TextStyle(fontSize: 10.0, color: Colors.grey[500]),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}