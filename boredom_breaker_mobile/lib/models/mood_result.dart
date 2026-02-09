class MoodResult {
  final String mood;
  final String emotion;
  final double intensity;

  MoodResult({required this.mood, required this.emotion, required this.intensity});

  factory MoodResult.fromJson(Map<String, dynamic> json) {
    return MoodResult(
      mood: json['mood'] ?? 'neutral',
      emotion: json['emotion'] ?? 'neutral',
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PlanItem {
  final String type;
  final String description;
  final int timeMinutes;

  PlanItem({required this.type, required this.description, required this.timeMinutes});

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? '',
      timeMinutes: json['time_minutes'] ?? 0,
    );
  }
}
