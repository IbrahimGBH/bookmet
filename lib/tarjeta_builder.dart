import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/tarjeta_producto.dart';

class TarjetaBuilder extends StatelessWidget {
  final List<List<QueryDocumentSnapshot<Map<String, dynamic>>>> filtro;
  final int cantidadColumnas;
  final int tarjetaSize;
  final bool smallVersion;

  const TarjetaBuilder({
    super.key,
    required this.filtro,
    required this.cantidadColumnas,
    required this.tarjetaSize,
    required this.smallVersion,
  });
  

  @override
  Widget build(BuildContext context) {

    final flatList = filtro.expand((x) => x).toList();
    if (smallVersion) {
      // Si se quiere la versión pequeña con scrollbar interactivo
      final ScrollController controller = ScrollController();
      return SizedBox(
        height: tarjetaSize.toDouble(),
        child: Scrollbar(
          controller: controller,
          thumbVisibility: true,
          interactive: true,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: flatList.length,
            itemBuilder: (context, index) {


              var producto = flatList[index];
              Map<String, dynamic> data = producto.data();
              String idProducto = producto.id; 
              String vendedorId = data.containsKey('vendedor_id') ? (data['vendedor_id'] ?? '') : '';
              String titulo = data.containsKey('nombre') ? (data['nombre'] ?? 'Sin título') : 'Sin título';
              String autor = data.containsKey('autor_marca') ? (data['autor_marca'] ?? 'Sin autor') : 'Sin autor';
              String precio = data.containsKey('valor') ? (data['valor'] ?? '0') : '0';
              String foto = data.containsKey('image_url') ? (data['image_url'] ?? "") : "";
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 20),
                child: TarjetaProducto(
                  idProducto: idProducto, 
                  vendedorId: vendedorId,
                  titulo: titulo,
                  autor: autor,
                  precio: precio,
                  foto: foto,
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Default: vertical grid
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cantidadColumnas,
          crossAxisSpacing: 25,
          mainAxisSpacing: 40,
          childAspectRatio: 0.7,
          mainAxisExtent: tarjetaSize.toDouble(),
        ),
        itemCount: flatList.length,
        itemBuilder: (context, index) {


          var producto = flatList[index];
          Map<String, dynamic> data = producto.data();
          String idProducto = producto.id; 
          String vendedorId = data.containsKey('vendedor_id') ? (data['vendedor_id'] ?? '') : '';
          String titulo = data.containsKey('nombre') ? (data['nombre'] ?? 'Sin título') : 'Sin título';
          String autor = data.containsKey('autor_marca') ? (data['autor_marca'] ?? 'Sin autor') : 'Sin autor';
          String precio = data.containsKey('valor') ? (data['valor'] ?? '0') : '0';
          String foto = data.containsKey('image_url') ? (data['image_url'] ?? "") : "";
          return TarjetaProducto(
            idProducto: idProducto, 
            vendedorId: vendedorId,
            titulo: titulo,
            autor: autor,
            precio: precio,
            foto: foto,
          );
        },
      );
    }
  }
}