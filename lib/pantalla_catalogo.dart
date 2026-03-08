import 'package:bookmet/home_screen.dart';
import 'package:bookmet/tarjeta_builder.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/crear_producto.dart';
import 'package:bookmet/editar_perfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:bookmet/auth.dart';
import 'package:bookmet/mi_perfil.dart';
import 'package:bookmet/dialogo_favoritos.dart';
import 'package:firebase_auth/firebase_auth.dart';



class PantallaCatalogo extends StatefulWidget {
  const PantallaCatalogo({super.key});

  @override
  State<PantallaCatalogo> createState() => _PantallaCatalogoState();
}

class _PantallaCatalogoState extends State<PantallaCatalogo> {
  // Variables para recordar los filtros
  List<String> categoriasSeleccionadas = [];
  List<String> estadosSeleccionados = [];
  List<String> transaccionesSeleccionadas = [];

  // Variables para la barra de búsqueda
  bool _estaBuscando = false;
  String _textoBusqueda = "";
  final TextEditingController _controladorBusqueda = TextEditingController();
@override
  void initState() {
    super.initState();
    // Esto hace que la revisión se ejecute justo cuando la pantalla termina de cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarWhatsApp(); 
      Future<void> _verificarSolicitudes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Buscamos en Firebase productos que sean MÍOS y que estén "Solicitados"
    // (Asegúrate de cambiar 'usuario_id' por el nombre del campo donde guardas el dueño del producto)
    final query = await FirebaseFirestore.instance
        .collection('productos')
        .where('id_vendedor', isEqualTo: user.uid) 
        .where('estado', isEqualTo: 'Solicitado')
        .get();

    // 2. Si encontramos alguno, lanzamos la alerta
    if (query.docs.isNotEmpty) {
      for (var doc in query.docs) {
        if (!mounted) return;
        
        final datosProducto = doc.data();
        // Usamos await en el showDialog para que si tiene varios productos solicitados, salgan uno por uno
        await showDialog(
          context: context,
          barrierDismissible: false, // No puede ignorar la notificación
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('¡Nueva Solicitud! 🎉'),
              // Cambia 'titulo' por el campo donde guardas el nombre del libro/producto
              content: Text('Alguien ha solicitado tu producto "${datosProducto['nombre']}".\n\n¿Confirmas que la venta/intercambio está en proceso?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Si el vendedor dice NO, el producto vuelve a estar Disponible para otros
                    doc.reference.update({
                      'estado': 'Disponible',
                      'solicitante_id': FieldValue.delete(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('No, cancelar', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    // Si el vendedor dice SÍ, el producto pasa a "En proceso" y se bloquea
                    doc.reference.update({'estado': 'En proceso'});
                    Navigator.pop(context);
                  },
                  child: const Text('Sí, confirmar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    }
   }
    
   _verificarSolicitudes(); 
  }); 
} 

  Future<void> _verificarWhatsApp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      final String? whatsapp = data['link_whatsapp']; 

      final regex = RegExp(r'(https?:\/\/)?(wa\.me\/|api\.whatsapp\.com\/send\?phone=)\d+');
      bool esValido = whatsapp != null && whatsapp.isNotEmpty && regex.hasMatch(whatsapp);

      if (!esValido) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false, 
          builder: (BuildContext context) {
            return PopScope( 
              canPop: false, 
              child: AlertDialog(
                title: const Text('¡Atención! 🚨'),
                content: const Text('Para poder usar Bookmet y hacer intercambios, es obligatorio tener un link válido de WhatsApp en tu perfil.'),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        Navigator.pop(context); 
                        Navigator.push( 
                          context,
                          MaterialPageRoute(builder: (context) => const EditarPerfil()),
                        );
                      },
                      child: const Text('Completar mi perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }
  String _normalizarTexto(String texto) {
    return texto.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

void _mostrarDialogoFiltros() {
    List<String> tempCategorias = List.from(categoriasSeleccionadas);
    List<String> tempEstados = List.from(estadosSeleccionados);
    List<String> tempTransacciones = List.from(transaccionesSeleccionadas);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Filtros de búsqueda:", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC0834A))),
                          IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFFC0834A), size: 30), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("Tipo de Material", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 15,
                        children: ['Libros', 'Guías', 'Material Lab', 'Equipos', 'Otros'].map((String opcion) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                activeColor: const Color(0xFFC0834A),
                                value: tempCategorias.contains(opcion),
                                onChanged: (bool? value) { setStateDialog(() { if (value == true) { tempCategorias.add(opcion); } else { tempCategorias.remove(opcion); } }); },
                              ),
                              Text(opcion),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      const Text("Estado de Conservación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 15,
                        children: ['Nuevo', 'Como nuevo', 'Desgastado'].map((String opcion) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                activeColor: const Color(0xFFC0834A),
                                value: tempEstados.contains(opcion),
                                onChanged: (bool? value) { setStateDialog(() { if (value == true) { tempEstados.add(opcion); } else { tempEstados.remove(opcion); } }); },
                              ),
                              Text(opcion),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      const Text("Tipo de Transacción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 15,
                        children: ['Intercambio', 'Venta', 'Gratis'].map((String opcion) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                activeColor: const Color(0xFFC0834A),
                                value: tempTransacciones.contains(opcion),
                                onChanged: (bool? value) { setStateDialog(() { if (value == true) { tempTransacciones.add(opcion); } else { tempTransacciones.remove(opcion); } }); },
                              ),
                              Text(opcion),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5853B), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                          onPressed: () {
                            setState(() {
                              categoriasSeleccionadas = tempCategorias;
                              estadosSeleccionados = tempEstados;
                              transaccionesSeleccionadas = tempTransacciones;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Aplicar filtros de búsqueda", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Color melocotón clarito del diseño
        backgroundColor: const Color(0xFFFFEAC5), 
        elevation: 0,
        toolbarHeight: 80,
        // LOGO ARRIBA A LA IZQUIERDA
        leadingWidth: 150, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset(
            'image/LogoBookmetMini.png',
            fit: BoxFit.contain,
          ),
        ),

        actions: [
          // BARRA DE BÚSQUEDA CONDICIONAL
          if (_estaBuscando)
            Container(
              width: 300, // Ancho de la barra de búsqueda
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controladorBusqueda,
                autofocus: true, // Para que el teclado se abra de una vez
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o autor...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFC0834A)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _estaBuscando = false;
                        _textoBusqueda = "";
                        _controladorBusqueda.clear();
                      });
                    },
                  ),
                ),
                onChanged: (valor) {
                  setState(() {
                    _textoBusqueda = _normalizarTexto(valor);
                  });
                },
              ),
            )
          else ...[
            // LUPITA Y FAVORITOS (SOLO SE MUESTRAN SI NO SE ESTÁ BUSCANDO)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 28),
              onPressed: () {
                setState(() {
                  _estaBuscando = true;
                });
              },
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DialogoFavoritos();
                  },
                );
              },
              child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ], // FIN BARRA DE BÚSQUEDA CONDICIONAL

          const SizedBox(width: 15),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearProducto()));
            }, 
            child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),            
                      
          const SizedBox(width: 15),
          TextButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);}, 
            child: const Text('Inicio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          
          // BOTÓN DE LA PERSONITA 
          PopupMenuButton<String>(

            icon: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFEA983E), 
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            iconSize: 50,
            onSelected: (String value) {
        
              switch (value) {
                case 'perfil':
                  showDialog(
                    context: context,
                    builder: (context){       
                    Size? screenSize =  MediaQuery.of(context).size;
                    final double dialogWidth = screenSize.width * 0.9;
                    final double dialogHeight = screenSize.height * 0.85;
                    return MiPerfil(dialogWidth: dialogWidth, dialogHeight: dialogHeight); 
                    }
                  );
                case 'editar':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfil()));
                  break;
                case 'cerrar_sesion':
                  Auth.instance.signOut(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'perfil',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Mi Perfil'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar Perfil'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 30), 
        ],

      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),



