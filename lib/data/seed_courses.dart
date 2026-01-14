import 'package:supabase_flutter/supabase_flutter.dart';

class SeedCourses {
  static final List<Map<String, dynamic>> _defaults = [
    {
      'name': 'Pemrograman Mobile',
      'lecturer': 'Budi Santoso, S.Kom., M.Kom.',
      'sks': 3,
      'day': 'Senin',
      'time': '08:00 - 10:30',
      'room': 'Lab Komputer 1',
    },
    {
      'name': 'Basis Data',
      'lecturer': 'Sari Wulandari, S.Kom., M.Kom.',
      'sks': 3,
      'day': 'Selasa',
      'time': '10:00 - 12:30',
      'room': 'Ruang 203',
    },
    {
      'name': 'Pemrograman Berorientasi Objek',
      'lecturer': 'Andi Pratama, S.Kom., M.T.',
      'sks': 3,
      'day': 'Rabu',
      'time': '13:00 - 15:30',
      'room': 'Ruang 105',
    },
    {
      'name': 'Rekayasa Perangkat Lunak',
      'lecturer': 'Dewi Anggraini, S.T., M.Kom.',
      'sks': 3,
      'day': 'Kamis',
      'time': '08:00 - 10:30',
      'room': 'Ruang 302',
    },
    {
      'name': 'Jaringan Komputer',
      'lecturer': 'Rizky Mahendra, S.Kom., M.T.',
      'sks': 2,
      'day': 'Jumat',
      'time': '09:00 - 10:40',
      'room': 'Lab Jaringan',
    },
    {
      'name': 'Kecerdasan Buatan',
      'lecturer': 'Nabila Putri, S.Kom., M.Cs.',
      'sks': 3,
      'day': 'Jumat',
      'time': '13:00 - 15:30',
      'room': 'Ruang 201',
    },
  ];

  static SupabaseClient get _sb => Supabase.instance.client;

  /// Insert default courses untuk user yang sedang login jika masih kosong.
  static Future<void> ensureDefaultForCurrentUser() async {
    final user = _sb.auth.currentUser;
    if (user == null) return;

    // Cek apakah sudah ada course untuk user ini
    final existing = await _safeSelectExisting(user.id);
    if (existing == true) return;

    // Coba beberapa skema kolom yang umum, supaya aman walau nama kolom beda
    final payloadVariants = _buildPayloadVariants(user.id);

    for (final payload in payloadVariants) {
      try {
        await _sb.from('courses').insert(payload);
        return;
      } catch (_) {
        // coba variant berikutnya
      }
    }
  }

  static Future<bool?> _safeSelectExisting(String uid) async {
    // Coba cek dengan user_id, kalau tabel kamu memang filter per user
    try {
      final res = await _sb.from('courses').select('id').eq('user_id', uid).limit(1);
      if (res is List) return res.isNotEmpty;
      return null;
    } catch (_) {
      // Kalau schema tidak ada user_id, fallback cek tanpa filter
      try {
        final res = await _sb.from('courses').select('id').limit(1);
        if (res is List) return res.isNotEmpty;
        return null;
      } catch (_) {
        return null;
      }
    }
  }

  /// Build beberapa kemungkinan payload supaya gak error kalau nama kolom beda.
  static List<List<Map<String, dynamic>>> _buildPayloadVariants(String uid) {
    // Variant A (paling ideal): name + lecturer + sks + day + time + room + user_id
    final a = _defaults.map((e) {
      return {
        'user_id': uid,
        'name': e['name'],
        'lecturer': e['lecturer'],
        'sks': e['sks'],
        'day': e['day'],
        'time': e['time'],
        'room': e['room'],
      };
    }).toList();

    // Variant B: name + dosen + sks + hari + jam + ruang + user_id (nama kolom indo)
    final b = _defaults.map((e) {
      return {
        'user_id': uid,
        'name': e['name'],
        'dosen': e['lecturer'],
        'sks': e['sks'],
        'hari': e['day'],
        'jam': e['time'],
        'ruang': e['room'],
      };
    }).toList();

    // Variant C: minimal aman (kalau tabel cuma punya name + user_id)
    final c = _defaults.map((e) {
      return {
        'user_id': uid,
        'name': e['name'],
      };
    }).toList();

    // Variant D: tanpa user_id (kalau tabel kamu tidak pakai user_id)
    final d = _defaults.map((e) {
      return {
        'name': e['name'],
        'lecturer': e['lecturer'],
        'sks': e['sks'],
        'day': e['day'],
        'time': e['time'],
        'room': e['room'],
      };
    }).toList();

    // Variant E: minimal tanpa user_id
    final e = _defaults.map((x) => {'name': x['name']}).toList();

    return [a, b, c, d, e];
  }
}
