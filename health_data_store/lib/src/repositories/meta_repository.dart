import 'package:health_data_store/src/types/date_range.dart';

/// The meta repository contains metadata about the stored data.
///
/// This includes data such as ranges in which events exist and what type of
/// data was collected during a event.
class MetaRepository {
  DateRange get availableRange {
    // TODO
    throw UnimplementedError();
  }

  DateTime get firstEntry {
    // TODO
    throw UnimplementedError();
  }

  DateRange get lastEntry {
    // TODO
    throw UnimplementedError();
  }

  // TODO: check what is needed

}
