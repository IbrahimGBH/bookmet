import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';


// Esto lo puse para el grafico que se ve al principio del dashboard
// Muestra el grafico en funcion a las carerras
class MetricasCarreras extends StatelessWidget {
  const MetricasCarreras({super.key});

  Future<Map<String, Map<String, int>>> obtenerEstadisticas() async {
    

    Map<String, Map<String, int>> datos = {};
    Map<String, String> cacheCarreras = {};
    var productosSnap = await FirebaseFirestore.instance.collection('productos').get();
    
    for (var doc in productosSnap.docs) {
      Map<String, dynamic> data = doc.data();
      String idVendedor = data['vendedor_id']?.toString() ?? '';
      if (idVendedor.isNotEmpty) {
        if (!cacheCarreras.containsKey(idVendedor)) {
          var userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(idVendedor).get();
          cacheCarreras[idVendedor] = userDoc.data()?['carrera']?.toString() ?? 'Otras';
        }
        String carrera = cacheCarreras[idVendedor]!;
        String tipo = data['tipo_transaccion']?.toString() ?? 'Venta';
        if (!datos.containsKey(carrera)) {
          datos[carrera] = {'Gratis': 0, 'Venta': 0, 'Intercambio': 0};
        }
        if (datos[carrera]!.containsKey(tipo)) {
          datos[carrera]![tipo] = datos[carrera]![tipo]! + 1;
        }
      }
    }
    return datos;
  }

  @override
  Widget build(BuildContext context) {
    final Color naranjaMetro = const Color(0xFFE5853B);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Análisis por Carrera", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: naranjaMetro,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, Map<String, int>>>(
        future: obtenerEstadisticas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          var datos = snapshot.data ?? {};
          if (datos.isEmpty) return const Center(child: Text("No hay datos"));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: datos.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, 
              mainAxisExtent: 220, 
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              String carrera = datos.keys.elementAt(index);
              return _cardCarreraCompacta(carrera, datos[carrera]!);
            },
          );
        },
      ),
    );
  }
// Lo puse compactado porque cuando se ponia 1 por linea se veia super feo 
  Widget _cardCarreraCompacta(String nombre, Map<String, int> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15), 
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(stats) + 3, 
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent, 
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 0,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          const TextStyle(
                            color: Colors.black87, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 10
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(fontSize: 9, fontWeight: FontWeight.bold);
                          switch (value.toInt()) {
                            case 0: return const Text('G', style: style);
                            case 1: return const Text('V', style: style);
                            case 2: return const Text('I', style: style);
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _crearGrupo(0, stats['Gratis']!.toDouble(), const Color(0xFF59BBA3)),
                    _crearGrupo(1, stats['Venta']!.toDouble(), const Color(0xFF3F85D5)),
                    _crearGrupo(2, stats['Intercambio']!.toDouble(), Colors.orangeAccent),
                  ],
                ),
              ),
            ),
            const Divider(height: 10),
            Center(
              child: Text(
                "Total: ${stats['Gratis']! + stats['Venta']! + stats['Intercambio']!}", 
                style: const TextStyle(fontSize: 9, color: Colors.grey)
              )
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _crearGrupo(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        )
      ],
      showingTooltipIndicators: [0], 
    );
  }

  double _getMaxY(Map<String, int> stats) {
    double maxVal = 0;
    stats.forEach((key, value) { if (value > maxVal) maxVal = value.toDouble(); });
    return maxVal == 0 ? 5 : maxVal;
  }
}


class GraficoGlobalCarreras extends StatelessWidget {
  const GraficoGlobalCarreras({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getDatosGlobales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var lista = snapshot.data!.entries.toList();

        return BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int i = value.toInt();
                    if (i >= 0 && i < lista.length) {
                      String txt = lista[i].key;
                      return Text(txt.length > 3 ? txt.substring(0,3).toUpperCase() : txt, style: const TextStyle(fontSize: 9));
                    }
                    return const Text("");
                  },
                ),
              ),
            ),
            barGroups: lista.asMap().entries.map((e) => BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: const Color(0xFF3F85D5), width: 14)],
            )).toList(),
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _getDatosGlobales() async {
    Map<String, int> conteo = {};
    Map<String, String> cache = {};
    var prods = await FirebaseFirestore.instance.collection('productos').get();
    for (var d in prods.docs) {
      String uid = d.data()['vendedor_id']?.toString() ?? '';
      if (uid.isNotEmpty) {
        if (!cache.containsKey(uid)) {
          var u = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
          cache[uid] = u.data()?['carrera'] ?? 'Otras';
        }
        conteo[cache[uid]!] = (conteo[cache[uid]!] ?? 0) + 1;
      }
    }
    return conteo;
  }
}