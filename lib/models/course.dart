class Course {
  final String id;
  final String userId;
  final String name;
  final String lecturer;
  final int sks;
  final String day;
  final String time;

  Course({
    required this.id,
    required this.userId,
    required this.name,
    required this.lecturer,
    required this.sks,
    required this.day,
    required this.time,
  });

  factory Course.fromMap(Map<String, dynamic> map) => Course(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        lecturer: map['lecturer'] as String,
        sks: (map['sks'] as num).toInt(),
        day: map['day'] as String,
        time: map['time'] as String,
      );

  Map<String, dynamic> toInsertMap() => {
        'user_id': userId,
        'name': name,
        'lecturer': lecturer,
        'sks': sks,
        'day': day,
        'time': time,
      };

  Map<String, dynamic> toUpdateMap() => {
        'name': name,
        'lecturer': lecturer,
        'sks': sks,
        'day': day,
        'time': time,
      };
}
