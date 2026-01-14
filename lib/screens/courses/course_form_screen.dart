import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _sb = Supabase.instance.client;

  final _nameC = TextEditingController();
  final _lecturerC = TextEditingController();
  final _timeC = TextEditingController();

  bool loading = false;
  Map<String, dynamic>? editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      editing = args;
      _nameC.text = args['name'] ?? '';
      _lecturerC.text = args['lecturer'] ?? '';
      _timeC.text = args['time'] ?? '';
    }
  }

  Future<void> _save() async {
    if (_nameC.text.trim().isEmpty) return;

    setState(() => loading = true);
    try {
      if (editing == null) {
        await _sb.from('courses').insert({
          'name': _nameC.text.trim(),
          'lecturer': _lecturerC.text.trim(),
          'time': _timeC.text.trim(),
        });
      } else {
        await _sb.from('courses').update({
          'name': _nameC.text.trim(),
          'lecturer': _lecturerC.text.trim(),
          'time': _timeC.text.trim(),
        }).eq('id', editing!['id']);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _lecturerC.dispose();
    _timeC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editing != null;

    return GradientScaffold(
      title: Text(isEdit ? 'Edit Matkul' : 'Tambah Matkul'),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Matkul',
                    prefixIcon: Icon(Icons.book, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lecturerC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Dosen',
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _timeC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Jadwal / Jam',
                    prefixIcon:
                        Icon(Icons.access_time, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: loading
                ? 'Menyimpan...'
                : (isEdit ? 'Simpan Perubahan' : 'Simpan Matkul'),
            onTap: loading ? null : _save,
          ),
        ],
      ),
    );
  }
}
