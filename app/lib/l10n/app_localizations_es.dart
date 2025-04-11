// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get title => 'Aplicación para la tensión arterial';

  @override
  String success(String msg) {
    return 'Exito: $msg';
  }

  @override
  String get loading => 'cargando…';

  @override
  String error(String msg) {
    return 'Error: $msg';
  }

  @override
  String get errNaN => 'Por favor, introduzca un número';

  @override
  String get errLt30 => '¿Número <= 30? ¡Desactive la validación en los ajustes!';

  @override
  String get errUnrealistic => '¿Valor poco realista? ¡Desactiva la validación en los ajustes!';

  @override
  String get errDiaGtSys => '¿dia >= sys? ¡Desactive la validación en la configuración!';

  @override
  String errCantOpenURL(String url) {
    return 'No se puede abrir la URL: $url';
  }

  @override
  String get errNoFileOpened => 'ningún archivo abierto';

  @override
  String get errNotStarted => 'no iniciado';

  @override
  String get errNoValue => 'Por favor, introduzca un valor';

  @override
  String get errNotEnoughDataToGraph => 'No hay datos suficientes para dibujar un gráfico.';

  @override
  String get errNoData => 'no hay datos';

  @override
  String get errWrongImportFormat => 'Sólo se pueden importar archivos en formato CSV y de base de datos SQLite.';

  @override
  String get errNeedHeadline => 'Sólo puedes importar archivos con un encabezado.';

  @override
  String get errCantReadFile => 'No se puede leer el contenido del archivo';

  @override
  String get errNotImportable => 'Este archivo no se puede importar';

  @override
  String get btnCancel => 'CANCELAR';

  @override
  String get btnSave => 'GUARDAR';

  @override
  String get btnConfirm => 'DE ACUERDO';

  @override
  String get btnUndo => 'DESHACER';

  @override
  String get sysLong => 'Sistólica';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diastólica';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Pulso';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Nota (opcional)';

  @override
  String get settings => 'Ajustes';

  @override
  String get layout => 'Apariencia';

  @override
  String get allowManualTimeInput => 'Permitir la introducción manual de la hora';

  @override
  String get enterTimeFormatScreen => 'Formato de la hora';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get iconSize => 'Tamaño del icono';

  @override
  String get graphLineThickness => 'Grosor de las líneas';

  @override
  String get animationSpeed => 'Duración de la animación';

  @override
  String get accentColor => 'Color del tema';

  @override
  String get sysColor => 'Color de la sistólica';

  @override
  String get diaColor => 'Color de la diástole';

  @override
  String get pulColor => 'Color del pulso';

  @override
  String get behavior => 'Comportamiento';

  @override
  String get validateInputs => 'Validación de las entradas';

  @override
  String get confirmDeletion => 'Confirmar el borrado';

  @override
  String get age => 'Edad';

  @override
  String get determineWarnValues => 'Determinar los valores de aviso';

  @override
  String get aboutWarnValuesScreen => 'Acerca de';

  @override
  String get aboutWarnValuesScreenDesc => 'Más información sobre los valores de advertencia';

  @override
  String get sysWarn => 'Advertencia de sistólica';

  @override
  String get diaWarn => 'Alerta diastólica';

  @override
  String get data => 'Fecha';

  @override
  String get version => 'Versión';

  @override
  String versionOf(String version) {
    return 'Versión: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Número de la versión: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Nombre del paquete: $name';
  }

  @override
  String get exportImport => 'Exportar / Importar';

  @override
  String get exportDir => 'Exportar el directorio';

  @override
  String get exportAfterEveryInput => 'Exportar tras cada entrada';

  @override
  String get exportAfterEveryInputDesc => 'No recomendado (hará que aumente la cantidad de archivos)';

  @override
  String get exportFormat => 'Formato de la exportación';

  @override
  String get exportCustomEntries => 'Personalizar los campos';

  @override
  String get addEntry => 'Añadir un campo';

  @override
  String get exportMimeType => 'Tipo de medio de exportación';

  @override
  String get exportCsvHeadline => 'Encabezado';

  @override
  String get exportCsvHeadlineDesc => 'Ayuda a determinar los tipos de valores';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'texto';

  @override
  String get other => 'otro';

  @override
  String get fieldDelimiter => 'Delimitador de campo';

  @override
  String get textDelimiter => 'Delimitador de texto';

  @override
  String get export => 'EXPORTAR';

  @override
  String get shared => 'compartido';

  @override
  String get import => 'IMPORTAR';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get licenses => 'Licencias de terceros';

  @override
  String importSuccess(int count) {
    return '$count entradas importadas';
  }

  @override
  String get exportWarnConfigNotImportable => '¡Hey! Solo un aviso amistoso: la configuración de exportación actual no va a ser importable. Para corregirlo, asegura que elegiste el formato de exportación como CSV e incluye un de los formatos de tiempo disponible.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Cuidado, no está exportando todos los campos: $fields$_temp0 missing.';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get measurementCount => 'Cuenta de medidas';

  @override
  String get measurementsPerDay => 'Mediciones por día';

  @override
  String get timeResolvedMetrics => 'Medidas por hora del día';

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
    return '$txt máx.';
  }

  @override
  String get warnValues => 'Valores de precaución';

  @override
  String get warnAboutTxt1 => 'Los valores de precaución son únicamente sugerencias y no consejo médico.';

  @override
  String get warnAboutTxt2 => 'Los valores dependientes de la edad predeterminada vienen de esta fuente.';

  @override
  String get warnAboutTxt3 => 'Dese la libertad de cambiar los valores para que se adapten a sus necesidades y siga las recomendaciones de su doctor.';

  @override
  String get enterTimeFormatString => 'formato de tiempo';

  @override
  String get now => 'ahora';

  @override
  String get notes => 'Notas';

  @override
  String get time => 'Tiempo';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteDesc => '¿Eliminar esta entrada? (Puedes desactivar estas confirmaciones en la configuración.)';

  @override
  String get deletionConfirmed => 'Entrada eliminada.';

  @override
  String get day => 'Día';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get year => 'Año';

  @override
  String get lifetime => 'Vida';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Semana$weekNum,$year';
  }

  @override
  String get last7Days => '7 días';

  @override
  String get last30Days => '30 días';

  @override
  String get allowMissingValues => 'Permitir valores faltantes';

  @override
  String get errTimeAfterNow => 'El tiempo seleccionado del día fue reiniciado, debido a que se ubica en el futuro. Puede desactivar esta validación el la configuración.';

  @override
  String get language => 'Lenguaje';

  @override
  String get custom => 'Personalizado';

  @override
  String get drawRegressionLines => 'Mostrar datos de tendencia';

  @override
  String get drawRegressionLinesDesc => 'Trazar líneas de regresión en el gráfico. Sólo es útil para intervalos grandes.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Los valores de la presión arterial desde $start hasta $end';
  }

  @override
  String get fieldFormat => 'Formato del campo';

  @override
  String get result => 'Resultado:';

  @override
  String get pulsePressure => 'Presión del pulso';

  @override
  String get addExportformat => 'Agregar formato de exportación';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get exportFieldFormatDocumentation => '## Variables\nEl campo de formato de exportación admite insertar valores de los siguientes marcadores:\n- `\$TIMESTAMP:` Representa el tiempo desde el Unix epoch en milisegundos.\n- `\$SYS:` Provee un valor si se encuentra disponible; de lo contrario; se predetermina a -1.\n- `\$DIA:`  Provee un valor si se encuentra disponible; de lo contrario; se predetermina a -1.\n- `\$PUL:`  Provee un valor si se encuentra disponible; de lo contrario; se predetermina a -1.\n- `\$NOTE:`  Provee un valor si se encuentra disponible; de lo contrario; se predetermina a -1.\n- `\$COLOR:` Representa el color de una medida como un número. (valor de ejemplo: `4291681337`)\n\nSi alguno de estos marcadores no esta presente en el registro de la presión arterial, serán remplazados con `null`.\n\n##Math\nPuede usar matemáticas básicas dentro de un doble paréntesis (\"`{{}}`\").\n\nLas siguientes operaciones matemáticas son compatibles:\n-Operaciones: +, -, *, /, %, ^\n- Funciones de un parámetro: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Funciones de dos parámetros: log, nrt, pow\n- Constantes: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nPara toda la especificación del intérprete matemático, puedes consultar la [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) documentación.\n\n## Orden de procesamiento\n1.Reemplazo de variable\n2.Matemática';

  @override
  String get default_ => 'Predeterminado';

  @override
  String get exportPdfHeaderHeight => 'Altura de la cabecera';

  @override
  String get exportPdfCellHeight => 'Altura de la fila';

  @override
  String get exportPdfHeaderFontSize => 'Tamaño de la fuente del cabezal';

  @override
  String get exportPdfCellFontSize => 'Tamaño de la fuente de la fila';

  @override
  String get average => 'Promedio';

  @override
  String get maximum => 'Máximo';

  @override
  String get minimum => 'Mínimo';

  @override
  String get exportPdfExportTitle => 'Encabezado';

  @override
  String get exportPdfExportStatistics => 'Estadísticas';

  @override
  String get exportPdfExportData => 'Tabla de datos';

  @override
  String get startWithAddMeasurementPage => 'Medida en el lanzamiento';

  @override
  String get startWithAddMeasurementPageDescription => 'En el lanzamiento de la aplicación, se muestra la pantalla del input de las medidas.';

  @override
  String get horizontalLines => 'Lineas horizontales';

  @override
  String get linePositionY => 'Posición de la linea (y)';

  @override
  String get customGraphMarkings => 'Marcas personalizadas';

  @override
  String get addLine => 'Agregar línea';

  @override
  String get useLegacyList => 'Usar la lista de legado';

  @override
  String get addMeasurement => 'Agregar medida';

  @override
  String get timestamp => 'Marca de tiempo';

  @override
  String get note => 'Nota';

  @override
  String get color => 'Color';

  @override
  String get exportSettings => 'Configuración de respaldo';

  @override
  String get importSettings => 'Restaurar configuración';

  @override
  String get requiresAppRestart => 'Se requiere reiniciar la aplicación';

  @override
  String get restartNow => 'Reiniciar ahora';

  @override
  String get warnNeedsRestartForUsingApp => 'Los archivos fueron eliminados en esta sesión. ¡Reinicie la aplicación para seguir usando returning en otras partes de la aplicación!';

  @override
  String get deleteAllMeasurements => 'Eliminar todas la mediciones';

  @override
  String get deleteAllSettings => 'Eliminar todas las configuraciones';

  @override
  String get warnDeletionUnrecoverable => 'Este paso no es reversible a no ser que manualmente haya realizado un respaldo. ¿Estás seguro de que deseas eliminar esto?';

  @override
  String get enterTimeFormatDesc => 'Un string formateador es una mezcla de string ICU/Skeleton predefinidas y cualquier texto adicional que desee incluir.\n\n[Si deseas saber sobre la lista completa de formatos válidos, los puede encontrar aquí.](screen://TimeFormattingHelp)\n\nSolo un recordatorio amistoso, usar string formateadores más largos o cortos no va a mágicamente alterar el ancho de las columnas de la tabla, lo cuál puede resultar en unas interrupciones irregulares en la linea y que el texto no se muestre.\n\npredeterminado: \"aa-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Grosor del color';

  @override
  String get needlePinBarWidthDesc => 'El ancho de las líneas que forman las entradas coloreadas en el gráfico.';

  @override
  String get errParseEmptyCsvFile => 'No hay suficientes lineas en el archivo csv para analizar el registro.';

  @override
  String get errParseTimeNotRestoreable => 'No hay una columna la cual permita restaurar una marca de tiempo.';

  @override
  String errParseUnknownColumn(String title) {
    return 'No hay una columna con el título \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'La línea $lineNumber tiene menos columnas que la primera línea.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'El campo de descodificación \"$fieldContent\" en la línea $lineNumber ha fallado.';
  }

  @override
  String get exportFieldsPreset => 'Exportar campos predeterminados';

  @override
  String get remove => 'Remover';

  @override
  String get manageExportColumns => 'Administrar la exportación de columnas';

  @override
  String get buildIn => 'Build-in';

  @override
  String get csvTitle => 'Título-CSV';

  @override
  String get recordFormat => 'Formato de registro';

  @override
  String get timeFormat => 'Formato del tiempo';

  @override
  String get errAccuracyLoss => 'Es esperable la pérdida de precisión al exportar con formatos del tiempo personalizados.';

  @override
  String get bottomAppBars => 'Barras de diálogo inferiores';

  @override
  String get medications => 'Medicinas';

  @override
  String get addMedication => 'Agregar medicina';

  @override
  String get name => 'Nombre';

  @override
  String get defaultDosis => 'Dosis predeterminada';

  @override
  String get noMedication => 'Sin medicación';

  @override
  String get dosis => 'Dosis';

  @override
  String get valueDistribution => 'Distribución de valores';

  @override
  String get titleInCsv => 'Título en CSV';

  @override
  String get errBleNoPerms => 'Sin permiso de bluetooth';

  @override
  String get preferredPressureUnit => 'Unidad de presión preferida';

  @override
  String get compactList => 'Lista de mediciones compacta';

  @override
  String get bluetoothDisabled => 'Bluetooth desactivado';

  @override
  String get errMeasurementRead => '¡Ocurrió un error al medir!';

  @override
  String get measurementSuccess => '¡Medición exitosa!';

  @override
  String get connect => 'Conectar';

  @override
  String get bluetoothInput => 'Entrada por Bluetooth';

  @override
  String get aboutBleInput => 'Algunos dispositivos de medición son compatibles con BLE GATT. Puede emparejar estos dispositivos aquí y transmitir mediciones automáticamente o desactivar esta opción en la configuración.';

  @override
  String get scanningForDevices => 'Buscando dispositivos';

  @override
  String get tapToClose => 'Toque para cerrar.';

  @override
  String get meanArterialPressure => 'Presión arterial media';

  @override
  String get userID => 'Id del usuario';

  @override
  String get bodyMovementDetected => 'Movimiento corporal detectado';

  @override
  String get cuffTooLoose => 'Puño demasiado flojo';

  @override
  String get improperMeasurementPosition => 'Posición de medición incorrecta';

  @override
  String get irregularPulseDetected => 'Pulso irregular detectado';

  @override
  String get pulseRateExceedsUpperLimit => 'La frecuencia cardíaca excede el límite superior';

  @override
  String get pulseRateLessThanLowerLimit => 'Frecuencia cardíaca por debajo del límite inferior';

  @override
  String get availableDevices => 'Dispositivos disponibles';

  @override
  String get deleteAllMedicineIntakes => 'Eliminar todas las tomas de medicamentos';

  @override
  String get deleteAllNotes => 'Borrar todas las notas';

  @override
  String get date => 'Fecha';

  @override
  String get intakes => 'Toma de medicamentos';

  @override
  String get errFeatureNotSupported => 'Esta función no está disponible en esta plataforma.';

  @override
  String get invalidZip => 'Archivo zip no válido.';

  @override
  String get errCantCreateArchive => 'No se puede crear el archivo. Por favor, informe del error si es posible.';

  @override
  String get activateWeightFeatures => 'Activar funciones relacionadas con el peso';

  @override
  String get weight => 'Peso';

  @override
  String get enterWeight => 'Introducir peso';

  @override
  String get selectMeasurementTitle => 'Selecciona la medida a utilizar';

  @override
  String measurementIndex(int number) {
    return 'Medida #$number';
  }

  @override
  String get select => 'Seleccionar';

  @override
  String get bloodPressure => 'Presión arterial';

  @override
  String get preferredWeightUnit => 'Unidad de peso preferida';

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
