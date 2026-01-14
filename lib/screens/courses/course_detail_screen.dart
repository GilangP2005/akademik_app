import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/primary_button.dart';

/// ===============================
/// ✅ DETAIL MATKUL (WAJIB ADA)
/// ===============================
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _sb = Supabase.instance.client;

  Map<String, dynamic> course = {};
  bool deleting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    course = (args is Map) ? args.cast<String, dynamic>() : <String, dynamic>{};
    setState(() {});
  }

  Future<void> _deleteCourse() async {
    final id = course['id'];
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Matkul?'),
        content: const Text('Data matkul akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => deleting = true);
    try {
      await _sb.from('courses').delete().eq('id', id);
      if (!mounted) return;
      Navigator.pop(context, true); // refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus matkul: $e')));
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  Future<void> _editCourse() async {
    final res = await Navigator.pushNamed(
      context,
      AppRoutes.courseForm,
      arguments: course,
    );
    if (res == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (course['name'] ?? '-').toString();
    final lecturer = (course['lecturer'] ?? '-').toString();
    final room = (course['room'] ?? '-').toString();
    final day = (course['day'] ?? '-').toString();
    final time = (course['time'] ?? '-').toString();
    final sks = (course['sks'] ?? '-').toString();

    return GradientScaffold(
      title: const Text('Detail Matkul'),
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: deleting ? null : _editCourse,
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          tooltip: 'Hapus',
          onPressed: deleting ? null : _deleteCourse,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    _row('Dosen', lecturer),
                    _row('SKS', sks),
                    _row('Ruangan', room),
                    _row('Hari', day),
                    _row('Jam', time),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: deleting ? 'Menghapus...' : 'Hapus Matkul',
                      onTap: deleting ? null : _deleteCourse,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

/// ===============================
/// ✅ DETAIL & EDIT ABSENSI (biar route attendanceDetail aman)
/// ===============================
class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  final _sb = Supabase.instance.client;

  bool saving = false;

  late Map<String, dynamic> row;
  late TextEditingController noteC;
  String status = 'Hadir';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    row = (args is Map) ? args.cast<String, dynamic>() : <String, dynamic>{};

    noteC = TextEditingController(text: (row['note'] ?? '').toString());
    status = (row['status'] ?? 'Hadir').toString();
    setState(() {});
  }

  @override
  void dispose() {
    noteC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = row['id'];
    if (id == null) return;

    setState(() => saving = true);
    try {
      await _sb.from('attendances').update({
        'status': status,
        'note': noteC.text.trim(),
      }).eq('id', id);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseName = (row['courses'] is Map ? (row['courses']['name'] ?? '-') : '-')?.toString() ?? '-';

    return GradientScaffold(
      title: const Text('Detail Absensi'),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: const [
                        DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                        DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                        DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                        DropdownMenuItem(value: 'Alpha', child: Text('Alpha')),
                      ],
                      onChanged: saving ? null : (v) => setState(() => status = v ?? 'Hadir'),
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteC,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Catatan', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(text: saving ? 'Menyimpan...' : 'Simpan', onTap: saving ? null : _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
