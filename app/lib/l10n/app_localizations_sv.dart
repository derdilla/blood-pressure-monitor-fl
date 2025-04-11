// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get title => 'Blodtrycksapp';

  @override
  String success(String msg) {
    return 'Lyckades: $msg';
  }

  @override
  String get loading => 'laddar…';

  @override
  String error(String msg) {
    return 'Fel: $msg';
  }

  @override
  String get errNaN => 'Vänligen skriv in ett tal';

  @override
  String get errLt30 => 'Number <= 30? Turn off validation in settings!';

  @override
  String get errUnrealistic => 'Orealistiskt värde? Stäng av validering i inställningarna!';

  @override
  String get errDiaGtSys => 'dia >= sys? Turn off validation in settings!';

  @override
  String errCantOpenURL(String url) {
    return 'Kan inte öppna URL: $url';
  }

  @override
  String get errNoFileOpened => 'no file opened';

  @override
  String get errNotStarted => 'ej startad';

  @override
  String get errNoValue => 'Please enter a value';

  @override
  String get errNotEnoughDataToGraph => 'Inte tillräckligt med data för att rita en graf.';

  @override
  String get errNoData => 'ingen data';

  @override
  String get errWrongImportFormat => 'You can only import files in CSV and SQLite database format.';

  @override
  String get errNeedHeadline => 'You can only import files with a headline.';

  @override
  String get errCantReadFile => 'The file\'s contents can not be read';

  @override
  String get errNotImportable => 'This file can\'t be imported';

  @override
  String get btnCancel => 'CANCEL';

  @override
  String get btnSave => 'SAVE';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'UNDO';

  @override
  String get sysLong => 'Systolic';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastolic';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pulse';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Note (optional)';

  @override
  String get settings => 'Settings';

  @override
  String get layout => 'Layout';

  @override
  String get allowManualTimeInput => 'Allow manual time input';

  @override
  String get enterTimeFormatScreen => 'Time format';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get iconSize => 'Icon size';

  @override
  String get graphLineThickness => 'Line thickness';

  @override
  String get animationSpeed => 'Animation duration';

  @override
  String get accentColor => 'Theme color';

  @override
  String get sysColor => 'Systolic color';

  @override
  String get diaColor => 'Diastolic color';

  @override
  String get pulColor => 'Pulse color';

  @override
  String get behavior => 'Behavior';

  @override
  String get validateInputs => 'Validate inputs';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get age => 'Age';

  @override
  String get determineWarnValues => 'Determine warn values';

  @override
  String get aboutWarnValuesScreen => 'About';

  @override
  String get aboutWarnValuesScreenDesc => 'More info on warn values';

  @override
  String get sysWarn => 'Systolic warn';

  @override
  String get diaWarn => 'Diastolic warn';

  @override
  String get data => 'Data';

  @override
  String get version => 'Version';

  @override
  String versionOf(String version) {
    return 'Version: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Version number: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Package name: $name';
  }

  @override
  String get exportImport => 'Export / Import';

  @override
  String get exportDir => 'Export directory';

  @override
  String get exportAfterEveryInput => 'Export after every entry';

  @override
  String get exportAfterEveryInputDesc => 'Not recommended (file explosion)';

  @override
  String get exportFormat => 'Export format';

  @override
  String get exportCustomEntries => 'Customize fields';

  @override
  String get addEntry => 'Add field';

  @override
  String get exportMimeType => 'Export media type';

  @override
  String get exportCsvHeadline => 'Headline';

  @override
  String get exportCsvHeadlineDesc => 'Helps to discriminate types';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'text';

  @override
  String get other => 'other';

  @override
  String get fieldDelimiter => 'Field delimiter';

  @override
  String get textDelimiter => 'Text delimiter';

  @override
  String get export => 'EXPORT';

  @override
  String get shared => 'shared';

  @override
  String get import => 'IMPORT';

  @override
  String get sourceCode => 'Source code';

  @override
  String get licenses => '3rd party licenses';

  @override
  String importSuccess(int count) {
    return 'Imported $count entries';
  }

  @override
  String get exportWarnConfigNotImportable => 'Hey! Just a friendly heads up: the current export configuration won\'t be importable. To fix it, make sure you set the export type as CSV and include one of the time formats available.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Beware that you are not exporting all fields: $fields $_temp0 missing.';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get measurementCount => 'Measurement count';

  @override
  String get measurementsPerDay => 'Measurements per day';

  @override
  String get timeResolvedMetrics => 'Metrics by time of day';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt min.';
  }

  @override
  String maxOf(String txt) {
    return '$txt max.';
  }

  @override
  String get warnValues => 'Warn values';

  @override
  String get warnAboutTxt1 => 'The warn values are a pure suggestions and no medical advice.';

  @override
  String get warnAboutTxt2 => 'The default age dependent values come from this source.';

  @override
  String get warnAboutTxt3 => 'Feel free to change the values to suit your needs and follow the recommendations of your doctor.';

  @override
  String get enterTimeFormatString => 'time format';

  @override
  String get now => 'now';

  @override
  String get notes => 'Notes';

  @override
  String get time => 'Time';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get confirmDeleteDesc => 'Delete this entry? (You can turn off these confirmations in the settings.)';

  @override
  String get deletionConfirmed => 'Entry deleted.';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get lifetime => 'Lifetime';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Week $weekNum, $year';
  }

  @override
  String get last7Days => '7 days';

  @override
  String get last30Days => '30 days';

  @override
  String get allowMissingValues => 'Allow missing values';

  @override
  String get errTimeAfterNow => 'The selected time is in the future. You can turn off this validation in the settings.';

  @override
  String get language => 'Language';

  @override
  String get custom => 'Custom';

  @override
  String get drawRegressionLines => 'Draw trend lines';

  @override
  String get drawRegressionLinesDesc => 'Draws regression lines in graph. Only useful for large intervalls.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Blood pressure values from $start until $end';
  }

  @override
  String get fieldFormat => 'Field format';

  @override
  String get result => 'Result:';

  @override
  String get pulsePressure => 'Pulse pressure';

  @override
  String get addExportformat => 'Add exportformat';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get exportFieldFormatDocumentation => '## Variables\nThe export field format supports inserting values for the following placeholders:\n- `\$TIMESTAMP:` Represents the time since the Unix epoch in milliseconds.\n- `\$SYS:` Provides a value if available; otherwise, it defaults to -1.\n- `\$DIA:` Provides a value if available; otherwise, it defaults to -1.\n- `\$PUL:` Provides a value if available; otherwise, it defaults to -1.\n- `\$NOTE:` Provides a value if available; otherwise, it defaults to -1.\n- `\$COLOR:` Represents the color of a measurement as a number. (example value: `4291681337`)\n\nIf any of the placeholders mentioned above are not present in the blood pressure record, they will be replaced with `null`.\n\n## Math\nYou can use basic mathematics inside double brackets (\"`{{}}`\").\n\nThe following mathematical operations are supported:\n- Operations: +, -, *, /, %, ^\n- One-parameter functions: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Two-parameter functions: log, nrt, pow\n- Constants: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nFor the full math interpreter specification, you can refer to the [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) documentation.\n\n## Processing order\n1. variable replacement\n2. Math';

  @override
  String get default_ => 'Default';

  @override
  String get exportPdfHeaderHeight => 'Header height';

  @override
  String get exportPdfCellHeight => 'Row height';

  @override
  String get exportPdfHeaderFontSize => 'Header font size';

  @override
  String get exportPdfCellFontSize => 'Row font size';

  @override
  String get average => 'Average';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'Headline';

  @override
  String get exportPdfExportStatistics => 'Statistics';

  @override
  String get exportPdfExportData => 'Data table';

  @override
  String get startWithAddMeasurementPage => 'Measurement on launch';

  @override
  String get startWithAddMeasurementPageDescription => 'Upon app launch, measurement input screen shown.';

  @override
  String get horizontalLines => 'Horizontal lines';

  @override
  String get linePositionY => 'Line position (y)';

  @override
  String get customGraphMarkings => 'Custom markings';

  @override
  String get addLine => 'Add line';

  @override
  String get useLegacyList => 'Use legacy list';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get note => 'Note';

  @override
  String get color => 'Color';

  @override
  String get exportSettings => 'Backup settings';

  @override
  String get importSettings => 'Restore settings';

  @override
  String get requiresAppRestart => 'Requires app restart';

  @override
  String get restartNow => 'Restart now';

  @override
  String get warnNeedsRestartForUsingApp => 'Files were deleted in this session. Restart the app to continue using returning to other parts of the app!';

  @override
  String get deleteAllMeasurements => 'Delete all measurements';

  @override
  String get deleteAllSettings => 'Delete all settings';

  @override
  String get warnDeletionUnrecoverable => 'This step not revertible unless you manually made a backup. Do you really want to delete this?';

  @override
  String get enterTimeFormatDesc => 'A formatter string is a blend of predefined ICU/Skeleton strings and any additional text you\'d like to include.\n\n[If you\'re curious about the complete list of valid formats, you can find them right here.](screen://TimeFormattingHelp)\n\nJust a friendly reminder, using longer or shorter format Strings won\'t magically alter the width of the table columns, which might lead to some awkward line breaks and text not showing.\n\ndefault: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Color thickness';

  @override
  String get needlePinBarWidthDesc => 'The width of the lines colored entries make on the graph.';

  @override
  String get errParseEmptyCsvFile => 'There are not enough lines in the csv file to parse the record.';

  @override
  String get errParseTimeNotRestoreable => 'There is no column that allows restoring a timestamp.';

  @override
  String errParseUnknownColumn(String title) {
    return 'There is no column with title \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Line $lineNumber has fewer columns than the first line.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Decoding field \"$fieldContent\" in line $lineNumber failed.';
  }

  @override
  String get exportFieldsPreset => 'Export fields preset';

  @override
  String get remove => 'Remove';

  @override
  String get manageExportColumns => 'Manage export columns';

  @override
  String get buildIn => 'Build-in';

  @override
  String get csvTitle => 'CSV-title';

  @override
  String get recordFormat => 'Record format';

  @override
  String get timeFormat => 'Time format';

  @override
  String get errAccuracyLoss => 'There is precision loss expected when exporting with custom time formatters.';

  @override
  String get bottomAppBars => 'Bottom dialogue bars';

  @override
  String get medications => 'Medications';

  @override
  String get addMedication => 'Add medication';

  @override
  String get name => 'Name';

  @override
  String get defaultDosis => 'Default dose';

  @override
  String get noMedication => 'No medication';

  @override
  String get dosis => 'Dose';

  @override
  String get valueDistribution => 'Value distribution';

  @override
  String get titleInCsv => 'Title in CSV';

  @override
  String get errBleNoPerms => 'No bluetooth permissions';

  @override
  String get preferredPressureUnit => 'Preferred pressure unit';

  @override
  String get compactList => 'Compact measurement list';

  @override
  String get bluetoothDisabled => 'Bluetooth disabled';

  @override
  String get errMeasurementRead => 'Error while taking measurement!';

  @override
  String get measurementSuccess => 'Measurement taken successfully!';

  @override
  String get connect => 'Connect';

  @override
  String get bluetoothInput => 'Bluetooth input';

  @override
  String get aboutBleInput => 'Some measurement devices are BLE GATT compatible. You can pair these devices here and automatically transmit measurements or disable this option in the settings.';

  @override
  String get scanningForDevices => 'Scanning for devices';

  @override
  String get tapToClose => 'Tap to close.';

  @override
  String get meanArterialPressure => 'Mean arterial pressure';

  @override
  String get userID => 'User ID';

  @override
  String get bodyMovementDetected => 'Body movement detected';

  @override
  String get cuffTooLoose => 'Cuff too loose';

  @override
  String get improperMeasurementPosition => 'Improper measurement position';

  @override
  String get irregularPulseDetected => 'Irregular pulse detected';

  @override
  String get pulseRateExceedsUpperLimit => 'Pulse rate exceeds upper limit';

  @override
  String get pulseRateLessThanLowerLimit => 'Pulse rate is less than lower limit';

  @override
  String get availableDevices => 'Available devices';

  @override
  String get deleteAllMedicineIntakes => 'Delete all medicine intakes';

  @override
  String get deleteAllNotes => 'Delete all notes';

  @override
  String get date => 'Date';

  @override
  String get intakes => 'Medicine intakes';

  @override
  String get errFeatureNotSupported => 'This feature is not available on this platform.';

  @override
  String get invalidZip => 'Invalid zip file.';

  @override
  String get errCantCreateArchive => 'Can\'t create archive. Please report the bug if possible.';

  @override
  String get activateWeightFeatures => 'Activate weight related features';

  @override
  String get weight => 'Weight';

  @override
  String get enterWeight => 'Enter weight';

  @override
  String get selectMeasurementTitle => 'Select the measurement to use';

  @override
  String measurementIndex(int number) {
    return 'Measurement #$number';
  }

  @override
  String get select => 'Select';

  @override
  String get bloodPressure => 'Blood pressure';

  @override
  String get preferredWeightUnit => 'Preferred weight unit';

  @override
  String get disabled => 'Disabled';

  @override
  String get oldBluetoothInput => 'Stable';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta cross-platform';

  @override
  String get bluetoothInputDesc => 'The beta backend works on more devices but is less tested. The cross-platform version may work on non-android and is planned to supersede the stable implementation once mature enough.';

  @override
  String get tapToSelect => 'Tap to select';
}
