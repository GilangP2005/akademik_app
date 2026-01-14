import 'package:flutter/material.dart';

import 'package:akademik_app/widgets/app_card.dart';

class AttendanceByCourse {
  final String courseName;
  final int total;
  final int hadir;

  const AttendanceByCourse({
    required this.courseName,
    required this.total,
    required this.hadir,
  });

  double get percent => total <= 0 ? 0 : (hadir / total);
}

class AttendanceChartData {
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final List<AttendanceByCourse> byCourse;

  const AttendanceChartData({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.byCourse,
  });

  int get total => hadir + izin + sakit + alpha;

  double get hadirPercent => total <= 0 ? 0 : (hadir / total);
  double get izinPercent => total <= 0 ? 0 : (izin / total);
  double get sakitPercent => total <= 0 ? 0 : (sakit / total);
  double get alphaPercent => total <= 0 ? 0 : (alpha / total);
}

class AttendanceChartsCard extends StatelessWidget {
  final AttendanceChartData data;

  const AttendanceChartsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = data.total;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Persentase Kehadiran',
              style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hadir: ${data.hadir} dari $total (${(data.hadirPercent * 100).toStringAsFixed(1)}%)',
                    style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _pill(
                  context,
                  '${(data.hadirPercent * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: data.hadirPercent.clamp(0, 1),
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _pill(context, 'Izin: ${data.izin}'),
                _pill(context, 'Sakit: ${data.sakit}'),
                _pill(context, 'Alpha: ${data.alpha}'),
              ],
            ),

            if (data.byCourse.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Top Matkul (Hadir)',
                style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ...data.byCourse.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _courseRow(context, e),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _courseRow(BuildContext context, AttendanceByCourse e) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          e.courseName.isEmpty ? '-' : e.courseName,
          style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: e.percent.clamp(0, 1),
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.40),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${e.hadir}/${e.total}',
              style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pill(BuildContext context, String text) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        text,
        style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
