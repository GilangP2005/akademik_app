import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/gradient_scaffold.dart';
import '../app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sb = Supabase.instance.client;
  int _index = 0;

  final _pages = const [
    Center(child: Text('Dashboard')),
    Center(child: Text('Matkul')),
    Center(child: Text('Kehadiran')),
    Center(child: Text('Profil')),
  ];

  Future<void> _logout() async {
    await _sb.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: const Text('Akademik App'),
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: _logout,
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _pages[_index],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          selectedIndex: _index,
          onDestinationSelected: (v) => setState(() => _index = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book),
              label: 'Matkul',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check),
              label: 'Kehadiran',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
