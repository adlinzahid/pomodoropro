import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pomodoro_pro/models/user_model.dart';

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
      print(e);
    }

    return retVal;
  }

  Future<UserModel> getUserInfo(String uid) async {
    UserModel retVal = UserModel(
        uid: '', email: '', fullName: '', accountCreated: Timestamp.now());

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("users").doc(uid).get();
      retVal.uid = uid;
      retVal.fullName = _docSnapshot.get('fullName');
      retVal.email = _docSnapshot.get('email');
      retVal.accountCreated = _docSnapshot.get('accountCreated');
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
