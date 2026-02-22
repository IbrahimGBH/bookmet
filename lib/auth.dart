import 'package:bookmet/admin_view.dart';
import 'package:bookmet/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  Auth();
  final FirebaseAuth fAuth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      bool esAdmin = await isAdmin(getUid());
      if(esAdmin==false){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      )
      ;}else{
              Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminView()),
              );
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //vacío
      } else if (e.code == 'wrong-password') {
        //vacío
      }
      return null;
    }
  }

  bool chequearUsuario(){
    final User? usuario = fAuth.currentUser;
    if(usuario==null){
      return false;
    }else{
      return true;
    }
  }

  String getUid(){
    final User? usuario = fAuth.currentUser;
    if(usuario != null){
      return usuario.uid;
    }else{
      return "No se ha iniciado sesión";
    }
  }

  Future<String> getNombre(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['nombre'];
      return campo;
    } else {
      return "";
    }
  }

   Future<String> getCarnet(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['carnet_id'];
      return campo;
    } else {
      return "";
    }
  }

   Future<String> getApellido(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['apellido'];
      return campo;
    } else {
      return "";
    }
  }

 Future<String> getCarrera(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['carrera'];
      return campo;
    } else {
      return "";
    }
  }

   Future<String> getPaypal(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['correo_paypal'];
      return campo;
    } else {
      return "";
    }
  }

   Future<String> getWhatsapp(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String campo = data?['link_whatsapp'];
      return campo;
    } else {
      return "";
    }
  }

    Future<bool> isAdmin(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (docSnapshot.data() != null && docSnapshot.data()!.containsKey('admin')) {
      Map<String, dynamic>? data = docSnapshot.data();
      bool campo = data?['admin'];
      return campo;
    } else {
      return false;
    }
  }
}
