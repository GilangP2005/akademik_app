import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';
import 'app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tjljaircqhmgbgaiupxc.supabase.co',
    anonKey: 'sb_publishable_YkDsGsqijB9MuWIGUkkZuw_CGx9T6Zb',
  );

  runApp(const AkademikApp());
}

class AkademikApp extends StatelessWidget {
  const AkademikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akademik App',
      debugShowCheckedModeBanner: false,

      // ⬇️ PENTING: hapus warna putih / hitam default
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
