import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> saveUserWorkout(String userId, String workoutType) async {
    await _db.collection('user_workouts').add({
      'userId': userId,
      'type': workoutType,
      'timestamp': Timestamp.now(),
    });
  }
  Future<void> addWorkout(String name) async {
    await _db.collection('workouts').add({
      'name': name,
      'createdAt': Timestamp.now(),
    });
  }
  Stream<QuerySnapshot> getWorkouts() {
    return _db.collection('workouts').snapshots();
  }
  Future<void> deleteWorkout(String id) async {
    await _db.collection('workouts').doc(id).delete();
  }
}
