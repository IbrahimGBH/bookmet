import 'package:bookmet/registrarse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Auth{
  Auth();
  Future<UserCredential?> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(context, MaterialPageRoute(builder: (context) => PagRegistro()));
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
}
