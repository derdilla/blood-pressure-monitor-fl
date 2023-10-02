import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsistentFutureBuilder<T> extends StatefulWidget {
  /// Future that gets evaluated.
  ///
  /// This Future is saved as a state, so the build function won't get called again when a rebuild occurs. The future
  /// gets evaluated once.
  final Future<T> future;
  final Widget Function(BuildContext context, T result) onData;
  
  final Widget? onNotStarted;
  final Widget? onWaiting;
  final Widget? Function(BuildContext context, String errorMsg)? onError;
  
  const ConsistentFutureBuilder({super.key, required this.future, this.onNotStarted, this.onWaiting, this.onError, required this.onData});

  @override
  State<ConsistentFutureBuilder<T>> createState() => _ConsistentFutureBuilderState<T>();
}

class _ConsistentFutureBuilderState<T> extends State<ConsistentFutureBuilder<T>> {
  late final Future<T> _future; // avoid rebuilds

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context)!.error(snapshot.error.toString()));
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return widget.onNotStarted ?? Text(AppLocalizations.of(context)!.errNotStarted);
          case ConnectionState.waiting:
          case ConnectionState.active:
            return widget.onWaiting ?? Text(AppLocalizations.of(context)!.loading);
          case ConnectionState.done:
            return widget.onData(context, snapshot.data as T);
        }
      });
  }
}