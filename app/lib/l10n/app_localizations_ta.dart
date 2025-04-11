// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get title => 'இரத்த அழுத்த பயன்பாடு';

  @override
  String success(String msg) {
    return 'வெற்றி: $msg';
  }

  @override
  String get loading => 'ஏற்றுகிறது…';

  @override
  String error(String msg) {
    return 'பிழை: $msg';
  }

  @override
  String get errNaN => 'தயவுசெய்து ஒரு எண்ணை உள்ளிடவும்';

  @override
  String get errLt30 => 'எண் <= 30? அமைப்புகளில் சரிபார்ப்பை அணைக்கவும்!';

  @override
  String get errUnrealistic => 'நம்பத்தகாத மதிப்பு? அமைப்புகளில் சரிபார்ப்பை அணைக்கவும்!';

  @override
  String get errDiaGtSys => 'dia> = sys? அமைப்புகளில் சரிபார்ப்பை அணைக்கவும்!';

  @override
  String errCantOpenURL(String url) {
    return 'முகவரி ஐ திறக்க முடியாது: $url';
  }

  @override
  String get errNoFileOpened => 'எந்த கோப்பும் திறக்கப்படவில்லை';

  @override
  String get errNotStarted => 'தொடங்கப்படவில்லை';

  @override
  String get errNoValue => 'தயவுசெய்து ஒரு மதிப்பை உள்ளிடவும்';

  @override
  String get errNotEnoughDataToGraph => 'வரைபடத்தை வரைய போதுமான தரவு இல்லை.';

  @override
  String get errNoData => 'தரவு இல்லை';

  @override
  String get errWrongImportFormat => 'நீங்கள் காபிம மற்றும் SQLITE தரவுத்தள வடிவத்தில் மட்டுமே கோப்புகளை இறக்குமதி செய்ய முடியும்.';

  @override
  String get errNeedHeadline => 'நீங்கள் ஒரு தலைப்புடன் மட்டுமே கோப்புகளை இறக்குமதி செய்ய முடியும்.';

  @override
  String get errCantReadFile => 'கோப்பின் உள்ளடக்கங்களைப் படிக்க முடியாது';

  @override
  String get errNotImportable => 'இந்த கோப்பை இறக்குமதி செய்ய முடியாது';

  @override
  String get btnCancel => 'ரத்துசெய்';

  @override
  String get btnSave => 'சேமி';

  @override
  String get btnConfirm => 'சரி';

  @override
  String get btnUndo => 'செயல்தவிர்';

  @override
  String get sysLong => 'சிச்டாலிக்';

  @override
  String get sysShort => 'சிச்';

  @override
  String get diaLong => 'டயச்டாலிக்';

  @override
  String get diaShort => 'டியா';

  @override
  String get pulLong => 'நாடி';

  @override
  String get pulShort => 'புல்';

  @override
  String get addNote => 'குறிப்பு (விரும்பினால்)';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get layout => 'மனையமைவு';

  @override
  String get allowManualTimeInput => 'கையேடு நேர உள்ளீட்டை அனுமதிக்கவும்';

  @override
  String get enterTimeFormatScreen => 'நேர வடிவம்';

  @override
  String get theme => 'கருப்பொருள்';

  @override
  String get system => 'மண்டலம்';

  @override
  String get dark => 'இருண்ட';

  @override
  String get light => 'ஒளி';

  @override
  String get iconSize => 'படவுரு அளவு';

  @override
  String get graphLineThickness => 'வரி தடிமன்';

  @override
  String get animationSpeed => 'அனிமேசன் காலம்';

  @override
  String get accentColor => 'கருப்பொருள் நிறம்';

  @override
  String get sysColor => 'சிச்டாலிக் நிறம்';

  @override
  String get diaColor => 'டயச்டாலிக் நிறம்';

  @override
  String get pulColor => 'துடிப்பு நிறம்';

  @override
  String get behavior => 'நடத்தை';

  @override
  String get validateInputs => 'உள்ளீடுகளை சரிபார்க்கவும்';

  @override
  String get confirmDeletion => 'நீக்குதலை உறுதிப்படுத்தவும்';

  @override
  String get age => 'அகவை';

  @override
  String get determineWarnValues => 'எச்சரிக்கை மதிப்புகளை தீர்மானிக்கவும்';

  @override
  String get aboutWarnValuesScreen => 'பற்றி';

  @override
  String get aboutWarnValuesScreenDesc => 'எச்சரிக்கை மதிப்புகள் பற்றிய கூடுதல் செய்தி';

  @override
  String get sysWarn => 'சிச்டாலிக் எச்சரிக்கை';

  @override
  String get diaWarn => 'டயச்டாலிக் எச்சரிக்கை';

  @override
  String get data => 'தகவல்கள்';

  @override
  String get version => 'பதிப்பு';

  @override
  String versionOf(String version) {
    return 'பதிப்பு: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'பதிப்பு எண்: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'தொகுப்பு பெயர்: $name';
  }

  @override
  String get exportImport => 'ஏற்றுமதி / இறக்குமதி';

  @override
  String get exportDir => 'ஏற்றுமதி அடைவு';

  @override
  String get exportAfterEveryInput => 'ஒவ்வொரு நுழைவுக்கும் பிறகு ஏற்றுமதி செய்யுங்கள்';

  @override
  String get exportAfterEveryInputDesc => 'பரிந்துரைக்கப்படவில்லை (கோப்பு வெடிப்பு)';

  @override
  String get exportFormat => 'ஏற்றுமதி வடிவம்';

  @override
  String get exportCustomEntries => 'புலங்களைத் தனிப்பயனாக்குங்கள்';

  @override
  String get addEntry => 'புலத்தைச் சேர்க்கவும்';

  @override
  String get exportMimeType => 'ஊடக வகை ஏற்றுமதி';

  @override
  String get exportCsvHeadline => 'தலைப்பு';

  @override
  String get exportCsvHeadlineDesc => 'வகைகளை பாகுபடுத்த உதவுகிறது';

  @override
  String get csv => 'சிஎச்வி';

  @override
  String get pdf => 'பி.டி.எஃப்';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'உரை';

  @override
  String get other => 'மற்றொன்று';

  @override
  String get fieldDelimiter => 'புலம் டிலிமிட்டர்';

  @override
  String get textDelimiter => 'உரை டிலிமிட்டர்';

  @override
  String get export => 'ஏற்றுமதி';

  @override
  String get shared => 'பகிரப்பட்டது';

  @override
  String get import => 'இறக்குமதி';

  @override
  String get sourceCode => 'மூலக் குறியீடு';

  @override
  String get licenses => '3 வது கட்சி உரிமங்கள்';

  @override
  String importSuccess(int count) {
    return 'இறக்குமதி செய்யப்பட்ட $count உள்ளீடுகள்';
  }

  @override
  String get exportWarnConfigNotImportable => 'ஏய்! ஒரு நட்புரீதியானது: தற்போதைய ஏற்றுமதி உள்ளமைவு இறக்குமதி செய்யப்படாது. அதை சரிசெய்ய, நீங்கள் ஏற்றுமதி வகையை காபிம ஆக அமைத்து, கிடைக்கக்கூடிய நேர வடிவங்களில் ஒன்றைச் சேர்க்கவும்.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'நீங்கள் எல்லா புலங்களையும் ஏற்றுமதி செய்யவில்லை என்பதில் புரிந்துகெள்ளுங்கள்: $fields $_temp0காணவில்லை.';
  }

  @override
  String get statistics => 'புள்ளிவிவரங்கள்';

  @override
  String get measurementCount => 'அளவீட்டு எண்ணிக்கை';

  @override
  String get measurementsPerDay => 'ஒரு நாளைக்கு அளவீடுகள்';

  @override
  String get timeResolvedMetrics => 'நாளின் நேரத்தின் அளவீடுகள்';

  @override
  String avgOf(String txt) {
    return '$txt';
  }

  @override
  String minOf(String txt) {
    return '$txt min.';
  }

  @override
  String maxOf(String txt) {
    return '$txt அதிகபட்சம்.';
  }

  @override
  String get warnValues => 'மதிப்புகளை எச்சரிக்கவும்';

  @override
  String get warnAboutTxt1 => 'எச்சரிக்கை மதிப்புகள் ஒரு தூய்மையான பரிந்துரைகள் மற்றும் மருத்துவ ஆலோசனைகள் இல்லை.';

  @override
  String get warnAboutTxt2 => 'இயல்புநிலை அகவை சார்ந்த மதிப்புகள் இந்த மூலத்திலிருந்து வருகின்றன.';

  @override
  String get warnAboutTxt3 => 'உங்கள் தேவைகளுக்கு ஏற்ப மதிப்புகளை மாற்றவும், உங்கள் மருத்துவரின் பரிந்துரைகளைப் பின்பற்றவும் தயங்க.';

  @override
  String get enterTimeFormatString => 'நேர வடிவம்';

  @override
  String get now => 'இப்போது';

  @override
  String get notes => 'குறிப்புகள்';

  @override
  String get time => 'நேரம்';

  @override
  String get confirmDelete => 'நீக்குதலை உறுதிப்படுத்தவும்';

  @override
  String get confirmDeleteDesc => 'இந்த உள்ளீட்டை நீக்கவா? (அமைப்புகளில் இந்த உறுதிப்படுத்தல்களை நீங்கள் அணைக்கலாம்.)';

  @override
  String get deletionConfirmed => 'நுழைவு நீக்கப்பட்டது.';

  @override
  String get day => 'நாள்';

  @override
  String get week => 'வாரம்';

  @override
  String get month => 'மாதம்';

  @override
  String get year => 'ஆண்டு';

  @override
  String get lifetime => 'வாழ்நாள்';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'வாரம் $weekNum, $year';
  }

  @override
  String get last7Days => '7 நாட்கள்';

  @override
  String get last30Days => '30 நாட்கள்';

  @override
  String get allowMissingValues => 'காணாமல் போன மதிப்புகளை அனுமதிக்கவும்';

  @override
  String get errTimeAfterNow => 'தேர்ந்தெடுக்கப்பட்ட நாள் நேரம் மீட்டமைக்கப்பட்டது, ஏனெனில் இது இந்த தருணத்திற்குப் பிறகு நிகழ்கிறது. அமைப்புகளில் இந்த சரிபார்ப்பை நீங்கள் அணைக்கலாம்.';

  @override
  String get language => 'மொழி';

  @override
  String get custom => 'தனிப்பயன்';

  @override
  String get drawRegressionLines => 'போக்கு கோடுகளை வரையவும்';

  @override
  String get drawRegressionLinesDesc => 'வரைபடத்தில் பின்னடைவு கோடுகளை ஈர்க்கிறது. பெரிய இடைவெளிகளுக்கு மட்டுமே பயனுள்ளதாக இருக்கும்.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return '$start முதல் $end வரை இரத்த அழுத்த மதிப்புகள்';
  }

  @override
  String get fieldFormat => 'புலம் வடிவம்';

  @override
  String get result => 'முடிவு:';

  @override
  String get pulsePressure => 'துடிப்பு அழுத்தம்';

  @override
  String get addExportformat => 'ஏற்றுமதி வடிவத்தைச் சேர்க்கவும்';

  @override
  String get edit => 'தொகு';

  @override
  String get delete => 'நீக்கு';

  @override
  String get exportFieldFormatDocumentation => '## மாறிகள்\nஏற்றுமதி புலம் வடிவம் பின்வரும் ஒதுக்கிடங்களுக்கான மதிப்புகளைச் செருகுவதை ஆதரிக்கிறது:\n- `\$TIMESTAMP:` மில்லி விநாடிகளில் யூனிக்ச் சகாப்தத்திலிருந்து நேரத்தைக் குறிக்கிறது.\n- `\$SYS:` கிடைத்தால் ஒரு மதிப்பை வழங்குகிறது; இல்லையெனில், இது -1 க்கு இயல்புநிலையாகும்.\n- `\$DIA:` கிடைத்தால் ஒரு மதிப்பை வழங்குகிறது; இல்லையெனில், இது -1 க்கு இயல்புநிலையாகும்.\n- `\$PUL:` கிடைத்தால் ஒரு மதிப்பை வழங்குகிறது; இல்லையெனில், இது -1 க்கு இயல்புநிலையாகும்.\n- `\$NOTE:` கிடைத்தால் ஒரு மதிப்பை வழங்குகிறது; இல்லையெனில், இது -1 க்கு இயல்புநிலையாகும்.\n- `\$COLOR:` ஒரு அளவீட்டின் நிறத்தை ஒரு எண்ணாகக் குறிக்கிறது. (எடுத்துக்காட்டு மதிப்பு: `4291681337`)\n\nமேலே குறிப்பிட்டுள்ள இடம் வைத்திருப்பவர்கள் யாராவது இரத்த அழுத்தப் பதிவில் இல்லை என்றால், அவர்கள் `null` உடன் மாற்றப்படுவார்கள்.\n\n## கணிதம்\nநீங்கள் இரட்டை அடைப்புக்குறிக்குள் அடிப்படை கணிதத்தைப் பயன்படுத்தலாம் (\"`{{}}`\").\n\nபின்வரும் கணித நடவடிக்கைகள் ஆதரிக்கப்படுகின்றன:\n- செயல்பாடுகள்: +, -, *, /, %, ^.\n- ஒற்றை-அளவுரு செயல்பாடுகள்: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- இரண்டு-அளவுரு செயல்பாடுகள்: அடுக்குஎண், என்ஆர்டி, அடுக்கு.\n- மாறிலிகள்: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nமுழு கணித மொழிபெயர்ப்பாளர் விவரக்குறிப்புக்கு, நீங்கள் [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) ஆவணங்களைக் குறிப்பிடலாம்.\n\n## செயலாக்க ஒழுங்கு\n1. மாறி மாற்று\n2. கணிதம்';

  @override
  String get default_ => 'இயல்புநிலை';

  @override
  String get exportPdfHeaderHeight => 'தலைப்பு உயரம்';

  @override
  String get exportPdfCellHeight => 'வரிசை உயரம்';

  @override
  String get exportPdfHeaderFontSize => 'தலைப்பு எழுத்துரு அளவு';

  @override
  String get exportPdfCellFontSize => 'வரிசை எழுத்துரு அளவு';

  @override
  String get average => 'சராசரி';

  @override
  String get maximum => 'பெருமம்';

  @override
  String get minimum => 'சிறுமம்';

  @override
  String get exportPdfExportTitle => 'தலைப்பு';

  @override
  String get exportPdfExportStatistics => 'புள்ளிவிவரங்கள்';

  @override
  String get exportPdfExportData => 'தரவு அட்டவணை';

  @override
  String get startWithAddMeasurementPage => 'துவக்கத்தில் அளவீட்டு';

  @override
  String get startWithAddMeasurementPageDescription => 'பயன்பாட்டு வெளியீட்டில், அளவீட்டு உள்ளீட்டுத் திரை காட்டப்பட்டுள்ளது.';

  @override
  String get horizontalLines => 'கிடைமட்ட கோடுகள்';

  @override
  String get linePositionY => 'வரி நிலை (y)';

  @override
  String get customGraphMarkings => 'தனிப்பயன் அடையாளங்கள்';

  @override
  String get addLine => 'வரி சேர்க்கவும்';

  @override
  String get useLegacyList => 'மரபு பட்டியலைப் பயன்படுத்தவும்';

  @override
  String get addMeasurement => 'அளவீட்டு சேர்க்கவும்';

  @override
  String get timestamp => 'நேர முத்திரை';

  @override
  String get note => 'குறிப்பு';

  @override
  String get color => 'நிறம்';

  @override
  String get exportSettings => 'காப்பு அமைப்புகள்';

  @override
  String get importSettings => 'அமைப்புகளை மீட்டெடுங்கள்';

  @override
  String get requiresAppRestart => 'பயன்பாட்டு மறுதொடக்கம் தேவை';

  @override
  String get restartNow => 'இப்போது மறுதொடக்கம் செய்யுங்கள்';

  @override
  String get warnNeedsRestartForUsingApp => 'இந்த அமர்வை நீக்கிய கோப்புகள். பயன்பாட்டின் பிற பகுதிகளுக்குத் திரும்புவதைப் பயன்படுத்த பயன்பாட்டை மறுதொடக்கம் செய்யுங்கள்!';

  @override
  String get deleteAllMeasurements => 'அனைத்து அளவீடுகளையும் நீக்கவும்';

  @override
  String get deleteAllSettings => 'எல்லா அமைப்புகளையும் நீக்கவும்';

  @override
  String get warnDeletionUnrecoverable => 'நீங்கள் கைமுறையாக ஒரு காப்புப்பிரதியைச் செய்யாவிட்டால் இந்த நடவடிக்கை மாற்றியமைக்காது. இதை நீக்க விரும்புகிறீர்களா?';

  @override
  String get enterTimeFormatDesc => 'ஒரு ஃபார்மேட்டர் சரம் என்பது முன் வரையறுக்கப்பட்ட ஐ.சி.யூ/எலும்புக்கூடு சரங்களின் கலவையாகும் மற்றும் நீங்கள் சேர்க்க விரும்பும் கூடுதல் உரை.\n\n [செல்லுபடியாகும் வடிவங்களின் முழுமையான பட்டியலைப் பற்றி நீங்கள் ஆர்வமாக இருந்தால், அவற்றை இங்கேயே காணலாம்.] (திரை: // timeformattinghelp)\n\n ஒரு நட்பு நினைவூட்டல், நீண்ட அல்லது குறுகிய வடிவ சரங்களை பயன்படுத்துவது அட்டவணை நெடுவரிசைகளின் அகலத்தை மாயமாக மாற்றவில்லை, இது சில மோசமான வரி இடைவெளிகளுக்கும் உரை காட்டப்படாதது.\n\n இயல்புநிலை: \"YY-MM-DD HH: MM\"';

  @override
  String get needlePinBarWidth => 'வண்ண தடிமன்';

  @override
  String get needlePinBarWidthDesc => 'கோடுகளின் அகலம் வண்ண உள்ளீடுகள் வரைபடத்தில் உருவாக்குகின்றன.';

  @override
  String get errParseEmptyCsvFile => 'பதிவை அலசுவதற்கு காபிம கோப்பில் போதுமான வரிகள் இல்லை.';

  @override
  String get errParseTimeNotRestoreable => 'நேர முத்திரையை மீட்டெடுக்க அனுமதிக்கும் நெடுவரிசை எதுவும் இல்லை.';

  @override
  String errParseUnknownColumn(String title) {
    return '\"$title\" என்ற தலைப்பைக் கொண்ட நெடுவரிசை இல்லை.';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'வரி $lineNumber முதல் வரியை விட குறைவான நெடுவரிசைகளைக் கொண்டுள்ளது.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'டிகோடிங் புலம் \"$fieldContent\" வரியில் $lineNumber தோல்வியுற்றது.';
  }

  @override
  String get exportFieldsPreset => 'ஏற்றுமதி புலங்கள் முன்னமைக்கப்பட்டவை';

  @override
  String get remove => 'அகற்று';

  @override
  String get manageExportColumns => 'ஏற்றுமதி நெடுவரிசைகளை நிர்வகிக்கவும்';

  @override
  String get buildIn => 'உருவாக்க';

  @override
  String get csvTitle => 'சி.எச்.வி-தலைப்பு';

  @override
  String get recordFormat => 'பதிவு வடிவம்';

  @override
  String get timeFormat => 'நேர வடிவம்';

  @override
  String get errAccuracyLoss => 'தனிப்பயன் நேர வடிவங்களுடன் ஏற்றுமதி செய்யும் போது துல்லியமான இழப்பு எதிர்பார்க்கப்படுகிறது.';

  @override
  String get bottomAppBars => 'கீழே உரையாடல் பார்கள்';

  @override
  String get medications => 'மருந்துகள்';

  @override
  String get addMedication => 'மருந்து சேர்க்கவும்';

  @override
  String get name => 'பெயர்';

  @override
  String get defaultDosis => 'இயல்புநிலை டோச்';

  @override
  String get noMedication => 'மருந்து இல்லை';

  @override
  String get dosis => 'டோச்';

  @override
  String get valueDistribution => 'மதிப்பு வழங்கல்';

  @override
  String get titleInCsv => 'காபிம இல் தலைப்பு';

  @override
  String get errBleNoPerms => 'ஊடலை அனுமதிகள் இல்லை';

  @override
  String get preferredPressureUnit => 'விருப்பமான அழுத்தம் அலகு';

  @override
  String get compactList => 'சிறிய அளவீட்டு பட்டியல்';

  @override
  String get bluetoothDisabled => 'ஊடலை முடக்கப்பட்டது';

  @override
  String get errMeasurementRead => 'அளவீட்டு எடுக்கும்போது பிழை!';

  @override
  String get measurementSuccess => 'அளவீட்டு வெற்றிகரமாக எடுக்கப்பட்டது!';

  @override
  String get connect => 'இணை';

  @override
  String get bluetoothInput => 'ஊடலை உள்ளீடு';

  @override
  String get aboutBleInput => 'சில அளவீட்டு சாதனங்கள் பிளே காட் இணக்கமானவை. இந்த சாதனங்களை நீங்கள் இங்கே இணைக்கலாம் மற்றும் தானாக அளவீடுகளை அனுப்பலாம் அல்லது அமைப்புகளில் இந்த விருப்பத்தை முடக்கலாம்.';

  @override
  String get scanningForDevices => 'சாதனங்களுக்கான ச்கேன்';

  @override
  String get tapToClose => 'மூட தட்டவும்.';

  @override
  String get meanArterialPressure => 'தமனி சார்ந்த அழுத்தம்';

  @override
  String get userID => 'பயனர் ஐடி';

  @override
  String get bodyMovementDetected => 'உடல் இயக்கம் கண்டறியப்பட்டது';

  @override
  String get cuffTooLoose => 'சுற்றுப்பட்டை மிகவும் தளர்வானது';

  @override
  String get improperMeasurementPosition => 'முறையற்ற அளவீட்டு நிலை';

  @override
  String get irregularPulseDetected => 'ஒழுங்கற்ற துடிப்பு கண்டறியப்பட்டது';

  @override
  String get pulseRateExceedsUpperLimit => 'துடிப்பு வீதம் மேல் வரம்பை மீறுகிறது';

  @override
  String get pulseRateLessThanLowerLimit => 'துடிப்பு வீதம் குறைந்த வரம்பை விட குறைவாக உள்ளது';

  @override
  String get availableDevices => 'கிடைக்கும் சாதனங்கள்';

  @override
  String get deleteAllMedicineIntakes => 'அனைத்து மருந்து உட்கொள்ளல்களையும் நீக்கு';

  @override
  String get deleteAllNotes => 'எல்லா குறிப்புகளையும் நீக்கு';

  @override
  String get date => 'திகதி';

  @override
  String get intakes => 'மருந்து உட்கொள்ளல்';

  @override
  String get errFeatureNotSupported => 'இந்த மேடையில் இந்த நற்பொருத்தம் கிடைக்கவில்லை.';

  @override
  String get invalidZip => 'தவறான சிப் கோப்பு.';

  @override
  String get errCantCreateArchive => 'காப்பகத்தை உருவாக்க முடியாது. முடிந்தால் பிழையைப் புகாரளிக்கவும்.';

  @override
  String get activateWeightFeatures => 'எடை தொடர்பான அம்சங்களை செயல்படுத்தவும்';

  @override
  String get weight => 'எடை';

  @override
  String get enterWeight => 'எடையை உள்ளிடவும்';

  @override
  String get selectMeasurementTitle => 'பயன்படுத்த அளவீட்டைத் தேர்ந்தெடுக்கவும்';

  @override
  String measurementIndex(int number) {
    return 'அளவீட்டு #$number';
  }

  @override
  String get select => 'தேர்ந்தெடு';

  @override
  String get bloodPressure => 'இரத்த அழுத்தம்';

  @override
  String get preferredWeightUnit => 'விருப்பமான எடை அலகு';

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
