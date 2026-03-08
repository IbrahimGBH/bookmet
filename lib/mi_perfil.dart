import 'package:bookmet/editar_perfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/auth.dart';
import 'package:bookmet/tarjeta_builder.dart';

class MiPerfil extends StatelessWidget {
  final double dialogWidth;
  final double dialogHeight; 
  const MiPerfil({super.key,required this.dialogWidth, required this.dialogHeight});
  

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Container(
          width: dialogWidth > 581 ? 581 : dialogWidth,
          height: dialogHeight,
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
                      _buildSeccionTitulo("Mis publicaciones:"),
                        
                      _buildItemLibro(),
                      
                      const SizedBox(height: 6),
                      _buildSeccionTitulo("Mis solicitudes:"),
                      
                      _buildTarjetaSolicitud(context),
                      const SizedBox(height: 24),
          
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
}

Widget _buildHeader(BuildContext context) {
  Future<String> get_nombreUsuario() async{
    String nombre = await Auth.instance.getNombre(Auth.instance.getUid());
    String apellido = await Auth.instance.getApellido(Auth.instance.getUid());
  return "$nombre $apellido";
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
      FutureBuilder(
        future: get_nombreUsuario(),
        builder: (context, asyncSnapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asyncSnapshot.data ?? "---Cargando---",
                style: TextStyle(color: Color(0xFFE5853B), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                //más tarde habrá que cambiar esto por un código que cree las estrellas en función de las calificaciones.
                children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFCD60), size: 18)),
              ),
              const Text("UNIMET", style: TextStyle(color: Colors.grey)),
            ],
          );
        }
      ),
    ],
  );
}

Widget _buildItemLibro() {
    return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('productos').snapshots(),
    builder: (context, snapshot) {
      
      if (!snapshot.hasData) return const CircularProgressIndicator();
      var documentosFiltrados = snapshot.data!.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> userId = [Auth.instance.getUid()];
        bool pasaCategoria = userId.isEmpty || userId.contains(data['vendedor_id']);
        return pasaCategoria;
      }).toList();
      if (documentosFiltrados.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Center(
            child: Text(
              "No se encontraron publicaciones con los filtros seleccionados.",
              style: TextStyle(
                fontSize: 16, 
                color: Colors.grey, 
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return TarjetaBuilder(filtro: [documentosFiltrados], cantidadColumnas: documentosFiltrados.length, tarjetaSize: 400, smallVersion: true,);
});}

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

Widget _buildSeccionTitulo(String titulo) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

Widget _buildTarjetaSolicitud(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('transacciones')
        .where('comprador_id', isEqualTo: Auth.instance.getUid())
        .where('estado', isEqualTo: 'pendiente')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      var transacciones = snapshot.data!.docs;
      if (transacciones.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Text(
              "No tienes solicitudes pendientes.",
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, prodSnapshot) {
          if (!prodSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var productosAll = prodSnapshot.data!.docs;
          // Filtrar productos que están en las transacciones pendientes
          var transIds = transacciones.map((t) => t['id_producto']).toSet();
          var productos = productosAll.where((doc) => transIds.contains(doc.id)).toList();
          if (productos.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Text(
                  "No se encontraron productos para tus solicitudes.",
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return TarjetaBuilder(
            filtro: [productos],
            cantidadColumnas: productos.length,
            tarjetaSize: 400,
            smallVersion: true,
          );
        },
      );
    },
  );
}