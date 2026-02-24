import 'api_client.dart';
import 'session_manager.dart';

class GamesApi {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, int>> getHighScores() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return {};

      final response = await _apiClient.client.get('/games/scores/$userId');
      if (response.data != null && response.data is Map) {
        return Map<String, int>.from(
          response.data.map(
            (key, value) =>
                MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0),
          ),
        );
      }
      return {};
    } catch (e) {
      // ignore
      return {};
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getGlobalHighScores() async {
    try {
      final response = await _apiClient.client.get('/games/highscores/global');
      if (response.data != null && response.data is Map) {
        return Map<String, Map<String, dynamic>>.from(
          response.data.map((key, value) {
            final valMap = Map<String, dynamic>.from(value as Map);
            return MapEntry(key.toString(), valMap);
          }),
        );
      }
      return {};
    } catch (e) {
      // ignore
      return {};
    }
  }

  static Future<void> submitScore(String gameName, int score) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      await _apiClient.client.post(
        '/games/$gameName/submit',
        data: {
          'user_id': userId,
          'result': {'score': score},
        },
      );
    } catch (e) {
      print('Error submitting score for $gameName: $e');
    }
  }
}
