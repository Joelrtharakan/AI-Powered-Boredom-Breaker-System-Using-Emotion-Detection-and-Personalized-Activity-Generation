import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/session_manager.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<dynamic>>>((ref) {
      return HistoryNotifier();
    });

class HistoryNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
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

      // Ensure we have a list
      final List<dynamic> history = response.data is List ? response.data : [];
      state = AsyncValue.data(history);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
