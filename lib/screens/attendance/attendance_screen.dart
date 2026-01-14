import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_routes.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/app_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _sb = Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>> all = [];
  List<Map<String, dynamic>> filtered = [];

  final TextEditingController _q = TextEditingController();

  String _status = 'Semua';
  int _range = 0; // 0=Semua, 7, 30, 31(bulan ini)

  @override
  void initState() {
    super.initState();
    _load();
    _q.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _q.removeListener(_applyFilter);
    _q.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await _sb
          .from('attendances')
          .select('id,status,note,date,course_id,courses(name)')
          .order('date', ascending: false);

      all = (res as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      _applyFilter();

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load kehadiran: $e')),
      );
    }
  }

  void _applyFilter() {
    final q = _q.text.trim().toLowerCase();

    DateTime? from;
    final now = DateTime.now();

    if (_range == 7) {
      from = now.subtract(const Duration(days: 7));
    } else if (_range == 30) {
      from = now.subtract(const Duration(days: 30));
    } else if (_range == 31) {
      from = DateTime(now.year, now.month, 1);
    }

    filtered = all.where((row) {
      final status = (row['status'] ?? '').toString();
      final note = (row['note'] ?? '').toString();
      final date = (row['date'] ?? '').toString();
      final courseName = (row['courses'] is Map)
          ? (((row['courses'] as Map)['name'])?.toString() ?? '')
          : '';

      // status filter
      if (_status != 'Semua' && status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }

      // range filter
      if (from != null) {
        final d = DateTime.tryParse(date);
        if (d == null) return false;
        if (d.isBefore(from)) return false;
      }

      // query filter
      if (q.isEmpty) return true;
      final hay = '$courseName $status $note $date'.toLowerCase();
      return hay.contains(q);
    }).toList();

    if (mounted) setState(() {});
  }

  void _reset() {
    _q.clear();
    _status = 'Semua';
    _range = 0;
    _applyFilter();
  }

  Future<void> _goAdd() async {
    final res = await Navigator.pushNamed(
      context,
      AppRoutes.attendanceForm,
      arguments: null,
    );
    if (res == true) _load();
  }

  Future<void> _goEdit(Map<String, dynamic> row) async {
    final res = await Navigator.pushNamed(
      context,
      AppRoutes.attendanceForm,
      arguments: row, // kirim row untuk edit
    );
    if (res == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: const Text('Kehadiran'),
      actions: [
        IconButton(
          tooltip: 'Reload',
          onPressed: _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
              children: [
                _filters(),
                const SizedBox(height: 12),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  _empty()
                else
                  ...filtered.map(_item),
              ],
            ),

            // FAB manual (karena GradientScaffold gak punya floatingActionButton:)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _goAdd,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _q,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search matkul / status / catatan / tanggal',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.filter_alt, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                      DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                      DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                      DropdownMenuItem(value: 'Alpha', child: Text('Alpha')),
                    ],
                    onChanged: (v) {
                      _status = v ?? 'Semua';
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _seg(
                  label: 'Semua',
                  active: _range == 0,
                  onTap: () {
                    _range = 0;
                    _applyFilter();
                  },
                ),
                _seg(
                  label: '7 hari',
                  active: _range == 7,
                  onTap: () {
                    _range = 7;
                    _applyFilter();
                  },
                ),
                _seg(
                  label: '30 hari',
                  active: _range == 30,
                  onTap: () {
                    _range = 30;
                    _applyFilter();
                  },
                ),
                _seg(
                  label: 'Bulan ini',
                  active: _range == 31,
                  onTap: () {
                    _range = 31;
                    _applyFilter();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Filter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _item(Map<String, dynamic> row) {
    final courseName = (row['courses'] is Map)
        ? (((row['courses'] as Map)['name'])?.toString() ?? '-')
        : '-';
    final status = (row['status'] ?? '-').toString();
    final date = (row['date'] ?? '').toString();
    final note = (row['note'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: ListTile(
          title: Text(
            courseName,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            '$status • $date${note.isEmpty ? '' : '\n$note'}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
          trailing: const Icon(Icons.chevron_right,
              color: Colors.white54),
          // Detail & edit: buka form screen dengan arguments row
          onTap: () => _goEdit(row),
        ),
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.white54),
            SizedBox(height: 12),
            Text(
              'Tidak ada data yang cocok',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 6),
            Text(
              'Coba ubah filter atau kata kunci.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
