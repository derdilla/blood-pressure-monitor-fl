import 'dart:collection';

import 'package:health_data_store/health_data_store.dart';

/// A data provider provides access to the data.
///
/// It interacts with the databases on a low level and only supports basic CRUD
/// operations.
///
/// Tables are structured in a way that they have a id ([int]) as a primary
/// key and have one or more other columns associated with that key.
abstract class DataProvider<T> {
  /// Gets all entries in the inclusive range.
  Future<UnmodifiableListView<(int,T)>> getInRange(DateRange range);

  /// Sets the data at [entryID] to [value].
  Future<void> set(int entryID, T value);

  /// Removes the value associated with this [entryID].
  Future<void> remove(int entryID);
}
