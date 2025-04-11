

import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Indicate a possible error during record parsing.
class RecordParsingResult {

  /// Pass a valid record list and indicate success.
  factory RecordParsingResult.ok(List<FullEntry> result)=>
      RecordParsingResult._create(result, null);

  /// Indicate a parsing failure.
  factory RecordParsingResult.err(EntryParsingError error)=>
      RecordParsingResult._create(null, error);
  RecordParsingResult._create(this._result, this._error);

  final List<FullEntry>? _result;
  final EntryParsingError? _error;

  /// Returns if there is an error present.
  ///
  /// Indicates that there is no result.
  bool hasError() => _error != null;

  /// The returned error, if present.
  EntryParsingError? get error => _error;

  /// Returns the passed list on success or the result of [errorHandler] in case
  /// a error is present.
  ///
  /// When [errorHandler] returns null a empty list is passed.
  List<FullEntry> getOr(List<FullEntry>? Function(EntryParsingError error) errorHandler) {
    if (_result != null) {
      assert(_error == null);
      return _result!;
    }
    assert(_error != null);
    return errorHandler(_error!) ?? [];
  }
}

/// Indicates what type error occurred while trying to decode a csv data.
sealed class EntryParsingError {
  /// Create the localized String explaining this error
  String localize(AppLocalizations localizations) => switch (this) {
    RecordParsingErrorEmptyFile() => localizations.errParseEmptyCsvFile,
    RecordParsingErrorTimeNotRestoreable() => localizations.errParseTimeNotRestoreable,
    RecordParsingErrorUnknownColumn() => localizations.errParseUnknownColumn(
        (this as RecordParsingErrorUnknownColumn).title,),
    RecordParsingErrorExpectedMoreFields() => localizations.errParseLineTooShort(
        (this as RecordParsingErrorExpectedMoreFields).lineNumber,),
    RecordParsingErrorUnparsableField() => localizations.errParseFailedDecodingField(
      (this as RecordParsingErrorUnparsableField).lineNumber,
      (this as RecordParsingErrorUnparsableField).fieldContents,),
  };
}

/// There are not enough lines in the csv file to parse the record.
class RecordParsingErrorEmptyFile extends EntryParsingError {}

/// There is no column that allows restoring a timestamp.
// TODO: return line.
class RecordParsingErrorTimeNotRestoreable extends EntryParsingError {}

/// There is no column with this csv title that can be reversed.
class RecordParsingErrorUnknownColumn extends EntryParsingError {
  RecordParsingErrorUnknownColumn(this.title);
  
  /// CSV title of the column no equivalent was found for. 
  final String title;
}

/// The current line has less fields than the first line.
class RecordParsingErrorExpectedMoreFields extends EntryParsingError {
  RecordParsingErrorExpectedMoreFields(this.lineNumber);

  /// Line in which this error occurred. 
  final int lineNumber;
}

/// The corresponding column couldn't decode a specific field in the csv file.
class RecordParsingErrorUnparsableField extends EntryParsingError {
  RecordParsingErrorUnparsableField(this.lineNumber, this.fieldContents);

  /// Line in which this error occurred.
  final int lineNumber;
  
  /// Text in the csv string that failed to parse.
  final String fieldContents;
}
