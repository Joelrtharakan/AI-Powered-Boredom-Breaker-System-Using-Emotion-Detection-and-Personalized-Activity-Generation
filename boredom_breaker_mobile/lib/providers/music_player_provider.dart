import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingMusic {
  final String title;
  final String url;

  PendingMusic({required this.title, required this.url});
}

final pendingMusicProvider = StateProvider<PendingMusic?>((ref) => null);
