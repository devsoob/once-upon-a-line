import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SentenceDto {
  SentenceDto({required this.workId, required this.content, required this.epochMs});

  final String workId;
  final String content;
  final int epochMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workId': workId,
    'content': content,
    'epochMs': epochMs,
  };

  static SentenceDto fromJson(Map<String, dynamic> json) => SentenceDto(
    workId: json['workId'] as String,
    content: json['content'] as String,
    epochMs: (json['epochMs'] as num).toInt(),
  );
}

abstract class SentencesRepository {
  Future<List<SentenceDto>> getSentences(String workId);
  Future<void> addSentence({required String workId, required String content});
  Future<DateTime?> getLastWriteAt();
}

class LocalSentencesRepository implements SentencesRepository {
  LocalSentencesRepository(this._prefs);

  static const String _kSentencesKey = 'sentences_v2';
  static const String _kLastWriteEpochMsKey = 'last_write_epoch_ms';

  final SharedPreferences _prefs;

  Future<List<SentenceDto>> _getAll() async {
    final String? jsonString = _prefs.getString(_kSentencesKey);
    if (jsonString == null || jsonString.isEmpty) return <SentenceDto>[];
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.whereType<Map<String, dynamic>>().map(SentenceDto.fromJson).toList();
    } catch (_) {
      return <SentenceDto>[];
    }
  }

  Future<void> _saveAll(List<SentenceDto> all) async {
    await _prefs.setString(
      _kSentencesKey,
      json.encode(all.map((SentenceDto e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<SentenceDto>> getSentences(String workId) async {
    final List<SentenceDto> all = await _getAll();
    all.sort((SentenceDto a, SentenceDto b) => a.epochMs.compareTo(b.epochMs));
    return all.where((SentenceDto s) => s.workId == workId).toList();
  }

  @override
  Future<void> addSentence({required String workId, required String content}) async {
    final List<SentenceDto> all = await _getAll();
    all.add(
      SentenceDto(workId: workId, content: content, epochMs: DateTime.now().millisecondsSinceEpoch),
    );
    await _saveAll(all);
    await _prefs.setInt(_kLastWriteEpochMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<DateTime?> getLastWriteAt() async {
    final int? epochMs = _prefs.getInt(_kLastWriteEpochMsKey);
    if (epochMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }
}
