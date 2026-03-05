import 'package:bookmet/home_screen.dart';
import 'package:bookmet/tarjeta_builder.dart';
import 'package:flutter/material.dart';
import 'package:bookmet/crear_producto.dart';
import 'package:bookmet/editar_perfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:bookmet/auth.dart';


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
          TextButton(
            onPressed: () {}, 
            child: const Text('Favoritos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearProducto()));

                      }, child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      
                      
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
                  print("Navegar a Mi Perfil");
                  break;
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
        
        bool pasaCategoria = categoriasSeleccionadas.isEmpty || categoriasSeleccionadas.contains(data['categoria']);
        bool pasaEstado = estadosSeleccionados.isEmpty || estadosSeleccionados.contains(data['estado']);
        bool pasaTransaccion = transaccionesSeleccionadas.isEmpty || transaccionesSeleccionadas.contains(data['tipo_transaccion']);

        return pasaCategoria && pasaEstado && pasaTransaccion;
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

      return TarjetaBuilder(filtro: [documentosFiltrados], cantidadColumnas: 3, tarjetaSize: 400,);
      
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
/*Widget _tarjetaProducto(BuildContext context, String titulo, String autor, String precio, String foto) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleProducto(
            titulo: titulo,
            autor: autor,
            precio: precio,
            foto: foto,
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: foto != "" 
                    ? Image.network(foto, fit: BoxFit.cover) 
                    : const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.favorite_border, color: Color(0xFFC0834A), size: 30),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
        Text(autor, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(precio, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}*/