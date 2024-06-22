import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A future builder with app defaults.
///
/// This allows to have the same loading style everywhere in the app.
class ConsistentFutureBuilder<T> extends StatefulWidget {
  /// Create a future builder with app defaults.
  const ConsistentFutureBuilder({
    super.key,
    required this.future,
    this.onNotStarted,
    this.onWaiting,
    required this.onData,
    this.cacheFuture = false,
    this.lastChildWhileWaiting = false,
  });

  /// Future that gets evaluated.
  final Future<T> future;

  /// The build strategy once the future loaded.
  final Widget Function(BuildContext context, T result) onData;

  /// The text displayed when no future is connected.
  ///
  /// This case should generally be avoided and is protected by assertions in
  /// debug builds.
  ///
  /// Is a 'not started' text by default.
  final Widget? onNotStarted;

  /// The future loading indicator.
  ///
  /// Shown while the element is loading. Defaults to 'loading... text'.
  final Widget? onWaiting;

  /// Internally save the future and avoid rebuilds.
  ///
  /// Caching will allow the future builder not to load again in some cases
  /// where a rebuild is triggered. But it comes at the cost that onData will
  /// not be called again, even if data changed.
  ///
  /// The parameter is false by default and should only be set to true when
  /// rebuilds are disruptive to the user and it is certain that the data will
  /// not change over the lifetime of the screen.
  final bool cacheFuture;

  /// When loading the next result the child that got build the last time will
  /// be returned.
  ///
  /// During the first build, [onWaiting] os respected instead.
  final bool lastChildWhileWaiting;

  @override
  State<ConsistentFutureBuilder<T>> createState() =>
      _ConsistentFutureBuilderState<T>();
}

class _ConsistentFutureBuilderState<T>
    extends State<ConsistentFutureBuilder<T>> {
  Future<T>? _future; // avoid rebuilds
  /// Used for returning the last child during load when rebuilding.
  Widget? _lastChild;

  @override
  void initState() {
    super.initState();
    if (widget.cacheFuture) {
      _future = widget.future;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future ?? widget.future,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
      // Might get called before localizations initialize.
      final localizations = AppLocalizations.of(context);
      if (snapshot.hasError) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(localizations?.error(snapshot.error.toString())
              ?? snapshot.error.toString(),),
        );
      }
      switch (snapshot.connectionState) {
        case ConnectionState.none:
          assert(false);
          return widget.onNotStarted ?? Text(localizations?.errNotStarted
              ?? 'NO_LOC_NO_START: please report this error.',);
        case ConnectionState.waiting:
        case ConnectionState.active:
          if (widget.lastChildWhileWaiting && _lastChild != null) {
            return _lastChild!;
          }
          return widget.onWaiting ?? Text(localizations?.loading
              ?? 'loading...',);
        case ConnectionState.done:
          _lastChild = widget.onData(context, snapshot.data as T);
          return _lastChild!;
      }
    },
  );
}
