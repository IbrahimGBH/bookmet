import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/auth.dart';

class Transaccion {
  Transaccion._internal();
  final FirebaseFirestore ffStore = FirebaseFirestore.instance;
  static final Transaccion _instance = Transaccion._internal();
  static Transaccion get instance => _instance;

  Future<void> solicitarTransaccion(
    String idProducto,
    String vendedorId,
  ) async {
    final producto = await ffStore
        .collection('productos')
        .doc(idProducto)
        .get();
    switch (producto['tipo_transaccion']) {
      case 'Intercambio':
      // Lógica para solicitar intercambio (por implementar)
      case 'Venta':
      // Lógica para solicitar compra (por implementar)
      case 'Gratis':
        try {
          DocumentReference transaccionRef = await ffStore
              .collection('transacciones')
              .add({
                'id_producto': idProducto,
                'vendedor_id': vendedorId,
                'comprador_id': Auth.instance.getUid(),
                'estado': 'pendiente',
                'fecha_inicio': Timestamp.now(),
                'fecha_confirmacion': null,
                'confirmacion_vendedor': false,
                'confirmacion_comprador': false,
                'aceptada':null,
              });
          await ffStore.collection('productos').doc(idProducto).update({
            'disponibilidad': 'en transaccion',
          });
          await ffStore
              .collection('usuarios')
              .doc(vendedorId)
              .collection('transacciones')
              .doc(transaccionRef.id)
              .set({
                'id_producto': idProducto,
                'rol': 'vendedor',
                'tipo': producto['tipo_transaccion'],
                'estado': 'pendiente',
              });
          await ffStore
              .collection('usuarios')
              .doc(Auth.instance.getUid())
              .collection('transacciones')
              .doc(transaccionRef.id)
              .set({
                'id_producto': idProducto,
                'rol': 'comprador',
                'tipo': producto['tipo_transaccion'],
                'estado': 'pendiente',
              });
        } catch (e) {
          //manejar error
        }
        break;
      default:
        // Manejar caso de tipo de transacción desconocido
        break;
    }
  }

  Future<void> finalizarTransaccion(String idTransaccion) async {
    try {
      final transaccionDoc = await ffStore
          .collection('transacciones')
          .doc(idTransaccion)
          .get();

      if (transaccionDoc.exists) {
        final data = transaccionDoc.data()!;
        final String compradorId = data['comprador_id'];
        final String vendedorId = data['vendedor_id'];
        final String idProducto = data['id_producto'];
        await ffStore
            .collection('usuarios')
            .doc(compradorId)
            .collection('transacciones')
            .doc(idTransaccion)
            .delete();

        await ffStore
            .collection('usuarios')
            .doc(vendedorId)
            .collection('transacciones')
            .doc(idTransaccion)
            .delete();

        await ffStore.collection('productos').doc(idProducto).update({
          'disponibilidad': 'no disponible',
        });

        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'estado': 'finalizada',
          'fecha_confirmacion': Timestamp.now(),
        });
      }
      //Aquí se debería añadir lógica para notificar tanto al comprador y el vendedor sobre la finalización de la transacción
    } catch (e) {
      //  manejar error
    }
  }

  Future<void> confirmarEntrega(String idTransaccion) async {
    try {
      final transaccionDoc = await ffStore
          .collection('transacciones')
          .doc(idTransaccion)
          .get();
      if (Auth.instance.getUid() == transaccionDoc['comprador_id']) {
        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'confirmacion_comprador': true,
        });
      } else if (Auth.instance.getUid() == transaccionDoc['vendedor_id']) {
        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'confirmacion_vendedor': true,
        });
      }
      if (transaccionDoc['confirmacion_comprador'] == true &&
          transaccionDoc['confirmacion_vendedor'] == true) {
        finalizarTransaccion(idTransaccion);
      }
    } catch (e) {
      //manejar error
    }
  }

  Future<void> eliminarTransaccion(String idTransaccion) async {
    try {
      final transaccionDoc = await ffStore
          .collection('transacciones')
          .doc(idTransaccion)
          .get();
      if (transaccionDoc.exists) {
        final data = transaccionDoc.data()!;
        final String compradorId = data['comprador_id'];
        final String vendedorId = data['vendedor_id'];
        final String idProducto = data['id_producto'];

        await ffStore
            .collection('usuarios')
            .doc(compradorId)
            .collection('transacciones')
            .doc(idTransaccion)
            .delete();

        await ffStore
            .collection('usuarios')
            .doc(vendedorId)
            .collection('transacciones')
            .doc(idTransaccion)
            .delete();

        await ffStore.collection('productos').doc(idProducto).update({
          'disponibilidad': 'disponible',
        });
      }

      await ffStore.collection('transacciones').doc(idTransaccion).delete();
      //Aquí se debería añadir lógica para notificar tanto al comprador y el vendedor sobre la eliminación de la transacción
    } catch (e) {
      //manejar error
    }
  }

  Future<void> aceptarSolicitud(String idTransaccion) async{
    try {
      await ffStore.collection('transacciones').doc(idTransaccion).update({
        'aceptada': true,
      });
    } catch (e) {
      // manejar error
    }
  }
}
