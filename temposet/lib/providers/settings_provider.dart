import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user settings (metronome tone, haptic, background play, etc.)
/// Settings auto-save on every change — no manual save needed.
class SettingsProvider extends ChangeNotifier {
  static const _keyTone = 'metronome_tone';
  static const _keyHaptic = 'haptic_feedback';
  static const _keyBackground = 'background_play';
  static const _keyScreenOn = 'screen_always_on';

  bool _backgroundPlay = true;
  bool _screenAlwaysOn = false;

  bool get backgroundPlay => _backgroundPlay;
  bool get screenAlwaysOn => _screenAlwaysOn;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _backgroundPlay = prefs.getBool(_keyBackground) ?? true;
    _screenAlwaysOn = prefs.getBool(_keyScreenOn) ?? false;
    notifyListeners();
  }

  void setBackgroundPlay(bool value) {
    _backgroundPlay = value;
    notifyListeners();
    _save();
  }

  void setScreenAlwaysOn(bool value) {
    _screenAlwaysOn = value;
    notifyListeners();
    _save();
  }

  /// Auto-save all settings immediately on change.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBackground, _backgroundPlay);
    await prefs.setBool(_keyScreenOn, _screenAlwaysOn);
  }
}
