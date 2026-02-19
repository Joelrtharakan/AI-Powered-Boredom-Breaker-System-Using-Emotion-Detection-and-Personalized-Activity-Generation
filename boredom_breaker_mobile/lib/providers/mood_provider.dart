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

      // 1.5 Log Mood for History
      await _api.post(
        '/mood/log',
        data: {
          'mood': moodData.data['mood'],
          'emotion': moodData.data['emotion'],
          'intensity': moodData.data['intensity'],
          'energy_level': moodData.data['energy_level'],
          'source': 'text',
          'activities_used': [],
        },
        queryParameters: {'user_id': userId},
      );

      final moodRes = moodData.data;

      // 2. Get Suggestion Plan (Calls Planner Agent)
      // Send FULL text for risk assessment
      final planRes = await _api.post(
        '/suggest/',
        data: {
          'user_id': userId,
          'mood': moodRes['mood'],
          'emotion': moodRes['emotion'],
          'intensity': moodRes['intensity'],
          'time_available_minutes': 30,
          'text': text, // CRITICAL: Send raw text for risk analysis
        },
      );

      // Parse plan items manually to verify data structure
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
