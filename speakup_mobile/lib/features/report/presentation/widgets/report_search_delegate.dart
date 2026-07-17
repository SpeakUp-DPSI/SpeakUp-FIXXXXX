import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/report_provider.dart';

class ReportSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  ReportSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Ketik untuk mencari laporan...'));
    }

    ref.read(reportSearchProvider.notifier).search(query);

    return Consumer(
      builder: (context, ref, _) {
        final results = ref.watch(reportSearchProvider);
        
        if (results.isEmpty) {
          return const Center(child: Text('Tidak ada laporan ditemukan.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final report = results[index];
            return ListTile(
              title: Text(report.title),
              subtitle: Text(report.reportCode),
              leading: const Icon(Icons.description),
              onTap: () {
                close(context, null);
                context.push('/report/${report.id}');
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Ketik untuk mencari laporan...'));
    }

    ref.read(reportSearchProvider.notifier).search(query);

    return Consumer(
      builder: (context, ref, _) {
        final results = ref.watch(reportSearchProvider);
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final report = results[index];
            return ListTile(
              title: Text(report.title),
              subtitle: Text(report.reportCode),
              leading: const Icon(Icons.search, color: AppTheme.neutral400),
              onTap: () {
                query = report.title;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
