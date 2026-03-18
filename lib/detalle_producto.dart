import 'package:bookmet/auth.dart';
import 'package:bookmet/notificacion.dart';
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

                  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final bool isAdmin = await Auth.instance.isAdmin(currentUserId ?? "");

                  // Si un admin borra una publicación, notifica al vendedor.
                  if (isAdmin && currentUserId != vendedorId) {
                    await Notificacion.instance.crearNotificacion(
                      userId: vendedorId,
                      titulo: 'Publicación eliminada por moderador',
                      cuerpo: 'Tu publicación "$titulo" fue eliminada por no cumplir con las normas.',
                      tipo: 'moderacion_eliminada',
                    );
                  }
                  
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
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500), 
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- IMAGEN ---
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 250, // Límite de altura para que no se haga infinito
                        ),
                        child: Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain, // MUESTRA LA FOTO COMPLETA SIEMPRE
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 20),

              // --- TÍTULO Y AUTOR ---
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Autor / Marca: $autor',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              // --- VENDEDOR ---
              FutureBuilder<List<String>>(
                future: Future.wait([
                  Auth.instance.getNombre(vendedorId),
                  Auth.instance.getApellido(vendedorId)
                ]),
                builder: (context, asyncSnapshot) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Size? screenSize = MediaQuery.of(context).size;
                          return VendedorDialog(
                            vendedorId: vendedorId,
                            dialogWidth: screenSize.width * 0.9,
                            dialogHeight: screenSize.height * 0.85,
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.person, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (asyncSnapshot.hasData && asyncSnapshot.data!.length == 2)
                                ? '${asyncSnapshot.data![0]} ${asyncSnapshot.data![1]}'
                                : 'Cargando vendedor...',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue[800]),
                        ],
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: 20),

              // --- CAJA DE DETALLES ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: const TextStyle(fontSize: 15.0, color: Colors.black87),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    
                    const Text('Estado de conservación', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    FutureBuilder(
                      future: fbase.get(),
                      builder: (context, asyncSnapshot) {
                        return Text(
                          asyncSnapshot.hasData ? '${asyncSnapshot.data!.get('estado')}' : 'Cargando...',
                          style: const TextStyle(fontSize: 15.0, color: Colors.black87, fontWeight: FontWeight.w500),
                        );
                      }
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),

                    const Text('Tipo de transacción', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                              displayText = tipo; 
                            }
                          }
                        }
                        return Text(
                          displayText,
                          style: TextStyle(fontSize: 16.0, color: Colors.green[700], fontWeight: FontWeight.bold)
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BOTONES Y LÓGICA ---
              FutureBuilder<bool>(
                future: Auth.instance.isAdmin(currentUserId ?? ""),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  bool isAdmin = adminSnapshot.data ?? false;

                  if (esMiPublicacion || isAdmin) {
                    return StreamBuilder<DocumentSnapshot>(
                  stream: fbase.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var data = snapshot.data!.data() as Map<String, dynamic>?;
                    String disponibilidad = data != null && data.containsKey('disponibilidad') ? (data['disponibilidad'] ?? '') : '';
                    if (disponibilidad == 'en transaccion' && !isAdmin) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('transacciones')
                            .where('id_producto', isEqualTo: idProducto)
                            .where('estado', isEqualTo: 'pendiente')
                            .snapshots(),
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
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (esMiPublicacion) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                                showDialog(
                                context: context,
                                builder: (context) => PantallaEditarProducto(
                                  idProducto: idProducto,
                                  tituloActual: titulo,
                                  autorActual: autor,
                                  precioActual: precio,
                                  descripcionActual: descripcion,
                                  imagenActual: imageUrl,
                                ),
                                );
                              },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[100],
                                  foregroundColor: Colors.blue[900],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _mostrarDialogoEliminar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[100],
                              foregroundColor: Colors.red[900],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  },
                );
                  } else {
                    return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transacciones')
                      .where('id_producto', isEqualTo: idProducto)
                      .where('comprador_id', isEqualTo: currentUserId)
                      .where('estado', isEqualTo: 'pendiente')
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool alreadyRequested = false;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      alreadyRequested = true;
                    }
                    return SizedBox(
                      width: double.infinity,
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
                          backgroundColor: const Color(0xFFE5853B), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        child: Text(
                          alreadyRequested ? 'Intercambio solicitado' : 'Solicitar Transacción',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
                  }
                }
              ),

              const SizedBox(height: 12),
              FutureBuilder(
                future: fbase.get(),
                builder: (context, asyncSnapshot) {
                  return Center(
                    child: Text(
                      asyncSnapshot.hasData ? '${asyncSnapshot.data!.get('disponibilidad')}' : 'Cargando...',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[400], fontStyle: FontStyle.italic),
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