class Attendance {
  final String id;
  final String userId;
  final String courseId;
  final String date; // format: yyyy-MM-dd (sesuai yang kamu pakai)
  final String status; // Hadir / Izin / Sakit / Alpha(atau lainnya)
  final String? note;
  final String? courseName;

  const Attendance({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.date,
    required this.status,
    this.note,
    this.courseName,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    final courses = map['courses'];
    String? name;
    if (courses is Map) {
      name = courses['name']?.toString();
    }

    return Attendance(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      courseId: (map['course_id'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      note: map['note']?.toString(),
      courseName: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'date': date,
      'status': status,
      'note': note,
    };
  }

  Attendance copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? date,
    String? status,
    String? note,
    String? courseName,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      courseName: courseName ?? this.courseName,
    );
  }
}
