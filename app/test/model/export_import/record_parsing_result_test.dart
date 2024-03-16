
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'record_formatter_test.dart';

void main() {
  test('should indicate when error is present', () async {
    final result = RecordParsingResult.err(RecordParsingErrorEmptyFile());
    expect(result.hasError(), isTrue);
  });
  test('should indicate when no error is present', () async {
    final result = RecordParsingResult.ok([mockRecord()]);
    expect(result.hasError(), isFalse);
  });
  test('should return error through getter', () async {
    final okResult = RecordParsingResult.ok([mockRecord()]);
    expect(okResult.error, isNull);

    final errResult = RecordParsingResult.err(RecordParsingErrorUnparsableField(42, 'fieldContents'));
    expect(errResult.error, isNotNull);
    expect(errResult.error, isA<RecordParsingErrorUnparsableField>()
      .having((p0) => p0.lineNumber, 'line number', 42)
      .having((p0) => p0.fieldContents, 'contents', 'fieldContents'),);
  });
  test('should normally return value when no error is present', () async {
    final record = mockRecord();

    final result = RecordParsingResult.ok([record]);
    final value = result.getOr((error) {
      fail('Error function called incorrectly.');
    });
    expect(value.length, 1);
    expect(value.first, record);
  });
  test('should call error function when error is present', () async {
    final result = RecordParsingResult.err(RecordParsingErrorExpectedMoreFields(123));
    final value = result.getOr((error) {
      expect(error, isA<RecordParsingErrorExpectedMoreFields>()
          .having((p0) => p0.lineNumber, 'line number', 123),);
      return [mockRecord(sys: 1234567)];
    });
    expect(value.length, 1);
    expect(value.first.systolic, 1234567);
  });
  test('should return empty list when error function returns null', () async {
    final result = RecordParsingResult.err(RecordParsingErrorExpectedMoreFields(123));
    final value = result.getOr((error) {
      expect(error, isA<RecordParsingErrorExpectedMoreFields>()
          .having((p0) => p0.lineNumber, 'line number', 123),);
      return null;
    });
    expect(value, isEmpty);
  });
}

