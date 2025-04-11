// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get title => 'Aplikacija za spremljanje krvnega tlaka';

  @override
  String success(String msg) {
    return 'Uspešno: $msg';
  }

  @override
  String get loading => 'nalaganje…';

  @override
  String error(String msg) {
    return 'Napaka: $msg';
  }

  @override
  String get errNaN => 'Prosim, vnesite vrednost';

  @override
  String get errLt30 => 'Vrednost je manj kot 30? V nastavitvah izključite preverjanje!';

  @override
  String get errUnrealistic => 'Nerealna vrednost? V nastavitvah izključite preverjanje!';

  @override
  String get errDiaGtSys => 'Diastolični pritisk je večji ali enak kot sistolični? V nastavitvah izključite preverjanje!';

  @override
  String errCantOpenURL(String url) {
    return 'Ne morem odpreti URL-ja: $url';
  }

  @override
  String get errNoFileOpened => 'datoteka ni bila odprta';

  @override
  String get errNotStarted => 'ni zagnano';

  @override
  String get errNoValue => 'Prosim, vnesite vrednost';

  @override
  String get errNotEnoughDataToGraph => 'Ni dovolj podatkov za izris grafa.';

  @override
  String get errNoData => 'ni podatkov';

  @override
  String get errWrongImportFormat => 'Uvozite lahko samo datoteke v CSV ali SQLite zapisu.';

  @override
  String get errNeedHeadline => 'Uvozite lahko samo datoteke z naslovno vrstico.';

  @override
  String get errCantReadFile => 'Vsebine datoteke ni mogoče prebrati';

  @override
  String get errNotImportable => 'Te datoteke ni mogoče uvoziti';

  @override
  String get btnCancel => 'PREKLIČI';

  @override
  String get btnSave => 'SHRANI';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'RAZVELJAVI';

  @override
  String get sysLong => 'Sistolični';

  @override
  String get sysShort => 'sis';

  @override
  String get diaLong => 'Diastolični';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Utrip';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Opomba (izbirno)';

  @override
  String get settings => 'Nastavitve';

  @override
  String get layout => 'Postavitev';

  @override
  String get allowManualTimeInput => 'Dovoli ročni vnos časa';

  @override
  String get enterTimeFormatScreen => 'Format časa';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistemska';

  @override
  String get dark => 'Temna';

  @override
  String get light => 'Svetla';

  @override
  String get iconSize => 'Velikost ikon';

  @override
  String get graphLineThickness => 'Debelina črte';

  @override
  String get animationSpeed => 'Trajanje animacije';

  @override
  String get accentColor => 'Barva teme';

  @override
  String get sysColor => 'Barva sistoličnega tlaka';

  @override
  String get diaColor => 'Barva diastoličnega tlaka';

  @override
  String get pulColor => 'Barva utripa';

  @override
  String get behavior => 'Obnašanje';

  @override
  String get validateInputs => 'Preverjaj vnose';

  @override
  String get confirmDeletion => 'Potrdi brisanje';

  @override
  String get age => 'Starost';

  @override
  String get determineWarnValues => 'Določi opozorilne vrednosti';

  @override
  String get aboutWarnValuesScreen => 'O mejnih vrednostih';

  @override
  String get aboutWarnValuesScreenDesc => 'Več informacij o mejnih vrednostih';

  @override
  String get sysWarn => 'Opozorilo glede sistoličnega tlaka';

  @override
  String get diaWarn => 'Opozorilo glede diastoličnega tlaka';

  @override
  String get data => 'Podatki';

  @override
  String get version => 'Različica';

  @override
  String versionOf(String version) {
    return 'Različica: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Številka različice: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Ime paketa: $name';
  }

  @override
  String get exportImport => 'Izvoz / Uvoz';

  @override
  String get exportDir => 'Mapa za izvoz';

  @override
  String get exportAfterEveryInput => 'Izvozi po vsakem novem vnosu';

  @override
  String get exportAfterEveryInputDesc => 'Ni priporočljivo (nastalo bo zelo veliko datotek)';

  @override
  String get exportFormat => 'Format izvoza';

  @override
  String get exportCustomEntries => 'Prilagodite polja';

  @override
  String get addEntry => 'Dodaj polje';

  @override
  String get exportMimeType => 'Tip izvozne datoteke';

  @override
  String get exportCsvHeadline => 'Naslovna vrstica';

  @override
  String get exportCsvHeadlineDesc => 'Pomaga pri razlikovanju vrst';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'besedilo';

  @override
  String get other => 'ostalo';

  @override
  String get fieldDelimiter => 'Ločilo polj';

  @override
  String get textDelimiter => 'Ločilo besedila';

  @override
  String get export => 'IZVOZI';

  @override
  String get shared => 'deljeno';

  @override
  String get import => 'UVOZI';

  @override
  String get sourceCode => 'Izvorna koda';

  @override
  String get licenses => 'Licence tretjih oseb';

  @override
  String importSuccess(int count) {
    return 'Število uvoženih vnosov: $count';
  }

  @override
  String get exportWarnConfigNotImportable => 'hej Samo prijateljsko opozorilo: trenutnega izvoza podatkov ne bo mogoče uvoziti nazaj v aplikacijo. Če želite to popraviti, se prepričajte, da ste nastavili vrsto izvoza kot CSV in vključili enega od razpoložljivih formatov časa.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'manjkajo',
      two: 'manjkata',
      one: 'manjka',
    );
    return 'Pozor, ne izvažate vseh polj: $fields $_temp0.';
  }

  @override
  String get statistics => 'Statistika';

  @override
  String get measurementCount => 'Število meritev';

  @override
  String get measurementsPerDay => 'Meritev na dan';

  @override
  String get timeResolvedMetrics => 'Meritve glede na čas dneva';

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
  String get warnValues => 'Opozorilne vrednosti';

  @override
  String get warnAboutTxt1 => 'Opozorilne vrednosti so zgolj predlogi in ne predstavljajo zdravstvenega nasveta.';

  @override
  String get warnAboutTxt2 => 'Privzete vrednosti, odvisne od starosti, prihajajo iz tega vira.';

  @override
  String get warnAboutTxt3 => 'Vrednosti lahko spremenite tako, da ustrezajo vašim potrebam in da upoštevate priporočila svojega zdravnika.';

  @override
  String get enterTimeFormatString => 'format časa';

  @override
  String get now => 'zdaj';

  @override
  String get notes => 'Opombe';

  @override
  String get time => 'Čas';

  @override
  String get confirmDelete => 'Potrdi izbris';

  @override
  String get confirmDeleteDesc => 'Želite izbrisati ta vnos? (Te potrditve lahko izklopite v nastavitvah.)';

  @override
  String get deletionConfirmed => 'Vnos izbrisan.';

  @override
  String get day => 'Dan';

  @override
  String get week => 'Teden';

  @override
  String get month => 'Mesec';

  @override
  String get year => 'Leto';

  @override
  String get lifetime => 'Celotno obdobje';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Teden $weekNum, $year';
  }

  @override
  String get last7Days => '7 dni';

  @override
  String get last30Days => '30 dni';

  @override
  String get allowMissingValues => 'Dovoli manjkajoče vrednosti';

  @override
  String get errTimeAfterNow => 'Izbrani čas dneva je bil ponastavljen, saj je bil izbran v prihodnosti. To preverjanje lahko izklopite v nastavitvah.';

  @override
  String get language => 'Jezik';

  @override
  String get custom => 'Po meri';

  @override
  String get drawRegressionLines => 'Nariši trendne črte';

  @override
  String get drawRegressionLinesDesc => 'Na grafu nariše regresijske črte. Uporabno samo za velike intervale.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Vrednosti krvnega tlaka od $start do $end';
  }

  @override
  String get fieldFormat => 'Format polja';

  @override
  String get result => 'Rezultat:';

  @override
  String get pulsePressure => 'Pulzni tlak';

  @override
  String get addExportformat => 'Dodaj obliko izvoza';

  @override
  String get edit => 'Uredi';

  @override
  String get delete => 'Izbriši';

  @override
  String get exportFieldFormatDocumentation => '## Spremenljivke\nOblika izvoznega polja podpira vstavljanje vrednosti za naslednje oznake:\n- `\$TIMESTAMP`: Predstavlja tim. Unix čas v milisekundah.\n- `\$SYS:` Zagotavlja vrednost, če je na voljo; sicer je privzeta vrednost -1.\n- `\$DIA:` Zagotavlja vrednost, če je na voljo; sicer je privzeta vrednost -1.\n- `\$PUL:` Zagotavlja vrednost, če je na voljo; sicer je privzeta vrednost -1.\n- `\$NOTE:` Zagotavlja vrednost, če je na voljo; sicer je privzeta vrednost -1.\n- `\$COLOR:` predstavlja barvo meritve kot številko. (primer vrednosti: `4291681337`)\n\nČe katera od zgoraj omenjenih oznak ni prisotna v zapisu o krvnem tlaku, bo nadomeščena z `null`.\n\n## Matematične operacije\nOsnovne matematične operacije lahko uporabite znotraj dvojnih oklepajev (\"`{{}}`\").\n\nPodprte so naslednje matematične operacije:\n- Operacije: +, -, *, /, %, ^\n- Funkcije z enim parametrom: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh\n- Funkcije z dvema parametroma: log, nrt, pow\n- Konstante: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nZa celotno specifikacijo matematičnih funkcij si lahko ogledate dokumentacijo [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter).\n\n## Procesiranje\n1. zamenjava spremenljivke\n2. matematične operacije';

  @override
  String get default_ => 'Privzeto';

  @override
  String get exportPdfHeaderHeight => 'Višina vzglavja';

  @override
  String get exportPdfCellHeight => 'Višina vrstice';

  @override
  String get exportPdfHeaderFontSize => 'Velikost pisave vzglavja';

  @override
  String get exportPdfCellFontSize => 'Velikost pisave vrstice';

  @override
  String get average => 'Povprečje';

  @override
  String get maximum => 'Maksimum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'Naslovna vrstica';

  @override
  String get exportPdfExportStatistics => 'Statistika';

  @override
  String get exportPdfExportData => 'Podatkovna tabela';

  @override
  String get startWithAddMeasurementPage => 'Meritev ob zagonu';

  @override
  String get startWithAddMeasurementPageDescription => 'Ob zagonu aplikacije se prikaže okno za vnos meritev.';

  @override
  String get horizontalLines => 'Horizontalne črte';

  @override
  String get linePositionY => 'Položaj črte (y)';

  @override
  String get customGraphMarkings => 'Oznake po meri';

  @override
  String get addLine => 'Dodaj črto';

  @override
  String get useLegacyList => 'Uporabi stari seznam';

  @override
  String get addMeasurement => 'Dodaj meritev';

  @override
  String get timestamp => 'Časovni žig';

  @override
  String get note => 'Opomba';

  @override
  String get color => 'Barva';

  @override
  String get exportSettings => 'Nastavitve varnostne kopije';

  @override
  String get importSettings => 'Nastavitve obnove varnostne kopije';

  @override
  String get requiresAppRestart => 'Zahteva ponoven zagon aplikacije';

  @override
  String get restartNow => 'Ponovno zaženi sedaj';

  @override
  String get warnNeedsRestartForUsingApp => 'V tej seji so bile izbrisane datoteke. Znova zaženite aplikacijo, če želite še naprej uporabljati vrnitev v druge dele aplikacije!';

  @override
  String get deleteAllMeasurements => 'Izbriši vse meritve';

  @override
  String get deleteAllSettings => 'Izbriši vse nastavitve';

  @override
  String get warnDeletionUnrecoverable => 'Ta korak je nepovraten, razen če ste ročno naredili varnostno kopijo. Ali res želite to izbrisati?';

  @override
  String get enterTimeFormatDesc => 'Oblikovalnik je mešanica vnaprej določenih nizov ICU/Skeleton in morebitnega dodatnega besedila, ki ga želite vključiti.\n\n[Če vas zanima celoten seznam veljavnih formatov, jih lahko najdete tukaj.](screen://TimeFormattingHelp)\n\nSamo prijazen opomnik, uporaba nizov daljšega ali krajšega formata ne bo spremenila širine stolpcev tabele, kar bi lahko povzročilo nerodne prelome vrstic in neprikazovanje besedila.\n\nprivzeto: \"ll-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Debelina barve';

  @override
  String get needlePinBarWidthDesc => 'Širina barvnih vnosov črt na grafu.';

  @override
  String get errParseEmptyCsvFile => 'V datoteki CSV ni dovolj vrstic za razčlenitev zapisa.';

  @override
  String get errParseTimeNotRestoreable => 'Ni stolpca, ki bi omogočal obnovitev časovnega žiga.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Ni stolpca z imenom \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Vrstica št. $lineNumber ima manj stolpcev kot prva vrstica.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Dekodiranje polja \"$fieldContent\" v vrstici št. $lineNumber ni uspelo.';
  }

  @override
  String get exportFieldsPreset => 'Prednastavitev izvoznih polj';

  @override
  String get remove => 'Odstrani';

  @override
  String get manageExportColumns => 'Upravljanje stolpcev za izvoz';

  @override
  String get buildIn => 'Vgrajeno';

  @override
  String get csvTitle => 'CSV-naslov';

  @override
  String get recordFormat => 'Format zapisa';

  @override
  String get timeFormat => 'Format časa';

  @override
  String get errAccuracyLoss => 'Pri izvozu podatkov z zapisom časa po meri lahko pride do izgube natančnosti.';

  @override
  String get bottomAppBars => 'Spodnje vrstice pogovornega okna';

  @override
  String get medications => 'Zdravila';

  @override
  String get addMedication => 'Dodaj zdravilo';

  @override
  String get name => 'Ime';

  @override
  String get defaultDosis => 'Privzeti odmerek';

  @override
  String get noMedication => 'Brez zdravil';

  @override
  String get dosis => 'Odmerek';

  @override
  String get valueDistribution => 'Porazdelitev vrednosti';

  @override
  String get titleInCsv => 'Naslov v CSV';

  @override
  String get errBleNoPerms => 'Manjkajo dovoljenja za Bluetooth';

  @override
  String get preferredPressureUnit => 'Želena enota za tlak';

  @override
  String get compactList => 'Zgoščen seznam meritev';

  @override
  String get bluetoothDisabled => 'Bluetooth onemogočen';

  @override
  String get errMeasurementRead => 'Napaka pri zajemu meritve!';

  @override
  String get measurementSuccess => 'Meritev uspešno zajeta!';

  @override
  String get connect => 'Poveži';

  @override
  String get bluetoothInput => 'Bluetooth vnos';

  @override
  String get aboutBleInput => 'Nekatere merilne naprave so združljive z BLE GATT. Tukaj lahko te naprave povežete z aplikacijo in omogočite samodejno posredovanje meritev ali pa to možnost onemogočite v nastavitvah.';

  @override
  String get scanningForDevices => 'Iskanje naprav';

  @override
  String get tapToClose => 'Tapnite za zapiranje.';

  @override
  String get meanArterialPressure => 'Povprečni arterijski tlak';

  @override
  String get userID => 'ID uporabnika';

  @override
  String get bodyMovementDetected => 'Zaznano gibanje telesa';

  @override
  String get cuffTooLoose => 'Manšeta je preveč ohlapna';

  @override
  String get improperMeasurementPosition => 'Nepravilen položaj merjenja';

  @override
  String get irregularPulseDetected => 'Zaznan nepravilen utrip';

  @override
  String get pulseRateExceedsUpperLimit => 'Utrip presega zgornjo mejo';

  @override
  String get pulseRateLessThanLowerLimit => 'Utrip presega spodnjo mejo';

  @override
  String get availableDevices => 'Razpoložljive naprave';

  @override
  String get deleteAllMedicineIntakes => 'Izbrišite vse vnose zdravil';

  @override
  String get deleteAllNotes => 'Izbrišite vse opombe';

  @override
  String get date => 'Datum';

  @override
  String get intakes => 'Vnosi zdravil';

  @override
  String get errFeatureNotSupported => 'Ta funkcija ni na voljo na tej platformi.';

  @override
  String get invalidZip => 'Neveljavna ZIP datoteka.';

  @override
  String get errCantCreateArchive => 'Ne morem ustvariti arhiva. Prosim, prijavite napako.';

  @override
  String get activateWeightFeatures => 'Aktivirajte funkcije, povezane s težo';

  @override
  String get weight => 'Teža';

  @override
  String get enterWeight => 'Vnesite težo';

  @override
  String get selectMeasurementTitle => 'Izberite meritev, ki jo želite uporabiti';

  @override
  String measurementIndex(int number) {
    return 'Meritev #$number';
  }

  @override
  String get select => 'Izberi';

  @override
  String get bloodPressure => 'Krvni tlak';

  @override
  String get preferredWeightUnit => 'Želena enota teže';

  @override
  String get disabled => 'Onemogočeno';

  @override
  String get oldBluetoothInput => 'Stabilna';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta med platformami';

  @override
  String get bluetoothInputDesc => 'Zaledje beta različice deluje na več napravah, vendar je manj preizkušeno. Različica za več platform morda deluje na napravah, ki niso Android, načrtujemo pa, da bo ta različica - ko bo dovolj razvita - nadomestila stabilno različico aplikacije.';

  @override
  String get tapToSelect => 'Tap to select';
}
