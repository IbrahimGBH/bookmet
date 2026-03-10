import 'package:bookmet/auth.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/transaccion.dart';
import 'package:bookmet/dialogo_calificacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TDialog extends StatelessWidget {
  final String idProducto;
  final String vendedorId;

  const TDialog({
    super.key,
    required this.idProducto,
    required this.vendedorId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('transacciones')
          .where('id_producto', isEqualTo: idProducto)
          .where('estado', isEqualTo: 'pendiente')
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorDialog(context, "Error al verificar la transacción.");
        }

        final String currentUserId = Auth.instance.getUid();
        final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return _buildConfirmationDialog(context);
        }

        final transaction = documents.first;
        final transactionData = transaction.data() as Map<String, dynamic>;
        final String compradorId = transactionData['comprador_id'];
        final String vendedorIdTx = transactionData['vendedor_id'];
        final bool isSeller = currentUserId == vendedorIdTx;
        final bool isAccepted = transactionData['aceptada'] == true;
        final String? propuesta = transactionData['propuesta'];
        final String tipoTransaccion = transactionData['tipo'] ?? 'Desconocido';

        if (isSeller && !isAccepted) {
          // Seller must accept or reject
          return AlertDialog(
            title: tipoTransaccion == 'Gratis' ? Text('Solicitud de transaccion') : Text("Solicitud de $tipoTransaccion"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tipoTransaccion == 'Intercambio' && propuesta != null) ...[
                  const Text("Propuesta del comprador:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE5853B))),
                  const SizedBox(height: 5),
                  Text(propuesta, style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 15),
                ],
                const Text("¿Deseas aceptar esta solicitud? Si la rechazas, será eliminada."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Transaccion.instance.eliminarTransaccion(transaction.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Intercambio rechazado y eliminado."), backgroundColor: Colors.red),
                  );
                },
                child: const Text("Rechazar", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Transaccion.instance.aceptarSolicitud(transaction.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Intercambio aceptado."), backgroundColor: Colors.green),
                  );
                },
                child: const Text("Aceptar"),
              ),
            ],
          );
        }

        if (compradorId == currentUserId && !isAccepted) {
          // Buyer, waiting for seller acceptance
          return AlertDialog(
            title: const Text('Solicitud pendiente'),
            content: const Text('La solicitud todavía no ha sido aceptada por el vendedor.'),
            actions: [
              TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Entendido")),
              TextButton(
                onPressed: () async {
                  await Transaccion.instance.eliminarTransaccion(transaction.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solicitud cancelada.'), backgroundColor: Colors.red),
                  );
                },
                child: const Text('Cancelar solicitud', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        }

        if (compradorId == currentUserId || isSeller) {
          return _buildStatusDialog(context, transaction);
        } else {
          return _buildUnavailableDialog(context);
        }
      },
    );
  }

  Widget _buildUnavailableDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Artículo no disponible"),
      content: const Text(
          "Este artículo ya está en proceso de transacción por otro usuario y no se puede solicitar."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Entendido"),
        ),
      ],
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    final TextEditingController propuestaController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('productos').doc(idProducto).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String tipo = data['tipo_transaccion'];

        return AlertDialog(
          title: Text("Confirmar Solicitud"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("¿Estás seguro de que deseas solicitar este artículo?"),
              if (tipo == 'Intercambio') ...[
                const SizedBox(height: 20),
                const Text("Tu oferta:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: propuestaController,
                  decoration: const InputDecoration(
                    hintText: "Ej: Te cambio mi libro de Física I...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Transaccion.instance.solicitarTransaccion(
                  idProducto, 
                  vendedorId,
                  propuesta: tipo == 'Intercambio' ? propuestaController.text : null
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Solicitud enviada."),
                      backgroundColor: Colors.green),
                );
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatusDialog(
      BuildContext context, DocumentSnapshot transaction) {
    final data = transaction.data() as Map<String, dynamic>;
    final bool compradorConfirmo = data['confirmacion_comprador'] ?? false;
    final bool vendedorConfirmo = data['confirmacion_vendedor'] ?? false;

    final String currentUserId = Auth.instance.getUid();
    final String compradorId = data['comprador_id'];
    final String vendedorIdTx = data['vendedor_id'];
    final bool isSeller = currentUserId == vendedorIdTx;

    return AlertDialog(
      title: const Text("Estado de tu Solicitud"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Estado actual: ${data['estado']}"),
          const SizedBox(height: 10),
          Text("Confirmación del comprador: ${compradorConfirmo ? 'Sí' : 'No'}"),
          Text("Confirmación del vendedor: ${vendedorConfirmo ? 'Sí' : 'No'}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try{
              if (!context.mounted) return; // Por si el usuario cierra la app rápido
              DocumentSnapshot vendedorDoc = await FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(vendedorIdTx) 
                  .get();
              if (vendedorDoc.exists && vendedorDoc.data() != null) {
                Map<String, dynamic> vendedorData = vendedorDoc.data() as Map<String, dynamic>;
                String linkWhatsapp = vendedorData['link_whatsapp'] ?? '';

                if (linkWhatsapp.isNotEmpty) {
                  final Uri url = Uri.parse(linkWhatsapp);
                  // Esta es la orden que saca a la persona a WhatsApp
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                }
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No se pudo abrir WhatsApp."), backgroundColor: Colors.red),
              );
            }
          },
          child: Text(isSeller ? "Contactar Comprador" : "Contactar Vendedor"),
        ),
        ElevatedButton(
          onPressed: (isSeller ? vendedorConfirmo : compradorConfirmo)
              ? null 
              : () async {
                  // Confirmar la entrega en Firestore
                  await Transaccion.instance.confirmarEntrega(transaction.id);

                  
                  if (!isSeller) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); 
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            CalificacionDialog(vendedorId: vendedorIdTx),
                      );
                    }
                  } else {
                    
                    if (context.mounted) Navigator.of(context).pop();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Has confirmado la entrega."),
                          backgroundColor: Colors.green),
                    );
                  }
                },
          child: const Text("Confirmar Entrega"),
        ),
        if (!(isSeller ? vendedorConfirmo : compradorConfirmo))
          TextButton(
            onPressed: () {
              _showCancelConfirmationDialog(context, transaction.id);
            },
            child: const Text("Cancelar Solicitud", style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: const Text('¿Estás seguro de que quieres cancelar esta solicitud? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Transaccion.instance.eliminarTransaccion(transactionId);
              Navigator.of(ctx).pop(); // Close confirmation
              Navigator.of(context).pop(); // Close status dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Solicitud cancelada."), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDialog(BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
