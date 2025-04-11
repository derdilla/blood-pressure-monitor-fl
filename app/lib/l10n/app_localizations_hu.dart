// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get title => 'Vérnyomás alkalmazás';

  @override
  String success(String msg) {
    return 'Sikeres: $msg';
  }

  @override
  String get loading => 'Betöltés…';

  @override
  String error(String msg) {
    return 'Hiba: $msg';
  }

  @override
  String get errNaN => 'Kérem adjon meg egy számot';

  @override
  String get errLt30 => 'Érték <= 30? Kapcsolja ki az ellenőrzést a beállításokban!';

  @override
  String get errUnrealistic => 'Nem valóságos érték? Kapcsolja ki az ellenőrzést a beállításokban!';

  @override
  String get errDiaGtSys => 'dia > sys? Kapcsolja ki az ellenőrzést a beállításokban!';

  @override
  String errCantOpenURL(String url) {
    return 'Nem sikerült megnyitni az URL-t : $url';
  }

  @override
  String get errNoFileOpened => 'Nincs megnyitható file';

  @override
  String get errNotStarted => 'nem indult el';

  @override
  String get errNoValue => 'Kérem adjon meg egy értéket';

  @override
  String get errNotEnoughDataToGraph => 'Nincs elég adat az ábra rajzolásához.';

  @override
  String get errNoData => 'Nincs adat';

  @override
  String get errWrongImportFormat => 'Csak CSV és SQLite formátumok beolvasása lehetséges.';

  @override
  String get errNeedHeadline => 'Csak fejléccel rendelkező fájl olvasható be.';

  @override
  String get errCantReadFile => 'A fájl tartalma nem olvasható';

  @override
  String get errNotImportable => 'A fájlt nem lehet beolvasni';

  @override
  String get btnCancel => 'MÉGSE';

  @override
  String get btnSave => 'MENTÉS';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'VISSZA';

  @override
  String get sysLong => 'Szisztolés';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diasztolés';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pulzus';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Jegyzet (opcionális)';

  @override
  String get settings => 'Beállítások';

  @override
  String get layout => 'Elrendezés';

  @override
  String get allowManualTimeInput => 'Engedje meg az idő kézi megadását';

  @override
  String get enterTimeFormatScreen => 'Idő formátum';

  @override
  String get theme => 'Téma';

  @override
  String get system => 'Rendszer';

  @override
  String get dark => 'Sötét';

  @override
  String get light => 'Világos';

  @override
  String get iconSize => 'Icon méret';

  @override
  String get graphLineThickness => 'Vonal vastagság';

  @override
  String get animationSpeed => 'Animáció időtartalma';

  @override
  String get accentColor => 'Téma szín';

  @override
  String get sysColor => 'Szisztolé szín';

  @override
  String get diaColor => 'Diasztolé szín';

  @override
  String get pulColor => 'Pulzus szín';

  @override
  String get behavior => 'Viselkedés';

  @override
  String get validateInputs => 'Értékek validálása';

  @override
  String get confirmDeletion => 'Törlés megerősítése';

  @override
  String get age => 'Életkor';

  @override
  String get determineWarnValues => 'Figyelmeztetési értékek meghatározása';

  @override
  String get aboutWarnValuesScreen => 'Rólunk';

  @override
  String get aboutWarnValuesScreenDesc => 'Több infó a figyelmeztetésekről';

  @override
  String get sysWarn => 'Figyelmeztetés (szisztolés)';

  @override
  String get diaWarn => 'Figyelmeztetés (diasztolés)';

  @override
  String get data => 'Adatok';

  @override
  String get version => 'Verzió';

  @override
  String versionOf(String version) {
    return 'Verzió: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Verzió szám: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Csomag neve: $name';
  }

  @override
  String get exportImport => 'Export / Import';

  @override
  String get exportDir => 'Export helye';

  @override
  String get exportAfterEveryInput => 'Export minden bevitel után';

  @override
  String get exportAfterEveryInputDesc => 'Nem ajánlott (túl sok fájl keletkezik)';

  @override
  String get exportFormat => 'Export formátum';

  @override
  String get exportCustomEntries => 'Mezők testreszabása';

  @override
  String get addEntry => 'Mező hozzáadása';

  @override
  String get exportMimeType => 'Export media type';

  @override
  String get exportCsvHeadline => 'Fejléc';

  @override
  String get exportCsvHeadlineDesc => 'Helps to discriminate types';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'szöveg';

  @override
  String get other => 'egyéb';

  @override
  String get fieldDelimiter => 'Mezőelválasztó';

  @override
  String get textDelimiter => 'Szövegelválasztó';

  @override
  String get export => 'EXPORT';

  @override
  String get shared => 'megosztott';

  @override
  String get import => 'IMPORT';

  @override
  String get sourceCode => 'Forráskód';

  @override
  String get licenses => '3rd party licensz';

  @override
  String importSuccess(int count) {
    return 'Importált bejegyzések: $count';
  }

  @override
  String get exportWarnConfigNotImportable => 'Hello! Csak egy baráti figyelmeztetés: a jelenlegi exportkonfiguráció nem lesz importálható. A javításhoz győződjön meg róla, hogy az export típusát CSV-re állította be, és tartalmazza a rendelkezésre álló időformátumok egyikét.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Vigyázzon, mert nem minden mező lesz exportálva: $fields $_temp0 hiányoznak.';
  }

  @override
  String get statistics => 'Statisztika';

  @override
  String get measurementCount => 'Mérések száma';

  @override
  String get measurementsPerDay => 'Mérések naponta';

  @override
  String get timeResolvedMetrics => 'Napon belüli mérések ideje';

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
  String get warnValues => 'Figyelmeztetési értékek';

  @override
  String get warnAboutTxt1 => 'A figyelmeztető értékek puszta javaslatok és nem orvosi tanácsadás.';

  @override
  String get warnAboutTxt2 => 'Az alapértelmezett korfüggő értékek ebből a forrásból származnak.';

  @override
  String get warnAboutTxt3 => 'Nyugodtan változtassa meg az értékeket a saját igényeinek megfelelően, és kövesse orvosa ajánlásait.';

  @override
  String get enterTimeFormatString => 'időformátum';

  @override
  String get now => 'most';

  @override
  String get notes => 'Jegyzetek';

  @override
  String get time => 'Idő';

  @override
  String get confirmDelete => 'Törlés megerősítése';

  @override
  String get confirmDeleteDesc => 'Törli ezt a bejegyzést? (A beállításokban kikapcsolhatja ezeket a megerősítéseket.)';

  @override
  String get deletionConfirmed => 'Bejegyzés törölve.';

  @override
  String get day => 'Nap';

  @override
  String get week => 'Hét';

  @override
  String get month => 'Hónap';

  @override
  String get year => 'Év';

  @override
  String get lifetime => 'Élettartam';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Hét $weekNum, $year';
  }

  @override
  String get last7Days => '7 nap';

  @override
  String get last30Days => '30 nap';

  @override
  String get allowMissingValues => 'Hiányzó értékek engedélyezése';

  @override
  String get errTimeAfterNow => 'A kiválasztott nap vissza lett állítva, mivel ez egy jövőbeli időpont. Ezt az érvényesítést kikapcsolhatja a beállításokban.';

  @override
  String get language => 'Nyelv';

  @override
  String get custom => 'Tetszőleges';

  @override
  String get drawRegressionLines => 'Trend vonal kirajzolása';

  @override
  String get drawRegressionLinesDesc => 'Draws regression lines in graph. Only useful for large intervalls.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Blood pressure values from $start until $end';
  }

  @override
  String get fieldFormat => 'Field format';

  @override
  String get result => 'Eredmény:';

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
