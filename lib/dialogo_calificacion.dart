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
  final _formKey = GlobalKey<FormState>(); 
  bool _isGuardando = false; 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("¡Producto Recibido!", textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Form( 
          key: _formKey,
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
              
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  hintText: "Escribe tu comentario aquí...", // Le quitamos el (opcional)
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El comentario es obligatorio';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: _isGuardando 
            ? const CircularProgressIndicator(color: Color(0xFFE5853B))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5853B),
                  shape: const StadiumBorder()
                ),
                // Se deshabilita si no hay estrellas
                onPressed: _rating == 0 ? null : () async {
                  //Verificamos que el comentario no esté vacío
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isGuardando = true);

                    try {
                      String myUid = Auth.instance.getUid();
                      String nombreAutor = "Usuario Anónimo";

                      // 1. Buscamos el nombre del usuario actual en Firestore
                      DocumentSnapshot myUserDoc = await FirebaseFirestore.instance.collection('usuarios').doc(myUid).get();
                      if (myUserDoc.exists && myUserDoc.data() != null) {
                        var myData = myUserDoc.data() as Map<String, dynamic>;
                        nombreAutor = "${myData['nombre'] ?? ''} ${myData['apellido'] ?? ''}".trim();
                      }

                      final ref = FirebaseFirestore.instance.collection('usuarios').doc(widget.vendedorId);
                      
                      // 2. Guardar el comentario incluyendo el nombre del autor
                      await ref.collection('comentarios').add({
                        'comentario': _comentarioController.text.trim(),
                        'calificacion': _rating,
                        'fecha': Timestamp.now(),
                        'comprador_id': myUid,
                        'autor': nombreAutor, 
                      });

                      // 3. Actualizar la puntuación del vendedor
                      await FirebaseFirestore.instance.runTransaction((tx) async {
                        DocumentSnapshot snap = await tx.get(ref);
                        if (snap.exists) {
                          Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
                          int p = (data['rating_puntos'] ?? 0) + _rating;
                          int v = (data['rating_votos'] ?? 0) + 1;
                          tx.update(ref, {'rating_puntos': p, 'rating_votos': v});
                        }
                      });            
                      
                      if (mounted) {
                        Navigator.pop(context); 
                        Navigator.pop(context); 
                      }
                    } catch (e) {
                      print("Error al calificar: $e");
                      setState(() => _isGuardando = false);
                    }
                  }
                },
                child: const Text("Enviar Calificación", style: TextStyle(color: Colors.white)),
              ),
        ),
      ],
    );
  }
}