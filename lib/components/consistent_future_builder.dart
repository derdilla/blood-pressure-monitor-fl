import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsistentFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T result) onData;
  
  final Widget? onNotStarted;
  final Widget? onWaiting;
  final Widget? Function(BuildContext context, String errorMsg)? onError;
  
  const ConsistentFutureBuilder({super.key, required this.future, this.onNotStarted, this.onWaiting, this.onError, required this.onData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context)!.error(snapshot.error.toString()));
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return onNotStarted ?? Text(AppLocalizations.of(context)!.errNotStarted);
          case ConnectionState.waiting:
          case ConnectionState.active:
            return onWaiting ?? Text(AppLocalizations.of(context)!.loading);
          case ConnectionState.done:
            return onData(context, snapshot.data as T);
        }
      });
  }
}