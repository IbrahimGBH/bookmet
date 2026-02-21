import 'package:flutter/material.dart';
import 'editar_perfil.dart.'; // Importamos tu nueva pantalla

void main() {
  runApp(const BookmetApp());
}

class BookmetApp extends StatelessWidget {
  const BookmetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmet Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Usamos un color semilla naranja, similar al de tu diseño
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE59254)),
        useMaterial3: true,
      ),
      // Aquí establecemos EditProfileScreen como la pantalla de inicio
      home: const EditProfileScreen(),
    );
  }
}