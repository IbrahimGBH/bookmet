import 'package:bookmet/registrarse.dart';
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PagRegistro()),
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
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
}
