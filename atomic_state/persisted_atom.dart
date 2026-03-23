// core/atomic_state/persisted_atom.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'async_atom.dart';
import 'result.dart';

// Duplicate key guard — debug mode only.
// Tracks all keys declared across the app lifetime.
// Never cleared — keys are permanent for the lifetime of the process.
final _registeredKeys = <String>{};

/// An [AsyncAtom] that automatically persists its state to SharedPreferences.
///
/// Extends [AsyncAtom] with two behaviours:
///   1. On construction, immediately loads cached data and emits [Success]
///      before any HTTP call or stream connects — the user sees content
///      on the first frame.
///   2. On every [Success] emit, auto-saves to disk (throttled by
///      [saveThrottle] to avoid hammering SharedPreferences on fast streams).
///
/// ## Declaration
///
/// Declare as a global variable alongside your controller, just like [AsyncAtom].
/// Every model used with [PersistedAtom] needs a `fromJsonToList` and
/// `toJsonList` static method — the same ones used by [APIRequest]:
///
/// ```dart
/// final deliveryStops = PersistedAtom<List<DeliveryStopModel>>(
///   key: 'delivery_stops',
///   fromJson: DeliveryStopModel.fromJsonToList,
///   toJson: DeliveryStopModel.toJsonList,
/// );
/// ```
///
/// ## Usage in the view
///
/// Identical to [AsyncAtom] — no changes needed in the widget tree:
///
/// ```dart
/// deliveryStops(
///   success: (stops) => StopsList(stops),
///   loading: StopsShimmer.new,
///   failure: (msg) => ErrorView(msg),
/// )
/// ```
///
/// ## Usage with streams
///
/// Works transparently with [listenTo] — every stream emission that reaches
/// [emit] is automatically saved to cache:
///
/// ```dart
/// deliveryStops.listenTo(
///   _service.stopsStream(),
///   onError: (_) async => deliveryStops.persistNow(), // flush before retry
/// );
/// ```
///
/// ## Offline behaviour
///
/// If the HTTP call fails but cached data is available, the atom stays in
/// [Success] — the screen keeps showing the last known state silently.
/// Pair with a global offline banner rather than per-screen stale logic.
///
/// ## Keys
///
/// Keys must be unique across the app. In debug mode, duplicate keys print
/// a warning to the console. Use a consistent naming convention:
///
/// ```dart
/// // feature_noun
/// 'delivery_stops'
/// 'user_profile'
/// 'notifications_list'
/// ```
///
/// ## Logout
///
/// [reset] clears both the in-memory state (back to [Idle]) and the cached
/// data on disk. Called automatically by [resetAllAtoms] — no manual wiring
/// needed.
class PersistedAtom<T> extends AsyncAtom<T> {
  /// The SharedPreferences key used to store this atom's value.
  /// Must be unique across the entire app.
  final String key;

  /// Deserialises the cached JSON back into [T].
  /// Use the same static method as your [APIRequest] adapter:
  /// `fromJson: MyModel.fromJsonToList`
  final T Function(dynamic json) fromJson;

  /// Serialises [T] into a JSON-encodable value for storage.
  /// Use the matching static method on your model:
  /// `toJson: MyModel.toJsonList`
  final dynamic Function(T value) toJson;

  /// Minimum time between automatic cache writes.
  /// Prevents SharedPreferences being called on every tick of a fast stream.
  /// Defaults to 30 seconds — reduce for data that must survive app kills
  /// more frequently, increase for high-frequency streams.
  final Duration saveThrottle;

  DateTime? _lastSave;

  PersistedAtom({
    required this.key,
    required this.fromJson,
    required this.toJson,
    this.saveThrottle = const Duration(seconds: 30),
  }) {
    assert(() {
      if (!_registeredKeys.add(key)) {
        debugPrint(
          '⚠️ PersistedAtom: duplicate key "$key" detected. '
          'Each PersistedAtom must have a unique key.',
        );
      }
      return true;
    }());
    _loadFromCache();
  }

  // ─── Cache hydration ──────────────────────────────────────────────────────

  /// Reads from SharedPreferences and emits [Success] if data exists.
  /// Called in the constructor — runs before init() or any HTTP call.
  /// Uses super.emit() directly to bypass _maybeSave — no point writing
  /// back to disk what we just read from it.
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return;
    try {
      super.emit(Success(fromJson(jsonDecode(raw))));
    } catch (_) {
      // Corrupt or unrecognised cache entry — silently ignore.
      // The next successful HTTP fetch or stream event will overwrite it.
    }
  }

  // ─── Auto-save ────────────────────────────────────────────────────────────

  /// Intercepts every emit. Triggers a throttled cache write for [Success].
  /// [Loading], [Failure], [Empty], and [Idle] states are never written to disk
  /// — only the last known good value is cached.
  @override
  void emit(Result<T> state) {
    super.emit(state);
    if (state is Success<T>) _maybeSave(state.value);
  }

  /// Writes to cache if outside the [saveThrottle] window.
  Future<void> _maybeSave(T value) async {
    final now = DateTime.now();
    final shouldSave = _lastSave == null || now.difference(_lastSave!) >= saveThrottle;
    if (!shouldSave) return;

    _lastSave = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(toJson(value)));
  }

  /// Forces an immediate cache write, bypassing the [saveThrottle] window.
  ///
  /// Call this in two situations:
  ///   1. App going to background — `AppLifecycleState.paused`
  ///   2. Stream disconnecting — inside `listenTo`'s `onError` callback
  ///
  /// This guarantees the latest merged state survives an app kill even if
  /// the throttle window hasn't elapsed yet.
  ///
  /// ```dart
  /// deliveryStops.listenTo(
  ///   deltaStream,
  ///   onError: (_) async {
  ///     await deliveryStops.persistNow();
  ///     // then retry...
  ///   },
  /// );
  /// ```
  Future<void> persistNow() async {
    final current = value;
    if (current is! Success<T>) return;
    _lastSave = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(toJson(current.value)));
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Clears cached data from disk and resets the atom to [Idle].
  /// Called automatically by [resetAllAtoms] on logout — ensures no data
  /// from a previous user session leaks into the next.
  @override
  void reset() {
    SharedPreferences.getInstance().then((prefs) => prefs.remove(key));
    super.reset(); // cancelStream() + emit(Idle())
  }
}
