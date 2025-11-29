import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/shared_preferences_service.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferencesService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesService(prefs);
});
