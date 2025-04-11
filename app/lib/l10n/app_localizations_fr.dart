// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'Pression artérielle';

  @override
  String success(String msg) {
    return 'Réussite : $msg';
  }

  @override
  String get loading => 'chargement…';

  @override
  String error(String msg) {
    return 'Erreur : $msg';
  }

  @override
  String get errNaN => 'Veuillez entrer un nombre';

  @override
  String get errLt30 => 'Nombre <= 30 ? Désactivez la validation dans les paramètres !';

  @override
  String get errUnrealistic => 'Valeur irréaliste ? Désactivez la validation dans les paramètres !';

  @override
  String get errDiaGtSys => 'dia >= sys ? Désactivez la validation dans les paramètres !';

  @override
  String errCantOpenURL(String url) {
    return 'Impossible d\'ouvrir l\'adresse $url';
  }

  @override
  String get errNoFileOpened => 'aucun fichier ouvert';

  @override
  String get errNotStarted => 'non démarré';

  @override
  String get errNoValue => 'Veuillez entrer une valeur';

  @override
  String get errNotEnoughDataToGraph => 'Pas assez de données pour générer un graphique.';

  @override
  String get errNoData => 'pas de données';

  @override
  String get errWrongImportFormat => 'Vous pouvez importer uniquement des fichiers au format CSV et des bases de données au format SQLite.';

  @override
  String get errNeedHeadline => 'Vous ne pouvez importer que des fichiers avec une ligne d\'entête.';

  @override
  String get errCantReadFile => 'Le contenu du fichier ne peut pas être lu';

  @override
  String get errNotImportable => 'Ce fichier ne peut pas être importé';

  @override
  String get btnCancel => 'ANNULER';

  @override
  String get btnSave => 'ENREGISTRER';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'ANNULER';

  @override
  String get sysLong => 'Systolique';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastolique';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pouls';

  @override
  String get pulShort => 'po';

  @override
  String get addNote => 'Note (facultative)';

  @override
  String get settings => 'Paramètres';

  @override
  String get layout => 'Mise en page';

  @override
  String get allowManualTimeInput => 'Permettre la saisie manuelle de l\'heure';

  @override
  String get enterTimeFormatScreen => 'Format de l\'heure';

  @override
  String get theme => 'Thème';

  @override
  String get system => 'Système';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get iconSize => 'Taille de l\'icône';

  @override
  String get graphLineThickness => 'Épaisseur de la ligne';

  @override
  String get animationSpeed => 'Durée de l\'animation';

  @override
  String get accentColor => 'Couleur du thème';

  @override
  String get sysColor => 'Couleur de la systole';

  @override
  String get diaColor => 'Couleur de la diastole';

  @override
  String get pulColor => 'Couleur de la fréquence cardiaque';

  @override
  String get behavior => 'Comportement';

  @override
  String get validateInputs => 'Confirmer les saisies';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get age => 'Âge';

  @override
  String get determineWarnValues => 'Déterminer les valeurs d\'alerte';

  @override
  String get aboutWarnValuesScreen => 'À propos';

  @override
  String get aboutWarnValuesScreenDesc => 'Plus d\'informations sur les valeurs d\'alerte';

  @override
  String get sysWarn => 'Alerte sur la systole';

  @override
  String get diaWarn => 'Alerte sur la diastole';

  @override
  String get data => 'Données';

  @override
  String get version => 'Version';

  @override
  String versionOf(String version) {
    return 'Version : $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Numéro de version : $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Nom du package : $name';
  }

  @override
  String get exportImport => 'Exporter / Importer';

  @override
  String get exportDir => 'Répertoire d\'export';

  @override
  String get exportAfterEveryInput => 'Exporter après chaque saisie';

  @override
  String get exportAfterEveryInputDesc => 'Non recommandé (explosion du fichier)';

  @override
  String get exportFormat => 'Format d\'exportation';

  @override
  String get exportCustomEntries => 'Personnaliser les champs';

  @override
  String get addEntry => 'Ajouter un champ';

  @override
  String get exportMimeType => 'Exporter le type de média';

  @override
  String get exportCsvHeadline => 'Ligne d\'entête';

  @override
  String get exportCsvHeadlineDesc => 'Aide pour distinguer les types';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'BDD SQLite';

  @override
  String get text => 'texte';

  @override
  String get other => 'autre';

  @override
  String get fieldDelimiter => 'Délimiteur de champ';

  @override
  String get textDelimiter => 'Délimiteur de texte';

  @override
  String get export => 'EXPORTER';

  @override
  String get shared => 'partagé';

  @override
  String get import => 'IMPORTER';

  @override
  String get sourceCode => 'Code source';

  @override
  String get licenses => 'Licences de tierces parties';

  @override
  String importSuccess(int count) {
    return '$count lignes importées';
  }

  @override
  String get exportWarnConfigNotImportable => 'Coucou ! Ceci est juste un avertissement amical : les options d\'export choisies ne seront pas importables. Pour corriger cela, choisissez un export en CSV, activez la ligne d\'entête et sélectionnez un des formats d\'heure disponibles.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sont manquants',
      one: 'est manquant',
    );
    return 'Attention, vous n\'exportez pas tous les champs : $fields $_temp0.';
  }

  @override
  String get statistics => 'Statistiques';

  @override
  String get measurementCount => 'Compteur de mesures';

  @override
  String get measurementsPerDay => 'Mesures par jour';

  @override
  String get timeResolvedMetrics => 'Statistiques de mesures selon l\'heure';

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
  String get warnValues => 'Valeurs d\'alerte';

  @override
  String get warnAboutTxt1 => 'Les valeurs d\'alerte ne sont que des suggestions et n\'ont pas valeur d\'avis médical.';

  @override
  String get warnAboutTxt2 => 'Source des valeurs par défaut en fonction de l\'âge.';

  @override
  String get warnAboutTxt3 => 'N\'hésitez pas à modifier les valeurs pour qu\'elles vous conviennent et suivent les recommandations de votre médecin.';

  @override
  String get enterTimeFormatString => 'format d\'heure';

  @override
  String get now => 'maintenant';

  @override
  String get notes => 'Notes';

  @override
  String get time => 'Heure';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmDeleteDesc => 'Supprimer cet enregistrement ? (Vous pouvez désactiver cette confirmation dans les paramètres.)';

  @override
  String get deletionConfirmed => 'Enregistrement supprimé.';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get lifetime => 'Durée de vie';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Semaine $weekNum, $year';
  }

  @override
  String get last7Days => '7 jours';

  @override
  String get last30Days => '30 jours';

  @override
  String get allowMissingValues => 'Autoriser les valeurs manquantes';

  @override
  String get errTimeAfterNow => 'L\'heure choisie est dans le futur. Vous pouvez désactiver cette validation dans les paramètres.';

  @override
  String get language => 'Langue';

  @override
  String get custom => 'Personnalisé';

  @override
  String get drawRegressionLines => 'Dessiner des lignes de tendances';

  @override
  String get drawRegressionLinesDesc => 'Dessiner des lignes de régression dans les graphiques. Utile seulement pour les grands intervalles.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Mesures de pression artérielle du $start au $end';
  }

  @override
  String get fieldFormat => 'Format de champ';

  @override
  String get result => 'Résultat :';

  @override
  String get pulsePressure => 'Pression pulsée';

  @override
  String get addExportformat => 'Ajouter un format d\'export';

  @override
  String get edit => 'Éditer';

  @override
  String get delete => 'Supprimer';

  @override
  String get exportFieldFormatDocumentation => '## Variables\nLe format d\'export supporte l\'insertion de valeurs pour les placeholders suivants :\n- `\$TIMESTAMP :` Représente la durée depuis l\'époque Unix en millisecondes.\n- `\$SYS :` Fournit une valeur si disponible ; sinon, it defaults to -1.\n- `\$DIA :` Fournit une valeur si disponible ; sinon, it defaults to -1.\n- `\$PUL :`Fournit une valeur si disponible ; sinon, it defaults to -1.\n- `\$NOTE :` Fournit une valeur si disponible ; sinon, it defaults to -1.\n- `\$COLOR :` Représente la couleur d\'une mesure comme nombre. ( example de valeur : `4291681337`)\n\nSi n\'importe lequel de ces placeholders mentionnés ci-dessus ne sont pas présents dans l\'enregistement de pression artérielle, ils seront remplacés par -1.\n\n## Maths\nVous pouvez utiliser des mathématiques basiques à l\'intérieur de doubles crochets (\"`{{}}`\").\n\nLes opérations mathématiques suivantes sont supportées :\n- Opérations : +, -, *, /, %, ^\n- Fonctions à paramètre unique : abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Fonctions à deux paramètres : log, nrt, pow\n- Constantes : e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\nPour la spécification complète de l\'interpréteur mathématique, vous pouvez vous référer au [function_tree](https ://pub.dev/documentation/function_tree/latest#interpreter) specification\n\n## Ordre de traitement\n1. remplacement de variable\n2. Maths';

  @override
  String get default_ => 'Défaut';

  @override
  String get exportPdfHeaderHeight => 'Hauteur de l\'en-tête';

  @override
  String get exportPdfCellHeight => 'Hauteur de ligne';

  @override
  String get exportPdfHeaderFontSize => 'Taille de caractère de l\'en-tête';

  @override
  String get exportPdfCellFontSize => 'Taille de caractères de ligne';

  @override
  String get average => 'Moyenne';

  @override
  String get maximum => 'Maximum';

  @override
  String get minimum => 'Minimum';

  @override
  String get exportPdfExportTitle => 'En-tête';

  @override
  String get exportPdfExportStatistics => 'Statistiques';

  @override
  String get exportPdfExportData => 'Tableau de données';

  @override
  String get startWithAddMeasurementPage => 'Mesure au lancement';

  @override
  String get startWithAddMeasurementPageDescription => 'Lors du lancement de l\'application, l\'écran de mesure s\'ouvre.';

  @override
  String get horizontalLines => 'Lignes horizontales';

  @override
  String get linePositionY => 'Position de ligne (y)';

  @override
  String get customGraphMarkings => 'Marquage personnalisé';

  @override
  String get addLine => 'Ajouter une ligne';

  @override
  String get useLegacyList => 'Ancien affichage de la liste';

  @override
  String get addMeasurement => 'Ajouter une mesure';

  @override
  String get timestamp => 'Horodatage';

  @override
  String get note => 'Note';

  @override
  String get color => 'Couleur';

  @override
  String get exportSettings => 'Sauvegarder les paramètres';

  @override
  String get importSettings => 'Importer les paramètres';

  @override
  String get requiresAppRestart => 'Requiert un redémarrage de l\'app';

  @override
  String get restartNow => 'Redémarrer maintenant';

  @override
  String get warnNeedsRestartForUsingApp => 'Des fichiers ont été supprimés dans cette session. Redémarrez l\'application pour continuer à utiliser d\'autres parties de celle-ci !';

  @override
  String get deleteAllMeasurements => 'Supprimer toutes les mesures';

  @override
  String get deleteAllSettings => 'Supprimer tous les paramètres';

  @override
  String get warnDeletionUnrecoverable => 'Cette étape est irréversible à moins que vous n\'ayez fait une sauvegarde manuelle. Êtes-vous certain de vouloir supprimer ceci ?';

  @override
  String get enterTimeFormatDesc => 'Une chaine de formatage est un mélange de chaines ICU/Skeleton et de n\'importe quel texte supplémentaire que vous souhaitez inclure.\n\n[Si vous souhaitez en savoir plus sur la liste complète des formats valides, tapez ici.](screen ://TimeFormattingHelp)\n\nRappel amical : utiliser des chaines de formatage plus courtes ou plus longues ne modifiera pas la largeur des colonnes de la table par magie, ce qui pourrait générer des retours à la ligne inattendus ou que du texte n\'apparaisse pas.\n\nValeur par défaut : \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Épaisseur';

  @override
  String get needlePinBarWidthDesc => 'L\'épaisseur des lignes coloriées que les saisies font sur la courbe.';

  @override
  String get errParseEmptyCsvFile => 'Il n’y a pas assez de lignes dans le fichier csv pour analyser l’enregistrement.';

  @override
  String get errParseTimeNotRestoreable => 'Il n’y a pas de colonne qui permet de restaurer un horodatage.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Il n’y a pas de colonne avec le titre \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'La ligne $lineNumber a moins de colonnes que la première ligne.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Le décodage du champ \"$fieldContent\" dans la ligne $lineNumber a échoué.';
  }

  @override
  String get exportFieldsPreset => 'Préréglage des champs d’exportation';

  @override
  String get remove => 'Retirer';

  @override
  String get manageExportColumns => 'Gérer les colonnes d’exportation';

  @override
  String get buildIn => 'Intégré';

  @override
  String get csvTitle => 'Titre CSV';

  @override
  String get recordFormat => 'Format d\'enregistrement';

  @override
  String get timeFormat => 'Format d\'heure';

  @override
  String get errAccuracyLoss => 'Une perte de précision est attendue lors de l’exportation avec des formateurs de temps personnalisés.';

  @override
  String get bottomAppBars => 'Barres de dialogue inférieures';

  @override
  String get medications => 'Médicaments';

  @override
  String get addMedication => 'Ajouter médicament';

  @override
  String get name => 'Nom';

  @override
  String get defaultDosis => 'Dose par défaut';

  @override
  String get noMedication => 'Pas de médicament';

  @override
  String get dosis => 'Dose';

  @override
  String get valueDistribution => 'Distribution des mesures';

  @override
  String get titleInCsv => 'Titre dans CSV';

  @override
  String get errBleNoPerms => 'Pas d’autorisations Bluetooth';

  @override
  String get preferredPressureUnit => 'Unité de pression préférée';

  @override
  String get compactList => 'Liste de mesures compacte';

  @override
  String get bluetoothDisabled => 'Bluetooth désactivé';

  @override
  String get errMeasurementRead => 'Erreur lors de la prise de mesure !';

  @override
  String get measurementSuccess => 'Mesure prise avec succès !';

  @override
  String get connect => 'Connecter';

  @override
  String get bluetoothInput => 'Entrée Bluetooth';

  @override
  String get aboutBleInput => 'Certains appareils de mesure sont compatibles BLE GATT. Vous pouvez jumeler ces appareils ici et transmettre automatiquement les mesures ou désactiver cette option dans les paramètres.';

  @override
  String get scanningForDevices => 'Recherche (balayage) d\'appareils';

  @override
  String get tapToClose => 'Appuyez pour fermer.';

  @override
  String get meanArterialPressure => 'Pression artérielle moyenne';

  @override
  String get userID => 'ID utilisateur';

  @override
  String get bodyMovementDetected => 'Mouvement du corps détecté';

  @override
  String get cuffTooLoose => 'Manchette trop lâche';

  @override
  String get improperMeasurementPosition => 'Position de mesure incorrecte';

  @override
  String get irregularPulseDetected => 'Pouls irrégulier détecté';

  @override
  String get pulseRateExceedsUpperLimit => 'Fréquence pouls dépasse limite supérieure';

  @override
  String get pulseRateLessThanLowerLimit => 'Fréquence pouls inférieure à la limite inférieure';

  @override
  String get availableDevices => 'Dispositifs disponibles';

  @override
  String get deleteAllMedicineIntakes => 'Supprimer toutes les prises de médicaments';

  @override
  String get deleteAllNotes => 'Supprimer toutes les notes';

  @override
  String get date => 'Date';

  @override
  String get intakes => 'Doses de médicaments';

  @override
  String get errFeatureNotSupported => 'Cette fonctionnalité n’est pas disponible sur cette plateforme.';

  @override
  String get invalidZip => 'Fichier ZIP invalide.';

  @override
  String get errCantCreateArchive => 'Impossible de créer l\'archive. Si possible, signalez ce bug.';

  @override
  String get activateWeightFeatures => 'Activer les fonctions relatives au poids';

  @override
  String get weight => 'Poids';

  @override
  String get enterWeight => 'Indiquez le poids';

  @override
  String get selectMeasurementTitle => 'Choisissez la mesure à utiliser';

  @override
  String measurementIndex(int number) {
    return 'Mesure n° $number';
  }

  @override
  String get select => 'Choisissez';

  @override
  String get bloodPressure => 'Pression artérielle';

  @override
  String get preferredWeightUnit => 'Unité de poids préférée';

  @override
  String get disabled => 'Désactivé';

  @override
  String get oldBluetoothInput => 'Stable';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta multi-plateformes';

  @override
  String get bluetoothInputDesc => 'La version bêta fonctionne sur un plus grand nombre d\'appareils mais a moins été testée. La version multi-plateformes peut fonctionner sur des appareils non-Android et il est prévu qu\'elle remplace la version stable une fois qu\'elle sera suffisamment mature.';

  @override
  String get tapToSelect => 'Tapez pour sélectionner';
}
