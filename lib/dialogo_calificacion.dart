import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/auth.dart';

class CalificacionDialog extends StatefulWidget {
  final String vendedorId;
  const CalificacionDialog({super.key, required this.vendedorId});

  @override
  State<CalificacionDialog> createState() => _CalificacionDialogState();
}

class _CalificacionDialogState extends State<CalificacionDialog> {
  int _rating = 0; 
  final TextEditingController _comentarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("¡Producto Recibido!", textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Qué tal fue tu experiencia con este vendedor?"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFCD60),
                    size: 35,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                hintText: "Escribe un comentario (opcional)...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5853B),
              shape: const StadiumBorder()
            ),
            // El botón se deshabilita hasta que el usuario marque al menos una estrella
            onPressed: _rating == 0 ? null : () async {
              final ref = FirebaseFirestore.instance.collection('usuarios').doc(widget.vendedorId);
              
              // Guardar el comentario en la subcolección 'comentarios' del vendedor
              await ref.collection('comentarios').add({
                'comentario': _comentarioController.text.trim(),
                'calificacion': _rating,
                'fecha': Timestamp.now(),
                'comprador_id': Auth.instance.getUid(),
              });

              await FirebaseFirestore.instance.runTransaction((tx) async {
                DocumentSnapshot snap = await tx.get(ref);
                if (snap.exists) {
                  Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
                  // Calculamos los nuevos valores sumando lo que ya había
                  int p = (data['rating_puntos'] ?? 0) + _rating;
                  int v = (data['rating_votos'] ?? 0) + 1;
                  tx.update(ref, {'rating_puntos': p, 'rating_votos': v});
                }
              });             
              if (mounted) Navigator.pop(context); 
            },
            child: const Text("Enviar Calificación", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}