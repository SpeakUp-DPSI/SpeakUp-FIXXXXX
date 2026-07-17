import 'package:supabase_flutter/supabase_flutter.dart';
void main() {
  final supabase = SupabaseClient('url', 'key');
  final q = supabase.from('reports').select();
  print(q.runtimeType);
}
