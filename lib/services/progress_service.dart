import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // 💾 SAVE PROGRESS
  Future<void> saveProgress({
    required String exercise,
    required double weight,
    required int reps,
  }) async {
    if (uid == null) return;

    await _db
        .collection("users")
        .doc(uid)
        .collection("progress")
        .doc(exercise)
        .set({
      "lastWeight": weight,
      "lastReps": reps,
      "updatedAt": Timestamp.now(),
    });
  }

  // 📥 GET LAST WEIGHT
  Future<double> getLastWeight(String exercise) async {
    if (uid == null) return 0;

    final doc = await _db
        .collection("users")
        .doc(uid)
        .collection("progress")
        .doc(exercise)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?["lastWeight"] ?? 0).toDouble();
  }
}