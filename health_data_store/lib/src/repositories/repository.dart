import 'dart:collection';

import 'package:health_data_store/src/data_providers/data_provider.dart';
import 'package:health_data_store/src/types/date_range.dart';

/// A repository is a abstraction around multiple [DataProvider]s.
///
/// Repositories wrap the primitive values of [DataProvider]s into more complex
/// types and provides domain models for the application.
abstract class Repository<T> {
  /// Adds a new value to the repository.
  Future<void> add(T value);

  /// Attempts to remove a value from the repository.
  ///
  /// This should only be called for values for values that are known to be in
  /// the repository.
  Future<void> remove(T value);

  /// Inclusively returns all values in the specified [range].
  Future<UnmodifiableListView<T>> get(DateRange range);
}
