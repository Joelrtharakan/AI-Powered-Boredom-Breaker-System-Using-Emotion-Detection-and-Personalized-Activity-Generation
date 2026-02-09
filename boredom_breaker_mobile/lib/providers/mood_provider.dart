import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../models/mood_result.dart'; 

final moodProvider = StateNotifierProvider<MoodNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return MoodNotifier();
});

class MoodNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  // Use the API Client
  final _api = ApiClient().client;

  MoodNotifier() : super(const AsyncValue.data({}));

  Future<void> analyzeMood(String text, int userId) async {
    state = const AsyncValue.loading();
    try {
      // 1. Detect Mood (Calls run_emotion_ai)
      final moodRes = await _api.post('/mood/detect', data: {'text': text});
      final moodData = moodRes.data;

      // 2. Get Suggestion Plan (Calls Planner Agent)
      final planRes = await _api.post('/suggest/', data: {
        'user_id': userId,
        'mood': moodData['mood'],
        'emotion': moodData['emotion'],
        'intensity': moodData['intensity'],
        'time_available_minutes': 30
      });

      // Parse plan items manually to verify data structure
      List<dynamic> plan = [];
      if (planRes.data['plan'] is List) {
          plan = planRes.data['plan'];
      }

      state = AsyncValue.data({
        'mood': moodData,
        'plan': plan
      });
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
