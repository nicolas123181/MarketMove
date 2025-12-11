import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, int>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<int> {
  static const _keyLowStockThreshold = 'low_stock_threshold';

  @override
  int build() {
    _loadSettings();
    return 5; // Default value
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_keyLowStockThreshold) ?? 5;
  }

  Future<void> setLowStockThreshold(int value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLowStockThreshold, value);
  }
}
