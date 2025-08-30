import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WorkDto {
  WorkDto({required this.id, required this.title, required this.createdAtEpochMs});

  final String id;
  final String title;
  final int createdAtEpochMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'createdAt': createdAtEpochMs,
  };

  static WorkDto fromJson(Map<String, dynamic> json) => WorkDto(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAtEpochMs: (json['createdAt'] as num).toInt(),
  );
}

abstract class WorksRepository {
  Future<List<WorkDto>> getWorks();
  Future<WorkDto> createWork({required String title});
  Future<void> deleteWork(String workId);
}

class LocalWorksRepository implements WorksRepository {
  LocalWorksRepository(this._prefs);

  static const String _kWorksKey = 'works_v2';

  final SharedPreferences _prefs;

  @override
  Future<List<WorkDto>> getWorks() async {
    final String? jsonString = _prefs.getString(_kWorksKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <WorkDto>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.whereType<Map<String, dynamic>>().map(WorkDto.fromJson).toList();
    } catch (_) {
      return <WorkDto>[];
    }
  }

  Future<void> _saveWorks(List<WorkDto> works) async {
    await _prefs.setString(_kWorksKey, json.encode(works.map((WorkDto e) => e.toJson()).toList()));
  }

  String _generateWorkId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<WorkDto> createWork({required String title}) async {
    final List<WorkDto> works = await getWorks();
    final WorkDto work = WorkDto(
      id: _generateWorkId(),
      title: title,
      createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    works.add(work);
    await _saveWorks(works);
    return work;
  }

  @override
  Future<void> deleteWork(String workId) async {
    final List<WorkDto> works = await getWorks();
    works.removeWhere((WorkDto w) => w.id == workId);
    await _saveWorks(works);
  }
}
