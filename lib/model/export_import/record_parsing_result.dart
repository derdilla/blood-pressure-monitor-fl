
import 'package:blood_pressure_app/model/blood_pressure/record.dart';

/// Indicate a possible error during record parsing.
class RecordParsingResult {

  /// Pass a valid record list and indicate success.
  factory RecordParsingResult.ok(List<BloodPressureRecord> result)=>
      RecordParsingResult._create(result, null);

  /// Indicate a parsing failure.
  factory RecordParsingResult.err(RecordParsingError error)=>
      RecordParsingResult._create(null, error);
  RecordParsingResult._create(this._result, this._error);

  final List<BloodPressureRecord>? _result;
  final RecordParsingError? _error;

  /// Returns if there is an error present.
  ///
  /// Indicates that there is no result.
  bool hasError() => _error != null;

  /// Returns the passed list on success or the result of [errorHandler] in case a error is present.
  ///
  /// When [errorHandler] returns null a empty list is passed.
  List<BloodPressureRecord> getOr(List<BloodPressureRecord>? Function(RecordParsingError error) errorHandler) {
    if (_result != null) {
      assert(_error == null);
      return _result!;
    }
    assert(_error != null);
    return errorHandler(_error!) ?? [];
  }
}

/// Indicates what type error occurred while trying to decode a csv data.
sealed class RecordParsingError {}

/// There are not enough lines in the csv file to parse the record.
class RecordParsingErrorEmptyFile implements RecordParsingError {}

/// There is no column that allows restoring a timestamp.
// TODO: return line.
class RecordParsingErrorTimeNotRestoreable implements RecordParsingError {}

/// There is no column with this csv title that can be reversed.
class RecordParsingErrorUnknownColumn implements RecordParsingError {
  RecordParsingErrorUnknownColumn(this.title);
  
  /// CSV title of the column no equivalent was found for. 
  final String title;
}

/// The current line has less fields than the first line.
class RecordParsingErrorExpectedMoreFields implements RecordParsingError {
  RecordParsingErrorExpectedMoreFields(this.lineNumber);

  /// Line in which this error occurred. 
  final int lineNumber;
}

/// The corresponding column couldn't decode a specific field in the csv file.
class RecordParsingErrorUnparsableField implements RecordParsingError {
  RecordParsingErrorUnparsableField(this.lineNumber, this.fieldContents);

  /// Line in which this error occurred.
  final int lineNumber;
  
  /// Text in the csv string that failed to parse.
  final String fieldContents;
}
