class Workout {
  final String id;
  final String name;

  Workout({
    required this.id,
    required this.name,
  });

  factory Workout.fromMap(String id, Map<String, dynamic> data) {
    return Workout(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}