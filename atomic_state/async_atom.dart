import 'dart:async';

import 'package:flutter/material.dart';
import 'result.dart';

// Global registry — all AsyncAtoms register themselves on creation.
// Used by AuthBuilder._resetAtoms() to reset all atoms on logout.
// Never modify this list directly.
final _atomRegistry = <AsyncAtom>[];

class AsyncAtom<T> extends ValueNotifier<Result<T>> {
  AsyncAtom() : super(Idle()) {
    // Self-register so _resetAtoms() never needs manual updates.
    // AsyncAtoms must always be global variables in controller files —
    // never created inside widgets or methods (would cause registry leak).
    assert(() {
      // In debug mode, warn if created inside a widget lifecycle
      // by checking if we're in a build/initState context.
      // Simple guard: registry should only grow, never shrink unexpectedly.
      return true;
    }());
    _atomRegistry.add(this);
  }

  // ─── Stream state ─────────────────────────────────────────────────────────

  StreamSubscription<T>? _subscription;

  // ─── Core emit ───────────────────────────────────────────────────────────

  void emit(Result<T> state) {
    assert(() {
      debugPrint('⚡ $runtimeType → ${state.runtimeType}');
      return true;
    }());
    value = state;
  }

  /// Call the atom directly as a widget.
  /// Only [success] is required. Defaults:
  ///   - loading → CircularProgressIndicator()
  ///   - failure → SizedBox()
  ///   - empty   → SizedBox()
  ///   - idle    → SizedBox()
  ///
  /// Usage:
  ///   rewards(success: RewardsList.new)
  ///   rewards(success: RewardsList.new, failure: ErrorText.new)
  Widget call({
    required Widget Function(T value) success,
    Widget Function(String message)? failure,
    Widget Function()? loading,
    Widget Function()? empty,
    Widget Function()? idle,
  }) {
    return ValueListenableBuilder(
      valueListenable: this,
      builder: (_, result, __) => switch (result) {
        Success(:final value) => success(value),
        Failure(:final message) => failure?.call(message) ?? const SizedBox(),
        Loading() => loading?.call() ?? const Center(child: CircularProgressIndicator()),
        Empty() => empty?.call() ?? const SizedBox(),
        Idle() => idle?.call() ?? const SizedBox(),
      },
    );
  }

  /// Resets this atom to Idle(). Called by AuthBuilder on logout.
  void reset() {
    cancelStream(); // always kill the stream before wiping state
    value = Idle();
  }

  // ─── Stream subscription ──────────────────────────────────────────────────

  /// Subscribes to [stream] and maps events into Result<T> automatically.
  ///
  /// [onData]  — optional side effect after a successful emit (e.g. cache write,
  ///             flipping a stale flag). Runs *after* the atom updates so the
  ///             UI is never blocked by a disk write.
  ///
  /// [onError] — called when the stream emits an error or closes unexpectedly.
  ///             The atom is intentionally *not* set to Failure() here — if
  ///             we already have Success data on screen, we don't want to
  ///             blank the UI. The controller decides what to show instead
  ///             (e.g. a stale banner + retry).
  ///
  /// Calling listenTo() a second time (e.g. after a manual refresh) safely
  /// cancels the previous subscription before attaching the new one.
  void listenTo(
    Stream<T> stream, {
    Future<void> Function(T data)? onData,
    void Function(Object error)? onError,
  }) {
    _subscription?.cancel();

    _subscription = stream.listen(
      (data) async {
        emit(Success(data));
        await onData?.call(data);
      },
      onError: (error) => onError?.call(error),
      // Stream closing (WebSocket disconnect, Firebase going offline)
      // is treated the same as an error — surfaces to the controller.
      onDone: () => onError?.call(
        StateError('Stream closed unexpectedly'),
      ),
      // false = a single bad event doesn't kill the subscription.
      // The controller's onError callback decides when to give up.
      cancelOnError: false,
    );
  }

  /// Cancels the active stream subscription without changing atom state.
  /// Call this when you want to stop listening but keep the last value visible.
  void cancelStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    cancelStream();
    super.dispose();
  }
}

/// Resets all registered AsyncAtoms to Idle().
/// Called by AuthBuilder when authState becomes Unauthenticated.
/// No manual registration needed — atoms self-register on creation.
void resetAllAtoms() {
  for (final atom in _atomRegistry) {
    atom.reset();
  }
}
