import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDataHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new message to the group collaboration collection
  Future<void> addMessage(String message) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('group_collaboration').add({
        'userName': user.displayName ?? "Anonymous",
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Fetch all messages from the group collaboration collection
  Stream<List<Map<String, dynamic>>> getMessages() {
    return _firestore
        .collection('group_collaboration')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'userName': doc['userName'],
                'message': doc['message'],
                'timestamp': doc['timestamp'],
              };
            }).toList());
  }
}
