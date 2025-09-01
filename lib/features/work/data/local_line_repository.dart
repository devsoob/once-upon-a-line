import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalLineRepository {
  LocalLineRepository(this._prefs);

  static const String _kLinesKey = 'lines';
  static const String _kLastWriteEpochMsKey = 'last_write_epoch_ms';

  final SharedPreferences _prefs;

  Future<List<String>> getLines() async {
    final String? jsonString = _prefs.getString(_kLinesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <String>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((dynamic e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> saveLine(String line) async {
    final List<String> lines = await getLines();
    lines.add(line);
    await _prefs.setString(_kLinesKey, json.encode(lines));
    await _prefs.setInt(_kLastWriteEpochMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastWriteAt() async {
    final int? epochMs = _prefs.getInt(_kLastWriteEpochMsKey);
    if (epochMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  Future<bool> canWriteNow() async {
    final DateTime? last = await getLastWriteAt();
    if (last == null) return true;
    final DateTime now = DateTime.now();
    return now.difference(last).inHours >= 24 ||
        (now.day != last.day || now.month != last.month || now.year != last.year);
  }
}
