// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get title => 'Bloeddruk App';

  @override
  String success(String msg) {
    return 'Succes: $msg';
  }

  @override
  String get loading => 'laden…';

  @override
  String error(String msg) {
    return 'Fout: $msg';
  }

  @override
  String get errNaN => 'Voer een nummer in';

  @override
  String get errLt30 => 'Nummer <= 30? Zet validatie uit in instellingen!';

  @override
  String get errUnrealistic => 'Onrealistische waarde? Zet validatie uit in instellingen!';

  @override
  String get errDiaGtSys => 'dia >= sys? Zet validatie uit in instellingen!';

  @override
  String errCantOpenURL(String url) {
    return 'Kan URL niet openen: $url';
  }

  @override
  String get errNoFileOpened => 'geen bestand geopend';

  @override
  String get errNotStarted => 'niet begonnen';

  @override
  String get errNoValue => 'Voer een waarde in';

  @override
  String get errNotEnoughDataToGraph => 'Niet genoeg gegevens om een grafiek te tekenen.';

  @override
  String get errNoData => 'geen gegevens';

  @override
  String get errWrongImportFormat => 'Alleen bestanden met CSV of SQLite database formaat kunnen geimporteerd worden.';

  @override
  String get errNeedHeadline => 'Alleen bestanden die beginnen met een veldregel kunnen geimporteerd worden.';

  @override
  String get errCantReadFile => 'De inhoud van het bestand kon niet gelezen worden';

  @override
  String get errNotImportable => 'Dit bestand kan niet geimporteerd worden';

  @override
  String get btnCancel => 'ANNULEREN';

  @override
  String get btnSave => 'OPSLAAN';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'ONGEDAAN MAKEN';

  @override
  String get sysLong => 'Systolisch';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastolisch';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Hartslag';

  @override
  String get pulShort => 'slg';

  @override
  String get addNote => 'Opmerking (optioneel)';

  @override
  String get settings => 'Instellingen';

  @override
  String get layout => 'Opmaak';

  @override
  String get allowManualTimeInput => 'Sta handmatige tijdsinvoer toe';

  @override
  String get enterTimeFormatScreen => 'Tijdsformaat';

  @override
  String get theme => 'Thema';

  @override
  String get system => 'Systeem';

  @override
  String get dark => 'Donker';

  @override
  String get light => 'Licht';

  @override
  String get iconSize => 'Pictogram Grootte';

  @override
  String get graphLineThickness => 'Lijndikte';

  @override
  String get animationSpeed => 'Animatie duur';

  @override
  String get accentColor => 'Thema kleur';

  @override
  String get sysColor => 'Systolische kleur';

  @override
  String get diaColor => 'Diastolische kleur';

  @override
  String get pulColor => 'Hartslag kleur';

  @override
  String get behavior => 'Gedrag';

  @override
  String get validateInputs => 'Valideer invoer';

  @override
  String get confirmDeletion => 'Bevestig verwijderingen';

  @override
  String get age => 'Leeftijd';

  @override
  String get determineWarnValues => 'Waarschuwingswaarden bepalen';

  @override
  String get aboutWarnValuesScreen => 'Over';

  @override
  String get aboutWarnValuesScreenDesc => 'Meer info over waarschuwingswaarden';

  @override
  String get sysWarn => 'Systolische waarschuwingswaarde';

  @override
  String get diaWarn => 'Diatolische waarschuwingswaarde';

  @override
  String get data => 'Gegevens';

  @override
  String get version => 'Versie';

  @override
  String versionOf(String version) {
    return 'Versie: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Versienummer: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Pakketnaam: $name';
  }

  @override
  String get exportImport => 'Exporteer / Importeer';

  @override
  String get exportDir => 'Exportmap';

  @override
  String get exportAfterEveryInput => 'Exporteer na elke invoer';

  @override
  String get exportAfterEveryInputDesc => 'Niet aangeraden (bestandsexplosie)';

  @override
  String get exportFormat => 'Exportformaat';

  @override
  String get exportCustomEntries => 'Velden aanpassen';

  @override
  String get addEntry => 'Voeg veld toe';

  @override
  String get exportMimeType => 'Type exportmedia';

  @override
  String get exportCsvHeadline => 'Veldregel';

  @override
  String get exportCsvHeadlineDesc => 'Helpt velden te onderscheiden';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'tekst';

  @override
  String get other => 'andere';

  @override
  String get fieldDelimiter => 'Veldscheidingsteken';

  @override
  String get textDelimiter => 'Tekstscheidingsteken';

  @override
  String get export => 'EXPORTEER';

  @override
  String get shared => 'gedeeld';

  @override
  String get import => 'IMPORTEER';

  @override
  String get sourceCode => 'Broncode';

  @override
  String get licenses => 'Licenties van derden';

  @override
  String importSuccess(int count) {
    return '$count items geimporteerd';
  }

  @override
  String get exportWarnConfigNotImportable => 'Hoi! Een vriendelijke waarschuwing: met de huidige instellingen kan de export niet geimporteerd worden. Los dit op door het export formaat als CSV in te stellen en voeg een van de beschikbare tijdsformaten toe.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'missen',
      one: 'mist',
    );
    return 'Let op dat niet alle velden geëxporteerd worden: $fields $_temp0.';
  }

  @override
  String get statistics => 'Statistiek';

  @override
  String get measurementCount => 'Aantal metingen';

  @override
  String get measurementsPerDay => 'Metingen per dag';

  @override
  String get timeResolvedMetrics => 'Tijds-Gerelateerde Statistiek';

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
  String get warnValues => 'Waarschuwingswaarden';

  @override
  String get warnAboutTxt1 => 'Waarschuwingswaarden zijn enkel suggesties en geen medisch advies.';

  @override
  String get warnAboutTxt2 => 'De standaard leeftijdsgerelateerde waarden zijn afkomstig van deze bron.';

  @override
  String get warnAboutTxt3 => 'Wees vrij om deze waarden aan te passen naar uw behoeftes en volg de aanbevelingen van uw dokter.';

  @override
  String get enterTimeFormatString => 'tijdsformaat';

  @override
  String get now => 'nu';

  @override
  String get notes => 'Opmerkingen';

  @override
  String get time => 'Tijd';

  @override
  String get confirmDelete => 'Bevestig verwijderen';

  @override
  String get confirmDeleteDesc => 'Verwijder dit item? (Deze bevestigingsvragen kunt u uitzetten in de instellingen.)';

  @override
  String get deletionConfirmed => 'Item verwijderd.';

  @override
  String get day => 'Dag';

  @override
  String get week => 'Week';

  @override
  String get month => 'Maand';

  @override
  String get year => 'Jaar';

  @override
  String get lifetime => 'Levensduur';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Week $weekNum, $year';
  }

  @override
  String get last7Days => '7 dagen';

  @override
  String get last30Days => '30 dagen';

  @override
  String get allowMissingValues => 'Sta missende waarden toe';

  @override
  String get errTimeAfterNow => 'De geselecteerde tijd was in de toekomst en is teruggezet naar de huidige tijd. Deze validatie kan uitgezet worden in de instellingen.';

  @override
  String get language => 'Taal';

  @override
  String get custom => 'Aangepast';

  @override
  String get drawRegressionLines => 'Teken trendlijnen';

  @override
  String get drawRegressionLinesDesc => 'Tekent regressielijnen in de grafiek. Alleen zinvol voor grote intervallen.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Bloeddrukwaarden van $start tot $end';
  }

  @override
  String get fieldFormat => 'Veldformaat';

  @override
  String get result => 'Resultaat:';

  @override
  String get pulsePressure => 'Polsdruk';

  @override
  String get addExportformat => 'Voeg export formaat toe';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijder';

  @override
  String get exportFieldFormatDocumentation => '## Variabelen\nHet export veldformaat ondersteund het invoegen van waarden met de volgende aanduidingen:\n- `\$TIMESTAMP:` De tijd in milliseconds sinds het Unix tijdsperk.\n- `\$SYS:` Systolische waarde indien beschikbaar, anders -1.\n- `\$DIA:` Diatolische waarde indien beschikbaar, anders -1.\n- `\$PUL:` Polsdruk indien beschikbaar, anders -1.\n- `\$NOTE:` Opmerking indien beschikbaar, anders -1.\n- `\$COLOR:` De metingskleur als een nummer. (voorbeeld waarde: `4291681337`)\n\nIndien geen van bovenstaande aanduidingen beschikbaar zijn in een bloedsdrukmeting record, dan worden ze vervangen met `null`.\n\n## Wiskunde\nEenvoudige wiskunde kan gebruikt worden binnen dubbele haken (\"`{{}}`\").\n\nDe volgende wiskundige bewerkingen worden ondersteund:\n- Operaties: +, -, *, /, %, ^\n- Eén-parameter functies: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Twee-parameter functies: log, nrt, pow\n- Constanten: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nVoor de volledige wiskundige vertaler specificaties, zie de [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) documentatie.\n\n## Bewerkingsvolgorde\n1. aanduidingen vervangen\n2. Wiskunde';

  @override
  String get default_ => 'Standaard';

  @override
  String get exportPdfHeaderHeight => 'Koptekst hoogte';

  @override
  String get exportPdfCellHeight => 'Regel hoogte';

  @override
  String get exportPdfHeaderFontSize => 'Koptekst lettergrootte';

  @override
  String get exportPdfCellFontSize => 'Regel lettergrootte';

  @override
  String get average => 'Gemiddeld';

  @override
  String get maximum => 'Maximaal';

  @override
  String get minimum => 'Minimaal';

  @override
  String get exportPdfExportTitle => 'Koptekst';

  @override
  String get exportPdfExportStatistics => 'Statistiek';

  @override
  String get exportPdfExportData => 'Gegevenstabel';

  @override
  String get startWithAddMeasurementPage => 'Meting bij lanceren';

  @override
  String get startWithAddMeasurementPageDescription => 'Meetinvoerscherm weergeven als app gelanceerd wordt.';

  @override
  String get horizontalLines => 'Horizontale lijnen';

  @override
  String get linePositionY => 'Lijnpositie (y)';

  @override
  String get customGraphMarkings => 'Markeringen op maat';

  @override
  String get addLine => 'Voeg lijn toe';

  @override
  String get useLegacyList => 'Gebruik legacy lijst';

  @override
  String get addMeasurement => 'Voeg meting toe';

  @override
  String get timestamp => 'Tijdstip';

  @override
  String get note => 'Opmerking';

  @override
  String get color => 'Kleur';

  @override
  String get exportSettings => 'Backup instellingen';

  @override
  String get importSettings => 'Herstel instellingen';

  @override
  String get requiresAppRestart => 'App herstart vereist';

  @override
  String get restartNow => 'Nu herstarten';

  @override
  String get warnNeedsRestartForUsingApp => 'Er zijn bestanden verwijderd tijdens deze sessie. Start de app opnieuw op om door te gaan met terugkeren naar andere delen van de app!';

  @override
  String get deleteAllMeasurements => 'Verwijder alle metingen';

  @override
  String get deleteAllSettings => 'Verwijder alle instellingen';

  @override
  String get warnDeletionUnrecoverable => 'Deze stap is onomkeerbaar tenzij er handmatig een backup is gemaakt. Weet u zeker dat u dit wilt verwijderen?';

  @override
  String get enterTimeFormatDesc => 'Een formatteringstekenreeks is een combinatie van vooraf gedefinieerde ICU/Skeleton tekenreeksen met eventueel extra tekst die u wilt toevoegen.\n\n[Nieuwsgierig naar de volledige lijst met geldige tekenreeksen? U vindt ze hier.](screen://TimeFormattingHelp)\n\nEen vriendelijke herinnering, de breedte van tabelkolommen wordt niet automatisch veranderd met het gebruik van langere of kortere formaten. Dit kan zorgen \nvoor rare regeleindes en/of tekst dat niet zichtbaar is.\n\nstandaard: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Kleurdikte';

  @override
  String get needlePinBarWidthDesc => 'De breedte van lijnen van gekleurde items in de grafiek.';

  @override
  String get errParseEmptyCsvFile => 'Het csv bestand bevat niet genoeg regels om een record te parsen.';

  @override
  String get errParseTimeNotRestoreable => 'Er is geen kolom waarmee een tijdstip kan worden hersteld.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Er is geen kolom met titel \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Regel $lineNumber heeft minder kolommen dan de eerste regel.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Decoderen van veld \"$fieldContent\" op regel $lineNumber mislukt.';
  }

  @override
  String get exportFieldsPreset => 'Exporteer vooringestelde velden';

  @override
  String get remove => 'Verwijder';

  @override
  String get manageExportColumns => 'Export kolommen beheren';

  @override
  String get buildIn => 'Ingebouwd';

  @override
  String get csvTitle => 'CSV-titel';

  @override
  String get recordFormat => 'Record formaat';

  @override
  String get timeFormat => 'Tijdsformaat';

  @override
  String get errAccuracyLoss => 'Er wordt een nauwkeurigheidsverlies verwacht bij het exporteren met aangepaste tijdsformaten.';

  @override
  String get bottomAppBars => 'Onderste dialoog balk';

  @override
  String get medications => 'Medicaties';

  @override
  String get addMedication => 'Voeg medicatie toe';

  @override
  String get name => 'Naam';

  @override
  String get defaultDosis => 'Standaard dosis';

  @override
  String get noMedication => 'Geen medicatie';

  @override
  String get dosis => 'Dosis';

  @override
  String get valueDistribution => 'Waardeverdeling';

  @override
  String get titleInCsv => 'Titel in CSV';

  @override
  String get errBleNoPerms => 'Geen bluetooth rechten';

  @override
  String get preferredPressureUnit => 'Voorkeur drukeenheid';

  @override
  String get compactList => 'Compacte meetlijst';

  @override
  String get bluetoothDisabled => 'Bluetooth uitgeschakeld';

  @override
  String get errMeasurementRead => 'Fout tijdens het maken van de meting!';

  @override
  String get measurementSuccess => 'Meting succesvol uitgevoerd!';

  @override
  String get connect => 'Verbind';

  @override
  String get bluetoothInput => 'Bluetooth invoer';

  @override
  String get aboutBleInput => 'Sommige meetapparaten zijn BLE GATT compatibel. Deze apparaten kunnen hier gekoppeld worden en automatisch metingen verzenden of schakel deze optie uit in instellingen.';

  @override
  String get scanningForDevices => 'Scannen op apparaten';

  @override
  String get tapToClose => 'Tik om te sluiten.';

  @override
  String get meanArterialPressure => 'Gemiddelde slagaderlijke druk';

  @override
  String get userID => 'Gebruikers ID';

  @override
  String get bodyMovementDetected => 'Lichaamsbeweging gedetecteerd';

  @override
  String get cuffTooLoose => 'Manchet zit te los';

  @override
  String get improperMeasurementPosition => 'Onjuiste metingspositie';

  @override
  String get irregularPulseDetected => 'Onregelmatige hartslag gededecteerd';

  @override
  String get pulseRateExceedsUpperLimit => 'Hartslag is hoger dan de bovenste limiet';

  @override
  String get pulseRateLessThanLowerLimit => 'Hartslag is lager dan de onderste limiet';

  @override
  String get availableDevices => 'Beschikbare apparaten';

  @override
  String get deleteAllMedicineIntakes => 'Verwijder alle medicijninnames';

  @override
  String get deleteAllNotes => 'Verwijder alle opmerkingen';

  @override
  String get date => 'Datum';

  @override
  String get intakes => 'Medicijninname';

  @override
  String get errFeatureNotSupported => 'Deze functie is niet beschikbaar op dit platform.';

  @override
  String get invalidZip => 'Ongeldig zip bestand.';

  @override
  String get errCantCreateArchive => 'Kan archief niet aanmaken. Rapporteer deze fout indien mogelijk.';

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
