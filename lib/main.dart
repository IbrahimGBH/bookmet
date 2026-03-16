import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'inicio_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://bofmcwkspuxsevvvwqxw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvZm1jd2tzcHV4c2V2dnZ3cXh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwODc0OTYsImV4cCI6MjA4ODY2MzQ5Nn0.OZrYZ1a65N3IqAryWPXujJOOHoCgTDt5rvPghla-Cu4',
  );
  
  runApp(const BookmetApp());
}

class BookmetApp extends StatelessWidget {
  const BookmetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookmet',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),

      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return HomeScreen();
          }

          return const InicioSesion();
        },
      ),
    );
  }
}