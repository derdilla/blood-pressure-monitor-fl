import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fr'),
    Locale('hu'),
    Locale('it'),
    Locale('nb'),
    Locale('nl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure App'**
  String get title;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success: {msg}'**
  String success(String msg);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String error(String msg);

  /// No description provided for @errNaN.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get errNaN;

  /// No description provided for @errLt30.
  ///
  /// In en, this message translates to:
  /// **'Number <= 30? Turn off validation in settings!'**
  String get errLt30;

  /// No description provided for @errUnrealistic.
  ///
  /// In en, this message translates to:
  /// **'Unrealistic value? Turn off validation in settings!'**
  String get errUnrealistic;

  /// No description provided for @errDiaGtSys.
  ///
  /// In en, this message translates to:
  /// **'dia >= sys? Turn off validation in settings!'**
  String get errDiaGtSys;

  /// No description provided for @errCantOpenURL.
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t open URL: {url}'**
  String errCantOpenURL(String url);

  /// No description provided for @errNoFileOpened.
  ///
  /// In en, this message translates to:
  /// **'no file opened'**
  String get errNoFileOpened;

  /// No description provided for @errNotStarted.
  ///
  /// In en, this message translates to:
  /// **'not started'**
  String get errNotStarted;

  /// No description provided for @errNoValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get errNoValue;

  /// No description provided for @errNotEnoughDataToGraph.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw a graph.'**
  String get errNotEnoughDataToGraph;

  /// No description provided for @errNoData.
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get errNoData;

  /// No description provided for @errWrongImportFormat.
  ///
  /// In en, this message translates to:
  /// **'You can only import files in CSV and SQLite database format.'**
  String get errWrongImportFormat;

  /// No description provided for @errNeedHeadline.
  ///
  /// In en, this message translates to:
  /// **'You can only import files with a headline.'**
  String get errNeedHeadline;

  /// No description provided for @errCantReadFile.
  ///
  /// In en, this message translates to:
  /// **'The file\'\'s contents can not be read'**
  String get errCantReadFile;

  /// No description provided for @errNotImportable.
  ///
  /// In en, this message translates to:
  /// **'This file can\'\'t be imported'**
  String get errNotImportable;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get btnSave;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get btnConfirm;

  /// No description provided for @btnUndo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get btnUndo;

  /// No description provided for @sysLong.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get sysLong;

  /// No description provided for @sysShort.
  ///
  /// In en, this message translates to:
  /// **'sys'**
  String get sysShort;

  /// No description provided for @diaLong.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diaLong;

  /// No description provided for @diaShort.
  ///
  /// In en, this message translates to:
  /// **'dia'**
  String get diaShort;

  /// No description provided for @pulLong.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get pulLong;

  /// No description provided for @pulShort.
  ///
  /// In en, this message translates to:
  /// **'pul'**
  String get pulShort;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get addNote;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @allowManualTimeInput.
  ///
  /// In en, this message translates to:
  /// **'Allow manual time input'**
  String get allowManualTimeInput;

  /// No description provided for @enterTimeFormatScreen.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get enterTimeFormatScreen;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @iconSize.
  ///
  /// In en, this message translates to:
  /// **'Icon size'**
  String get iconSize;

  /// No description provided for @graphLineThickness.
  ///
  /// In en, this message translates to:
  /// **'Line thickness'**
  String get graphLineThickness;

  /// No description provided for @animationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Animation duration'**
  String get animationSpeed;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get accentColor;

  /// No description provided for @sysColor.
  ///
  /// In en, this message translates to:
  /// **'Systolic color'**
  String get sysColor;

  /// No description provided for @diaColor.
  ///
  /// In en, this message translates to:
  /// **'Diastolic color'**
  String get diaColor;

  /// No description provided for @pulColor.
  ///
  /// In en, this message translates to:
  /// **'Pulse color'**
  String get pulColor;

  /// No description provided for @behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behavior;

  /// No description provided for @validateInputs.
  ///
  /// In en, this message translates to:
  /// **'Validate inputs'**
  String get validateInputs;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @determineWarnValues.
  ///
  /// In en, this message translates to:
  /// **'Determine warn values'**
  String get determineWarnValues;

  /// No description provided for @aboutWarnValuesScreen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutWarnValuesScreen;

  /// No description provided for @aboutWarnValuesScreenDesc.
  ///
  /// In en, this message translates to:
  /// **'More info on warn values'**
  String get aboutWarnValuesScreenDesc;

  /// No description provided for @sysWarn.
  ///
  /// In en, this message translates to:
  /// **'Systolic warn'**
  String get sysWarn;

  /// No description provided for @diaWarn.
  ///
  /// In en, this message translates to:
  /// **'Diastolic warn'**
  String get diaWarn;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionOf.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String versionOf(String version);

  /// No description provided for @buildNumberOf.
  ///
  /// In en, this message translates to:
  /// **'Version number: {buildNumber}'**
  String buildNumberOf(String buildNumber);

  /// No description provided for @packageNameOf.
  ///
  /// In en, this message translates to:
  /// **'Package name: {name}'**
  String packageNameOf(String name);

  /// No description provided for @exportImport.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get exportImport;

  /// No description provided for @exportDir.
  ///
  /// In en, this message translates to:
  /// **'Export directory'**
  String get exportDir;

  /// No description provided for @exportAfterEveryInput.
  ///
  /// In en, this message translates to:
  /// **'Export after every entry'**
  String get exportAfterEveryInput;

  /// No description provided for @exportAfterEveryInputDesc.
  ///
  /// In en, this message translates to:
  /// **'Not recommended (file explosion)'**
  String get exportAfterEveryInputDesc;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get exportFormat;

  /// No description provided for @exportCustomEntries.
  ///
  /// In en, this message translates to:
  /// **'Customize fields'**
  String get exportCustomEntries;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addEntry;

  /// No description provided for @exportMimeType.
  ///
  /// In en, this message translates to:
  /// **'Export media type'**
  String get exportMimeType;

  /// No description provided for @exportCsvHeadline.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get exportCsvHeadline;

  /// No description provided for @exportCsvHeadlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps to discriminate types'**
  String get exportCsvHeadlineDesc;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @db.
  ///
  /// In en, this message translates to:
  /// **'SQLite DB'**
  String get db;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'text'**
  String get text;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get other;

  /// No description provided for @fieldDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Field delimiter'**
  String get fieldDelimiter;

  /// No description provided for @textDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Text delimiter'**
  String get textDelimiter;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'EXPORT'**
  String get export;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'shared'**
  String get shared;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'IMPORT'**
  String get import;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'3rd party licenses'**
  String get licenses;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} entries'**
  String importSuccess(int count);

  /// No description provided for @exportWarnConfigNotImportable.
  ///
  /// In en, this message translates to:
  /// **'Hey! Just a friendly heads up: the current export configuration won\'\'t be importable. To fix it, make sure you set the export type as CSV and include one of the time formats available.'**
  String get exportWarnConfigNotImportable;

  /// No description provided for @exportWarnNotEveryFieldExported.
  ///
  /// In en, this message translates to:
  /// **'Beware that you are not exporting all fields: {fields} {count, plural, one{is} other{are}} missing.'**
  String exportWarnNotEveryFieldExported(int count, String fields);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @measurementCount.
  ///
  /// In en, this message translates to:
  /// **'Measurement count'**
  String get measurementCount;

  /// No description provided for @measurementsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Measurements per day'**
  String get measurementsPerDay;

  /// No description provided for @timeResolvedMetrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics by time of day'**
  String get timeResolvedMetrics;

  /// No description provided for @avgOf.
  ///
  /// In en, this message translates to:
  /// **'{txt} Ø'**
  String avgOf(String txt);

  /// No description provided for @minOf.
  ///
  /// In en, this message translates to:
  /// **'{txt} min.'**
  String minOf(String txt);

  /// No description provided for @maxOf.
  ///
  /// In en, this message translates to:
  /// **'{txt} max.'**
  String maxOf(String txt);

  /// No description provided for @warnValues.
  ///
  /// In en, this message translates to:
  /// **'Warn values'**
  String get warnValues;

  /// No description provided for @warnAboutTxt1.
  ///
  /// In en, this message translates to:
  /// **'The warn values are a pure suggestions and no medical advice.'**
  String get warnAboutTxt1;

  /// No description provided for @warnAboutTxt2.
  ///
  /// In en, this message translates to:
  /// **'The default age dependent values come from this source.'**
  String get warnAboutTxt2;

  /// No description provided for @warnAboutTxt3.
  ///
  /// In en, this message translates to:
  /// **'Feel free to change the values to suit your needs and follow the recommendations of your doctor.'**
  String get warnAboutTxt3;

  /// No description provided for @enterTimeFormatString.
  ///
  /// In en, this message translates to:
  /// **'time format'**
  String get enterTimeFormatString;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry? (You can turn off these confirmations in the settings.)'**
  String get confirmDeleteDesc;

  /// No description provided for @deletionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted.'**
  String get deletionConfirmed;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @weekOfYear.
  ///
  /// In en, this message translates to:
  /// **'Week {weekNum}, {year}'**
  String weekOfYear(int weekNum, int year);

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get last30Days;

  /// No description provided for @allowMissingValues.
  ///
  /// In en, this message translates to:
  /// **'Allow missing values'**
  String get allowMissingValues;

  /// No description provided for @errTimeAfterNow.
  ///
  /// In en, this message translates to:
  /// **'The selected time is in the future. You can turn off this validation in the settings.'**
  String get errTimeAfterNow;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @drawRegressionLines.
  ///
  /// In en, this message translates to:
  /// **'Draw trend lines'**
  String get drawRegressionLines;

  /// No description provided for @drawRegressionLinesDesc.
  ///
  /// In en, this message translates to:
  /// **'Draws regression lines in graph. Only useful for large intervalls.'**
  String get drawRegressionLinesDesc;

  /// No description provided for @pdfDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure values from {start} until {end}'**
  String pdfDocumentTitle(String start, String end);

  /// No description provided for @fieldFormat.
  ///
  /// In en, this message translates to:
  /// **'Field format'**
  String get fieldFormat;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get result;

  /// No description provided for @pulsePressure.
  ///
  /// In en, this message translates to:
  /// **'Pulse pressure'**
  String get pulsePressure;

  /// No description provided for @addExportformat.
  ///
  /// In en, this message translates to:
  /// **'Add exportformat'**
  String get addExportformat;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @exportFieldFormatDocumentation.
  ///
  /// In en, this message translates to:
  /// **'\'## Variables\nThe export field format supports inserting values for the following placeholders:\n- `\$TIMESTAMP:` Represents the time since the Unix epoch in milliseconds.\n- `\$SYS:` Provides a value if available; otherwise, it defaults to -1.\n- `\$DIA:` Provides a value if available; otherwise, it defaults to -1.\n- `\$PUL:` Provides a value if available; otherwise, it defaults to -1.\n- `\$NOTE:` Provides a value if available; otherwise, it defaults to -1.\n- `\$COLOR:` Represents the color of a measurement as a number. (example value: `4291681337`)\n\nIf any of the placeholders mentioned above are not present in the blood pressure record, they will be replaced with `null`.\n\n## Math\nYou can use basic mathematics inside double brackets (\"`{{}}`\").\n\nThe following mathematical operations are supported:\n- Operations: +, -, *, /, %, ^\n- One-parameter functions: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Two-parameter functions: log, nrt, pow\n- Constants: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nFor the full math interpreter specification, you can refer to the [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) documentation.\n\n## Processing order\n1. variable replacement\n2. Math\''**
  String get exportFieldFormatDocumentation;

  /// No description provided for @default_.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_;

  /// No description provided for @exportPdfHeaderHeight.
  ///
  /// In en, this message translates to:
  /// **'Header height'**
  String get exportPdfHeaderHeight;

  /// No description provided for @exportPdfCellHeight.
  ///
  /// In en, this message translates to:
  /// **'Row height'**
  String get exportPdfCellHeight;

  /// No description provided for @exportPdfHeaderFontSize.
  ///
  /// In en, this message translates to:
  /// **'Header font size'**
  String get exportPdfHeaderFontSize;

  /// No description provided for @exportPdfCellFontSize.
  ///
  /// In en, this message translates to:
  /// **'Row font size'**
  String get exportPdfCellFontSize;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @exportPdfExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get exportPdfExportTitle;

  /// No description provided for @exportPdfExportStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get exportPdfExportStatistics;

  /// No description provided for @exportPdfExportData.
  ///
  /// In en, this message translates to:
  /// **'Data table'**
  String get exportPdfExportData;

  /// No description provided for @startWithAddMeasurementPage.
  ///
  /// In en, this message translates to:
  /// **'Measurement on launch'**
  String get startWithAddMeasurementPage;

  /// No description provided for @startWithAddMeasurementPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Upon app launch, measurement input screen shown.'**
  String get startWithAddMeasurementPageDescription;

  /// No description provided for @horizontalLines.
  ///
  /// In en, this message translates to:
  /// **'Horizontal lines'**
  String get horizontalLines;

  /// No description provided for @linePositionY.
  ///
  /// In en, this message translates to:
  /// **'Line position (y)'**
  String get linePositionY;

  /// No description provided for @customGraphMarkings.
  ///
  /// In en, this message translates to:
  /// **'Custom markings'**
  String get customGraphMarkings;

  /// No description provided for @addLine.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get addLine;

  /// No description provided for @useLegacyList.
  ///
  /// In en, this message translates to:
  /// **'Use legacy list'**
  String get useLegacyList;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @exportSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup settings'**
  String get exportSettings;

  /// No description provided for @importSettings.
  ///
  /// In en, this message translates to:
  /// **'Restore settings'**
  String get importSettings;

  /// No description provided for @requiresAppRestart.
  ///
  /// In en, this message translates to:
  /// **'Requires app restart'**
  String get requiresAppRestart;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart now'**
  String get restartNow;

  /// No description provided for @warnNeedsRestartForUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Files were deleted in this session. Restart the app to continue using returning to other parts of the app!'**
  String get warnNeedsRestartForUsingApp;

  /// No description provided for @deleteAllMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Delete all measurements'**
  String get deleteAllMeasurements;

  /// No description provided for @deleteAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Delete all settings'**
  String get deleteAllSettings;

  /// No description provided for @warnDeletionUnrecoverable.
  ///
  /// In en, this message translates to:
  /// **'This step not revertible unless you manually made a backup. Do you really want to delete this?'**
  String get warnDeletionUnrecoverable;

  /// No description provided for @enterTimeFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'A formatter string is a blend of predefined ICU/Skeleton strings and any additional text you\'\'d like to include.\n\n[If you\'\'re curious about the complete list of valid formats, you can find them right here.](screen://TimeFormattingHelp)\n\nJust a friendly reminder, using longer or shorter format Strings won\'\'t magically alter the width of the table columns, which might lead to some awkward line breaks and text not showing.\n\ndefault: \"yy-MM-dd HH:mm\"'**
  String get enterTimeFormatDesc;

  /// No description provided for @needlePinBarWidth.
  ///
  /// In en, this message translates to:
  /// **'Color thickness'**
  String get needlePinBarWidth;

  /// No description provided for @needlePinBarWidthDesc.
  ///
  /// In en, this message translates to:
  /// **'The width of the lines colored entries make on the graph.'**
  String get needlePinBarWidthDesc;

  /// No description provided for @errParseEmptyCsvFile.
  ///
  /// In en, this message translates to:
  /// **'There are not enough lines in the csv file to parse the record.'**
  String get errParseEmptyCsvFile;

  /// No description provided for @errParseTimeNotRestoreable.
  ///
  /// In en, this message translates to:
  /// **'There is no column that allows restoring a timestamp.'**
  String get errParseTimeNotRestoreable;

  /// No description provided for @errParseUnknownColumn.
  ///
  /// In en, this message translates to:
  /// **'There is no column with title \"{title}\".'**
  String errParseUnknownColumn(String title);

  /// No description provided for @errParseLineTooShort.
  ///
  /// In en, this message translates to:
  /// **'Line {lineNumber} has fewer columns than the first line.'**
  String errParseLineTooShort(int lineNumber);

  /// No description provided for @errParseFailedDecodingField.
  ///
  /// In en, this message translates to:
  /// **'Decoding field \"{fieldContent}\" in line {lineNumber} failed.'**
  String errParseFailedDecodingField(int lineNumber, String fieldContent);

  /// No description provided for @exportFieldsPreset.
  ///
  /// In en, this message translates to:
  /// **'Export fields preset'**
  String get exportFieldsPreset;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @manageExportColumns.
  ///
  /// In en, this message translates to:
  /// **'Manage export columns'**
  String get manageExportColumns;

  /// No description provided for @buildIn.
  ///
  /// In en, this message translates to:
  /// **'Build-in'**
  String get buildIn;

  /// No description provided for @csvTitle.
  ///
  /// In en, this message translates to:
  /// **'CSV-title'**
  String get csvTitle;

  /// No description provided for @recordFormat.
  ///
  /// In en, this message translates to:
  /// **'Record format'**
  String get recordFormat;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @errAccuracyLoss.
  ///
  /// In en, this message translates to:
  /// **'There is precision loss expected when exporting with custom time formatters.'**
  String get errAccuracyLoss;

  /// No description provided for @bottomAppBars.
  ///
  /// In en, this message translates to:
  /// **'Bottom dialogue bars'**
  String get bottomAppBars;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get addMedication;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @defaultDosis.
  ///
  /// In en, this message translates to:
  /// **'Default dose'**
  String get defaultDosis;

  /// No description provided for @noMedication.
  ///
  /// In en, this message translates to:
  /// **'No medication'**
  String get noMedication;

  /// No description provided for @dosis.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dosis;

  /// No description provided for @valueDistribution.
  ///
  /// In en, this message translates to:
  /// **'Value distribution'**
  String get valueDistribution;

  /// No description provided for @titleInCsv.
  ///
  /// In en, this message translates to:
  /// **'Title in CSV'**
  String get titleInCsv;

  /// No description provided for @errBleNoPerms.
  ///
  /// In en, this message translates to:
  /// **'No bluetooth permissions'**
  String get errBleNoPerms;

  /// No description provided for @preferredPressureUnit.
  ///
  /// In en, this message translates to:
  /// **'Preferred pressure unit'**
  String get preferredPressureUnit;

  /// No description provided for @compactList.
  ///
  /// In en, this message translates to:
  /// **'Compact measurement list'**
  String get compactList;

  /// No description provided for @bluetoothDisabled.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth disabled'**
  String get bluetoothDisabled;

  /// No description provided for @errMeasurementRead.
  ///
  /// In en, this message translates to:
  /// **'Error while taking measurement!'**
  String get errMeasurementRead;

  /// No description provided for @measurementSuccess.
  ///
  /// In en, this message translates to:
  /// **'Measurement taken successfully!'**
  String get measurementSuccess;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @bluetoothInput.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth input'**
  String get bluetoothInput;

  /// No description provided for @aboutBleInput.
  ///
  /// In en, this message translates to:
  /// **'Some measurement devices are BLE GATT compatible. You can pair these devices here and automatically transmit measurements or disable this option in the settings.'**
  String get aboutBleInput;

  /// No description provided for @scanningForDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices'**
  String get scanningForDevices;

  /// No description provided for @tapToClose.
  ///
  /// In en, this message translates to:
  /// **'Tap to close.'**
  String get tapToClose;

  /// No description provided for @meanArterialPressure.
  ///
  /// In en, this message translates to:
  /// **'Mean arterial pressure'**
  String get meanArterialPressure;

  /// No description provided for @userID.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userID;

  /// No description provided for @bodyMovementDetected.
  ///
  /// In en, this message translates to:
  /// **'Body movement detected'**
  String get bodyMovementDetected;

  /// No description provided for @cuffTooLoose.
  ///
  /// In en, this message translates to:
  /// **'Cuff too loose'**
  String get cuffTooLoose;

  /// No description provided for @improperMeasurementPosition.
  ///
  /// In en, this message translates to:
  /// **'Improper measurement position'**
  String get improperMeasurementPosition;

  /// No description provided for @irregularPulseDetected.
  ///
  /// In en, this message translates to:
  /// **'Irregular pulse detected'**
  String get irregularPulseDetected;

  /// No description provided for @pulseRateExceedsUpperLimit.
  ///
  /// In en, this message translates to:
  /// **'Pulse rate exceeds upper limit'**
  String get pulseRateExceedsUpperLimit;

  /// No description provided for @pulseRateLessThanLowerLimit.
  ///
  /// In en, this message translates to:
  /// **'Pulse rate is less than lower limit'**
  String get pulseRateLessThanLowerLimit;

  /// No description provided for @availableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available devices'**
  String get availableDevices;

  /// No description provided for @deleteAllMedicineIntakes.
  ///
  /// In en, this message translates to:
  /// **'Delete all medicine intakes'**
  String get deleteAllMedicineIntakes;

  /// No description provided for @deleteAllNotes.
  ///
  /// In en, this message translates to:
  /// **'Delete all notes'**
  String get deleteAllNotes;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @intakes.
  ///
  /// In en, this message translates to:
  /// **'Medicine intakes'**
  String get intakes;

  /// No description provided for @errFeatureNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available on this platform.'**
  String get errFeatureNotSupported;

  /// No description provided for @invalidZip.
  ///
  /// In en, this message translates to:
  /// **'Invalid zip file.'**
  String get invalidZip;

  /// No description provided for @errCantCreateArchive.
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t create archive. Please report the bug if possible.'**
  String get errCantCreateArchive;

  /// No description provided for @activateWeightFeatures.
  ///
  /// In en, this message translates to:
  /// **'Activate weight related features'**
  String get activateWeightFeatures;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// No description provided for @selectMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Select the measurement to use'**
  String get selectMeasurementTitle;

  /// No description provided for @measurementIndex.
  ///
  /// In en, this message translates to:
  /// **'Measurement #{number}'**
  String measurementIndex(int number);

  /// Used when f.e. selecting a single measurement when the bluetooth device returned multiple
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get bloodPressure;

  /// Setting for the unit the app will use for displaying weight
  ///
  /// In en, this message translates to:
  /// **'Preferred weight unit'**
  String get preferredWeightUnit;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @oldBluetoothInput.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get oldBluetoothInput;

  /// No description provided for @newBluetoothInputOldLib.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get newBluetoothInputOldLib;

  /// No description provided for @newBluetoothInputCrossPlatform.
  ///
  /// In en, this message translates to:
  /// **'Beta cross-platform'**
  String get newBluetoothInputCrossPlatform;

  /// No description provided for @bluetoothInputDesc.
  ///
  /// In en, this message translates to:
  /// **'The beta backend works on more devices but is less tested. The cross-platform version may work on non-android and is planned to supersede the stable implementation once mature enough.'**
  String get bluetoothInputDesc;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cs', 'de', 'en', 'es', 'et', 'fr', 'hu', 'it', 'nb', 'nl', 'pt', 'ru', 'sl', 'sv', 'ta', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs': return AppLocalizationsCs();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'et': return AppLocalizationsEt();
    case 'fr': return AppLocalizationsFr();
    case 'hu': return AppLocalizationsHu();
    case 'it': return AppLocalizationsIt();
    case 'nb': return AppLocalizationsNb();
    case 'nl': return AppLocalizationsNl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'sl': return AppLocalizationsSl();
    case 'sv': return AppLocalizationsSv();
    case 'ta': return AppLocalizationsTa();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
