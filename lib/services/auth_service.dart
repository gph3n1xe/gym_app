import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> register(
      String email,
      String password,
      String firstName,
      String lastName,
      ) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "theme": "dark",
        "createdAt": Timestamp.now(),
      });

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future<User?> login(
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }
}