import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/follow_up_remote_data_source.dart';

final followUpRemoteDataSourceProvider = Provider<FollowUpRemoteDataSource>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return FollowUpRemoteDataSource(supabaseClient);
});
