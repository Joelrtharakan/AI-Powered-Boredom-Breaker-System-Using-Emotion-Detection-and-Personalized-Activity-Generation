import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'history_provider.dart';

final moodProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      return MoodNotifier(ref);
    });

class MoodNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref _ref;
  final _api = ApiClient().client;

  MoodNotifier(this._ref) : super(const AsyncValue.data({}));

  Future<void> analyzeMood(String text, int userId) async {
    state = const AsyncValue.loading();
    try {
      // TURBO MODE: Combined single-trip request for Emotion + Plan + Log
      // This collapses 3 sequential requests into 1 parallelized backend operation
      final response = await _api.post(
        '/mood/detect-and-plan',
        data: {'text': text, 'user_id': userId},
      );

      final data = response.data;
      final moodRes = data['mood'];
      final plan = data['plan'] as List<dynamic>;

      final ds = moodRes['decision_source'] ?? '';
      bool noEmotion =
          (ds == 'no_emotion_detected' || ds == 'neutral_override');

      state = AsyncValue.data({
        'mood': moodRes,
        'plan': plan,
        'no_emotion': noEmotion,
      });

      // TURBO SYNC: Force-refresh history so logs appear in real-time
      _ref.invalidate(historyProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> getSurprisePlan() async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.get('/suggest/surprise');
      // Wrap it in a plan-like structure our UI expects
      state = AsyncValue.data({
        'mood': {'mood': 'surprised', 'intensity': 1.0},
        'plan': res.data is List ? res.data : [res.data],
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data({});
  }
}
