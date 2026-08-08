import 'dart:convert';

import '../models/custom_symptom.dart';
import '../models/daily_log_entry.dart';
import '../models/journal_entry.dart';
import '../models/period_log.dart';
import '../models/profile.dart';

/// Versioned on-device backup payload (`format: ritu.backup`).
class RituBackup {
  const RituBackup({
    required this.version,
    required this.exportedAt,
    this.profile,
    this.periodLogs = const [],
    this.dailyLogs = const [],
    this.journalEntries = const [],
    this.customSymptoms = const [],
  });

  static const formatId = 'ritu.backup';
  static const currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final Profile? profile;
  final List<PeriodLog> periodLogs;
  final List<DailyLogEntry> dailyLogs;
  final List<JournalEntry> journalEntries;
  final List<CustomSymptom> customSymptoms;

  Map<String, Object?> toJson() {
    return {
      'format': formatId,
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      if (profile != null) 'profile': _profileToJson(profile!),
      if (periodLogs.isNotEmpty)
        'periodLogs': periodLogs.map(_periodToJson).toList(),
      if (dailyLogs.isNotEmpty)
        'dailyLogs': dailyLogs.map(_dailyLogToJson).toList(),
      if (journalEntries.isNotEmpty)
        'journalEntries': journalEntries.map(_journalToJson).toList(),
      if (customSymptoms.isNotEmpty)
        'customSymptoms': customSymptoms.map(_symptomToJson).toList(),
    };
  }

  String encodePretty() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  static RituBackup decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup root must be a JSON object');
    }
    return fromJson(decoded);
  }

  static RituBackup fromJson(Map<String, dynamic> json) {
    final format = json['format'];
    if (format != formatId) {
      throw FormatException(
        'Unsupported backup format: expected "$formatId", got "$format"',
      );
    }

    final version = json['version'];
    if (version is! int || version < 1 || version > currentVersion) {
      throw FormatException('Unsupported backup version: $version');
    }

    final exportedAtRaw = json['exportedAt'];
    if (exportedAtRaw is! String) {
      throw const FormatException('Missing exportedAt');
    }
    final exportedAt = DateTime.parse(exportedAtRaw);

    return RituBackup(
      version: version,
      exportedAt: exportedAt,
      profile: json['profile'] == null
          ? null
          : _profileFromJson(_asMap(json['profile'], 'profile')),
      periodLogs: _mapList(json['periodLogs'], 'periodLogs', _periodFromJson),
      dailyLogs: _mapList(json['dailyLogs'], 'dailyLogs', _dailyLogFromJson),
      journalEntries: _mapList(
        json['journalEntries'],
        'journalEntries',
        _journalFromJson,
      ),
      customSymptoms: _mapList(
        json['customSymptoms'],
        'customSymptoms',
        _symptomFromJson,
      ),
    );
  }
}

Map<String, Object?> _profileToJson(Profile profile) => {
      'displayName': profile.displayName,
      'createdAt': profile.createdAt.toIso8601String(),
      'onboardingCompletedAt':
          profile.onboardingCompletedAt?.toIso8601String(),
      'typicalPeriodDays': profile.typicalPeriodDays,
    };

Profile _profileFromJson(Map<String, dynamic> json) {
  return Profile(
    displayName: _requireString(json, 'displayName'),
    createdAt: _requireDate(json, 'createdAt'),
    onboardingCompletedAt: _optionalDate(json, 'onboardingCompletedAt'),
    typicalPeriodDays: json['typicalPeriodDays'] as int?,
  );
}

Map<String, Object?> _periodToJson(PeriodLog log) => {
      'startedOn': log.startedOn.toIso8601String(),
      'endedOn': log.endedOn?.toIso8601String(),
      'source': log.source,
      'createdAt': log.createdAt.toIso8601String(),
      'updatedAt': log.updatedAt.toIso8601String(),
    };

PeriodLog _periodFromJson(Map<String, dynamic> json) {
  return PeriodLog(
    id: 0,
    startedOn: _requireDate(json, 'startedOn'),
    endedOn: _optionalDate(json, 'endedOn'),
    source: _requireString(json, 'source'),
    createdAt: _requireDate(json, 'createdAt'),
    updatedAt: _requireDate(json, 'updatedAt'),
  );
}

Map<String, Object?> _dailyLogToJson(DailyLogEntry entry) => {
      'loggedOn': entry.loggedOn.toIso8601String(),
      'flowIntensity': entry.flowIntensity,
      'crampIntensity': entry.crampIntensity,
      'moods': entry.moods,
      'energyLevel': entry.energyLevel,
      'sleepQuality': entry.sleepQuality,
      'wellbeing': entry.wellbeing,
      'symptoms': entry.symptoms,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
    };

DailyLogEntry _dailyLogFromJson(Map<String, dynamic> json) {
  return DailyLogEntry(
    id: 0,
    loggedOn: _requireDate(json, 'loggedOn'),
    flowIntensity: json['flowIntensity'] as String?,
    crampIntensity: json['crampIntensity'] as int?,
    moods: _stringList(json['moods']),
    energyLevel: json['energyLevel'] as String?,
    sleepQuality: json['sleepQuality'] as String?,
    wellbeing: json['wellbeing'] as int?,
    symptoms: _stringList(json['symptoms']),
    createdAt: _requireDate(json, 'createdAt'),
    updatedAt: _requireDate(json, 'updatedAt'),
  );
}

Map<String, Object?> _journalToJson(JournalEntry entry) => {
      'loggedOn': entry.loggedOn.toIso8601String(),
      'body': entry.body,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
    };

JournalEntry _journalFromJson(Map<String, dynamic> json) {
  return JournalEntry(
    id: 0,
    loggedOn: _requireDate(json, 'loggedOn'),
    body: _requireString(json, 'body'),
    createdAt: _requireDate(json, 'createdAt'),
    updatedAt: _requireDate(json, 'updatedAt'),
  );
}

Map<String, Object?> _symptomToJson(CustomSymptom symptom) => {
      'name': symptom.name,
      'createdAt': symptom.createdAt.toIso8601String(),
    };

CustomSymptom _symptomFromJson(Map<String, dynamic> json) {
  return CustomSymptom(
    id: 0,
    name: _requireString(json, 'name'),
    createdAt: _requireDate(json, 'createdAt'),
  );
}

List<T> _mapList<T>(
  Object? raw,
  String field,
  T Function(Map<String, dynamic>) map,
) {
  if (raw == null) return <T>[];
  if (raw is! List) {
    throw FormatException('$field must be a list');
  }
  return raw
      .map((item) => map(_asMap(item, field)))
      .toList();
}

Map<String, dynamic> _asMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  throw FormatException('$field entries must be objects');
}

List<String> _stringList(Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) return const [];
  return raw.map((e) => e.toString()).toList();
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Missing or invalid $key');
  }
  return value;
}

DateTime _requireDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Missing or invalid $key');
  }
  return DateTime.parse(value);
}

DateTime? _optionalDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Invalid $key');
  }
  return DateTime.parse(value);
}
