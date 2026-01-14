import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_routes.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/app_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _ByCourseTmp {
  final String courseName;
  int total = 0;
  int hadir = 0;

  _ByCourseTmp({required this.courseName});
}

class AttendanceChartData {
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final List<_ByCourseTmp> byCourse;

  const AttendanceChartData({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.byCourse,
  });
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _sb = Supabase.instance.client;

  bool loading = true;

  int totalCourses = 0;
  int totalAttendance = 0;

  AttendanceChartData chartData = const AttendanceChartData(
    hadir: 0,
    izin: 0,
    sakit: 0,
    alpha: 0,
    byCourse: [],
  );

  List<Map<String, dynamic>> recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final courseRows = await _sb.from('courses').select('id').order('name');
      final attRows = await _sb
          .from('attendances')
          .select('id,status,date,course_id,courses(name)')
          .order('date', ascending: false);

      totalCourses = (courseRows as List).length;
      totalAttendance = (attRows as List).length;

      int hadir = 0, izin = 0, sakit = 0, alpha = 0;

      final byCourseMap = <String, _ByCourseTmp>{};

      for (final raw in (attRows as List)) {
        final m = (raw as Map).cast<String, dynamic>();
        final status = (m['status'] ?? '').toString().toLowerCase().trim();

        if (status == 'hadir') hadir++;
        if (status == 'izin') izin++;
        if (status == 'sakit') sakit++;
        if (status == 'alpha') alpha++;

        final courseName = (m['courses'] is Map)
            ? (((m['courses'] as Map)['name'])?.toString() ?? '-')
            : '-';

        final key = courseName.isEmpty ? '-' : courseName;
        byCourseMap.putIfAbsent(key, () => _ByCourseTmp(courseName: key));
        byCourseMap[key]!.total++;
        if (status == 'hadir') byCourseMap[key]!.hadir++;
      }

      final byCourse = byCourseMap.values.toList()
        ..sort((a, b) => b.total.compareTo(a.total));

      chartData = AttendanceChartData(
        hadir: hadir,
        izin: izin,
        sakit: sakit,
        alpha: alpha,
        byCourse: byCourse.take(5).toList(),
      );

      recent = (attRows as List)
          .take(8)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load dashboard: $e')),
      );
    }
  }

  void _go(String route) => Navigator.pushNamed(context, route);

  double _w(bool isWide, double wide, double narrow) => isWide ? wide : narrow;

  @override
  Widget build(BuildContext context) {
    final email = _sb.auth.currentUser?.email ?? '-';

    return GradientScaffold(
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          tooltip: 'Reload',
          onPressed: _load,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Profil',
          onPressed: () => _go(AppRoutes.profile),
          icon: const Icon(Icons.person),
        ),
      ],
      child: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;

                  final int total = chartData.hadir +
                      chartData.izin +
                      chartData.sakit +
                      chartData.alpha;

                  final double hadirP =
                      total == 0 ? 0 : (chartData.hadir / total) * 100.0;
                  final double izinP =
                      total == 0 ? 0 : (chartData.izin / total) * 100.0;
                  final double sakitP =
                      total == 0 ? 0 : (chartData.sakit / total) * 100.0;
                  final double alphaP =
                      total == 0 ? 0 : (chartData.alpha / total) * 100.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: _w(isWide, 520, double.infinity),
                                  child: AppCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Selamat datang 👋',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  email,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.80),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.10),
                                            child: const Icon(Icons.person),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _w(isWide, 250, double.infinity),
                                  child: _statCard(
                                    icon: Icons.menu_book,
                                    title: 'Total Matkul',
                                    value: totalCourses.toString(),
                                  ),
                                ),
                                SizedBox(
                                  width: _w(isWide, 250, double.infinity),
                                  child: _statCard(
                                    icon: Icons.fact_check,
                                    title: 'Total Kehadiran',
                                    value: totalAttendance.toString(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: _w(isWide, 380, double.infinity),
                                  child: _quickActions(isWide: isWide),
                                ),
                                SizedBox(
                                  width: _w(isWide, 700, double.infinity),
                                  child: AppCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Statistik Persentase Kehadiran',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Hadir: ${chartData.hadir} dari $total (${hadirP.toStringAsFixed(1)}%)',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            child: LinearProgressIndicator(
                                              value: total == 0
                                                  ? 0
                                                  : (chartData.hadir / total),
                                              minHeight: 10,
                                              backgroundColor: Colors.white
                                                  .withValues(alpha: 0.10),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              _pill('Izin: ${chartData.izin}'),
                                              _pill('Sakit: ${chartData.sakit}'),
                                              _pill('Alpha: ${chartData.alpha}'),
                                              _pill('${hadirP.toStringAsFixed(1)}%'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: _w(isWide, 540, double.infinity),
                                  child: AppCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ringkasan Kehadiran',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (total == 0)
                                            Text(
                                              'Belum ada data',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.80),
                                              ),
                                            )
                                          else
                                            Column(
                                              children: [
                                                _legendRow('Hadir', chartData.hadir,
                                                    hadirP.toDouble()),
                                                _legendRow('Izin', chartData.izin,
                                                    izinP.toDouble()),
                                                _legendRow('Sakit', chartData.sakit,
                                                    sakitP.toDouble()),
                                                _legendRow('Alpha', chartData.alpha,
                                                    alphaP.toDouble()),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _w(isWide, 540, double.infinity),
                                  child: AppCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Aktivitas Terakhir',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (recent.isEmpty)
                                            Text(
                                              'Belum ada data absensi',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.80),
                                              ),
                                            )
                                          else
                                            ...recent.map(_recentTile),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions({required bool isWide}) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip('Matkul', Icons.menu_book, () => _go(AppRoutes.courses)),
                _chip('Absensi', Icons.checklist, () => _go(AppRoutes.attendance)),
                _chip('Tambah Absensi', Icons.add, () => _go(AppRoutes.attendanceForm)),
                _chip('Profil', Icons.person, () => _go(AppRoutes.profile)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _legendRow(String label, int value, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
          Text('$value', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              '${percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTile(Map<String, dynamic> row) {
    final courseName = (row['courses'] is Map)
        ? (((row['courses'] as Map)['name'])?.toString() ?? '-')
        : '-';
    final status = (row['status'] ?? '-').toString();
    final date = (row['date'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: ListTile(
          title: Text(courseName, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(
            '$status • $date',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
        ),
      ),
    );
  }
}
