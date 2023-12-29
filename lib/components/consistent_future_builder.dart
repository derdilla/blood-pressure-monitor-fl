import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsistentFutureBuilder<T> extends StatefulWidget {
  /// Future that gets evaluated.
  final Future<T> future;
  final Widget Function(BuildContext context, T result) onData;
  
  final Widget? onNotStarted;
  final Widget? onWaiting;
  final Widget? Function(BuildContext context, String errorMsg)? onError;

  /// Internally save the future and avoid rebuilds.
  ///
  /// Caching will allow the future builder not to load again in some cases where a rebuild is triggered. But it comes at
  /// the cost that onData will not be called again, even if data changed.
  ///
  /// The parameter is false by default and should only be set to true when rebuilds are disruptive to the user and it
  /// is certain that the data will not change over the lifetime of the screen.
  final bool cacheFuture;

  /// When loading the next result the child that got build the last time will be returned.
  ///
  /// During the first build, [onWaiting] os respected instead.
  final bool lastChildWhileWaiting;

  const ConsistentFutureBuilder({super.key, required this.future, this.onNotStarted, this.onWaiting, this.onError,
    required this.onData, this.cacheFuture = false, this.lastChildWhileWaiting = false});

  @override
  State<ConsistentFutureBuilder<T>> createState() => _ConsistentFutureBuilderState<T>();
}

class _ConsistentFutureBuilderState<T> extends State<ConsistentFutureBuilder<T>> {
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
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future ?? widget.future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context)?.error(snapshot.error.toString()) ?? snapshot.error.toString());
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return widget.onNotStarted ?? Text(AppLocalizations.of(context)!.errNotStarted);
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (widget.lastChildWhileWaiting && _lastChild != null) return _lastChild!;
            return widget.onWaiting ?? Text(AppLocalizations.of(context)!.loading);
          case ConnectionState.done:
            _lastChild = widget.onData(context, snapshot.data as T);
            return _lastChild!;
        }
      });
  }
}