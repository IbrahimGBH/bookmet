import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmet/model/auth.dart';
import 'package:bookmet/viewmodel/notificacion.dart';

class Transaccion {
  Transaccion._internal();
  final FirebaseFirestore ffStore = FirebaseFirestore.instance;
  static final Transaccion _instance = Transaccion._internal();
  static Transaccion get instance => _instance;

  Future<void> solicitarTransaccion(
    String idProducto,
    String vendedorId,
    {String? propuesta}
  ) async {
    final producto = await ffStore
        .collection('productos')
        .doc(idProducto)
        .get();
    
    final String tipo = producto['tipo_transaccion'];
    
    // Datos base comunes
    Map<String, dynamic> datosTransaccion = {
      'id_producto': idProducto,
      'vendedor_id': vendedorId,
      'comprador_id': Auth.instance.getUid(),
      'estado': 'pendiente',
      'fecha_inicio': Timestamp.now(),
      'fecha_confirmacion': null,
      'confirmacion_vendedor': false,
      'confirmacion_comprador': false,
      'aceptada': false,
      'tipo': tipo,
    };

    switch (tipo) {
      case 'Intercambio':
        // En intercambio guardamos la propuesta del comprador
        if (propuesta != null) {
          datosTransaccion['propuesta'] = propuesta;
        }
        break;
      case 'Venta':
        // La transacción ya fue cobrada vía PayPal en la UI.
        // Ahora sí la marcamos como "aceptada" automáticamente porque el dinero ya entró.
        datosTransaccion['aceptada'] = true;
        break;
      case 'Gratis':
        //No se requiere más info
        break;
      default:
        return;
    }
    try {
          DocumentReference transaccionRef = await ffStore
              .collection('transacciones')
              .add(datosTransaccion);

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
                'tipo': tipo,
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
                'tipo': tipo,
                'estado': 'pendiente',
              });

          String nombreComprador = await Auth.instance.getNombre(Auth.instance.getUid());
          String apellidoComprador = await Auth.instance.getApellido(Auth.instance.getUid());
          String nombreProducto = producto['nombre'] ?? 'un artículo';
          
          String tituloNotif = (tipo == 'Venta') ? '¡Producto Vendido!' : 'Nueva Solicitud';
          String cuerpoNotif = (tipo == 'Venta') 
              ? '$nombreComprador $apellidoComprador ha comprado tu producto "$nombreProducto".'
              : '$nombreComprador $apellidoComprador ha enviado una solicitud de $tipo por "$nombreProducto".';

          await Notificacion.instance.crearNotificacion(
            userId: vendedorId,
            titulo: tituloNotif,
            cuerpo: cuerpoNotif,
            tipo: 'solicitud_transaccion',
          );
        } catch (e) {
          //manejar error
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

        await ffStore.collection('productos').doc(idProducto).delete();

        // Eliminar de favoritos de todos los usuarios
        var favoritosSnap = await ffStore
            .collectionGroup('favoritos')
            .where('id_producto', isEqualTo: idProducto)
            .get();
        
        WriteBatch batch = ffStore.batch();
        for (var doc in favoritosSnap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'estado': 'finalizada',
          'fecha_confirmacion': Timestamp.now(),
        });
      }
    } catch (e) {
      // manejar error
    }
  }

  Future<void> confirmarEntrega(String idTransaccion) async {
    try {
      final transaccionDoc = await ffStore
          .collection('transacciones')
          .doc(idTransaccion)
          .get();
      
      if (!transaccionDoc.exists) return;

      final data = transaccionDoc.data()!;
      bool compradorConfirmo = data['confirmacion_comprador'] ?? false;
      bool vendedorConfirmo = data['confirmacion_vendedor'] ?? false;

      // Actualizamos quién hizo clic y cambiamos la variable local a true
      if (Auth.instance.getUid() == data['comprador_id']) {
        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'confirmacion_comprador': true,
        });
        compradorConfirmo = true; 
      } else if (Auth.instance.getUid() == data['vendedor_id']) {
        await ffStore.collection('transacciones').doc(idTransaccion).update({
          'confirmacion_vendedor': true,
        });
        vendedorConfirmo = true; 
      }
      
      // Si ambos son true, se ejecuta la finalización que borra el producto
      if (compradorConfirmo && vendedorConfirmo) {
        await finalizarTransaccion(idTransaccion);
      }
    } catch (e) {
      // manejar error
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
          
        if(Auth.instance.getUid() == compradorId) {  
          String nombreComprador = await Auth.instance.getNombre(Auth.instance.getUid());
          String apellidoComprador = await Auth.instance.getApellido(Auth.instance.getUid());
          
          String tituloNotif = 'Solicitud cancelada';
          String cuerpoNotif = '$nombreComprador $apellidoComprador ha cancelado su solicitud.';

          await Notificacion.instance.crearNotificacion(
            userId: vendedorId,
            titulo: tituloNotif,
            cuerpo: cuerpoNotif,
            tipo: 'solicitud_transaccion',
          );
        }
      }

      await ffStore.collection('transacciones').doc(idTransaccion).delete();
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
