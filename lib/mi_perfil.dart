import 'package:bookmet/editar_perfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';
import 'package:bookmet/tarjeta_builder.dart';
import 'transaccion.dart';


class MiPerfil extends StatefulWidget {
  final double dialogWidth;
  final double dialogHeight; 
  const MiPerfil({super.key,required this.dialogWidth, required this.dialogHeight});
  
@override
  State<MiPerfil> createState() => _MiPerfilState();
}

class _MiPerfilState extends State<MiPerfil> {
  // Variables para controlar el "Ver más"
  bool verTodasPublicaciones = false;
  bool verTodasSolicitudes = false;
  @override

  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Container(
          width: widget.dialogWidth > 581 ? 581 : widget.dialogWidth ,
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
                      _buildItemLibro(context),
                    
                    const SizedBox(height: 6),
                    
                    // Solicitudes
                    _buildTarjetaSolicitud(context),
                    
                    const SizedBox(height: 30),
                    _buildBotonesAccion(context),
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
  Future<Map<String, dynamic>> get_datosUsuario() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(Auth.instance.getUid())
        .get();
    return doc.data() as Map<String, dynamic>;
  }
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
      FutureBuilder<Map<String, dynamic>>(
        future: get_datosUsuario(),
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) return const Text("Cargando...");
          
          var data = asyncSnapshot.data!;
          String nombreCompleto = "${data['nombre']} ${data['apellido']}";
          
     
          int puntos = data['rating_puntos'] ?? 0;
          int votos = data['rating_votos'] ?? 0;
          double promedio = votos > 0 ? puntos / votos : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombreCompleto,
                style: const TextStyle(color: Color(0xFFE5853B), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                
                children: List.generate(5, (index) {
                  return Icon(
                    index < promedio.round() ? Icons.star : Icons.star_border, 
                    color: const Color(0xFFFFCD60), 
                    size: 18
                  );
                }),
              ),
              const Text("UNIMET", style: TextStyle(color: Colors.grey)),
            ],
          );
        }
      ),
    ],
  );
}

Widget _buildItemLibro(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('vendedor_id', isEqualTo: Auth.instance.getUid())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        var todosLosDocs = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
        var limitados = todosLosDocs.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccionTitulo("Mis publicaciones:", alPresionarVerMas: () {
              _mostrarTodo(context, "Todas mis publicaciones", todosLosDocs);
            }),
            TarjetaBuilder(
              filtro: [limitados], 
              cantidadColumnas: limitados.length, 
              tarjetaSize: 400, 
              smallVersion: true,
            ),
          ],
        );
      },
    );
  }



Widget _buildBotonesAccion(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5853B), shape: StadiumBorder()),
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfil()));},
          child: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDAB9), shape: StadiumBorder()),
          onPressed: () {Auth.instance.signOut(context);},
          child: const Text("Cerrar sesión", style: TextStyle(color: Color(0xFFE5853B))),
        ),
      ),
    ],
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
// aqui cambie un pelo el codigo para que salga el boton de ver mas y todas las solicitudes pendientes.
Widget _buildTarjetaSolicitud(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('transacciones')
        .where('comprador_id', isEqualTo: Auth.instance.getUid())
        .where('estado', isEqualTo: 'pendiente')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const CircularProgressIndicator();
      

      var transacciones = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
      
      if (transacciones.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccionTitulo("Mis solicitudes:"),
            const Text("No tienes solicitudes pendientes.", style: TextStyle(color: Colors.grey)),
          ],
        );
      }

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, prodSnapshot) {
          if (!prodSnapshot.hasData) return const SizedBox();
          
          var productosAll = prodSnapshot.data!.docs;
          var transIds = transacciones.map((t) => t['id_producto']).toSet();
          
          var productosRelacionados = productosAll.where((doc) => transIds.contains(doc.id)).toList();
          var limitados = productosRelacionados.take(2).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildSeccionTitulo("Mis solicitudes:", alPresionarVerMas: () {
                _mostrarTodo(context, "Todas mis solicitudes", transacciones, esSolicitud: true);
              }),
              TarjetaBuilder(
                filtro: [limitados],
                cantidadColumnas: limitados.length,
                tarjetaSize: 400,
                smallVersion: true,
              ),
            ],
          );
        },
      );
    },
  );
}
void _mostrarTodo(BuildContext context, String titulo, List<QueryDocumentSnapshot<Map<String, dynamic>>> listaCompleta, {bool esSolicitud = false}) {
  showDialog(
    context: context,
    builder: (context) {
      // Creamos un controlador explícito para vincular Scrollbar y la lista
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
                  // Asignamos el controlador al Scrollbar
                  controller: scrollController,
                  thumbVisibility: true, // Hace visible la barra siempre
                  child: esSolicitud
                      ? ListView.builder(
                          // Asignamos EL MISMO controlador al ListView
                          controller: scrollController,
                          itemCount: listaCompleta.length,
                          itemBuilder: (context, index) =>
                              _buildFilaAccionSolicitud(listaCompleta[index]),
                        )
                      : TarjetaBuilder(
                          // Si es publicacion, seguimos con tu grid
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
Widget _buildFilaAccionSolicitud(QueryDocumentSnapshot<Map<String, dynamic>> transDoc) {
  final transData = transDoc.data();
  final String idProducto = transData['id_producto'];
  final String idTransaccion = transDoc.id;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('productos').doc(idProducto).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
      
      var productoData = snapshot.data!.data() as Map<String, dynamic>;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
         
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productoData['imagen_url'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, width: 60, height: 60),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EN PROGRESO - ${productoData['nombre']}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _botonAccion("Aceptar solicitud", const Color(0xFF6ABF97), () {
                        Transaccion.instance.aceptarSolicitud(idTransaccion);
                      }),
                      const SizedBox(width: 8),
                      _botonAccion("Rechazar solicitud", const Color(0xFFB54D43), () {
                        Transaccion.instance.eliminarTransaccion(idTransaccion);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _botonAccion(String texto, Color color, VoidCallback onTap) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
}