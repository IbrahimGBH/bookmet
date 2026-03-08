import 'package:bookmet/auth.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/transaccion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

        if (isSeller && !isAccepted) {
          // Seller must accept or reject
          return AlertDialog(
            title: const Text("Aceptar intercambio"),
            content: const Text("¿Deseas aceptar este intercambio? Si lo rechazas, la solicitud será eliminada."),
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
    return AlertDialog(
      title: const Text("Confirmar Solicitud"),
      content: const Text("¿Estás seguro de que deseas solicitar este artículo?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Transaccion.instance.solicitarTransaccion(idProducto, vendedorId);
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
          Text("Tu confirmación: ${compradorConfirmo ? 'Sí' : 'No'}"),
          Text("Confirmación del vendedor: ${vendedorConfirmo ? 'Sí' : 'No'}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Función para contactar no implementada.")),
            );
          },
          child: Text(isSeller ? "Contactar Comprador" : "Contactar Vendedor"),
        ),
        ElevatedButton(
          onPressed: compradorConfirmo
              ? null
              : () {
                  Transaccion.instance.confirmarEntrega(transaction.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Has confirmado la entrega."),
                        backgroundColor: Colors.green),
                  );
                },
          child: const Text("Confirmar Entrega"),
        ),
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