// IMAGEN DEL CATÁLOGO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/catalogo.png', 
                  width: double.infinity,
                  height: 450, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
            

            
            const SizedBox(height: 40),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtros:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  
                  GestureDetector(
                    onTap: _mostrarDialogoFiltros,

                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAC5), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Selecciona los filtros....", 
                        style: TextStyle(color: Colors.black54)
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

          
           Padding(
  padding: const EdgeInsets.symmetric(horizontal: 40.0),

  child: StreamBuilder(
    
    stream: FirebaseFirestore.instance.collection('productos').snapshots(),
    builder: (context, snapshot) {
      
      if (!snapshot.hasData) return const CircularProgressIndicator();
        // Lógica de filtrado
      var documentosFiltrados = snapshot.data!.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // 1. Filtros de botones
        bool pasaCategoria = categoriasSeleccionadas.isEmpty || categoriasSeleccionadas.contains(data['categoria']);
        bool pasaEstado = estadosSeleccionados.isEmpty || estadosSeleccionados.contains(data['estado']);
        bool pasaTransaccion = transaccionesSeleccionadas.isEmpty || transaccionesSeleccionadas.contains(data['tipo_transaccion']);

        // 2. Filtro de la barra de búsqueda
        bool pasaBusqueda = true;
        if (_textoBusqueda.isNotEmpty) {
          String nombreProducto = data.containsKey('nombre') ? _normalizarTexto(data['nombre']) : '';
          String autorProducto = data.containsKey('autor_marca') ? _normalizarTexto(data['autor_marca']) : '';
          
          // Comprueba si el texto ingresado está contenido en el nombre o en el autor
          pasaBusqueda = nombreProducto.contains(_textoBusqueda) || autorProducto.contains(_textoBusqueda);
        }

        return pasaCategoria && pasaEstado && pasaTransaccion && pasaBusqueda;
      }).toList();

      //Esto es por si no existen publicaciones con los filtros seleccionados diga que no hay
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

      return TarjetaBuilder(filtro: [documentosFiltrados], cantidadColumnas: 3, tarjetaSize: 400, smallVersion: false,);
      
      //comentado por si acaso, usar tarjeta builder
      /*GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 25,
          mainAxisSpacing: 40,
          childAspectRatio: 0.7,
        ),

        itemCount: documentosFiltrados.length, // Usamos el tamaño de la lista filtrada
        itemBuilder: (context, index) {
        var producto = documentosFiltrados[index]; // Usamos los productos filtrados


          
          // Convertimos a Map para evitar el error de campos faltantes
          Map<String, dynamic> data = producto.data() as Map<String, dynamic>;

          //Extraemos los valores de forma segura
          String titulo = data.containsKey('nombre') ? (data['nombre'] ?? 'Sin título') : 'Sin título';
          String autor = data.containsKey('autor_marca') ? (data['autor_marca'] ?? 'Sin autor') : 'Sin autor';
          String precio = data.containsKey('valor') ? (data['valor'] ?? '0') : '0';
          String foto = data.containsKey('image_url') ? (data['image_url'] ?? "") : "";

          //Enviamos los datos a la tarjeta
          return TarjetaProducto(
            titulo: titulo,
            autor: autor,
            precio: precio,
            foto: foto,
          );
        },
      );*/
    },
  ),
),
            
           const SizedBox(height: 100),
          ]    
        ),
        
      ),
    );
  }
}
