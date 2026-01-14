import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/app_card.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() =>
      _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  final _sb = Supabase.instance.client;

  late Map<String, dynamic> data;
  final _noteC = TextEditingController();
  String status = 'hadir';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    status = data['status'];
    _noteC.text = data['notes'] ?? '';
  }

  Future<void> _save() async {
    await _sb.from('attendances').update({
      'status': status,
      'notes': _noteC.text,
    }).eq('id', data['id']);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    await _sb.from('attendances').delete().eq('id', data['id']);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final course =
        (data['courses'] is Map) ? data['courses']['name'] : '-';

    return GradientScaffold(
      title: const Text('Detail Kehadiran'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _delete,
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                    DropdownMenuItem(value: 'izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                    DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
                  ],
                  onChanged: (v) => setState(() => status = v!),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _noteC,
                  decoration:
                      const InputDecoration(labelText: 'Catatan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
