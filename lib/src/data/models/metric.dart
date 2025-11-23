// lib/src/models/metric.dart
class Metric {
  final String name;
  double value;
  final String unit;
  String status; // 'normal', 'low', 'high'
  final String range;
  List<double> history;
  List<DateTime> timestamps;

  Metric({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.range,
    List<double>? history,
    List<DateTime>? timestamps,
  }) : history = history ?? [],
       timestamps = timestamps ?? [];

  /// Create from JSON (supports old format without timestamps)
  factory Metric.fromJson(Map<String, dynamic> j) {
    final now = DateTime.now();

    final historyList =
        (j['history'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList();

    final parsedTimestamps = <DateTime>[];

    // Handle timestamps if they exist (backward compatible)
    if (j['timestamps'] != null && j['timestamps'] is List) {
      parsedTimestamps.addAll(
        (j['timestamps'] as List).map((t) {
          if (t is String) {
            try {
              return DateTime.parse(t);
            } catch (_) {
              return now;
            }
          } else if (t is int) {
            return DateTime.fromMillisecondsSinceEpoch(t);
          }
          return now;
        }),
      );
    }

    // If timestamps are missing or their count doesn't match history,
    // fill remaining entries with the same "now" to ensure consistent dates
    if (parsedTimestamps.length != historyList.length) {
      parsedTimestamps
        ..clear()
        ..addAll(List<DateTime>.filled(historyList.length, now));
    }

    return Metric(
      name: j['name'] as String,
      value: (j['value'] as num).toDouble(),
      unit: j['unit'] as String,
      status: (j['status'] as String? ?? 'normal').toLowerCase(),
      range: j['range'] as String,
      history: historyList,
      timestamps: parsedTimestamps,
    );
  }

  /// Convert to JSON (now includes timestamps)
  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'status': status,
    'range': range,
    'history': history,
    'timestamps': timestamps.map((t) => t.toIso8601String()).toList(),
  };

  /// Immutable copy with optional overrides
  Metric copyWith({
    String? name,
    double? value,
    String? unit,
    String? status,
    String? range,
    List<double>? history,
    List<DateTime>? timestamps,
  }) {
    return Metric(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      range: range ?? this.range,
      history: history ?? List<double>.from(this.history),
      timestamps: timestamps ?? List<DateTime>.from(this.timestamps),
    );
  }

  @override
  String toString() {
    return 'Metric{name: $name, value: $value, status: $status, historyCount: ${history.length}, timestampsCount: ${timestamps.length}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metric &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value &&
          status == other.status &&
          history.length == other.history.length &&
          timestamps.length == other.timestamps.length;

  @override
  int get hashCode =>
      name.hashCode ^
      value.hashCode ^
      status.hashCode ^
      history.hashCode ^
      timestamps.hashCode;
}
