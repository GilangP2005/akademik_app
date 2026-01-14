import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:akademik_app/data/seed_courses.dart';
import '../../app_routes.dart';
import '../../widgets/app_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _sb = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> all = [];
  List<Map<String, dynamic>> filtered = [];

  final _searchC = TextEditingController();
  String _selectedLecturer = 'Semua';

  @override
  void initState() {
    super.initState();
    _init();
    _searchC.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchC.removeListener(_applyFilters);
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => loading = true);
    try {
      await SeedCourses.ensureDefaultForCurrentUser();
    } catch (_) {}
    await _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final uid = _sb.auth.currentUser?.id;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          all = [];
          filtered = [];
          loading = false;
        });
        return;
      }

      final res = await _sb
          .from('courses')
          .select('id,name,lecturer,day,time,room,created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      all = (res as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      _applyFilters();

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load matkul: $e')),
      );
    }
  }

  void _applyFilters() {
    final q = _searchC.text.trim().toLowerCase();

    List<Map<String, dynamic>> temp = List.from(all);

    if (_selectedLecturer != 'Semua') {
      temp = temp
          .where((c) =>
              (c['lecturer'] ?? '').toString().trim() == _selectedLecturer)
          .toList();
    }

    if (q.isNotEmpty) {
      temp = temp.where((c) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        final lect = (c['lecturer'] ?? '').toString().toLowerCase();
        final day = (c['day'] ?? '').toString().toLowerCase();
        final room = (c['room'] ?? '').toString().toLowerCase();
        return name.contains(q) ||
            lect.contains(q) ||
            day.contains(q) ||
            room.contains(q);
      }).toList();
    }

    if (!mounted) return;
    setState(() => filtered = temp);
  }

  List<String> _lecturerOptions() {
    final set = <String>{};
    for (final c in all) {
      final v = (c['lecturer'] ?? '').toString().trim();
      if (v.isNotEmpty) set.add(v);
    }
    final list = set.toList()..sort();
    return ['Semua', ...list];
  }

  void _goDetail(Map<String, dynamic> course) {
    Navigator.pushNamed(
      context,
      AppRoutes.courseDetail,
      arguments: course,
    ).then((_) => _load());
  }

  void _goAdd() {
    Navigator.pushNamed(context, AppRoutes.courseForm).then((_) => _load());
  }

  void _goEdit(Map<String, dynamic> course) {
    Navigator.pushNamed(
      context,
      AppRoutes.courseForm,
      arguments: course,
    ).then((_) => _load());
  }

  Future<void> _delete(Map<String, dynamic> course) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Matkul'),
        content: Text('Yakin hapus "${course['name'] ?? '-'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _sb.from('courses').delete().eq('id', course['id']);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lecturerOptions = _lecturerOptions();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Matkul'),
        actions: [
          IconButton(
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goAdd,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1C1B5E),
              Color(0xFF1E4BB8),
              Color(0xFF21A6FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
              children: [
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cari & Filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0x14FFFFFF),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.white),
                            hintText: 'Cari matkul / dosen / hari / ruangan...',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0x14FFFFFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: lecturerOptions.contains(
                                            _selectedLecturer)
                                        ? _selectedLecturer
                                        : 'Semua',
                                    dropdownColor: const Color(0xFF1E2B7A),
                                    iconEnabledColor: Colors.white,
                                    items: lecturerOptions
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() => _selectedLecturer = v);
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLecturer = 'Semua';
                                  _searchC.clear();
                                });
                                _applyFilters();
                              },
                              icon:
                                  const Icon(Icons.clear, color: Colors.white),
                              tooltip: 'Reset',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Total: ${filtered.length} matkul',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _goAdd,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Tambah',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filtered.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        all.isEmpty
                            ? 'Belum ada data matkul.\nTekan + untuk menambah.'
                            : 'Tidak ada hasil untuk filter saat ini.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                  )
                else
                  ...filtered.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _goDetail(c),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0x14FFFFFF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.book,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (c['name'] ?? '-').toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Dosen: ${(c['lecturer'] ?? '-').toString()}',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 8,
                                          children: [
                                            _chipInfo(
                                                Icons.today,
                                                (c['day'] ?? '-').toString(),
                                                context),
                                            _chipInfo(
                                                Icons.access_time,
                                                (c['time'] ?? '-').toString(),
                                                context),
                                            _chipInfo(
                                                Icons.room,
                                                (c['room'] ?? '-').toString(),
                                                context),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    iconColor: Colors.white,
                                    onSelected: (v) {
                                      if (v == 'edit') _goEdit(c);
                                      if (v == 'delete') _delete(c);
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(
                                          value: 'delete', child: Text('Hapus')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipInfo(IconData icon, String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}
