import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/session_manager.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      return HistoryNotifier();
    });

class HistoryNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final _api = ApiClient().client;

  HistoryNotifier() : super(const AsyncValue.loading()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final userId = await SessionManager.getUserId() ?? 1;
      final response = await _api.get(
        '/mood/history',
        queryParameters: {'user_id': userId},
      );

      if (response.data is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          response.data as Map,
        );
        if (mounted) state = AsyncValue.data(data);
      } else {
        if (mounted) state = const AsyncValue.data({'items': [], 'total': 0});
      }
    } catch (e, stack) {
      if (mounted) state = AsyncValue.error(e, stack);
    }
  }
}
