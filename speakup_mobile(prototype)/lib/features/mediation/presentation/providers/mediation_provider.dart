import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/mediation_remote_data_source.dart';
import '../../data/models/mediation_model.dart';

final mediationRemoteDataSourceProvider = Provider<MediationRemoteDataSource>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return MediationRemoteDataSource(supabaseClient);
});

final myMediationsProvider = FutureProvider<List<MediationModel>>((ref) async {
  final dataSource = ref.read(mediationRemoteDataSourceProvider);
  return dataSource.getMyMediations();
});
