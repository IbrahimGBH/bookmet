import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/tarjeta_builder.dart';

class VendedorDialog extends StatefulWidget {
  final String vendedorId;
  final double dialogWidth;
  final double dialogHeight;

  const VendedorDialog({
    super.key,
    required this.vendedorId,
    required this.dialogWidth,
    required this.dialogHeight,
  });

  @override
  State<VendedorDialog> createState() => _VendedorDialogState();
}

class _VendedorDialogState extends State<VendedorDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        width: widget.dialogWidth > 581 ? 581 : widget.dialogWidth,
        height: widget.dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE5853B), width: 12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildPublicaciones(context),
                    const SizedBox(height: 30),
                    _buildBotonComentarios(context),
                  ],
                ),
              ),
              _buildBotonCerrar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(widget.vendedorId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("Cargando perfil...");
        if (!snapshot.data!.exists) return const Text("Usuario no encontrado");

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String nombreCompleto = "${data['nombre']} ${data['apellido']}";
        
        int puntos = data['rating_puntos'] ?? 0;
        int votos = data['rating_votos'] ?? 0;
        double promedio = votos > 0 ? puntos / votos : 0.0;

        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 15,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCompleto,
                  style: const TextStyle(color: Color(0xFFE5853B), fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < promedio.round() ? Icons.star : Icons.star_border, 
                        color: const Color(0xFFFFCD60), 
                        size: 28
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      "(${promedio.toStringAsFixed(1)})", 
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ],
                ),
                const Text("Vendedor UNIMET", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPublicaciones(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('vendedor_id', isEqualTo: widget.vendedorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var todosLosDocs = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
        var limitados = todosLosDocs.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccionTitulo("Publicaciones del vendedor:", alPresionarVerMas: () {
              _mostrarTodo(context, "Publicaciones de este vendedor", todosLosDocs);
            }),
            if (todosLosDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Este usuario no tiene publicaciones activas.", style: TextStyle(color: Colors.grey)),
              )
            else
              TarjetaBuilder(
                filtro: [limitados], 
                cantidadColumnas: limitados.length > 0 ? limitados.length : 1, 
                tarjetaSize: 400, 
                smallVersion: true,
              ),
          ],
        );
      },
    );
  }

  Widget _buildBotonComentarios(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5853B),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => _mostrarComentarios(context),
        icon: const Icon(Icons.comment, color: Colors.white),
        label: const Text("Ver Comentarios y Reseñas", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildBotonCerrar(BuildContext context) {
    return Positioned(
      right: 10,
      top: 10,
      child: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFFE5853B), size: 30),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo, {VoidCallback? alPresionarVerMas}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (alPresionarVerMas != null)
          TextButton(
            onPressed: alPresionarVerMas,
            child: const Text("Ver más", style: TextStyle(color: Color(0xFFE5853B), fontSize: 14)),
          ),
      ],
    );
  }

  void _mostrarTodo(BuildContext context, String titulo, List<QueryDocumentSnapshot<Map<String, dynamic>>> listaCompleta) {
    showDialog(
      context: context,
      builder: (context) {
        final ScrollController scrollController = ScrollController();
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE5853B))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFE5853B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: TarjetaBuilder(
                      scrollController: scrollController,
                      isScrollable: true,
                      filtro: [listaCompleta],
                      cantidadColumnas: 2,
                      tarjetaSize: 350,
                      smallVersion: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarComentarios(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Comentarios de compradores"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(widget.vendedorId)
                  .collection('comentarios')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE5853B)));
                }
                
                var docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text("Aún no hay comentarios."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    int calificacion = data['calificacion'] ?? 0;
                    String comentario = data['comentario'] ?? '';
                    String autor = data['autor'] ?? 'Usuario'; 

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFFFDAB9), child: Icon(Icons.person, color: Colors.white)),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           
                            Text(
                              autor, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                            const SizedBox(height: 4),
                            // Las estrellitas debajo del nombre
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < calificacion ? Icons.star : Icons.star_border,
                                size: 16,
                                color: const Color(0xFFFFCD60),
                              )),
                            ),
                          ],
                        ),
                        // El comentario se muestra como subtítulo
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(comentario),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: Color(0xFFE5853B))),
            ),
          ],
        );
      },
    );
  }
}