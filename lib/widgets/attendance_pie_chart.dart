import 'package:flutter/material.dart';

class AttendancePieChart extends StatelessWidget {
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;

  const AttendancePieChart({
    super.key,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
  });

  int get total => hadir + izin + sakit + alpha;

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const Center(
        child: Text('Belum ada data', style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legend('Hadir', hadir, Colors.green),
        _legend('Izin', izin, Colors.orange),
        _legend('Sakit', sakit, Colors.blue),
        _legend('Alpha', alpha, Colors.red),
      ],
    );
  }

  Widget _legend(String label, int value, Color color) {
    final pct = ((value / total) * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value ($pct%)',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
