import 'package:flutter/material.dart';

class AttendanceByCourse {
  final String course;
  final int hadir;
  final int total;

  AttendanceByCourse({
    required this.course,
    required this.hadir,
    required this.total,
  });

  double get percent => total == 0 ? 0 : hadir / total;
}

class AttendanceByCourseChart extends StatelessWidget {
  final List<AttendanceByCourse> data;

  const AttendanceByCourseChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data grafik',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map(_bar).toList(),
    );
  }

  Widget _bar(AttendanceByCourse d) {
    final pct = (d.percent * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${d.course} • $pct%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: d.percent,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
