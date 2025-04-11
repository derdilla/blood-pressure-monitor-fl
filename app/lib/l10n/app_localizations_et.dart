// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get title => 'Vererõhu andmete arhiiv';

  @override
  String success(String msg) {
    return 'Õnnestus: $msg';
  }

  @override
  String get loading => 'laadime…';

  @override
  String error(String msg) {
    return 'Viga: $msg';
  }

  @override
  String get errNaN => 'Palun sisesta number';

  @override
  String get errLt30 => 'Number on väiksem või võrdne kui 30? Vajadusel saad seadistustest valideerimise välja lülitada!';

  @override
  String get errUnrealistic => 'Ebaloogiline number? Vajadusel saad seadistustest valideerimise välja lülitada!';

  @override
  String get errDiaGtSys => 'Diastoolne vererõhk on süstoolsest suurem või sellega võrdne? Vajadusel saad seadistustest valideerimise välja lülitada!';

  @override
  String errCantOpenURL(String url) {
    return 'Võrguaadressi avamine ei õnnestu: $url';
  }

  @override
  String get errNoFileOpened => 'ühtegi faili pole avatud';

  @override
  String get errNotStarted => 'pole käivitatud';

  @override
  String get errNoValue => 'Palun sisesta väärtus';

  @override
  String get errNotEnoughDataToGraph => 'Graafiku joonistamiseks pole piisavalt andmeid.';

  @override
  String get errNoData => 'andmeid pole';

  @override
  String get errWrongImportFormat => 'Sa saad importida andmeid vaid csv ja SQLite andmebaasi vormingutes.';

  @override
  String get errNeedHeadline => 'Sa saad importida vaid andmeid, millel on päiserida.';

  @override
  String get errCantReadFile => 'Faili sisu lugemine ei õnnestu';

  @override
  String get errNotImportable => 'Seda faili ei saa importida';

  @override
  String get btnCancel => 'KATKESTA';

  @override
  String get btnSave => 'SALVESTA';

  @override
  String get btnConfirm => 'SOBIB';

  @override
  String get btnUndo => 'VÕTA TAGASI';

  @override
  String get sysLong => 'Ülemine vererõhk';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Alumine vererõhk';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pulss';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Märkus (kui pead vajalikuks)';

  @override
  String get settings => 'Seadistused';

  @override
  String get layout => 'Paigutus';

  @override
  String get allowManualTimeInput => 'Luba kellaaja sisestamist käsitsi';

  @override
  String get enterTimeFormatScreen => 'Kellaja vorming';

  @override
  String get theme => 'Kujundus';

  @override
  String get system => 'Süsteemi kujundus';

  @override
  String get dark => 'Tume kujundus';

  @override
  String get light => 'Hele kujundus';

  @override
  String get iconSize => 'Ikooni suurus';

  @override
  String get graphLineThickness => 'Joone jämedus';

  @override
  String get animationSpeed => 'Arvutianimatsiooni kestus';

  @override
  String get accentColor => 'Kujunduse värv';

  @override
  String get sysColor => 'Ülemise ehk süstoolne vererõhu värv';

  @override
  String get diaColor => 'Alumise ehk diastoolse vererõhu värv';

  @override
  String get pulColor => 'Pulsi värv';

  @override
  String get behavior => 'Käitumine';

  @override
  String get validateInputs => 'Kontrolli, kas sisendid on loogilised';

  @override
  String get confirmDeletion => 'Kustutamisel küsi kinnitust';

  @override
  String get age => 'Vanus';

  @override
  String get determineWarnValues => 'Seadista hoiatuslävendid';

  @override
  String get aboutWarnValuesScreen => 'Teave';

  @override
  String get aboutWarnValuesScreenDesc => 'Lisateave hoiatuslävendite kohta';

  @override
  String get sysWarn => 'Ülemise ehk süstoolse vererõhu hoiatuslävend';

  @override
  String get diaWarn => 'Alumise ehk diastoolse vererõhu hoiatuslävend';

  @override
  String get data => 'Andmed';

  @override
  String get version => 'Versioon';

  @override
  String versionOf(String version) {
    return 'Versioon: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Versiooni number: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Paketi nimi: $name';
  }

  @override
  String get exportImport => 'Eksport ja import';

  @override
  String get exportDir => 'Kaust andmete ekportimiseks';

  @override
  String get exportAfterEveryInput => 'Ekspordi peale iga kirje sisestust';

  @override
  String get exportAfterEveryInputDesc => 'Pole soovitatav (tekib andmeuputus)';

  @override
  String get exportFormat => 'Ekspordivorming';

  @override
  String get exportCustomEntries => 'Kohanda välju';

  @override
  String get addEntry => 'Lisa väli';

  @override
  String get exportMimeType => 'Eksporditav failitüüp';

  @override
  String get exportCsvHeadline => 'Päiseväli';

  @override
  String get exportCsvHeadlineDesc => 'Võimaldab eraldada andmetüüpe';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite andmebaas';

  @override
  String get text => 'tekst';

  @override
  String get other => 'muu';

  @override
  String get fieldDelimiter => 'Väljade eraldaja';

  @override
  String get textDelimiter => 'Teksti eraldaja';

  @override
  String get export => 'EKSPORT';

  @override
  String get shared => 'jagatud';

  @override
  String get import => 'IMPORT';

  @override
  String get sourceCode => 'Lähtekood';

  @override
  String get licenses => 'kolmandate osapoolte litsentsid';

  @override
  String importSuccess(int count) {
    return 'Importisime $count kirjet';
  }

  @override
  String get exportWarnConfigNotImportable => 'Hei! Lihtsalt üks sõbralik soovitus: praegune ekspordiseadistus ei taga, et andmed on ka tagasi imporditavad. Vea parandamiseks palun kontrolli, et andmevorming ekspordiks on CSV ja sa oled kaasanud ühe saadavaloevatest ajavormingutest.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'on',
      one: 'on',
    );
    return 'Palun arvesta, et sa pole eksportimas kõiki andmevälju: puudu $fields $_temp0.';
  }

  @override
  String get statistics => 'Statistika';

  @override
  String get measurementCount => 'Mõõdistuste arv';

  @override
  String get measurementsPerDay => 'Mõõdistusi päevas';

  @override
  String get timeResolvedMetrics => 'Andmestik päevaaja järgi';

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
  String get warnValues => 'Hoiatuslävendid';

  @override
  String get warnAboutTxt1 => 'Hoiatuslävend on vaid soovitus ega pole meditsiiniline nõuanne.';

  @override
  String get warnAboutTxt2 => 'Vaikimisi lävendväärtused on east sõltuvad ja tulevad sellest allikast.';

  @override
  String get warnAboutTxt3 => 'Palun muuda väärtusi vastavalt oma vajadustele ning järgi oma arsti soovitusi.';

  @override
  String get enterTimeFormatString => 'kellaja vorming';

  @override
  String get now => 'praegu';

  @override
  String get notes => 'Märkmed';

  @override
  String get time => 'Aeg';

  @override
  String get confirmDelete => 'Kinnita kustutamine';

  @override
  String get confirmDeleteDesc => 'Kas kustutame selle kirje? (Sa saad sellised kontrollküsimised seadistusest kinni keerata.)';

  @override
  String get deletionConfirmed => 'Kirje on kustutatud.';

  @override
  String get day => 'Päev';

  @override
  String get week => 'Nädal';

  @override
  String get month => 'Kuu';

  @override
  String get year => 'Aasta';

  @override
  String get lifetime => 'Eluiga';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Nädal $weekNum, $year';
  }

  @override
  String get last7Days => '7 päeva';

  @override
  String get last30Days => '30 päeva';

  @override
  String get allowMissingValues => 'Luba puuduvaid väärtusi';

  @override
  String get errTimeAfterNow => 'Valitud aeg on tulevikus. Sa saad selle kontrollireegli seadistustest välja lülitada.';

  @override
  String get language => 'Keel';

  @override
  String get custom => 'Kohandatud';

  @override
  String get drawRegressionLines => 'Joonista trendijooni';

  @override
  String get drawRegressionLinesDesc => 'Lisa graafikule lineaarregressiooni joon. Mõttekas vaid suurema andmehulga puhul.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Vererõhu väärtused alates $start kuni $end';
  }

  @override
  String get fieldFormat => 'Välja vorming';

  @override
  String get result => 'Tulemus:';

  @override
  String get pulsePressure => 'Pulsirõhk';

  @override
  String get addExportformat => 'Lisa ekspordivorming';

  @override
  String get edit => 'Muuda';

  @override
  String get delete => 'Kustuta';

  @override
  String get exportFieldFormatDocumentation => '## Muutujad\nEkspordiväljade vorminguks saad kasutada selliseid kohatäitjaid:\n- `\$TIMESTAMP:` unixi ajaloendur millisekundites.\n- `\$SYS:` kui väärtus on olemas, siis seda kuvatakse, muidu on väärtuseks -1.\n- `\$DIA:` kui väärtus on olemas, siis seda kuvatakse, muidu on väärtuseks -1.\n- `\$PUL:` kui väärtus on olemas, siis seda kuvatakse, muidu on väärtuseks -1.\n- `\$NOTE:` kui väärtus on olemas, siis seda kuvatakse, muidu on väärtuseks -1.\n- `\$COLOR:` mõõtmise värv numbrina. (näiteks: `4291681337`)\n\nKui mõnda kohatäitjat pole defineeritud, siis ekspordikirjes on selle asemel `null`.\n\n## Matemaatika\nTopeltlooksulgudes saad kasutada tavalist matemaatikat (\"`{{}}`\").\n\nToetatud on järgmised matemaatilised tehted ja lisavõimalused:\n- tehted: +, -, *, /, %, ^\n- ühe parameetriga funktsioonid: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- kahe parameetriga funktsioonid: log, nrt, pow\n- konstandid: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nTervikliku matemaatikainterpretaatori spetsifikatsiooni leiad siit [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) juhendist.\n\n## Töötlemise järjekord\n1. muutujate paigutus\n2. matemaatika';

  @override
  String get default_ => 'Vaikimisi';

  @override
  String get exportPdfHeaderHeight => 'Päiserea kõrgus';

  @override
  String get exportPdfCellHeight => 'Rea kõrgus';

  @override
  String get exportPdfHeaderFontSize => 'Päiserea kirjatüübi suurus';

  @override
  String get exportPdfCellFontSize => 'Rea kirjatüübi suurus';

  @override
  String get average => 'Keskmine';

  @override
  String get maximum => 'Maksimum';

  @override
  String get minimum => 'Miinimum';

  @override
  String get exportPdfExportTitle => 'Pealkiri';

  @override
  String get exportPdfExportStatistics => 'Statistika';

  @override
  String get exportPdfExportData => 'Andmetabel';

  @override
  String get startWithAddMeasurementPage => 'Lisamise vaade rakenduse käivitamisel';

  @override
  String get startWithAddMeasurementPageDescription => 'Rakenduse käivitamisel kuvatakse lisamise vaade.';

  @override
  String get horizontalLines => 'Horisontaaljooned';

  @override
  String get linePositionY => 'Joone asukoht (y)';

  @override
  String get customGraphMarkings => 'Kohandatud markerid';

  @override
  String get addLine => 'Lisa joon';

  @override
  String get useLegacyList => 'Kasuta pärandloendit';

  @override
  String get addMeasurement => 'Lisa mõõtmine';

  @override
  String get timestamp => 'Ajatempel';

  @override
  String get note => 'Märkus';

  @override
  String get color => 'Värv';

  @override
  String get exportSettings => 'Varunda seadistused';

  @override
  String get importSettings => 'Taasta seadistused';

  @override
  String get requiresAppRestart => 'Eeldab rakenduse taaskäivitamist';

  @override
  String get restartNow => 'Taaskäivita kohe';

  @override
  String get warnNeedsRestartForUsingApp => 'Selles sessioonis kustutasime mõned failid. Jätkamaks muus osas rakenduse kasutamist käivita ta uuesti!';

  @override
  String get deleteAllMeasurements => 'Kustuta kõik mõõtmised';

  @override
  String get deleteAllSettings => 'Kustuta kõik seadistused';

  @override
  String get warnDeletionUnrecoverable => 'Kui sa pole just varem teinud varukoopiat, siis see samm on pöördumatu. Kas sa kindlasti soovid selle info kustutada?';

  @override
  String get enterTimeFormatDesc => 'Vorming on segu ICU/Skeleton spetsifikatsiooni sõnedest ja lisatekstist, mida tahaksid juurde panna.\n\n[Kui tahad, siis kõikide kasutatavate vormingute kohta saad lugeda siit.](screen://TimeFormattingHelp)\n\nVäikese ääremärkusena ütleme, et pikema või lühema vormingu kasutamine ei muuda imeväel tabeli veergude laiust, kuid võib tekitada imelikke reavahetusi ja osa teksti kasdumist.\n\nvaikimisi: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Joone paksus';

  @override
  String get needlePinBarWidthDesc => 'Joone paksus, mille värvilised kirjed graafikul teevad.';

  @override
  String get errParseEmptyCsvFile => 'Kirjete töötlemiseks pole csv-failis piisavalt ridu.';

  @override
  String get errParseTimeNotRestoreable => 'Pole veergu, mis võimaldaks ajatempli taastamist.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Pole veergu nimega „$title“.';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'Real $lineNumber on esimese reaga võrreldes vähem välju.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Real „$lineNumber“ asuva „$fieldContent“ välja dekodeerimine ei õnnestunud.';
  }

  @override
  String get exportFieldsPreset => 'Ekspordi väljade eelseadistus';

  @override
  String get remove => 'Eemalda';

  @override
  String get manageExportColumns => 'Halda eksporditavaid välju';

  @override
  String get buildIn => 'Sisseehitatud';

  @override
  String get csvTitle => 'CSV-pealkiri';

  @override
  String get recordFormat => 'Salvestusvorming';

  @override
  String get timeFormat => 'Ajavorming';

  @override
  String get errAccuracyLoss => 'Kui ekspordid endaseadistatud ajavormingutes võib tekkida andmetäpsuse kadu.';

  @override
  String get bottomAppBars => 'Tegevusriba all ääres';

  @override
  String get medications => 'Ravimid';

  @override
  String get addMedication => 'Lisa ravim';

  @override
  String get name => 'Nimi';

  @override
  String get defaultDosis => 'Vaikimisi doos';

  @override
  String get noMedication => 'Ravimeid pole';

  @override
  String get dosis => 'Doos';

  @override
  String get valueDistribution => 'Väärtuste jaotumine';

  @override
  String get titleInCsv => 'Pealkiri csv-failis';

  @override
  String get errBleNoPerms => 'Pole õigusi bluetoothi kasutamiseks';

  @override
  String get preferredPressureUnit => 'Eelistatud rõhuühik';

  @override
  String get compactList => 'Kompaktne mõõdistuste loend';

  @override
  String get bluetoothDisabled => 'Bluetoothi kasutamine on välja lülitatud';

  @override
  String get errMeasurementRead => 'Viga mõõtmisel!';

  @override
  String get measurementSuccess => 'Mõõtmine õnnestus!';

  @override
  String get connect => 'Ühenda';

  @override
  String get bluetoothInput => 'Sisend bluetoothist';

  @override
  String get aboutBleInput => 'Mõned vererõhuaparaadid ühilduvad BLE GATT standardiga. Palun vaata, et seade oleks paardunud ja siis saad mõõtmisi siia automaatselt edastada. Kui sa seda ei soovi, siis lülita see eelistus seadistustest välja.';

  @override
  String get scanningForDevices => 'Otsime seadmeid';

  @override
  String get tapToClose => 'Sulgemiseks klõpsi.';

  @override
  String get meanArterialPressure => 'Keskmine arteriaalne vererõhk';

  @override
  String get userID => 'Kasutajatunnus';

  @override
  String get bodyMovementDetected => 'Tuvastasime keha liikumise';

  @override
  String get cuffTooLoose => 'Mansett on liiga lõdvalt';

  @override
  String get improperMeasurementPosition => 'Vale koht mõõtmiseks';

  @override
  String get irregularPulseDetected => 'Tuvastasime korrapäratu pulsi';

  @override
  String get pulseRateExceedsUpperLimit => 'Pulss on ülempiirist suurem';

  @override
  String get pulseRateLessThanLowerLimit => 'Pulss on alampiirist väiksem';

  @override
  String get availableDevices => 'Saadavalolevad seadmed';

  @override
  String get deleteAllMedicineIntakes => 'Kustuta kõik ravimite võtmise märked';

  @override
  String get deleteAllNotes => 'Kustuta kõik märkused';

  @override
  String get date => 'Kuupäev';

  @override
  String get intakes => 'Ravimite võtmine';

  @override
  String get errFeatureNotSupported => 'See funktsionaalsus pole sellel platvormil saadaval.';

  @override
  String get invalidZip => 'Vigane zip-fail.';

  @override
  String get errCantCreateArchive => 'Arhiivi loomine ei õnnestu. Kui võimalik siis palun teata sellest veast.';

  @override
  String get activateWeightFeatures => 'Lülita sisse kaaluga seotud funktsionaalsus';

  @override
  String get weight => 'Kaal';

  @override
  String get enterWeight => 'Palun sisesta kaal';

  @override
  String get selectMeasurementTitle => 'Vali kasutatav mõõdistus';

  @override
  String measurementIndex(int number) {
    return 'Mõõdistus nr $number';
  }

  @override
  String get select => 'Vali';

  @override
  String get bloodPressure => 'Vererõhk';

  @override
  String get preferredWeightUnit => 'Eelistatud kaaluühik';

  @override
  String get disabled => 'Pole kasutusel';

  @override
  String get oldBluetoothInput => 'Stabiilne liides';

  @override
  String get newBluetoothInputOldLib => 'Beetaliides';

  @override
  String get newBluetoothInputCrossPlatform => 'Platvormiülene beetaliides';

  @override
  String get bluetoothInputDesc => 'Beetaliides toimib enamate seadmetega, aga on vähem testitud. Platvormiülene beetaliides võib toimida ka muude, kui Androidipõhiste seadmetega ning meie eesmärk on, et peale piisavat testimist ta ühel hetkel asendab senise stabiilse liidese.';

  @override
  String get tapToSelect => 'Valimiseks puuduta';
}
