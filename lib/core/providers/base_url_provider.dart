import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

final baseUrlProvider = StateNotifierProvider<BaseUrlNotifier, String>((ref) {
  return BaseUrlNotifier();
});

class BaseUrlNotifier extends StateNotifier<String> {
  BaseUrlNotifier() : super(AppConstants.baseUrl) {
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(AppConstants.baseUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }

  Future<void> setBaseUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.baseUrlKey, trimmedUrl);
      state = trimmedUrl;
    }
  }
}
