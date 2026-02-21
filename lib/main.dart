import 'package:flutter/material.dart';
import 'home_screen.dart'; 

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        fontFamily: 'Inter', 
      ),

      home: HomeScreen(), 
    );
  }
}