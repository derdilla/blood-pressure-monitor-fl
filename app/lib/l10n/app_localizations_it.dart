// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get title => 'App per la pressione sanguigna';

  @override
  String success(String msg) {
    return 'Completato: $msg';
  }

  @override
  String get loading => 'Caricamento…';

  @override
  String error(String msg) {
    return 'Errore: $msg';
  }

  @override
  String get errNaN => 'Inserisci un numero';

  @override
  String get errLt30 => '<= 30? Disattiva convalida nelle impostazioni!';

  @override
  String get errUnrealistic => 'Non realistico? Disattiva convalida nelle impostazioni!';

  @override
  String get errDiaGtSys => 'PAD >= PAS? Disattiva convalida nelle impostazioni!';

  @override
  String errCantOpenURL(String url) {
    return 'Impossibile aprire l\'URL: $url';
  }

  @override
  String get errNoFileOpened => 'Nessun file aperto';

  @override
  String get errNotStarted => 'Non avviato';

  @override
  String get errNoValue => 'Inserisci un valore';

  @override
  String get errNotEnoughDataToGraph => 'Non ci sono dati sufficienti per tracciare un grafico.';

  @override
  String get errNoData => 'Nessun dato';

  @override
  String get errWrongImportFormat => 'Puoi importare solo file in formato database CSV e SQLite.';

  @override
  String get errNeedHeadline => 'Puoi importare solo file con una riga di intestazione.';

  @override
  String get errCantReadFile => 'Il contenuto del file non può essere letto';

  @override
  String get errNotImportable => 'Questo file non può essere importato';

  @override
  String get btnCancel => 'Annulla';

  @override
  String get btnSave => 'Salva';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'Precedente';

  @override
  String get sysLong => 'Sistolica';

  @override
  String get sysShort => 'PAS';

  @override
  String get diaLong => 'Diastolica';

  @override
  String get diaShort => 'PAD';

  @override
  String get pulLong => 'Frequenza';

  @override
  String get pulShort => 'FC';

  @override
  String get addNote => 'Nota (facoltativa)';

  @override
  String get settings => 'Impostazioni';

  @override
  String get layout => 'Disposizione';

  @override
  String get allowManualTimeInput => 'Data e ora manuale';

  @override
  String get enterTimeFormatScreen => 'Formato data e ora';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get iconSize => 'Dimensione icona';

  @override
  String get graphLineThickness => 'Spessore linea';

  @override
  String get animationSpeed => 'Durata animazione';

  @override
  String get accentColor => 'Colore del tema';

  @override
  String get sysColor => 'Colore sistolica';

  @override
  String get diaColor => 'Colore diastolica';

  @override
  String get pulColor => 'Colore frequenza';

  @override
  String get behavior => 'Comportamento';

  @override
  String get validateInputs => 'Convalida inserimenti';

  @override
  String get confirmDeletion => 'Conferma eliminazione';

  @override
  String get age => 'Età';

  @override
  String get determineWarnValues => 'Determina valori di avviso';

  @override
  String get aboutWarnValuesScreen => 'Informazioni';

  @override
  String get aboutWarnValuesScreenDesc => 'Ulteriori informazioni sui valori di avviso';

  @override
  String get sysWarn => 'Avviso sistolica';

  @override
  String get diaWarn => 'Avviso diastolica';

  @override
  String get data => 'Dati';

  @override
  String get version => 'Versione';

  @override
  String versionOf(String version) {
    return 'Versione: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Numero versione: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Nome pacchetto: $name';
  }

  @override
  String get exportImport => 'Esporta e importa';

  @override
  String get exportDir => 'Cartella di esportazione';

  @override
  String get exportAfterEveryInput => 'Esporta dopo ogni inserimento';

  @override
  String get exportAfterEveryInputDesc => 'Non consigliato (sovraccarico file)';

  @override
  String get exportFormat => 'Formato esportazione';

  @override
  String get exportCustomEntries => 'Personalizza campi';

  @override
  String get addEntry => 'Aggiungi campo';

  @override
  String get exportMimeType => 'Supporto per l\'esportazione';

  @override
  String get exportCsvHeadline => 'Riga di intestazione';

  @override
  String get exportCsvHeadlineDesc => 'Aiuta a determinare i tipi di valori';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'DB SQLite';

  @override
  String get text => 'Testo';

  @override
  String get other => 'Altro';

  @override
  String get fieldDelimiter => 'Separatore campi';

  @override
  String get textDelimiter => 'Delimitatore testo';

  @override
  String get export => 'Esporta';

  @override
  String get shared => 'Condiviso';

  @override
  String get import => 'Importa';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get licenses => 'Licenze di terze parti';

  @override
  String importSuccess(int count) {
    return '$count voci importate';
  }

  @override
  String get exportWarnConfigNotImportable => 'Avviso: l\'attuale configurazione di esportazione non potrà essere importata nuovamente. Per risolvere il problema, assicurati di impostare il tipo di esportazione come CSV e includi uno dei formati data e ora disponibili.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Attenzione, non stai esportando tutti i campi. Mancano: $fields $_temp0.';
  }

  @override
  String get statistics => 'Statistiche';

  @override
  String get measurementCount => 'Numero di misurazioni';

  @override
  String get measurementsPerDay => 'Media misurazioni al giorno';

  @override
  String get timeResolvedMetrics => 'Metriche per ora del giorno';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt min';
  }

  @override
  String maxOf(String txt) {
    return '$txt max';
  }

  @override
  String get warnValues => 'Valori di avviso';

  @override
  String get warnAboutTxt1 => 'I valori di avviso sono semplici suggerimenti e non consigli medici.';

  @override
  String get warnAboutTxt2 => 'Fonte dei valori predefiniti in base all\'età.';

  @override
  String get warnAboutTxt3 => 'Sentiti libero di modificare i valori in base alle tue esigenze e segui le raccomandazioni del medico.';

  @override
  String get enterTimeFormatString => 'Formato data e ora';

  @override
  String get now => 'Adesso';

  @override
  String get notes => 'Note';

  @override
  String get time => 'Ora';

  @override
  String get confirmDelete => 'Conferma eliminazione';

  @override
  String get confirmDeleteDesc => 'Eliminare questa voce? Puoi disattivare queste conferme nelle impostazioni';

  @override
  String get deletionConfirmed => 'Voce eliminata.';

  @override
  String get day => 'Giorno';

  @override
  String get week => 'Settimana';

  @override
  String get month => 'Mese';

  @override
  String get year => 'Anno';

  @override
  String get lifetime => 'Tutte le date';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Settimana $weekNum, $year';
  }

  @override
  String get last7Days => '7 giorni';

  @override
  String get last30Days => '30 giorni';

  @override
  String get allowMissingValues => 'Consenti valori mancanti';

  @override
  String get errTimeAfterNow => 'L\'orario selezionato è nel futuro. Puoi disattivare questa convalida nelle impostazioni.';

  @override
  String get language => 'Lingua';

  @override
  String get custom => 'Personalizzato';

  @override
  String get drawRegressionLines => 'Disegna linee di tendenza';

  @override
  String get drawRegressionLinesDesc => 'Disegna le linee di regressione nel grafico. Utile solo per intervalli ampi.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Valori pressione sanguigna dal $start al $end';
  }

  @override
  String get fieldFormat => 'Formato campo';

  @override
  String get result => 'Risultato:';

  @override
  String get pulsePressure => 'Pressione del polso';

  @override
  String get addExportformat => 'Aggiungi formato di esportazione';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get exportFieldFormatDocumentation => '## Variabili\nIl formato del campo di esportazione supporta l\'inserimento di valori per le seguenti variabili:\n- `\$TIMESTAMP:` Rappresenta il tempo trascorso dall\'epoca Unix, espresso in millisecondi.\n- `\$SYS:` Fornisce il valore se disponibile, in alternativa il valore predefinito è -1.\n- `\$DIA:` Fornisce il valore se disponibile, in alternativa il valore predefinito è -1.\n- `\$PUL:` Fornisce il valore se disponibile, in alternativa il valore predefinito è -1.\n- `\$NOTE:` Fornisce il valore se disponibile, in alternativa il valore predefinito è -1.\n- `\$COLOR:` Rappresenta il colore di una misura come numero, il valore di esempio: `4291681337`.\n\nSe qualcuna delle variabili menzionate sopra non sono presenti nella registrazione della pressione sanguigna, verranno sostituite con `null`.\n\n## Matematica\nPuoi usare operazioni matematiche basiche all\'interno di doppie graffe (\"`{{}}`\").\n\nSono supportate le seguenti operazioni matematiche:\n- Operazioni: +, -, *, /, %, ^\n- Equazioni di primo grado: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Equazioni di secondo grado: log, nrt, pow\n- Costanti: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nPer le specifiche complete dell\'interprete matematico, si può fare riferimento all\'[albero delle funzioni](https://pub.dev/documentation/function_tree/latest#interpreter)\n\n## Ordine di elaborazione\n1. Sostituzione variabile\n2. Matematica';

  @override
  String get default_ => 'Predefinito';

  @override
  String get exportPdfHeaderHeight => 'Altezza intestazione';

  @override
  String get exportPdfCellHeight => 'Altezza riga';

  @override
  String get exportPdfHeaderFontSize => 'Dimensione carattere intestazione';

  @override
  String get exportPdfCellFontSize => 'Dimensione carattere riga';

  @override
  String get average => 'Media';

  @override
  String get maximum => 'Massima';

  @override
  String get minimum => 'Minima';

  @override
  String get exportPdfExportTitle => 'Riga di intestazione';

  @override
  String get exportPdfExportStatistics => 'Statistiche';

  @override
  String get exportPdfExportData => 'Tabella dati';

  @override
  String get startWithAddMeasurementPage => 'Misurazione all\'avvio';

  @override
  String get startWithAddMeasurementPageDescription => 'All\'avvio dell\'app viene mostrata la schermata di immissione della misurazione.';

  @override
  String get horizontalLines => 'Linee orizzontali';

  @override
  String get linePositionY => 'Posizione linea (y)';

  @override
  String get customGraphMarkings => 'Marcatori personalizzati';

  @override
  String get addLine => 'Aggiungi linea';

  @override
  String get useLegacyList => 'Usa elenco alternativo';

  @override
  String get addMeasurement => 'Aggiungi misurazione';

  @override
  String get timestamp => 'Data e ora';

  @override
  String get note => 'Nota';

  @override
  String get color => 'Colore';

  @override
  String get exportSettings => 'Backup impostazioni';

  @override
  String get importSettings => 'Ripristino impostazioni';

  @override
  String get requiresAppRestart => 'Richiede il riavvio dell\'app';

  @override
  String get restartNow => 'Riavvia ora';

  @override
  String get warnNeedsRestartForUsingApp => 'Alcuni file sono stati eliminati durante questa sessione. Riavvia l\'app per continuare a utilizzare le altre parti dell\'app!';

  @override
  String get deleteAllMeasurements => 'Elimina tutte le misurazioni';

  @override
  String get deleteAllSettings => 'Elimina tutte le impostazioni';

  @override
  String get warnDeletionUnrecoverable => 'Questo passaggio non è reversibile a meno che tu non abbia effettuato manualmente un backup. Vuoi davvero eliminarlo?';

  @override
  String get enterTimeFormatDesc => 'Una stringa di formattazione è un insieme di stringhe ICU/Skeleton predefinite e di qualsiasi testo aggiuntivo che si desidera includere.\n\n[Se sei curioso di conoscere l\'elenco completo dei formati validi, puoi trovarli qui.](screen://TimeFormattingHelp)\n\nAvviso: l\'uso di stringhe di formato più lungo o più corto non altera magicamente la larghezza delle colonne della tabella, il che potrebbe portare a problematiche interruzioni di riga e alla mancata visualizzazione del testo.\n\nFormato predefinito: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Spessore colore';

  @override
  String get needlePinBarWidthDesc => 'La larghezza delle linee colorate che le voci creano sul grafico.';

  @override
  String get errParseEmptyCsvFile => 'Non sono presenti righe sufficienti nel file CSV per analizzare la registrazione.';

  @override
  String get errParseTimeNotRestoreable => 'Non esiste una colonna che consenta di ripristinare data e ora.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Non esiste alcuna colonna con il titolo \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'La riga $lineNumber ha meno colonne della prima riga.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'La decodifica del campo \"$fieldContent\" nella riga $lineNumber non è riuscita.';
  }

  @override
  String get exportFieldsPreset => 'Campi di esportazione preimpostati';

  @override
  String get remove => 'Rimuovi';

  @override
  String get manageExportColumns => 'Gestisci colonne di esportazione';

  @override
  String get buildIn => 'Integrato';

  @override
  String get csvTitle => 'Titolo CSV';

  @override
  String get recordFormat => 'Formato registrazione';

  @override
  String get timeFormat => 'Formato data e ora';

  @override
  String get errAccuracyLoss => 'È prevista una perdita di precisione durante l\'esportazione con formattatori orari personalizzati.';

  @override
  String get bottomAppBars => 'Barre di dialogo in basso';

  @override
  String get medications => 'Farmaci';

  @override
  String get addMedication => 'Aggiungi farmaci';

  @override
  String get name => 'Nome';

  @override
  String get defaultDosis => 'Dose predefinita';

  @override
  String get noMedication => 'Nessun farmaco';

  @override
  String get dosis => 'Dose';

  @override
  String get valueDistribution => 'Distribuzione dei valori';

  @override
  String get titleInCsv => 'Titolo in CSV';

  @override
  String get errBleNoPerms => 'Nessuna autorizzazione Bluetooth';

  @override
  String get preferredPressureUnit => 'Unità di pressione preferita';

  @override
  String get compactList => 'Elenco compatto misurazioni';

  @override
  String get bluetoothDisabled => 'Bluetooth disabilitato';

  @override
  String get errMeasurementRead => 'Errore durante la misurazione!';

  @override
  String get measurementSuccess => 'Misurazione effettuata con successo!';

  @override
  String get connect => 'Connetti';

  @override
  String get bluetoothInput => 'Ingresso Bluetooth';

  @override
  String get aboutBleInput => 'Alcuni dispositivi di misurazione sono compatibili con BLE GATT. Puoi associare questi dispositivi qui e trasmettere automaticamente le misurazioni o disattivare questa opzione nelle impostazioni.';

  @override
  String get scanningForDevices => 'Scansione dei dispositivi';

  @override
  String get tapToClose => 'Tocca per chiudere.';

  @override
  String get meanArterialPressure => 'Pressione sanguigna media';

  @override
  String get userID => 'ID utente';

  @override
  String get bodyMovementDetected => 'Rilevato movimento del corpo';

  @override
  String get cuffTooLoose => 'Polsino troppo largo';

  @override
  String get improperMeasurementPosition => 'Posizione di misurazione errata';

  @override
  String get irregularPulseDetected => 'Rilevata pulsazione irregolare';

  @override
  String get pulseRateExceedsUpperLimit => 'Frequenza cardiaca superiore al limite massimo';

  @override
  String get pulseRateLessThanLowerLimit => 'Frequenza cardiaca inferiore al limite minimo';

  @override
  String get availableDevices => 'Dispositivi disponibili';

  @override
  String get deleteAllMedicineIntakes => 'Elimina tutte le assunzioni di medicinali';

  @override
  String get deleteAllNotes => 'Elimina tutte le note';

  @override
  String get date => 'Data';

  @override
  String get intakes => 'Assunzioni di medicinali';

  @override
  String get errFeatureNotSupported => 'Questa funzionalità non è disponibile su questa piattaforma.';

  @override
  String get invalidZip => 'File zip non valido.';

  @override
  String get errCantCreateArchive => 'Impossibile creare l\'archivio. Segnalare il bug, se possibile.';

  @override
  String get activateWeightFeatures => 'Attiva funzionalità relative al peso';

  @override
  String get weight => 'Peso';

  @override
  String get enterWeight => 'Inserisci peso';

  @override
  String get selectMeasurementTitle => 'Seleziona la misura da usare';

  @override
  String measurementIndex(int number) {
    return 'Misurazione #$number';
  }

  @override
  String get select => 'Seleziona';

  @override
  String get bloodPressure => 'Pressione sanguigna';

  @override
  String get preferredWeightUnit => 'Unità di peso preferita';

  @override
  String get disabled => 'Disabilitato';

  @override
  String get oldBluetoothInput => 'Stabile';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta multipiattaforma';

  @override
  String get bluetoothInputDesc => 'Il backend beta funziona su più dispositivi ma è meno testato. La versione multipiattaforma potrebbe funzionare su dispositivi non Android e si prevede che sostituirà l\'implementazione stabile una volta sufficientemente matura.';

  @override
  String get tapToSelect => 'Tocca per selezionare';
}
