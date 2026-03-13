import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicLaunchData {
  final String title;
  final String url;
  MusicLaunchData({required this.title, required this.url});
}

final musicLaunchProvider = StateProvider<MusicLaunchData?>((ref) => null);
