// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class Auth {
  final TextEditingController emailController = TextEditingController();
  final _auth =
      FirebaseAuth.instance; // Create an instance of the FirebaseAuth class

//create user with email and password
  Future<User?> createUserWithEmailAndPassword(String email, String password,
      String fullName, BuildContext context) async {
    try {
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        log('Email, password or full name is empty');
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error in signing up', textAlign: TextAlign.center),
                content: Text('Email, password or full name is empty'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
        return null;
      }
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
    } catch (e) {
      //check if email is already registered
      if (e.toString().contains('email-already-in-use')) {
        log('Email already in use');
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Error in signing up',
                  textAlign: TextAlign.center,
                ),
                content: Text('Email is already being used by another account'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      } //check if password is less than 6 characters
      else if (e.toString().contains('weak-password')) {
        log('Password is too weak');
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error in signing up', textAlign: TextAlign.center),
                content: Text(
                    'Password is too weak, must be at least 6 characters and contain a number'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      } else {
        log('Error in creating user: $e'); // Log the error
      }
      return null;
    }
  }

  //sign in user with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        log('Email or password is empty');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error', textAlign: TextAlign.center),
              content: Text('Email or password is empty'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return null;
      }

      final creds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } catch (e) {
      //check if email is registered
      if (!e.toString().contains('no user record')) {
        log('Error in signing in: $e'); // Log the error
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error', textAlign: TextAlign.center),
              content: Text('Invalid email or password'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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

  //sign in with google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _auth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code); // Log the error
    }
    return null;
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
