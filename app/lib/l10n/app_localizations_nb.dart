// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get title => 'Blodtrykksprogram';

  @override
  String success(String msg) {
    return 'Vellykket: $msg';
  }

  @override
  String get loading => 'laster inn …';

  @override
  String error(String msg) {
    return 'Feil: $msg';
  }

  @override
  String get errNaN => 'Skriv inn et tall';

  @override
  String get errLt30 => 'Nummer <=30? Skru av bekreftelse i innstillingene!';

  @override
  String get errUnrealistic => 'Urealistisk verdi? Skru av bekreftelse i innstillingene!';

  @override
  String get errDiaGtSys => 'dia >=sys? Skru av bekreftelse i innstillingene!';

  @override
  String errCantOpenURL(String url) {
    return 'Kan ikke åpne nettadresse: $url';
  }

  @override
  String get errNoFileOpened => 'ingen fil åpnet';

  @override
  String get errNotStarted => 'ikke startet';

  @override
  String get errNoValue => 'Skriv inn en verdi';

  @override
  String get errNotEnoughDataToGraph => 'Ikke nok data til å tegne diagram.';

  @override
  String get errNoData => 'ingen data';

  @override
  String get errWrongImportFormat => 'Du kan kun importere filer i CSV og SQLite-databaseformat.';

  @override
  String get errNeedHeadline => 'Du kan kun importere filer med overskrift.';

  @override
  String get errCantReadFile => 'Filinnholdet kan ikke leses';

  @override
  String get errNotImportable => 'Filen kan ikke importeres';

  @override
  String get btnCancel => 'Avbryt';

  @override
  String get btnSave => 'Lagre';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'Angre';

  @override
  String get sysLong => 'Systolisk';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastolisk';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Puls';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Notat (valgfritt)';

  @override
  String get settings => 'Innstillinger';

  @override
  String get layout => 'Utseende';

  @override
  String get allowManualTimeInput => 'Tillat manuell inntasting av tid';

  @override
  String get enterTimeFormatScreen => 'Tidsformat';

  @override
  String get theme => 'Drakt';

  @override
  String get system => 'System';

  @override
  String get dark => 'Mørk';

  @override
  String get light => 'Lys';

  @override
  String get iconSize => 'Ikonstørrelse';

  @override
  String get graphLineThickness => 'Linjetykkelse';

  @override
  String get animationSpeed => 'Animasjonsvarighet';

  @override
  String get accentColor => 'Draktfarge';

  @override
  String get sysColor => 'Systolisk farge';

  @override
  String get diaColor => 'Diastolisk farge';

  @override
  String get pulColor => 'Pulsfarge';

  @override
  String get behavior => 'Adferd';

  @override
  String get validateInputs => 'Bekreft inndata';

  @override
  String get confirmDeletion => 'Bekreft sletting';

  @override
  String get age => 'Alder';

  @override
  String get determineWarnValues => 'Fastsett advarselsverdier';

  @override
  String get aboutWarnValuesScreen => 'Om';

  @override
  String get aboutWarnValuesScreenDesc => 'Mer info om advarselsverdier';

  @override
  String get sysWarn => 'Systolisk advarsel';

  @override
  String get diaWarn => 'Diastolisk advarsel';

  @override
  String get data => 'Data';

  @override
  String get version => 'Versjon';

  @override
  String versionOf(String version) {
    return 'Versjon: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Versjonsnummer: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Pakkenavn: $name';
  }

  @override
  String get exportImport => 'Eksporter/importer';

  @override
  String get exportDir => 'Eksporter mappe';

  @override
  String get exportAfterEveryInput => 'Eksporter etter hver oppføring';

  @override
  String get exportAfterEveryInputDesc => 'Ikke anbefalt (dataeksplosjon)';

  @override
  String get exportFormat => 'Eksportformat';

  @override
  String get exportCustomEntries => 'Tilpass felter';

  @override
  String get addEntry => 'Legg til felt';

  @override
  String get exportMimeType => 'Eksporter mediatype';

  @override
  String get exportCsvHeadline => 'Overskrift';

  @override
  String get exportCsvHeadlineDesc => 'Hjelper til å skille typer';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite-DB';

  @override
  String get text => 'tekst';

  @override
  String get other => 'annet';

  @override
  String get fieldDelimiter => 'Feltinndeler';

  @override
  String get textDelimiter => 'Tekstinndeler';

  @override
  String get export => 'Eksporter';

  @override
  String get shared => 'delt';

  @override
  String get import => 'Importer';

  @override
  String get sourceCode => 'Kildekode';

  @override
  String get licenses => 'Tredjepartslisenser';

  @override
  String importSuccess(int count) {
    return 'Importerte $count oppføringer';
  }

  @override
  String get exportWarnConfigNotImportable => 'Gjør eksportoppsettet importerbart ved å sette eksporttypen til \\\"CSV\\\", skru på overskrift, inkluder feltene \'diastolic\', \'systolic\', \'pulse\', \'notes\', sammen med ett av de tilgjengelige tidsformatene.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Husk at du ikke eksporterer alle feltene: $fields $_temp0 mangler';
  }

  @override
  String get statistics => 'Statistikk';

  @override
  String get measurementCount => 'Målingsantall';

  @override
  String get measurementsPerDay => 'Målinger per dag';

  @override
  String get timeResolvedMetrics => 'Tidsutledet data';

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
    return '$txt maks.';
  }

  @override
  String get warnValues => 'Advarselsverdier';

  @override
  String get warnAboutTxt1 => 'Advarselsverdiene er kun forslag, og ikke medisinske råd.';

  @override
  String get warnAboutTxt2 => 'Forvalgt aldersavhengig verdi kommer fra denne kilden.';

  @override
  String get warnAboutTxt3 => 'Endre gjerne verdiene, og følg anbefalingene din doktor gir deg.';

  @override
  String get enterTimeFormatString => 'tidsformat';

  @override
  String get now => 'nå';

  @override
  String get notes => 'Notater';

  @override
  String get time => 'Tid';

  @override
  String get confirmDelete => 'Bekreft sletting';

  @override
  String get confirmDeleteDesc => 'Slett oppføringen? (Du kan skru av disse bekreftelsene i innstillingene.)';

  @override
  String get deletionConfirmed => 'Oppføring slettet.';

  @override
  String get day => 'dag';

  @override
  String get week => 'uke';

  @override
  String get month => 'måned';

  @override
  String get year => 'År';

  @override
  String get lifetime => 'Levetid';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Uke $weekNum, $year';
  }

  @override
  String get last7Days => '7 dager';

  @override
  String get last30Days => '30 dager';

  @override
  String get allowMissingValues => 'Tillat manglende verdier';

  @override
  String get errTimeAfterNow => 'Valgt tid på dagen er etter dette tidspunktet. Automatisk tilbakestilt til nåværende tid. Du kan skru av denne bekreftelsen i innstillingene.';

  @override
  String get language => 'Språk';

  @override
  String get custom => 'Egendefinert';

  @override
  String get drawRegressionLines => 'Tegn trendlinjer';

  @override
  String get drawRegressionLinesDesc => 'Tegner regresjonslinjer i diagram. Kun nyttig for store intervaller.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Blood pressure values from $start until $end';
  }

  @override
  String get fieldFormat => 'Feltformat';

  @override
  String get result => 'Resultat:';

  @override
  String get pulsePressure => 'Pulse pressure';

  @override
  String get addExportformat => 'Add exportformat';

  @override
  String get edit => 'Rediger';

  @override
  String get delete => 'Slett';

  @override
  String get exportFieldFormatDocumentation => '## Variables\nThe export field format supports inserting values for the following placeholders:\n- `\$TIMESTAMP:` Represents the time since the Unix epoch in milliseconds.\n- `\$SYS:` Provides a value if available; otherwise, it defaults to -1.\n- `\$DIA:` Provides a value if available; otherwise, it defaults to -1.\n- `\$PUL:` Provides a value if available; otherwise, it defaults to -1.\n- `\$NOTE:` Provides a value if available; otherwise, it defaults to -1.\n- `\$COLOR:` Represents the color of a measurement as a number. (example value: `4291681337`)\n\nIf any of the placeholders mentioned above are not present in the blood pressure record, they will be replaced with `null`.\n\n## Math\nYou can use basic mathematics inside double brackets (\"`{{}}`\").\n\nThe following mathematical operations are supported:\n- Operations: +, -, *, /, %, ^\n- One-parameter functions: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Two-parameter functions: log, nrt, pow\n- Constants: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nFor the full math interpreter specification, you can refer to the [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) documentation.\n\n## Processing order\n1. variable replacement\n2. Math';

  @override
  String get default_ => 'Forvalg';

  @override
  String get exportPdfHeaderHeight => 'Header height';

  @override
  String get exportPdfCellHeight => 'Row height';

  @override
  String get exportPdfHeaderFontSize => 'Header font size';

  @override
  String get exportPdfCellFontSize => 'Row font size';

  @override
  String get average => 'Gjennomsnitt';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'Headline';

  @override
  String get exportPdfExportStatistics => 'Statistikk';

  @override
  String get exportPdfExportData => 'Datatabell';

  @override
  String get startWithAddMeasurementPage => 'Måling ved oppstart';

  @override
  String get startWithAddMeasurementPageDescription => 'Upon app launch, measurement input screen shown.';

  @override
  String get horizontalLines => 'Vannrette linjer';

  @override
  String get linePositionY => 'Line position (y)';

  @override
  String get customGraphMarkings => 'Egendefinerte markeringer';

  @override
  String get addLine => 'Legg til linje';

  @override
  String get useLegacyList => 'Use legacy list';

  @override
  String get addMeasurement => 'Legg til måling';

  @override
  String get timestamp => 'Tidsstempel';

  @override
  String get note => 'Notat';

  @override
  String get color => 'Farge';

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
  String get enterTimeFormatDesc => 'En formateringsstreng er en miks av predefinert ICU/Skeleton -strenger og all annen tekst du vil inkludere.\n\n[En fullstendig liste over gyldige formater er å finne her.](screen://TimeFormattingHelp)\n\nBruk av lengre eller kortere formatstrenger endrer ikke også bredden på tabellkolonnene, noe som fører til linjeskift og tekst som ikke vises.\n\nforvalg: \"yy-MM-dd HH:mm\"';

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
