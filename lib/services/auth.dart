import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

//create user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await creds.user?.updateDisplayName(fullName);
      await creds.user?.reload();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(creds.user?.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'uid': creds.user?.uid,
        'createdAt': FieldValue.serverTimestamp()
      });
      return creds.user;
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code); // Log the error
    }
    return null;
  }

  //sign in user with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code); // Log the error
    }
    return null;
  }

  //sign out user

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error in signing out: $e"); // Log the error
    }
  }

  exceptionHandler(String code) {
    switch (code) {
      case 'email-already-in-use':
        log('Email already in use');
      case 'invalid-email':
        log('Invalid email');
      case 'user-not-found':
        log('User not found');
      case 'wrong-password':
        log('Wrong password');
      default:
        log('Something went wrong');
    }
  }
}
