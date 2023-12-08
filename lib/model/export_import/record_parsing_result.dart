
import 'package:blood_pressure_app/model/blood_pressure.dart';

/// Indicate a possible error during record parsing.
class RecordParsingResult {
  RecordParsingResult._create(this._result, this._error);

  final List<BloodPressureRecord>? _result;
  final RecordParsingErrorType? _error;

  /// Pass a valid record list and indicate success.
  factory RecordParsingResult.ok(List<BloodPressureRecord> result)=>
      RecordParsingResult._create(result, null);

  /// Indicate a parsing failure.
  factory RecordParsingResult.err(RecordParsingErrorType type)=>
      RecordParsingResult._create(null, type);

  /// Returns if there is an error present.
  ///
  /// Indicates that there is no result.
  bool hasError() => _error != null;

  /// Returns the passed list on success or the result of [errorHandler] in case a error is present.
  ///
  /// When [errorHandler] returns null a empty list is passed.
  List<BloodPressureRecord> getOr(List<BloodPressureRecord>? Function(RecordParsingErrorType error) errorHandler) {
    if (_result != null) {
      assert(_error == null);
      return _result!;
    }
    assert(_error != null);
    return errorHandler(_error!) ?? [];
  }
}

// TODO: consider converting to sealed class to allow passing error details.
/// Indicates what type error occurred while trying to decode a csv data.
enum RecordParsingErrorType {
  /// There are not enough lines in the csv file to parse the record.
  emptyFile,

  /// There is no column with this csv title that can be reversed.
  unknownColumn,

  /// The current line has less fields than the first line.
  expectedMoreFields,

  /// There is no column that allows restoring a timestamp.
  timeNotRestoreable,

  /// The corresponding column couldn't decode a specific field in the csv file.
  unparsableField,
  // TODO ...
}