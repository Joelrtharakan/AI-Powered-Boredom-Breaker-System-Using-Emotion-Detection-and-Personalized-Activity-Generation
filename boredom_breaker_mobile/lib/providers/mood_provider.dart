import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

final moodProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      return MoodNotifier();
    });

class MoodNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  // Use the API Client
  final _api = ApiClient().client;

  MoodNotifier() : super(const AsyncValue.data({}));

  Future<void> analyzeMood(String text, int userId) async {
    state = const AsyncValue.loading();
    try {
      final moodData = await _api.post('/mood/detect', data: {'text': text});
      final moodRes = moodData.data;

      // If no emotion was detected, skip planner and show message
      if (moodRes['decision_source'] == 'no_emotion_detected') {
        state = AsyncValue.data({
          'mood': moodRes,
          'plan': <dynamic>[],
          'no_emotion': true,
        });
        return;
      }

      // Log Mood for History
      await _api.post(
        '/mood/log',
        data: {
          'mood': moodRes['mood'],
          'emotion': moodRes['emotion'],
          'intensity': moodRes['intensity'],
          'energy_level': moodRes['energy_level'],
          'source': 'text',
          'activities_used': [],
        },
        queryParameters: {'user_id': userId},
      );

      // Get Suggestion Plan (Calls Planner Agent)
      final planRes = await _api.post(
        '/suggest/',
        data: {
          'user_id': userId,
          'mood': moodRes['mood'],
          'emotion': moodRes['emotion'],
          'intensity': moodRes['intensity'],
          'time_available_minutes': 30,
          'text': text,
          'decision_source': moodRes['decision_source'] ?? '',
        },
      );

      List<dynamic> plan = [];
      if (planRes.data['plan'] is List) {
        plan = planRes.data['plan'];
      }

      state = AsyncValue.data({'mood': moodRes, 'plan': plan});
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
