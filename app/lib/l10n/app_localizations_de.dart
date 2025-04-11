// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get title => 'Blutdruck App';

  @override
  String success(String msg) {
    return 'Erfolg: $msg';
  }

  @override
  String get loading => 'Lade…';

  @override
  String error(String msg) {
    return 'Fehler: $msg';
  }

  @override
  String get errNaN => 'Bitte Zahl eingeben';

  @override
  String get errLt30 => 'Wert <= 30? Deaktiviere Prüfung in Einstellungen!';

  @override
  String get errUnrealistic => 'Fehleingabe? Deaktiviere Prüfung in den Einstellungen!';

  @override
  String get errDiaGtSys => 'dia >= sys? Deaktiviere Prüfung in den Einstellungen!';

  @override
  String errCantOpenURL(String url) {
    return 'Kann URL nicht öffnen: $url';
  }

  @override
  String get errNoFileOpened => 'Keine Datei geöffnet';

  @override
  String get errNotStarted => 'Nicht begonnen';

  @override
  String get errNoValue => 'Bitte Wert eingeben';

  @override
  String get errNotEnoughDataToGraph => 'Zuwenig Daten für Graphen.';

  @override
  String get errNoData => 'Keine Daten';

  @override
  String get errWrongImportFormat => 'Es können nur Dateien im CSV und SQLite db Format importiert werden.';

  @override
  String get errNeedHeadline => 'Es können nur Dateien mit einer Überschrift importiert werden.';

  @override
  String get errCantReadFile => 'Der Inhalt der Datei kann nicht gelesen werden';

  @override
  String get errNotImportable => 'Diese Datei kann nicht importiert werden';

  @override
  String get btnCancel => 'ABBRUCH';

  @override
  String get btnSave => 'SPEICHERN';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'ZURÜCK';

  @override
  String get sysLong => 'Systole';

  @override
  String get sysShort => 'Sys';

  @override
  String get diaLong => 'Diastole';

  @override
  String get diaShort => 'Dia';

  @override
  String get pulLong => 'Puls';

  @override
  String get pulShort => 'Pul';

  @override
  String get addNote => 'Notiz (optional)';

  @override
  String get settings => 'Einstellungen';

  @override
  String get layout => 'Layout';

  @override
  String get allowManualTimeInput => 'Editierbare Zeitangaben';

  @override
  String get enterTimeFormatScreen => 'Datums-/Zeitformat';

  @override
  String get theme => 'Aussehen';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';

  @override
  String get iconSize => 'Größe der Knöpfe';

  @override
  String get graphLineThickness => 'Linienstärke d. Graphen';

  @override
  String get animationSpeed => 'Animationsdauer';

  @override
  String get accentColor => 'Farbschema';

  @override
  String get sysColor => 'Farbe für Systole';

  @override
  String get diaColor => 'Farbe für Diastole';

  @override
  String get pulColor => 'Farbe für Puls';

  @override
  String get behavior => 'Verhalten';

  @override
  String get validateInputs => 'Eingaben prüfen';

  @override
  String get confirmDeletion => 'Löschen bestätigen';

  @override
  String get age => 'Alter';

  @override
  String get determineWarnValues => 'Warnwerte bestimmen';

  @override
  String get aboutWarnValuesScreen => 'Mehr Infos';

  @override
  String get aboutWarnValuesScreenDesc => 'Mehr Infos zu den Warnwerten';

  @override
  String get sysWarn => 'Warnwert Sys';

  @override
  String get diaWarn => 'Warnwert Dia';

  @override
  String get data => 'Daten';

  @override
  String get version => 'Version';

  @override
  String versionOf(String version) {
    return 'Version: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Versions Nummer: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Paketname: $name';
  }

  @override
  String get exportImport => 'Exportieren / Importieren';

  @override
  String get exportDir => 'Export Ordner';

  @override
  String get exportAfterEveryInput => 'Export nach jedem Eintrag';

  @override
  String get exportAfterEveryInputDesc => 'Nicht empfohlen (datenexplosion)';

  @override
  String get exportFormat => 'Exportformat';

  @override
  String get exportCustomEntries => 'Eigene Felder';

  @override
  String get addEntry => 'Feld hinzufügen';

  @override
  String get exportMimeType => 'Export medien typ';

  @override
  String get exportCsvHeadline => 'Überschrift';

  @override
  String get exportCsvHeadlineDesc => 'Feldbezeichnungen zum Differenzieren';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'Text';

  @override
  String get other => 'Anderes';

  @override
  String get fieldDelimiter => 'Feldseparator';

  @override
  String get textDelimiter => 'Textbegrenzung';

  @override
  String get export => 'EXPORT';

  @override
  String get shared => 'Geteilt';

  @override
  String get import => 'IMPORT';

  @override
  String get sourceCode => 'Quellcode';

  @override
  String get licenses => 'Lizenzen dritter';

  @override
  String importSuccess(int count) {
    return 'Es wurden $count Einträge importiert';
  }

  @override
  String get exportWarnConfigNotImportable => 'Hey! Nur eine freundliche Info: Die aktuelle Exportkonfiguration ist nicht importierbar. Um das zu beheben, stelle sicher, dass der Exporttyp als CSV festgelegt ist und eines der verfügbaren Zeitformate enthalten ist.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'einige Felder werden',
      one: 'ein Feld wird',
    );
    return 'Achtung, $_temp0 nicht exportiert: $fields.';
  }

  @override
  String get statistics => 'Statistik';

  @override
  String get measurementCount => 'Anzahl Messungen';

  @override
  String get measurementsPerDay => 'Messungen pro Tag';

  @override
  String get timeResolvedMetrics => 'Werte nach Tageszeit';

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
  String get warnValues => 'Warnwerte';

  @override
  String get warnAboutTxt1 => 'Die Warnwerte sind lediglich Vorschläge, kein medizinischer Rat.';

  @override
  String get warnAboutTxt2 => 'Die voreingestellten Basiswerte für Altersstufen stammen aus dieser Quelle.';

  @override
  String get warnAboutTxt3 => 'Ändere die Werte nach Bedarf und stimme dich mit deinem Arzt ab.';

  @override
  String get enterTimeFormatString => 'Zeitformat-String';

  @override
  String get now => 'jetzt';

  @override
  String get notes => 'Notizen';

  @override
  String get time => 'Zeitpunkt';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmDeleteDesc => 'Soll der Eintrag gelöscht werden? (Diese Rückfragen können in den Einstellungen abgestellt werden.)';

  @override
  String get deletionConfirmed => 'Eintrag gelöscht.';

  @override
  String get day => 'Tag';

  @override
  String get week => 'Woche';

  @override
  String get month => 'Monat';

  @override
  String get year => 'Jahr';

  @override
  String get lifetime => 'Lebenszeit';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Woche $weekNum, $year';
  }

  @override
  String get last7Days => '7 Tage';

  @override
  String get last30Days => '30 Tage';

  @override
  String get allowMissingValues => 'Fehlende Werte erlauben';

  @override
  String get errTimeAfterNow => 'Die ausgewählte Uhrzeit wurde zurückgesetzt, da sie in der Zukunft liegt. Die Überprüfung lässt sich in den Einstellungen deaktivieren.';

  @override
  String get language => 'Sprache';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get drawRegressionLines => 'Zeichne Trendlinien';

  @override
  String get drawRegressionLinesDesc => 'Zeichne Regressionslinien im Graphen. Nur nützlich für große Intervalle.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Blutdruckwerte von $start bis $end';
  }

  @override
  String get fieldFormat => 'Feldformat';

  @override
  String get result => 'Ergebnis:';

  @override
  String get pulsePressure => 'Pulsdruck';

  @override
  String get addExportformat => 'Exportformat hinzufügen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get exportFieldFormatDocumentation => '## Variablen\nDas Exportfeldformat unterstützt das Einfügen von Werten für die folgenden Platzhalter:\n- `\$TIMESTAMP:` Stellt die Zeit seit der Unix-Epoche in Millisekunden dar.\n- `\$SYS:` Liefert einen Wert, falls vorhanden; andernfalls ist er standardmäßig -1.\n- `\$DIA:` Liefert einen Wert, falls vorhanden; andernfalls ist er standardmäßig -1.\n- `\$PUL:` Gibt einen Wert an, falls verfügbar; andernfalls ist er standardmäßig -1.\n- `\$NOTE:` Gibt einen Wert an, falls verfügbar; andernfalls ist er standardmäßig -1.\n- `\$COLOR:` Repräsentiert die Farbe einer Messung als eine Zahl. (Beispielwert: `4291681337`)\n\nWenn einer der oben genannten Platzhalter im Blutdruckdatensatz nicht vorhanden ist, wird er durch -1 ersetzt.\n\n## Mathematik\nInnerhalb von Doppelklammern (\"`{{}}`\") kannst Du die Grundrechenarten verwenden.\n\nDie folgenden mathematischen Operationen werden unterstützt:\n- Operationen: +, -, *, /, %, ^\n- Funktionen mit einem Parameter: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Funktionen mit zwei Parametern: log, nrt, pow\n- Konstanten: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nDie vollständige Spezifikation des mathematischen Interpreters findest Du in der [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) Spezifikation\n\n## Reihenfolge der Verarbeitung\n1. Variablen-Ersetzung\n2. Mathematik';

  @override
  String get default_ => 'Standard';

  @override
  String get exportPdfHeaderHeight => 'Höhe der Kopfzeile';

  @override
  String get exportPdfCellHeight => 'Zeilenhöhe';

  @override
  String get exportPdfHeaderFontSize => 'Schriftgröße der Kopfzeile';

  @override
  String get exportPdfCellFontSize => 'Zeilen-Schriftgröße';

  @override
  String get average => 'Durchschnitt';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'Überschrift';

  @override
  String get exportPdfExportStatistics => 'Statistik';

  @override
  String get exportPdfExportData => 'Datentabelle';

  @override
  String get startWithAddMeasurementPage => 'Eintrag nach Start';

  @override
  String get startWithAddMeasurementPageDescription => 'Nach dem App-Start öffnet sich die Messungserfassungsseite.';

  @override
  String get horizontalLines => 'Horizontale Linien';

  @override
  String get linePositionY => 'Linienposition (y)';

  @override
  String get customGraphMarkings => 'Eigene Markierungen';

  @override
  String get addLine => 'Linie hinzufügen';

  @override
  String get useLegacyList => 'Bisheriges Listenlayout verwenden';

  @override
  String get addMeasurement => 'Messung hinzufügen';

  @override
  String get timestamp => 'Zeitstempel';

  @override
  String get note => 'Anmerkung';

  @override
  String get color => 'Farbe';

  @override
  String get exportSettings => 'Einstellungen sichern';

  @override
  String get importSettings => 'Einstellungen wiederherstellen';

  @override
  String get requiresAppRestart => 'Erfordert Neustart der App';

  @override
  String get restartNow => 'Jetzt neustarten';

  @override
  String get warnNeedsRestartForUsingApp => 'Es wurden Dateien gelöscht. Starten sie die App neu bevor sie mit der Benutzung fortfahren!';

  @override
  String get deleteAllMeasurements => 'Alle Einträge löschen';

  @override
  String get deleteAllSettings => 'Alle Einstellungen löschen';

  @override
  String get warnDeletionUnrecoverable => 'Diese Handlung ist unumkehrbar, wenn sie keine Sicherung gemacht haben. Wollen sie wirklich mit der Löschung fortfahren?';

  @override
  String get enterTimeFormatDesc => 'Das Datumsformat besteht aus einer Mischung vordefinierter ICU-Strings sowie anderer Zeichen deiner Wahl.\n\n[Die vollständige Liste gültiger Formate findest du hier.](screen://TimeFormattingHelp)\n\nBitte beachte, dass kürzere/längere Zeitformat-Strings nicht die Spaltenbreiten ändern. Sie führen eher zu unerwünschten Umbrüchen.\n\nVoreingestellt: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Farblinienstärke';

  @override
  String get needlePinBarWidthDesc => 'Die Dicke der Linien, aus denen der Graph besteht.';

  @override
  String get errParseEmptyCsvFile => 'Es sind nicht genug Zeilen in der csv-Datei, um den Eintrag wiederherzustellen.';

  @override
  String get errParseTimeNotRestoreable => 'Es ist keine Spalte zum wiederherstellen des Zeitstempels vorhanden.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Es wurde keine Spalte mit dem Titel \"$title\" gefunden.';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Zeile $lineNumber ist kürzer als die erste Zeile.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Kann Feld \"$fieldContent\" in Zeile $lineNumber nicht entpacken.';
  }

  @override
  String get exportFieldsPreset => 'Export-spalten Voreinstellung';

  @override
  String get remove => 'Entfernen';

  @override
  String get manageExportColumns => 'Export-spalten Verwaltung';

  @override
  String get buildIn => 'Eingebaut';

  @override
  String get csvTitle => 'CSV-titel';

  @override
  String get recordFormat => 'Eintragsformatierung';

  @override
  String get timeFormat => 'Zeitformatierung';

  @override
  String get errAccuracyLoss => 'Es ist ein Genauigkeitsverlust zu erwarten, wenn eigene Zeitformate verwendet werden.';

  @override
  String get bottomAppBars => 'Dialogschaltflächen am unteren Bildschirmrand';

  @override
  String get medications => 'Medikamentierungen';

  @override
  String get addMedication => 'Medikamentierung hinzufügen';

  @override
  String get name => 'Bezeichnung';

  @override
  String get defaultDosis => 'Standarddosis';

  @override
  String get noMedication => 'Keine Medikamentierung';

  @override
  String get dosis => 'Dosis';

  @override
  String get valueDistribution => 'Werteverteilung';

  @override
  String get titleInCsv => 'Titel in CSV-Dateien';

  @override
  String get errBleNoPerms => 'Keine Bluetooth Berechtigung';

  @override
  String get preferredPressureUnit => 'Bevorzugte Druck-Maßeinheit';

  @override
  String get compactList => 'Kompakte Messwertliste';

  @override
  String get bluetoothDisabled => 'Bluetooth deaktiviert';

  @override
  String get errMeasurementRead => 'Fehler während der Messung!';

  @override
  String get measurementSuccess => 'Messung erfolgreich durchgeführt!';

  @override
  String get connect => 'Verbinden';

  @override
  String get bluetoothInput => 'Bluetooth Eingabe';

  @override
  String get aboutBleInput => 'Manche Messgeräte sind BLE GATT kompatibel. Du kannst diese Geräte hier koppeln und die Messungen automatisch übertragen. Alternativ deaktiviere diese Option in den Einstellungen.';

  @override
  String get scanningForDevices => 'Suche nach Geräten';

  @override
  String get tapToClose => 'Drücken zum Schließen.';

  @override
  String get meanArterialPressure => 'Mittlerer arterieller Blutdruck';

  @override
  String get userID => 'Nutzer ID';

  @override
  String get bodyMovementDetected => 'Körperbewegung erkannt';

  @override
  String get cuffTooLoose => 'Manschette zu locker';

  @override
  String get improperMeasurementPosition => 'Falsche Messposition';

  @override
  String get irregularPulseDetected => 'Unregelmäßiger Puls festgestellt';

  @override
  String get pulseRateExceedsUpperLimit => 'Pulsfrequenz übersteigt oberes Limit';

  @override
  String get pulseRateLessThanLowerLimit => 'Pulsfrequenz unterschreitet unteres Limit';

  @override
  String get availableDevices => 'Verfügbare Geräte';

  @override
  String get deleteAllMedicineIntakes => 'Alle Medikamenteneinnahmen löschen';

  @override
  String get deleteAllNotes => 'Alle Notizen löschen';

  @override
  String get date => 'Datum';

  @override
  String get intakes => 'Medikamenten-Einnahmen';

  @override
  String get errFeatureNotSupported => 'Diese Funktion ist auf dieser Plattform nicht verfügbar.';

  @override
  String get invalidZip => 'Ungültige ZIP-Datei.';

  @override
  String get errCantCreateArchive => 'Konnte Archiv nicht erstellen. Bitte melden Sie wenn möglich diesen Fehler.';

  @override
  String get activateWeightFeatures => 'Gewichtsbezogene Funktionen aktivieren';

  @override
  String get weight => 'Gewicht';

  @override
  String get enterWeight => 'Gewicht eingeben';

  @override
  String get selectMeasurementTitle => 'Zu nutzende Messung auswählen';

  @override
  String measurementIndex(int number) {
    return 'Messung #$number';
  }

  @override
  String get select => 'Auswählen';

  @override
  String get bloodPressure => 'Blutdruck';

  @override
  String get preferredWeightUnit => 'Bevorzugte Maßeinheit für Gewicht';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get oldBluetoothInput => 'Stable';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta cross-platform';

  @override
  String get bluetoothInputDesc => 'Das Beta-Backend funktioniert auf mehr Geräten, ist aber weniger getestet. Die plattformübergreifende Version kann auf Nicht-Android-Geräten funktionieren und soll die stabile Implementierung ablösen, sobald sie ausgereift genug ist.';

  @override
  String get tapToSelect => 'Tap to select';
}
