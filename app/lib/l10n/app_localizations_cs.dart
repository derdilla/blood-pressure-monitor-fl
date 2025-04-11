// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get title => 'Aplikace Krevní tlak';

  @override
  String success(String msg) {
    return 'Úspěch: $msg';
  }

  @override
  String get loading => 'načítání…';

  @override
  String error(String msg) {
    return 'Chyba: $msg';
  }

  @override
  String get errNaN => 'Zadejte číslo';

  @override
  String get errLt30 => 'Číslo <= 30? Vypněte ověřování v nastavení!';

  @override
  String get errUnrealistic => 'Nereálná hodnota? Vypněte ověřování v nastavení!';

  @override
  String get errDiaGtSys => 'dia >= sys? Vypněte ověřování v nastavení!';

  @override
  String errCantOpenURL(String url) {
    return 'Nelze otevřít URL: $url';
  }

  @override
  String get errNoFileOpened => 'nebyl otevřen žádný soubor';

  @override
  String get errNotStarted => 'není spuštěn';

  @override
  String get errNoValue => 'Zadejte hodnotu';

  @override
  String get errNotEnoughDataToGraph => 'Není dostatek dat pro nakreslení grafu.';

  @override
  String get errNoData => 'nejsou data';

  @override
  String get errWrongImportFormat => 'Importovat lze pouze soubory ve formátu CSV a databáze SQLite.';

  @override
  String get errNeedHeadline => 'Importovat lze pouze soubory s nadpisem.';

  @override
  String get errCantReadFile => 'Obsah souboru nelze přečíst';

  @override
  String get errNotImportable => 'Tento soubor nelze importovat';

  @override
  String get btnCancel => 'ZRUŠIT';

  @override
  String get btnSave => 'ULOŽIT';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'ZPĚT';

  @override
  String get sysLong => 'Systolický';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastolický';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pulz';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Poznámka (volitelně)';

  @override
  String get settings => 'Nastavení';

  @override
  String get layout => 'Rozvržení';

  @override
  String get allowManualTimeInput => 'Povolit ruční zadání času';

  @override
  String get enterTimeFormatScreen => 'Formát času';

  @override
  String get theme => 'Motiv';

  @override
  String get system => 'Systém';

  @override
  String get dark => 'Tmavý';

  @override
  String get light => 'Světlý';

  @override
  String get iconSize => 'Velikost ikon';

  @override
  String get graphLineThickness => 'Tloušťka linky';

  @override
  String get animationSpeed => 'Trvání animace';

  @override
  String get accentColor => 'Barva motivu';

  @override
  String get sysColor => 'Systolická barva';

  @override
  String get diaColor => 'Diastolická barva';

  @override
  String get pulColor => 'Barva pulzu';

  @override
  String get behavior => 'Chování';

  @override
  String get validateInputs => 'Ověření vstupů';

  @override
  String get confirmDeletion => 'Potvrdit smazání';

  @override
  String get age => 'Věk';

  @override
  String get determineWarnValues => 'Určení varovných hodnot';

  @override
  String get aboutWarnValuesScreen => 'O...';

  @override
  String get aboutWarnValuesScreenDesc => 'Více informací o varovných hodnotách';

  @override
  String get sysWarn => 'Systolické varování';

  @override
  String get diaWarn => 'Diastolické varování';

  @override
  String get data => 'Data';

  @override
  String get version => 'Verze';

  @override
  String versionOf(String version) {
    return 'Verze: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Číslo verze: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Název balíčku: $name';
  }

  @override
  String get exportImport => 'Export / Import';

  @override
  String get exportDir => 'Adresář exportu';

  @override
  String get exportAfterEveryInput => 'Export po každém záznamu';

  @override
  String get exportAfterEveryInputDesc => 'Nedoporučuje se (mnoho souborů)';

  @override
  String get exportFormat => 'Formát exportu';

  @override
  String get exportCustomEntries => 'Přizpůsobit pole';

  @override
  String get addEntry => 'Přidat pole';

  @override
  String get exportMimeType => 'Typ exportovaného média';

  @override
  String get exportCsvHeadline => 'Záhlaví';

  @override
  String get exportCsvHeadlineDesc => 'Pomáhá rozlišit typy';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'text';

  @override
  String get other => 'jiné';

  @override
  String get fieldDelimiter => 'Oddělovač polí';

  @override
  String get textDelimiter => 'Oddělovač textu';

  @override
  String get export => 'EXPORT';

  @override
  String get shared => 'sdílené';

  @override
  String get import => 'IMPORT';

  @override
  String get sourceCode => 'Zdrojový kód';

  @override
  String get licenses => 'Licence třetích stran';

  @override
  String importSuccess(int count) {
    return 'Importováno $count záznamů';
  }

  @override
  String get exportWarnConfigNotImportable => 'Ahoj! Jen přátelské upozornění: aktuální konfiguraci exportu nebude možné importovat. Chcete-li to napravit, ujistěte se, že jste nastavili typ exportu jako CSV a uvedli jeden z dostupných časových formátů.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Dejte si pozor, abyste neexportovali všechna pole: $fields $_temp0 chybí.';
  }

  @override
  String get statistics => 'Statistika';

  @override
  String get measurementCount => 'Počet měření';

  @override
  String get measurementsPerDay => 'Měření za den';

  @override
  String get timeResolvedMetrics => 'Metriky podle denní doby';

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
  String get warnValues => 'Varovné hodnoty';

  @override
  String get warnAboutTxt1 => 'Varovné hodnoty jsou pouhým doporučením, nikoli lékařským doporučením.';

  @override
  String get warnAboutTxt2 => 'Výchozí hodnoty závislé na věku pocházejí z tohoto zdroje.';

  @override
  String get warnAboutTxt3 => 'Nebojte se změnit hodnoty podle svých potřeb a dodržujte doporučení svého lékaře.';

  @override
  String get enterTimeFormatString => 'formát času';

  @override
  String get now => 'teď';

  @override
  String get notes => 'Poznámky';

  @override
  String get time => 'Čas';

  @override
  String get confirmDelete => 'Potvrzení smazání';

  @override
  String get confirmDeleteDesc => 'Smazat tuto položku? (Tato potvrzení můžete vypnout v nastavení.)';

  @override
  String get deletionConfirmed => 'Záznam smazán.';

  @override
  String get day => 'Den';

  @override
  String get week => 'Týden';

  @override
  String get month => 'Měsíc';

  @override
  String get year => 'Rok';

  @override
  String get lifetime => 'Celé období';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Týden $weekNum, $year';
  }

  @override
  String get last7Days => '7 dní';

  @override
  String get last30Days => '30 dní';

  @override
  String get allowMissingValues => 'Povolit chybějící hodnoty';

  @override
  String get errTimeAfterNow => 'Vybraný denní čas byl vynulován, protože nastane po tomto okamžiku. Tuto validaci můžete vypnout v nastavení.';

  @override
  String get language => 'Jazyk';

  @override
  String get custom => 'Vlastní';

  @override
  String get drawRegressionLines => 'Kreslení trendových čar';

  @override
  String get drawRegressionLinesDesc => 'Kreslí regresní přímky do grafu. Užitečné pouze pro velké intervaly.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Hodnoty krevního tlaku od $start do $end';
  }

  @override
  String get fieldFormat => 'Formát pole';

  @override
  String get result => 'Výsledek:';

  @override
  String get pulsePressure => 'Pulzní tlak';

  @override
  String get addExportformat => 'Přidat exportní formát';

  @override
  String get edit => 'Upravit';

  @override
  String get delete => 'Smazat';

  @override
  String get exportFieldFormatDocumentation => '## Proměnné\nFormát exportního pole podporuje vkládání hodnot pro následující zástupné znaky:\n- `\$TIMESTAMP:` Představuje čas od epochy Unixu v milisekundách.\n- `\$SYS:` Uvádí hodnotu, pokud je k dispozici; jinak je výchozí hodnota -1.\n- `\$DIA:` Udává hodnotu, pokud je k dispozici; jinak je výchozí hodnotou -1.\n- `\$PUL:` Udává hodnotu, je-li k dispozici; jinak je výchozí hodnotou -1.\n- `\$NOTE:` Udává hodnotu, je-li k dispozici; jinak je výchozí hodnotou -1.\n- `\$COLOR:` Představuje barvu měření jako číslo. (příklad hodnoty: `4291681337`)\n\nPokud některý z výše uvedených zástupných symbolů není v záznamu krevního tlaku přítomen, bude nahrazen hodnotou `null`.\n\n## Math\nUvnitř dvojitých závorek (\"`{{}}`\") můžete používat základní matematické údaje.\n\nPodporovány jsou následující matematické operace:\n- Operace: +, -, *, /, %, ^\n- Jednoparametrové funkce: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Dvouparametrové funkce: log, nrt, pow\n- Konstanty: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nÚplnou specifikaci matematického interpretu najdete v dokumentaci [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter).\n\n## Pořadí zpracování\n1. nahrazení proměnné\n2. Math';

  @override
  String get default_ => 'Výchozí';

  @override
  String get exportPdfHeaderHeight => 'Výška záhlaví';

  @override
  String get exportPdfCellHeight => 'Výška řádku';

  @override
  String get exportPdfHeaderFontSize => 'Velikost písma záhlaví';

  @override
  String get exportPdfCellFontSize => 'Velikost písma řádku';

  @override
  String get average => 'Průměr';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'Záhlaví';

  @override
  String get exportPdfExportStatistics => 'Statistika';

  @override
  String get exportPdfExportData => 'Tabulka dat';

  @override
  String get startWithAddMeasurementPage => 'Měření při spuštění';

  @override
  String get startWithAddMeasurementPageDescription => 'Po spuštění aplikace se zobrazí obrazovka pro zadávání měření.';

  @override
  String get horizontalLines => 'Vodorovné čáry';

  @override
  String get linePositionY => 'Poloha čáry (y)';

  @override
  String get customGraphMarkings => 'Vlastní značení';

  @override
  String get addLine => 'Přidat linku';

  @override
  String get useLegacyList => 'Použít starší seznam';

  @override
  String get addMeasurement => 'Přidat měření';

  @override
  String get timestamp => 'Časové razítko';

  @override
  String get note => 'Poznámka';

  @override
  String get color => 'Barva';

  @override
  String get exportSettings => 'Nastavení zálohy';

  @override
  String get importSettings => 'Obnovit nastavení';

  @override
  String get requiresAppRestart => 'Vyžaduje restart aplikace';

  @override
  String get restartNow => 'Restartovat';

  @override
  String get warnNeedsRestartForUsingApp => 'Soubory, které byly v této relaci odstraněny. Restartujte aplikaci, abyste mohli pokračovat v používání a vrátit se do dalších částí aplikace!';

  @override
  String get deleteAllMeasurements => 'Odstranit všechna měření';

  @override
  String get deleteAllSettings => 'Odstranit všechna nastavení';

  @override
  String get warnDeletionUnrecoverable => 'Tento krok nelze vrátit, pokud jste ručně neprovedli zálohu. Opravdu to chcete smazat?';

  @override
  String get enterTimeFormatDesc => 'Formátovací řetězec je směs předdefinovaných řetězců ICU/Skeleton a jakéhokoli dalšího textu, který chcete zahrnout.\n\n[Pokud vás zajímá úplný seznam platných formátů, najdete je přímo zde] (screen://TimeFormattingHelp).\n\nJen přátelsky připomínáme, že použití delších nebo kratších formátovacích řetězců nezmění zázračně šířku sloupců tabulky, což by mohlo vést k nepříjemnému zalomení řádků a nezobrazení textu.\n\nvýchozí: „yy-MM-dd HH:mm“';

  @override
  String get needlePinBarWidth => 'Tloušťka barvy';

  @override
  String get needlePinBarWidthDesc => 'Šířka čar, které barevné položky tvoří v grafu.';

  @override
  String get errParseEmptyCsvFile => 'V souboru csv není dostatek řádků pro analýzu záznamu.';

  @override
  String get errParseTimeNotRestoreable => 'Neexistuje žádný sloupec, který by umožňoval obnovení časového razítka.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Neexistuje žádný sloupec s názvem „$title“.';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Řádek $lineNumber má méně sloupců než první řádek.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Dekódování pole „$fieldContent“ v řádku $lineNumber se nezdařilo.';
  }

  @override
  String get exportFieldsPreset => 'Předvolba polí pro export';

  @override
  String get remove => 'Odstranit';

  @override
  String get manageExportColumns => 'Správa sloupců pro export';

  @override
  String get buildIn => 'Integrované';

  @override
  String get csvTitle => 'CSV-název';

  @override
  String get recordFormat => 'Formát záznamu';

  @override
  String get timeFormat => 'Formát času';

  @override
  String get errAccuracyLoss => 'Při exportu s vlastními formátovači času se očekává ztráta přesnosti.';

  @override
  String get bottomAppBars => 'Spodní dialogové lišty';

  @override
  String get medications => 'Léky';

  @override
  String get addMedication => 'Přidat léky';

  @override
  String get name => 'Název';

  @override
  String get defaultDosis => 'Výchozí dávkování';

  @override
  String get noMedication => 'Žádné léky';

  @override
  String get dosis => 'Dávkování';

  @override
  String get valueDistribution => 'Rozložení hodnot';

  @override
  String get titleInCsv => 'Název v CSV';

  @override
  String get errBleNoPerms => 'Žádné oprávnění Bluetooth';

  @override
  String get preferredPressureUnit => 'Preferovaná jednotka tlaku';

  @override
  String get compactList => 'Kompaktní seznam měření';

  @override
  String get bluetoothDisabled => 'Bluetooth vypnuto';

  @override
  String get errMeasurementRead => 'Chyba během měření!';

  @override
  String get measurementSuccess => 'Měření proběhlo úspěšně!';

  @override
  String get connect => 'Připojit';

  @override
  String get bluetoothInput => 'Vstup Bluetooth';

  @override
  String get aboutBleInput => 'Některá měřicí zařízení jsou kompatibilní s BLE GATT. Tato zařízení zde můžete spárovat a automaticky přenášet měření nebo tuto možnost v nastavení zakázat.';

  @override
  String get scanningForDevices => 'Skenování zařízení';

  @override
  String get tapToClose => 'Klepnutím zavřete.';

  @override
  String get meanArterialPressure => 'Střední arteriální tlak';

  @override
  String get userID => 'ID uživatele';

  @override
  String get bodyMovementDetected => 'Zjištěný pohyb těla';

  @override
  String get cuffTooLoose => 'Příliš volná manžeta';

  @override
  String get improperMeasurementPosition => 'Nesprávná poloha při měření';

  @override
  String get irregularPulseDetected => 'Zjištěn nepravidelný puls';

  @override
  String get pulseRateExceedsUpperLimit => 'Tepová frekvence překračuje horní hranici';

  @override
  String get pulseRateLessThanLowerLimit => 'Tepová frekvence je nižší než spodní hranice';

  @override
  String get availableDevices => 'Dostupná zařízení';

  @override
  String get deleteAllMedicineIntakes => 'Vymazat všechny příjmy léků';

  @override
  String get deleteAllNotes => 'Odstranit všechny poznámky';

  @override
  String get date => 'Datum';

  @override
  String get intakes => 'Příjem léků';

  @override
  String get errFeatureNotSupported => 'Tato funkce není na této platformě k dispozici.';

  @override
  String get invalidZip => 'Neplatný soubor zip.';

  @override
  String get errCantCreateArchive => 'Nelze vytvořit archiv. Pokud je to možné, nahlaste prosím chybu.';

  @override
  String get activateWeightFeatures => 'Aktivace funkcí souvisejících s hmotností';

  @override
  String get weight => 'Hmotnost';

  @override
  String get enterWeight => 'Zadejte hmotnost';

  @override
  String get selectMeasurementTitle => 'Zvolte měření, které chcete použít';

  @override
  String measurementIndex(int number) {
    return 'Měření #$number';
  }

  @override
  String get select => 'Vybrat';

  @override
  String get bloodPressure => 'Krevní tlak';

  @override
  String get preferredWeightUnit => 'Preferovaná jednotka hmotnosti';

  @override
  String get disabled => 'Vypnuto';

  @override
  String get oldBluetoothInput => 'Stabilní';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta multiplatformní';

  @override
  String get bluetoothInputDesc => 'Beta verze backendu funguje na více zařízeních, ale je méně otestovaná. Multiplatformní verze může fungovat i na jiných zařízeních než Android a plánuje se, že nahradí stabilní implementaci, jakmile bude dostatečně zralá.';

  @override
  String get tapToSelect => 'Tap to select';
}
