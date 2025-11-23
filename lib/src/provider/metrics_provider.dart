import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/src/data/data_sample.dart' as sample;
import 'package:health_app/src/data/models/metric.dart';
import 'package:health_app/src/services/storage_service.dart';

final metricsNotifierProvider =
    StateNotifierProvider<MetricsNotifier, List<Metric>>((ref) {
      return MetricsNotifier();
    });

final userProvider = Provider<String?>(
  (ref) => ref.watch(
    metricsNotifierProvider.select(
      (list) => list.isNotEmpty ? 'Alex Chen' : null,
    ),
  ),
);

class MetricsNotifier extends StateNotifier<List<Metric>> {
  final StorageService _storage = StorageService();
  MetricsNotifier() : super([]);

  bool _loaded = false;

  // Called early from main to trigger load
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.readRawJson();
      if (raw == null) {
        // load sample
        final metrics =
            (sample.sampleJson['metrics'] as List)
                .map((e) => Metric.fromJson(e as Map<String, dynamic>))
                .toList();
        state = metrics;
        await _saveAll(metrics);
      } else {
        final metricsJson =
            (raw['metrics'] as List)
                .map((e) => Metric.fromJson(e as Map<String, dynamic>))
                .toList();
        state = metricsJson;
      }
    } catch (e) {
      // fallback to sample data on errors
      final metrics =
          (sample.sampleJson['metrics'] as List)
              .map((e) => Metric.fromJson(e as Map<String, dynamic>))
              .toList();
      state = metrics;
    }
    _loaded = true;
  }

  Future<void> _saveAll(List<Metric> metrics) async {
    final map = {
      'user': 'Alex Chen',
      'last_updated': DateTime.now().toIso8601String(),
      'metrics': metrics.map((m) => m.toJson()).toList(),
    };
    await _storage.saveRawJson(map);
  }

  Metric? getByName(String name) {
    try {
      return state.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> addReading(
    String name,
    double newValue, {
    DateTime? timestamp,
  }) async {
    final now =
        timestamp ?? DateTime.now(); // Allows manual timestamp if needed
    final idx = state.indexWhere((m) => m.name == name);
    if (idx == -1) return;

    final m = state[idx];

    // Update history and timestamps together
    final newHistory = List<double>.from(m.history)..add(newValue);
    final newTimestamps = List<DateTime>.from(m.timestamps)..add(now);

    String newStatus = m.status;

    // Recalculate status based on normal range
    try {
      final parts = m.range.split('-').map((s) => s.trim()).toList();
      if (parts.length == 2) {
        final low = double.tryParse(parts[0]) ?? -double.infinity;
        final high = double.tryParse(parts[1]) ?? double.infinity;
        newStatus =
            newValue < low
                ? 'low'
                : newValue > high
                ? 'high'
                : 'normal';
      }
    } catch (_) {}

    final updated = m.copyWith(
      value: newValue,
      history: newHistory,
      timestamps: newTimestamps,
      status: newStatus,
    );

    final newList = List<Metric>.from(state)..[idx] = updated;
    state = newList;

    await _saveAll(newList);
  }
}
