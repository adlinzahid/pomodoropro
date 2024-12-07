import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  late String uid;
  String? email;
  late String fullName;
  late Timestamp accountCreated;

  UserModel({
    required this.uid,
    this.email,
    required this.fullName,
    required this.accountCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'accountCreated': accountCreated,
    };
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      fullName: '',
      accountCreated: Timestamp.fromDate(DateTime.now()),
    );
  }
}
