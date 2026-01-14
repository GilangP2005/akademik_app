import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/app_card.dart';

class AttendanceFormScreen extends StatefulWidget {
  const AttendanceFormScreen({super.key});

  @override
  State<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  SupabaseClient get _client => Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String? editingId;

  String? selectedCourseId;
  DateTime selectedDate = DateTime.now();
  String? selectedStatus; // dibuat nullable supaya validator jalan
  final noteC = TextEditingController();

  List<Map<String, dynamic>> courses = [];
  final statuses = const ['Hadir', 'Izin', 'Sakit', 'Alpha'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Map) {
        final m = arg.cast<String, dynamic>();
        editingId = m['id']?.toString();
        selectedCourseId = m['course_id']?.toString();
        selectedStatus = (m['status'] ?? 'Hadir').toString();
        noteC.text = (m['note'] ?? '').toString();

        final rawDate = m['date']?.toString();
        final parsed = DateTime.tryParse(rawDate ?? '');
        if (parsed != null) selectedDate = parsed;
      } else {
        selectedStatus = 'Hadir';
      }

      _loadCourses();
      setState(() {});
    });
  }

  @override
  void dispose() {
    noteC.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final res = await _client
          .from('courses')
          .select('id,name')
          .eq('user_id', uid)
          .order('name');

      final list = (res as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      if (!mounted) return;
      setState(() => courses = list);

      // Auto set matkul pertama kalau belum kepilih (UX)
      if ((selectedCourseId == null || selectedCourseId!.isEmpty) &&
          courses.isNotEmpty) {
        setState(() => selectedCourseId = courses.first['id'].toString());
      }
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    if (loading) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => selectedDate = picked);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green.withValues(alpha: 0.85) : null,
      ),
    );
  }

  Future<void> _save() async {
    // cegah double click
    if (loading) return;

    // VALIDASI FORM
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (selectedCourseId == null || selectedCourseId!.isEmpty) {
      _showSnack('Pilih matkul dulu sebelum simpan.');
      return;
    }
    if (selectedStatus == null || selectedStatus!.isEmpty) {
      _showSnack('Pilih status dulu sebelum simpan.');
      return;
    }

    setState(() => loading = true);

    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw 'User belum login';

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final note = noteC.text.trim();

      final payload = {
        'user_id': uid,
        'course_id': selectedCourseId,
        'date': dateStr,
        'status': selectedStatus,
        'note': note.isEmpty ? null : note,
      };

      if (editingId == null) {
        await _client.from('attendance').insert(payload);
        _showSnack('✅ Kehadiran berhasil ditambahkan', success: true);
      } else {
        await _client.from('attendance').update(payload).eq('id', editingId!);
        _showSnack('✅ Kehadiran berhasil diperbarui', success: true);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal simpan: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editingId != null;

    return GradientScaffold(
      title: Text(isEdit ? 'Edit Kehadiran' : 'Tambah Kehadiran'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Matkul',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCourseId,
                      items: courses
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c['id'].toString(),
                              child: Text(
                                c['name'].toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: loading
                          ? null
                          : (v) => setState(() => selectedCourseId = v),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Matkul wajib dipilih';
                        return null;
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0x14FFFFFF),
                        border: OutlineInputBorder(),
                        hintText: 'Pilih matkul',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: loading ? null : _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0x14FFFFFF),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('yyyy-MM-dd').format(selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              loading ? '...' : 'Pilih',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: loading
                          ? null
                          : (v) => setState(() => selectedStatus = v),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Status wajib dipilih';
                        return null;
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0x14FFFFFF),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Catatan (opsional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteC,
                      maxLines: 3,
                      enabled: !loading,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0x14FFFFFF),
                        border: OutlineInputBorder(),
                        hintText: 'Misal: telat, izin keluarga, dsb',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : () async => _save(),
                        icon: Icon(loading ? Icons.hourglass_top : Icons.save),
                        label: Text(loading ? 'Menyimpan...' : 'Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
