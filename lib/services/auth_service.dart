import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<User?> register(
      String email,
      String password,
      String username,
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
        "username": username,
        "email": email,
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