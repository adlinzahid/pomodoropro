import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class OurDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel> streamUser(String uid) {
    return _firestore.collection("users").doc(uid).snapshots().map((doc) {
      return UserModel.fromFirebaseUser(doc.data() as User);
    });
  }

  Future<String> createUser(UserModel user) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").doc(user.uid).set({
        'fullName': user.fullName,
        'email': user.email,
        'accountCreated': Timestamp.now(),
      });

      retVal = "success";
    } catch (e) {
      log(e.toString());
    }

    return retVal;
  }

  Future<UserModel> getUserInfo(String uid) async {
    UserModel retVal = UserModel(
        uid: '', email: '', fullName: '', accountCreated: Timestamp.now());

    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection("users").doc(uid).get();
      retVal.uid = uid;
      retVal.fullName = docSnapshot.get('fullName');
      retVal.email = docSnapshot.get('email');
      retVal.accountCreated = docSnapshot.get('accountCreated');
    } catch (e) {
      log(e.toString());
    }
    return retVal;
  }
}
