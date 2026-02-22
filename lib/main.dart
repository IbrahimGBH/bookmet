// import 'package:flutter/material.dart';

// void main() {
//   runApp(const BookmetApp());
// }

// class BookmetApp extends StatelessWidget {
//   const BookmetApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bookmet Marketplace',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
//         useMaterial3: true,
//       ),
//       home: const Scaffold(
//         body: Center(
//           child: Text(
//             'Hito 1: Bookmet Configurado\nListo para desarrollo',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:bookmet/inicio_sesion.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'BookMet',
      theme: ThemeData(
        primarySwatch: Colors.orange, 
        useMaterial3: true,
        fontFamily: 'Inter', 
      ),

      home: HomeScreen(), 
    );
  }
}