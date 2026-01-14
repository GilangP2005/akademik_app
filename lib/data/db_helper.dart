import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get user => client.auth.currentUser;

  static String get userId {
    final u = user;
    if (u == null) throw Exception("User belum login");
    return u.id;
  }
}
