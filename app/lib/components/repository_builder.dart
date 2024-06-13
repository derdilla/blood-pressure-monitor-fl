import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// A builder that provides the contents of a repository.
class RepositoryBuilder<T, R extends Repository<T>> extends StatefulWidget {
  /// Create a builder that provides the contents of a repository.
  const RepositoryBuilder({super.key,
    required this.rangeType,
    required this.onData,
  });

  /// Which measurements to load.
  final IntervallStoreManagerLocation rangeType;

  /// The build strategy once the data loaded.
  final Widget Function(BuildContext, List<T>) onData;

  @override
  State<RepositoryBuilder> createState() => _RepositoryBuilderState<T, R>();
}

class _RepositoryBuilderState<T, R extends Repository<T>> extends State<RepositoryBuilder> {
  late final R _repo;

  @override
  void initState() {
    super.initState();
    _repo = RepositoryProvider.of<R>(context);
  }

  @override
  Widget build(BuildContext context) => Consumer<IntervallStoreManager>(
    builder: (context, intervallManager, child) {
      final range = intervallManager.get(widget.rangeType).currentRange;
      return StreamBuilder(
        stream: _repo.subscribe(),
        builder: (context, _) => ConsistentFutureBuilder(
          future: _repo.get(range),
          onData: widget.onData,
        ),
      );
    },
  );
}
// TODO: test
