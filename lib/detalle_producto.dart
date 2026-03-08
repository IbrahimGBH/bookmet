import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_editar_producto.dart';
import 'chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';


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
                  // Borramos de Firebase usando el ID
                  await FirebaseFirestore.instance.collection('productos').doc(idProducto).delete();
                  
                  Navigator.of(ctx).pop(); // Cierra la alerta
                  Navigator.of(context).pop(); // Cierra la ventana de detalles
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada'), backgroundColor: Colors.red),
                  );
                } catch (e) {
                  print("Error al eliminar: $e");
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
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    bool esMiPublicacion = (currentUserId != null && currentUserId == vendedorId);

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
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
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
              const SizedBox(height: 16),
              const Text(
                'Tipo de transacción:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                precio == '0' ? 'Intercambio' : 'Venta: $precio',
                style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),

              if (esMiPublicacion)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Cierra la ventana actual de detalles
                        Navigator.of(context).pop(); 
                        
                        // Abre la nueva pantalla de edición
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
                )

              else
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[200],
                    foregroundColor: Colors.orange[900],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar solicitud'),
                          content: const Text('¿Deseas iniciar el proceso de intercambio/compra de este producto?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cierra si dice NO
                              },
                              child: const Text('No', style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              onPressed: () async {
                                try {
                                  // 1. Guardamos en Firebase (⚠️ CAMBIA idProducto POR TU VARIABLE REAL)
                                  await FirebaseFirestore.instance.collection('productos').doc(idProducto).update({
                                    'estado': 'Solicitado',
                                    'solicitante_id': FirebaseAuth.instance.currentUser?.uid,
                                  });

                                  // 2. Verificamos que la app siga viva
                                  if (!context.mounted) return;

                                  // 3. Cerramos ambas ventanas flotantes
                                  Navigator.pop(context); 
                                  Navigator.pop(context); 

                                  // 4. Viajamos al chat
                                  // Buscamos los datos del dueño del libro en Firebase
            DocumentSnapshot vendedorDoc = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(vendedorId) // <--- ¡Aquí está tu variable mágica!
                .get();

            if (!context.mounted) return; // Por si el usuario cierra la app rápido

            if (vendedorDoc.exists && vendedorDoc.data() != null) {
              Map<String, dynamic> vendedorData = vendedorDoc.data() as Map<String, dynamic>;
              String linkWhatsapp = vendedorData['link_whatsapp'] ?? '';

              if (linkWhatsapp.isNotEmpty) {
                final Uri url = Uri.parse(linkWhatsapp);
                // Esta es la orden que saca a la persona a WhatsApp
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir WhatsApp 😕')),
                  );
                }
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El dueño no tiene WhatsApp registrado')),
                  );
              }
            }
                                } catch (e) {
                                  print("🚨 ERROR EN FIREBASE: $e");
                                }
                              },
                              child: const Text('Sí, iniciar proceso', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Solicitar producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ), // Cierra el ElevatedButton
              ), // <-- ¡AQUÍ ESTÁ EL PARÉNTESIS DEL CENTER QUE FALTABA!
          ], // Cierra la lista de hijos (children) de la Columna principal
          ),
        ),
      ),
    );
  }
}