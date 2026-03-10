import 'package:bookmet/auth.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/transaccion.dart';
import 'package:bookmet/dialogo_calificacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    
    bool isProcessingPayment = false;
    bool waitingForUserVerification = false;
    String? currentOrderId; // Para guardar el ID 

    // Credenciales para el paypal
    String clientId = "AU4-2lWmQ4qSXz3al1DnHovsN3BRFW5ssjGfLTOdzcAaxDr7-LIc-okOjsBlC5b1f4Cd3-HD1zG3GQ8r"; 
    String secret = "EIxXdS8pe0lFCCUd_U0GnPPJRvVqiSR99QIS_6m-x0ZZIgDcGEUJ9JZ1Wfs5OtKNb7wT2HGXKzU28DhT"; 

    // Función auxiliar para obtener el token de PayPal
    Future<String> getPayPalToken() async {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}';
      var response = await http.post(
        Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
        headers: {'Authorization': basicAuth, 'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=client_credentials'
      );
      return jsonDecode(response.body)['access_token'];
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('productos').doc(idProducto).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String tipo = data['tipo_transaccion'];
        // Usamos 'valor' 
        final String precioString = data['valor']?.toString() ?? '0.00'; 
        final String nombreProducto = data['nombre'] ?? 'Producto';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tipo == 'Venta' ? "Confirmar Compra" : "Confirmar $tipo"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isProcessingPayment)
                    const Center(child: CircularProgressIndicator())
                  else if (waitingForUserVerification)
                    const Text("Se ha abierto una pestaña de PayPal.\n\nCompleta tu pago. Cuando veas la pantalla final, cierra esa pestaña y presiona 'Ya pagué' para validar tu compra.")
                  else ...[
                    Text(tipo == 'Venta' ? "¿Deseas proceder al pago de \$$precioString por este artículo?" : "¿Estás seguro de que deseas solicitar este artículo?"),
                  ],
                ],
              ),
              actions: [
                if (!isProcessingPayment)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancelar"),
                  ),
                
                // --- BOTÓN 1: CREAR ORDEN Y ABRIR PAYPAL ---
                if (!isProcessingPayment && !waitingForUserVerification)
                  ElevatedButton(
                    onPressed: () async {
                      if (tipo != 'Venta') {
                        Transaccion.instance.solicitarTransaccion(idProducto, vendedorId);
                        Navigator.of(context).pop();
                      } else {
                        setState(() { isProcessingPayment = true; });
                        try {
                          String token = await getPayPalToken();
                          var orderResponse = await http.post(
                            Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders'),
                            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                            body: jsonEncode({
                              "intent": "CAPTURE",
                              "purchase_units": [{
                                "amount": {"currency_code": "USD", "value": precioString},
                                "description": "Compra de $nombreProducto"
                              }],
                              "application_context": {
                                "return_url": "https://example.com", // <-- Cambiado a una página en blanco para que no de error
                                "cancel_url": "https://example.com",
                                "user_action": "PAY_NOW"
                              }
                            })
                          );
                          
                          var orderData = jsonDecode(orderResponse.body);
                          currentOrderId = orderData['id']; //Guardamos el id
                          String approveUrl = orderData['links'].firstWhere((link) => link['rel'] == 'approve')['href'];

                          final Uri url = Uri.parse(approveUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                            setState(() { isProcessingPayment = false; waitingForUserVerification = true; });
                          }
                        } catch (e) {
                          setState(() { isProcessingPayment = false; });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error con PayPal")));
                        }
                      }
                    },
                    child: Text(tipo == 'Venta' ? "Pagar con PayPal" : "Confirmar"),
                  ),
                
                // --- BOTÓN 2: VALIDAR EL PAGO ---
                if (waitingForUserVerification && !isProcessingPayment)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() { isProcessingPayment = true; });
                      try {
                        String token = await getPayPalToken();
                        
                        var captureResponse = await http.post(
                          Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders/$currentOrderId/capture'),
                          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                        );
                        
                        var captureData = jsonDecode(captureResponse.body);
                        
                        // Validamos si PayPal nos dice que se completó
                        if (captureData['status'] == 'COMPLETED') {
                          await Transaccion.instance.solicitarTransaccion(idProducto, vendedorId);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Pago verificado y registrado con éxito!"), backgroundColor: Colors.green));
                          }
                        } else {
                          // Validación para saber si el usuario mintió o cerró antes de tiempo
                          setState(() { isProcessingPayment = false; });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aún no has completado el pago en PayPal."), backgroundColor: Colors.red));
                          }
                        }
                      } catch (e) {
                        setState(() { isProcessingPayment = false; });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al verificar el pago.")));
                      }
                    },
                    child: const Text("Ya pagué"),
                  )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildStatusDialog(
      BuildContext context, DocumentSnapshot transaction) {
    final data = transaction.data() as Map<String, dynamic>;
    final bool compradorConfirmo = data['confirmacion_comprador'] ?? false;
    final bool vendedorConfirmo = data['confirmacion_vendedor'] ?? false;
    
    // Para saber si es Venta, Intercambio o Gratis
    final String tipoTransaccion = data['tipo'] ?? 'Desconocido'; 

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
          child: Text(isSeller ? "Confirmar Entrega" : "Compra Recibida"),
        ),
        
        if (tipoTransaccion != 'Venta' && !(isSeller ? vendedorConfirmo : compradorConfirmo))
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
