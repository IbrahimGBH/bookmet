import 'dart:async';
import 'package:bookmet/auth.dart';
import 'package:bookmet/dialogo_transaccion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notificacion {
  Notificacion._internal();
  static final Notificacion _instance = Notificacion._internal();
  static Notificacion get instance => _instance;
  
  StreamSubscription? _solicitudesSubscription;
  final Set<String> _notificacionesMostradas = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> crearNotificacion({
    required String userId,
    required String titulo,
    required String cuerpo,
    String tipo = 'general',
  }) async {
    if (userId.isEmpty) return;
    try {
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('notificaciones')
          .add({
        'titulo': titulo,
        'cuerpo': cuerpo,
        'fecha': Timestamp.now(),
        'leido': false,
        'tipo': tipo,
      });
    } catch (e) {
      print("Error al crear la notificación: $e");
    }
  }

  Stream<QuerySnapshot> getNuevasNotificacionesStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('notificaciones')
        .where('leido', isEqualTo: false)
        .snapshots();
  }


  Future<void> mostrarHistorial(BuildContext context) async {
    await _marcarNotificacionesComoLeidas();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _HistorialDialog(),
    );
  }

  void escucharNuevasSolicitudes(BuildContext context) {
    _solicitudesSubscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = FirebaseFirestore.instance
        .collection('transacciones')
        .where('vendedor_id', isEqualTo: user.uid)
        .where('estado', isEqualTo: 'pendiente')
        .where('aceptada', isEqualTo: false);

    _solicitudesSubscription = query.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final docId = change.doc.id;
        if (change.type == DocumentChangeType.added) {
          if (!_notificacionesMostradas.contains(docId)) {
            _mostrarDialogoSolicitud(context, change.doc);
            _notificacionesMostradas.add(docId);
          }
        } else if (change.type == DocumentChangeType.removed) {
          _notificacionesMostradas.remove(docId);
        }
      }
    });
  }

  Future<void> _mostrarDialogoSolicitud(BuildContext context, DocumentSnapshot txDoc) async {
    if (!context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final datosTx = txDoc.data() as Map<String, dynamic>;
    final String idProducto = datosTx['id_producto'];

    // Obtenemos información extra para mostrar en el diálogo
    final prodDoc = await FirebaseFirestore.instance.collection('productos').doc(idProducto).get();
    final String nombreProducto = prodDoc.exists ? (prodDoc.data()?['nombre'] ?? 'un artículo') : 'un artículo';
    final String compradorId = datosTx['comprador_id'];

    final nombreComprador = await Auth.instance.getNombre(compradorId);
    final apellidoComprador = await Auth.instance.getApellido(compradorId);
    final String nombreCompleto = '$nombreComprador $apellidoComprador'.trim();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('¡Nueva Solicitud! 🎉'),
          content: Text('${nombreCompleto.isNotEmpty ? nombreCompleto : 'Un usuario'} ha solicitado tu producto "$nombreProducto".\n\n¿Deseas ver la solicitud?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Luego', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(context: context, builder: (context) => TDialog(idProducto: idProducto, vendedorId: user.uid));
              },
              child: const Text('Ver solicitud', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Marca todas las notificaciones no leídas del usuario actual como leídas.
  Future<void> _marcarNotificacionesComoLeidas() async {
    if (_userId == null) return;
    final querySnapshot = await _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('notificaciones')
        .where('leido', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'leido': true});
    }
    await batch.commit();
  }
}

class _HistorialDialog extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Formateo manual de fecha sin 'intl'
  String _formatFecha(Timestamp fecha) {
    final dt = fecha.toDate().toLocal();
    // Formato: AAAA-MM-DD hh:mm
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Estilo rectangular como Favoritos
      child: SizedBox(
        width: 550,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: const Color(0xFFEA983E), // Color naranja BookMet
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "NOTIFICACIONES",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            // --- CONTENIDO ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(userId)
                      .collection('notificaciones')
                      .orderBy('fecha', descending: true)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No tienes notificaciones.'));

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        var notif = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        String titulo = notif['titulo'] ?? 'Notificación';
                        String cuerpo = notif['cuerpo'] ?? '';
                        Timestamp fecha = notif['fecha'] ?? Timestamp.now();
                        String fechaFormateada = _formatFecha(fecha);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.notifications_active_outlined, color: Colors.orange),
                          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$cuerpo\n$fechaFormateada', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          isThreeLine: true,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
