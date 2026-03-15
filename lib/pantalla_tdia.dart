import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaTdia extends StatefulWidget {
  const PantallaTdia({super.key});

  @override
  State<PantallaTdia> createState() => _PantallaTdiaState();
}

class _PantallaTdiaState extends State<PantallaTdia> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5853B),
        title: const Text("Detalle de Transacciones", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('transacciones').orderBy('fecha_inicio', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          int total = docs.length;

          // Contadores
          int pendientes = 0;
          int finalizadas = 0;
          
          Map<String, int> tipoConteo = {};
          Map<String, int> estadoConteo = {};
          
          // Datos para gráfico lineal (Este mes)
          DateTime now = DateTime.now();
          int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
          Map<int, int> iniciadasDia = {for (var i = 1; i <= daysInMonth; i++) i: 0};
          Map<int, int> finalizadasDia = {for (var i = 1; i <= daysInMonth; i++) i: 0};
          double maxVal = 0;

          for (var doc in docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            
            // Estado
            String estado = data['estado'] ?? 'desconocido';
            if (estado == 'pendiente') pendientes++;
            if (estado == 'finalizada') finalizadas++;
            
            estadoConteo[estado] = (estadoConteo[estado] ?? 0) + 1;

            // Tipo (Venta, Intercambio, Gratis)
            String tipo = data['tipo'] ?? 'Otro';
            tipoConteo[tipo] = (tipoConteo[tipo] ?? 0) + 1;
            
            Timestamp? tInicio = data['fecha_inicio'];
            if (tInicio != null) {
              DateTime d = tInicio.toDate();
              if (d.year == now.year && d.month == now.month) {
                iniciadasDia[d.day] = (iniciadasDia[d.day] ?? 0) + 1;
                if (iniciadasDia[d.day]! > maxVal) maxVal = iniciadasDia[d.day]!.toDouble();
              }
            }
            
            Timestamp? tFin = data['fecha_confirmacion'];
            if (tFin != null) {
              DateTime d = tFin.toDate();
              if (d.year == now.year && d.month == now.month) {
                finalizadasDia[d.day] = (finalizadasDia[d.day] ?? 0) + 1;
                if (finalizadasDia[d.day]! > maxVal) maxVal = finalizadasDia[d.day]!.toDouble();
              }
            }
          }
          
          maxVal = (maxVal + 2).roundToDouble(); // Margen superior
          List<FlSpot> spotsIniciadas = iniciadasDia.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
          List<FlSpot> spotsFinalizadas = finalizadasDia.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE5853B), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text("TOTAL TRANSACCIONES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text("$total", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFE5853B)))
                    ],
                  ),
                ),

                Row(
                  children: [
                    _cardMini("Pendientes", pendientes.toString(), const Color(0xFFE05555)),
                    const SizedBox(width: 15),
                    _cardMini("Finalizadas", finalizadas.toString(), const Color(0xFF59BBA3))
                  ],
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _chartContainer(
                        title: "Por Tipo",
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 30,
                                  sections: _mostrarSecciones(tipoConteo, total),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: ListView(
                                shrinkWrap: true,
                                children: _generarLeyenda(tipoConteo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _chartContainer(
                        title: "Por Estado",
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 30,
                                  sections: _mostrarSecciones(estadoConteo, total),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: ListView(
                                shrinkWrap: true,
                                children: _generarLeyenda(estadoConteo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Gráfico Lineal: Transacciones este mes
                _chartContainer(
                  title: "Transacciones este mes",
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _simpleLegend("Iniciadas", const Color(0xFFE05555)),
                          const SizedBox(width: 20),
                          _simpleLegend("Finalizadas", const Color(0xFF59BBA3)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                )
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 1, maxX: daysInMonth.toDouble(), minY: 0, maxY: maxVal,
                            lineBarsData: [
                              LineChartBarData(spots: spotsIniciadas, color: const Color(0xFFE05555), isCurved: true, dotData: const FlDotData(show: false), barWidth: 3, preventCurveOverShooting: true),
                              LineChartBarData(spots: spotsFinalizadas, color: const Color(0xFF59BBA3), isCurved: true, dotData: const FlDotData(show: false), barWidth: 3, preventCurveOverShooting: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Transacciones Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 10 ? 10 : docs.length,
                  itemBuilder: (context, index) {
                    var tx = docs[index];
                    var data = tx.data() as Map<String, dynamic>;
                    
                    String tipo = data['tipo'] ?? 'Transacción';
                    String estado = data['estado'] ?? 'desconocido';
                    Timestamp? ts = data['fecha_inicio'];
                    
                    String fechaStr = "";
                    if (ts != null) {
                      DateTime dt = ts.toDate();
                      fechaStr = "${dt.day}/${dt.month}/${dt.year}";
                    }

                    IconData icon;
                    if (tipo == 'Venta') {
                      icon = Icons.attach_money;
                    } else if (tipo == 'Intercambio') {
                      icon = Icons.swap_horiz;
                    } else {
                      icon = Icons.card_giftcard;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: estado == 'pendiente' ? const Color(0xFFE05555) : const Color(0xFF59BBA3),
                          child: Icon(icon, color: Colors.white),
                        ),
                        title: Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Estado: $estado\nFecha: $fechaStr"),
                        // Aquí podrías agregar un onTap para ver detalles específicos de la transacción
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _mostrarDetalleTransaccion(context, tx);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarDetalleTransaccion(BuildContext context, DocumentSnapshot txDoc) {
    final data = txDoc.data() as Map<String, dynamic>;
    final String idProducto = data['id_producto'];
    final String idVendedor = data['vendedor_id'];
    final String idComprador = data['comprador_id'];
    final String estado = data['estado'] ?? 'N/A';
    final Timestamp? ts = data['fecha_inicio'];
    final Timestamp? tsFin = data['fecha_confirmacion'];

    String fechaStr = "N/A";
    if (ts != null) {
      DateTime dt = ts.toDate();
      fechaStr = "${dt.day}/${dt.month}/${dt.year}";
    }
    
    String? fechaFinStr;
    if (tsFin != null) {
      DateTime dt = tsFin.toDate();
      fechaFinStr = "${dt.day}/${dt.month}/${dt.year}";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Detalle de Transacción"),
          content: FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait([
              FirebaseFirestore.instance.collection('productos').doc(idProducto).get(),
              FirebaseFirestore.instance.collection('usuarios').doc(idVendedor).get(),
              FirebaseFirestore.instance.collection('usuarios').doc(idComprador).get(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 3) {
                return const Text("No se pudieron cargar los detalles.");
              }

              final vendedorDoc = snapshot.data![1];
              final compradorDoc = snapshot.data![2];

              final vendedorData = vendedorDoc.data() as Map<String, dynamic>?;
              final compradorData = compradorDoc.data() as Map<String, dynamic>?;

              final String nombreVendedor = "${vendedorData?['nombre'] ?? ''} ${vendedorData?['apellido'] ?? ''}".trim();
              final String nombreComprador = "${compradorData?['nombre'] ?? ''} ${compradorData?['apellido'] ?? ''}".trim();

              return SingleChildScrollView(
                child: _detalleResumido(
                  context: context,
                  comprador: nombreComprador.isNotEmpty ? nombreComprador : 'Usuario no encontrado',
                  vendedor: nombreVendedor.isNotEmpty ? nombreVendedor : 'Usuario no encontrado',
                  fechaInicio: fechaStr,
                  fechaFin: fechaFinStr,
                  estado: estado,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }


  // --- WIDGETS INTERNOS ---

  Widget _chartContainer({required String title, required Widget child}) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  Color _getColor(String key, int index) {
    switch (key.toLowerCase()) {
      case 'pendiente': return const Color(0xFFE05555); 
      case 'finalizada': return const Color(0xFF59BBA3);
      case 'venta': return const Color(0xFF3F85D5);
      case 'intercambio': return const Color(0xFFE5853B);
      case 'gratis': return Colors.purple;
      default:
        // Paleta fallback
        List<Color> palette = [Colors.amber, Colors.cyan, Colors.brown, Colors.indigo];
        return palette[index % palette.length];
    }
  }

  List<Widget> _generarLeyenda(Map<String, int> conteo) {
    List<Widget> leyenda = [];
    int i = 0;
    conteo.forEach((key, cantidad) {
      if (cantidad > 0) {
        final color = _getColor(key, i);
        leyenda.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
      }
    });
    return leyenda;
  }

  List<PieChartSectionData> _mostrarSecciones(Map<String, int> conteo, int total) {
    List<PieChartSectionData> secciones = [];
    int i = 0;
    conteo.forEach((key, cantidad) {
      if (cantidad > 0) {
        final color = _getColor(key, i);
        secciones.add(PieChartSectionData(
          color: color,
          value: cantidad.toDouble(),
          title: '${((cantidad/total)*100).round()}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ));
        i++;
      }
    });
    return secciones;
  }

  Widget _cardMini(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _detalleResumido({
    required BuildContext context,
    required String comprador,
    required String vendedor,
    required String fechaInicio,
    String? fechaFin,
    required String estado,
  }) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
        children: [
          const TextSpan(text: "Comprador: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "$comprador\n"),
          const TextSpan(text: "Vendedor: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "$vendedor\n"),
          const TextSpan(text: "Fecha Inicio: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "$fechaInicio\n"),
          if (fechaFin != null) ...[
            const TextSpan(text: "Fecha Confirmación: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "$fechaFin\n"),
          ],
          const TextSpan(text: "Estado: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: estado),
        ],
      ),
    );
  }

  Widget _simpleLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}