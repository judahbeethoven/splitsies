import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsService {
  static const _upiKey = 'settings_upi_id';
  static const _nameKey = 'settings_display_name';

  final _upiId = BehaviorSubject<String>.seeded('');
  final _displayName = BehaviorSubject<String>.seeded('You');

  Stream<String> get upiId$ => _upiId.stream;
  String get upiId => _upiId.value;
  bool get hasUpiId => upiId.trim().isNotEmpty;

  Stream<String> get displayName$ => _displayName.stream;
  String get displayName => _displayName.value;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _upiId.add(prefs.getString(_upiKey) ?? '');
    _displayName.add(prefs.getString(_nameKey) ?? 'You');
  }

  Future<void> setUpiId(String value) async {
    final cleaned = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_upiKey, cleaned);
    _upiId.add(cleaned);
  }

  Future<void> setDisplayName(String value) async {
    final cleaned = value.trim().isEmpty ? 'You' : value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, cleaned);
    _displayName.add(cleaned);
  }

  void dispose() {
    _upiId.close();
    _displayName.close();
  }
}
