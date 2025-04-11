// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get title => 'App de Pressão Arterial';

  @override
  String success(String msg) {
    return 'Sucesso: $msg';
  }

  @override
  String get loading => 'Carregando…';

  @override
  String error(String msg) {
    return 'Erro: $msg';
  }

  @override
  String get errNaN => 'Por favor digite um número';

  @override
  String get errLt30 => 'Número <= 30? Desligue a validação nas configurações!';

  @override
  String get errUnrealistic => 'Valor fora da realidade? Desligue a validação nas configurações!';

  @override
  String get errDiaGtSys => 'dia >= sys? Desligue a validação nas configurações!';

  @override
  String errCantOpenURL(String url) {
    return 'Não foi possível abrir a URL: $url';
  }

  @override
  String get errNoFileOpened => 'nenhum arquivo aberto';

  @override
  String get errNotStarted => 'não iniciado';

  @override
  String get errNoValue => 'Por favor digite um valor';

  @override
  String get errNotEnoughDataToGraph => 'Sem dados suficientes para desenhar um gráfico.';

  @override
  String get errNoData => 'sem dados';

  @override
  String get errWrongImportFormat => 'Você só pode importar arquivos nos formatos CSV e banco de dados do SQLite.';

  @override
  String get errNeedHeadline => 'Você só pode importar arquivos que tenham cabeçalho.';

  @override
  String get errCantReadFile => 'Não foi possível ler o conteúdo do arquivo';

  @override
  String get errNotImportable => 'Não foi possível importar este arquivo';

  @override
  String get btnCancel => 'CANCELAR';

  @override
  String get btnSave => 'SALVAR';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'DESFAZER';

  @override
  String get sysLong => 'Sistólica';

  @override
  String get sysShort => 'sís';

  @override
  String get diaLong => 'Diastólica';

  @override
  String get diaShort => 'dias';

  @override
  String get pulLong => 'Pulso';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Nota (opcional)';

  @override
  String get settings => 'Configurações';

  @override
  String get layout => 'Layout';

  @override
  String get allowManualTimeInput => 'Permitir digitar o tempo manualmente';

  @override
  String get enterTimeFormatScreen => 'Forma da hora';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get iconSize => 'Tamanho do Ícone';

  @override
  String get graphLineThickness => 'Grossura da Linha';

  @override
  String get animationSpeed => 'Duração da animação';

  @override
  String get accentColor => 'Cor do tema';

  @override
  String get sysColor => 'Cor sistólica';

  @override
  String get diaColor => 'Cor diastólica';

  @override
  String get pulColor => 'Cor do pulso';

  @override
  String get behavior => 'Comportamento';

  @override
  String get validateInputs => 'Validar campos de entrada';

  @override
  String get confirmDeletion => 'Confirmar deleção';

  @override
  String get age => 'Idade';

  @override
  String get determineWarnValues => 'Determinar valores de aviso';

  @override
  String get aboutWarnValuesScreen => 'Sobre';

  @override
  String get aboutWarnValuesScreenDesc => 'Mais informções sobre valores de aviso';

  @override
  String get sysWarn => 'Aviso para pressão sistólica';

  @override
  String get diaWarn => 'Aviso para pressão diastólica';

  @override
  String get data => 'Dados';

  @override
  String get version => 'Versão';

  @override
  String versionOf(String version) {
    return 'Versão: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Número da versão: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Nome do pacote: $name';
  }

  @override
  String get exportImport => 'Exportar / Importar';

  @override
  String get exportDir => 'Diretório de exportação';

  @override
  String get exportAfterEveryInput => 'Exportar depois de cada entrada';

  @override
  String get exportAfterEveryInputDesc => 'Não recomendado (explosão do arquivo)';

  @override
  String get exportFormat => 'Formato da exportação';

  @override
  String get exportCustomEntries => 'Campos personalizados';

  @override
  String get addEntry => 'Adicionar campo';

  @override
  String get exportMimeType => 'Tipo da mídia para exportação';

  @override
  String get exportCsvHeadline => 'Título';

  @override
  String get exportCsvHeadlineDesc => 'Ajuda a diferenciar tipos';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'BD SQLite';

  @override
  String get text => 'text';

  @override
  String get other => 'outro';

  @override
  String get fieldDelimiter => 'Encontrar delimitador';

  @override
  String get textDelimiter => 'Delimitador de texto';

  @override
  String get export => 'EXPORTAR';

  @override
  String get shared => 'Compartilhado';

  @override
  String get import => 'IMPORTAR';

  @override
  String get sourceCode => 'Código fonte';

  @override
  String get licenses => 'Licenças de terceiros';

  @override
  String importSuccess(int count) {
    return '$count registros foram importados';
  }

  @override
  String get exportWarnConfigNotImportable => 'Olá! Apenas um aviso amigável: a configuração da exportção atual impedirá a importação. Para corregir isso, tenha certeza de escolher o tipo de exportação com CSV, ativar o título, e incluir um dos formatos de tempo disponíveis.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'estão',
      one: 'está',
    );
    return 'Atenção você não exportando todos os campos: $fields $_temp0 faltando.';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get measurementCount => 'Quantidade de medições';

  @override
  String get measurementsPerDay => 'Medições por dia';

  @override
  String get timeResolvedMetrics => 'Métricas relacionadas ao tempo';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt mín.';
  }

  @override
  String maxOf(String txt) {
    return '$txt máx.';
  }

  @override
  String get warnValues => 'Valores para alerta';

  @override
  String get warnAboutTxt1 => 'Os valores de alerta são apenas sugestões e não são opiniões médicas.';

  @override
  String get warnAboutTxt2 => 'Os valores padrões dependentes da idade vieram desta fonte.';

  @override
  String get warnAboutTxt3 => 'Você pode mudar os valores para atenderem às suas necessidades e para seguir as recomendações do seu médico.';

  @override
  String get enterTimeFormatString => 'Formato da hora';

  @override
  String get now => 'agora';

  @override
  String get notes => 'Anotações';

  @override
  String get time => 'Hora';

  @override
  String get confirmDelete => 'Confirmar deleção';

  @override
  String get confirmDeleteDesc => 'Apagar esse registro? (Você pode desligar essa confirmações nas configurações)';

  @override
  String get deletionConfirmed => 'Registro apagado.';

  @override
  String get day => 'Dia';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mês';

  @override
  String get year => 'Ano';

  @override
  String get lifetime => 'Vitalícia';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Semana $weekNum, $year';
  }

  @override
  String get last7Days => '7 dias';

  @override
  String get last30Days => '30 dias';

  @override
  String get allowMissingValues => 'Permitir valores em falta';

  @override
  String get errTimeAfterNow => 'A hora do dia selecionada foi revertida, porque ela está no futuro. Você pode desligar essa validação nas configurações.';

  @override
  String get language => 'Língua';

  @override
  String get custom => 'Personalizado';

  @override
  String get drawRegressionLines => 'Desenhar linhas de tendência';

  @override
  String get drawRegressionLinesDesc => 'Desenha linhas de regressão no gráfico. Útil para intervalos grandes.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Valores de pressão sanguínea de $start até $end';
  }

  @override
  String get fieldFormat => 'Formato do campo';

  @override
  String get result => 'Resultado:';

  @override
  String get pulsePressure => 'Pressão da pulsação';

  @override
  String get addExportformat => 'Incluir formato de exportação';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Deletar';

  @override
  String get exportFieldFormatDocumentation => '## Variáveis\nO formato do campo de exportação suporta inserir os valore para os seguintes placeholders:\n- `\$TIMESTAMP:` Representa o tempo desde o Unix epoch em milisegundos.\n- `\$SYS:` Determina um valor se disponível; se não, o valor padrão é `null`.\n- `\$DIA:`Determina um valor se disponível; se não, o valor padrão é `null`.\n- `\$PUL:` Determina um valor se disponível; se não, o valor padrão é `null`.\n- `\$NOTE:` Determina um valor se disponível; se não, o valor padrão é `null`.\n- `\$COLOR:` Representa o valor númerico para a cor de uma medição . (valor de exemplo: `4291681337`)\n\nSe qualquer um dos placeholders mencionados a cima não estiverem present no registro da pressão arterial, o valor será substituido por -1.\n\n## Matemática\nYou can use basic mathematics inside double brackets (\"`{{}}`\").\nVocê pode usar matemática básica dentro de chaves duplas (\"`{{}}`\").\n\nAs operações matemáticas suportadas são as seguintes:\n- Operações: +, -, *, /, %, ^\n- Funções com um parâmetro: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh\n- Funções com dois parâmetros: log, nrt, pow\n- Constantes: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\nFor the full math interpreter specification, you can refer to the [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) specification\nPara a specificação completa do interpretador matemático, você verificar a especificação [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter)\n\n## Order de processamento\n1. Substituição de variável\n2. Matemática';

  @override
  String get default_ => 'Predefinição';

  @override
  String get exportPdfHeaderHeight => 'Altura do cabeçalho';

  @override
  String get exportPdfCellHeight => 'Altura da linha';

  @override
  String get exportPdfHeaderFontSize => 'Tamanho da fonte do cabeçalho';

  @override
  String get exportPdfCellFontSize => 'Tamanho da fonte da linha';

  @override
  String get average => 'Média';

  @override
  String get maximum => 'Máximo';

  @override
  String get minimum => 'Mínimo';

  @override
  String get exportPdfExportTitle => 'Título';

  @override
  String get exportPdfExportStatistics => 'Estatísticas';

  @override
  String get exportPdfExportData => 'Tabela de dados';

  @override
  String get startWithAddMeasurementPage => 'Medição no lançamento';

  @override
  String get startWithAddMeasurementPageDescription => 'Após o lançamento da app, o ecrã de entrada de medição é mostrada.';

  @override
  String get horizontalLines => 'Linhas horizontais';

  @override
  String get linePositionY => 'Posição da linha (y)';

  @override
  String get customGraphMarkings => 'Marcações personalizadas';

  @override
  String get addLine => 'Adicionar linha';

  @override
  String get useLegacyList => 'Utilizar lista de legado';

  @override
  String get addMeasurement => 'Adicionar medição';

  @override
  String get timestamp => 'Registo de data e hora';

  @override
  String get note => 'Anotação';

  @override
  String get color => 'Cor';

  @override
  String get exportSettings => 'Configurações de backup';

  @override
  String get importSettings => 'Restaurar configurações';

  @override
  String get requiresAppRestart => 'Requer reinício da app';

  @override
  String get restartNow => 'Reiniciar agora';

  @override
  String get warnNeedsRestartForUsingApp => 'Os ficheiros foram eliminados nesta sessão. Reinicie a aplicação para utilizar outras partes da aplicação!';

  @override
  String get deleteAllMeasurements => 'Eliminar todas as medições';

  @override
  String get deleteAllSettings => 'Apagar todas as configurações';

  @override
  String get warnDeletionUnrecoverable => 'Este passo não é revertível a menos que fez um backup manualmente. Quer mesmo apagar isto?';

  @override
  String get enterTimeFormatDesc => 'Uma cadeia de formatação é uma mistura de cadeias predefinidas ICU/Skeleton e qualquer texto adicional que gostaria de incluir.\n\n[Se está curioso sobre a lista completa de formatos válidos, pode encontrá-los aqui.](screen://TimeFormattingHelp)\n\nApenas um lembrete amigável, usando o formato mais longo ou mais curto Cadeias não irá alterar magicamente a largura das colunas de tabela, o que pode levar a algumas quebras de linha desajeitadas e texto não mostrando.\n\npadrão: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Espessura de cor';

  @override
  String get needlePinBarWidthDesc => 'A largura das linhas que as entradas coloridas fazem no gráfico.';

  @override
  String get errParseEmptyCsvFile => 'Não há linhas suficientes no arquivo CSV para analisar o registo.';

  @override
  String get errParseTimeNotRestoreable => 'Não há uma coluna que permita restaurar o registo de data e hora.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Não há nenhuma coluna com o título \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'A linha $lineNumber tem menos colunas do que a primeira linha.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Erro ao descodificar o campo \"$fieldContent\" na linha $lineNumber.';
  }

  @override
  String get exportFieldsPreset => 'Predefinição de campos de exportação';

  @override
  String get remove => 'Remover';

  @override
  String get manageExportColumns => 'Gerir colunas de exportação';

  @override
  String get buildIn => 'Integrar';

  @override
  String get csvTitle => 'Título CSV';

  @override
  String get recordFormat => 'Formato de registo';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get errAccuracyLoss => 'É expectável que perca precisão ao exportar com formatos de tempo personalizados.';

  @override
  String get bottomAppBars => 'Barras de diálogo inferiores';

  @override
  String get medications => 'Medicamentos';

  @override
  String get addMedication => 'Adicionar medicação';

  @override
  String get name => 'Nome';

  @override
  String get defaultDosis => 'dose padrão';

  @override
  String get noMedication => 'Sem medicação';

  @override
  String get dosis => 'Dose';

  @override
  String get valueDistribution => 'Distribuição de valor';

  @override
  String get titleInCsv => 'Título em CSV';

  @override
  String get errBleNoPerms => 'No bluetooth permissions';

  @override
  String get preferredPressureUnit => 'Preferred pressure unit';

  @override
  String get compactList => 'Compact measurement list';

  @override
  String get bluetoothDisabled => 'Bluetooth disabled';

  @override
  String get errMeasurementRead => 'Error while taking measurement!';

  @override
  String get measurementSuccess => 'Measurement taken successfully!';

  @override
  String get connect => 'Connect';

  @override
  String get bluetoothInput => 'Bluetooth input';

  @override
  String get aboutBleInput => 'Some measurement devices are BLE GATT compatible. You can pair these devices here and automatically transmit measurements or disable this option in the settings.';

  @override
  String get scanningForDevices => 'Scanning for devices';

  @override
  String get tapToClose => 'Tap to close.';

  @override
  String get meanArterialPressure => 'Mean arterial pressure';

  @override
  String get userID => 'User ID';

  @override
  String get bodyMovementDetected => 'Body movement detected';

  @override
  String get cuffTooLoose => 'Cuff too loose';

  @override
  String get improperMeasurementPosition => 'Improper measurement position';

  @override
  String get irregularPulseDetected => 'Irregular pulse detected';

  @override
  String get pulseRateExceedsUpperLimit => 'Pulse rate exceeds upper limit';

  @override
  String get pulseRateLessThanLowerLimit => 'Pulse rate is less than lower limit';

  @override
  String get availableDevices => 'Available devices';

  @override
  String get deleteAllMedicineIntakes => 'Delete all medicine intakes';

  @override
  String get deleteAllNotes => 'Delete all notes';

  @override
  String get date => 'Date';

  @override
  String get intakes => 'Medicine intakes';

  @override
  String get errFeatureNotSupported => 'This feature is not available on this platform.';

  @override
  String get invalidZip => 'Invalid zip file.';

  @override
  String get errCantCreateArchive => 'Can\'t create archive. Please report the bug if possible.';

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

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get title => 'Aplicativo de Pressão Arterial';

  @override
  String success(String msg) {
    return 'Sucesso: $msg';
  }

  @override
  String get loading => 'carregando…';

  @override
  String error(String msg) {
    return 'Erro: $msg';
  }

  @override
  String get errNaN => 'Por favor insira um Número';

  @override
  String get errLt30 => 'Número <= 30? Desative a validação nas configurações!';

  @override
  String get errUnrealistic => 'Valor irreal? Desative a validação nas configurações!';

  @override
  String get errDiaGtSys => 'dia >= sys? Desative a validação nas configurações!';

  @override
  String errCantOpenURL(String url) {
    return 'Não foi possível abrir o URL: $url';
  }

  @override
  String get errNoFileOpened => 'nenhum arquivo aberto';

  @override
  String get errNotStarted => 'não iniciado';

  @override
  String get errNoValue => 'Por favor insira um valor';

  @override
  String get errNotEnoughDataToGraph => 'Não há dados suficientes para desenhar um gráfico.';

  @override
  String get errNoData => 'sem dados';

  @override
  String get errWrongImportFormat => 'Você só pode importar arquivos no formato de banco de dados CSV e SQLite.';

  @override
  String get errNeedHeadline => 'Você só pode importar arquivos com título.';

  @override
  String get errCantReadFile => 'O conteúdo do arquivo não pode ser lido';

  @override
  String get errNotImportable => 'Este arquivo não pode ser importado';

  @override
  String get btnCancel => 'CANCELAR';

  @override
  String get btnSave => 'SALVAR';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'DESFAZER';

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
  String get settings => 'Configurações';

  @override
  String get layout => 'Disposição';

  @override
  String get allowManualTimeInput => 'Permitir entrada manual de hora';

  @override
  String get enterTimeFormatScreen => 'Formato de hora';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get iconSize => 'Tamanho do ícone';

  @override
  String get graphLineThickness => 'Espessura da linha';

  @override
  String get animationSpeed => 'Duração da animação';

  @override
  String get accentColor => 'Cor do tema';

  @override
  String get sysColor => 'Cor da sistólica';

  @override
  String get diaColor => 'Cor da diastólica';

  @override
  String get pulColor => 'Cor de pulso';

  @override
  String get behavior => 'Comportamento';

  @override
  String get validateInputs => 'Validar entradas';

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get age => 'Idade';

  @override
  String get determineWarnValues => 'Determinar valores de alerta';

  @override
  String get aboutWarnValuesScreen => 'Sobre';

  @override
  String get aboutWarnValuesScreenDesc => 'Mais informações sobre valores de alerta';

  @override
  String get sysWarn => 'Alerta sistólico';

  @override
  String get diaWarn => 'Alerta diastólico';

  @override
  String get data => 'Dados';

  @override
  String get version => 'Versão';

  @override
  String versionOf(String version) {
    return 'Versão: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Número da versão: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Nome do pacote: $name';
  }

  @override
  String get exportImport => 'Exportar / Importar';

  @override
  String get exportDir => 'Diretório de exportação';

  @override
  String get exportAfterEveryInput => 'Exportar após cada entrada';

  @override
  String get exportAfterEveryInputDesc => 'Não recomendado (explosão de arquivo)';

  @override
  String get exportFormat => 'Formato de exportação';

  @override
  String get exportCustomEntries => 'Personalizar campos';

  @override
  String get addEntry => 'Adicionar campo';

  @override
  String get exportMimeType => 'Tipo de mídia de exportação';

  @override
  String get exportCsvHeadline => 'Título';

  @override
  String get exportCsvHeadlineDesc => 'Ajuda a discriminar tipos';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'texto';

  @override
  String get other => 'outro';

  @override
  String get fieldDelimiter => 'Delimitador de campo';

  @override
  String get textDelimiter => 'Delimitador de texto';

  @override
  String get export => 'EXPORTAR';

  @override
  String get shared => 'compartilhado';

  @override
  String get import => 'IMPORTAR';

  @override
  String get sourceCode => 'Código-fonte';

  @override
  String get licenses => 'Licenças de terceiros';

  @override
  String importSuccess(int count) {
    return 'Importadas $count entradas';
  }

  @override
  String get exportWarnConfigNotImportable => 'Ei! Apenas um aviso amigável: a configuração de exportação atual não será importável. Para corrigir isso, certifique-se de definir o tipo de exportação como CSV e incluir um dos formatos de hora disponíveis.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'estão',
      one: 'está',
    );
    return 'Atente-se que você não está exportando todos os campos: $fields $_temp0 faltando.';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get measurementCount => 'Contagem de medições';

  @override
  String get measurementsPerDay => 'Medições por dia';

  @override
  String get timeResolvedMetrics => 'Métricas por hora do dia';

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
  String get warnValues => 'Valores de alerta';

  @override
  String get warnAboutTxt1 => 'Os valores de alerta são pura sugestão e sem orientação médica.';

  @override
  String get warnAboutTxt2 => 'Os valores padrão dependentes da idade vêm desta fonte.';

  @override
  String get warnAboutTxt3 => 'Fique à vontade para alterar os valores de acordo com suas necessidades e siga as recomendações do seu médico.';

  @override
  String get enterTimeFormatString => 'formato de hora';

  @override
  String get now => 'agora';

  @override
  String get notes => 'Notas';

  @override
  String get time => 'Hora';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get confirmDeleteDesc => 'Excluir esta entrada? (Você pode desativar essas confirmações nas configurações.)';

  @override
  String get deletionConfirmed => 'Entrada excluída.';

  @override
  String get day => 'Dia';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mês';

  @override
  String get year => 'Ano';

  @override
  String get lifetime => 'Vida';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Semana $weekNum, $year';
  }

  @override
  String get last7Days => '7 dias';

  @override
  String get last30Days => '30 dias';

  @override
  String get allowMissingValues => 'Permitir valores faltando';

  @override
  String get errTimeAfterNow => 'O horário do dia selecionado foi zerado, pois ocorre após este momento. Você pode desligar esta validação nas configurações.';

  @override
  String get language => 'Linguagem';

  @override
  String get custom => 'Personalizado';

  @override
  String get drawRegressionLines => 'Desenhar linhas de tendência';

  @override
  String get drawRegressionLinesDesc => 'Desenha linhas de regressão no gráfico. Útil apenas para intervalos grandes.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Valores de pressão arterial de $start até $end';
  }

  @override
  String get fieldFormat => 'Formato do campo';

  @override
  String get result => 'Resultado:';

  @override
  String get pulsePressure => 'Pressão de pulso';

  @override
  String get addExportformat => 'Adicionar formato de exportação';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get exportFieldFormatDocumentation => '## Variáveis\nO formato do campo de exportação suporta a inserção de valores para os seguintes espaços reservados:\n- `\$TIMESTAMP:` Representa o tempo desde a época Unix em milissegundos.\n- `\$SYS:` Fornece um valor, se disponível; caso contrário, o padrão é -1.\n- `\$DIA:` Fornece um valor, se disponível; caso contrário, o padrão é -1.\n- `\$PUL:` Fornece um valor, se disponível; caso contrário, o padrão é -1.\n- `\$NOTE:` Fornece um valor, se disponível; caso contrário, o padrão é -1.\n- `\$COLOR:` Representa a cor de uma medida como um número. (valor de exemplo: `4291681337`)\n\nSe algum dos marcadores mencionados acima não estiver presente no registro da pressão arterial, ele será substituído por -1.\n\n## Matemática\nVocê pode usar matemática básica entre colchetes duplos (\"`{{}}`\").\n\nAs seguintes operações matemáticas são suportadas:\n- Operações: +, -, *, /, %, ^\n- Funções de um parâmetro: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Funções de dois parâmetros: log, nrt, pow\n- Constantes: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\nPara a especificação completa do intérprete matemático, você pode consultar a especificação da [árvore_de_funções](https://pub.dev/documentation/function_tree/latest#interpreter)\n\n## Ordem de processamento\n1. substituição de variável\n2. Matemática';

  @override
  String get default_ => 'Padrão';

  @override
  String get exportPdfHeaderHeight => 'Altura do cabeçalho';

  @override
  String get exportPdfCellHeight => 'Altura da linha';

  @override
  String get exportPdfHeaderFontSize => 'Tamanho da fonte do cabeçalho';

  @override
  String get exportPdfCellFontSize => 'Tamanho da fonte da linha';

  @override
  String get average => 'Média';

  @override
  String get maximum => 'Máximo';

  @override
  String get minimum => 'Mínimo';

  @override
  String get exportPdfExportTitle => 'Título';

  @override
  String get exportPdfExportStatistics => 'Estatísticas';

  @override
  String get exportPdfExportData => 'Tabela de dados';

  @override
  String get startWithAddMeasurementPage => 'Medição no lançamento';

  @override
  String get startWithAddMeasurementPageDescription => 'Ao iniciar o aplicativo, a tela de entrada de medição é exibida.';

  @override
  String get horizontalLines => 'Linhas horizontais';

  @override
  String get linePositionY => 'Posição da linha (y)';

  @override
  String get customGraphMarkings => 'Marcações personalizadas';

  @override
  String get addLine => 'Adicionar linha';

  @override
  String get useLegacyList => 'Usar lista legada';

  @override
  String get addMeasurement => 'Adicionar medição';

  @override
  String get timestamp => 'Carimbo de data e hora';

  @override
  String get note => 'Nota';

  @override
  String get color => 'Cor';

  @override
  String get exportSettings => 'Configurações de backup';

  @override
  String get importSettings => 'Restaurar configurações';

  @override
  String get requiresAppRestart => 'Requer reinicialização do aplicativo';

  @override
  String get restartNow => 'Reiniciar agora';

  @override
  String get warnNeedsRestartForUsingApp => 'Os arquivos foram excluídos nesta sessão. Reinicie o aplicativo para continuar usando, retornando para outras partes do aplicativo!';

  @override
  String get deleteAllMeasurements => 'Excluir todas as medições';

  @override
  String get deleteAllSettings => 'Excluir todas as configurações';

  @override
  String get warnDeletionUnrecoverable => 'Esta etapa não pode ser revertida, a menos que você tenha um backup manual. Você realmente deseja excluir isso?';

  @override
  String get enterTimeFormatDesc => 'Uma string de formatador é uma mistura de strings ICU/Skeleton predefinidas e qualquer texto adicional que você gostaria de incluir.\n\n[Se estiver curioso para saber a lista completa de formatos válidos, você pode encontrá-los aqui.](screen://TimeFormattingHelp)\n\nApenas um lembrete amigável: usar Strings de formato mais longo ou mais curto não alterará magicamente a largura das colunas da tabela, o que pode levar a algumas quebras de linha estranhas e à não exibição do texto.\n\npadrão: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Espessura da cor';

  @override
  String get needlePinBarWidthDesc => 'A largura das linhas que as entradas coloridas fazem no gráfico.';

  @override
  String get errParseEmptyCsvFile => 'Não há linhas suficientes no arquivo CSV para analisar o registro.';

  @override
  String get errParseTimeNotRestoreable => 'Não há nenhuma coluna que permita restaurar um carimbo de data/hora.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Não há nenhuma coluna com o título \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'A linha $lineNumber possui menos colunas do que a primeira linha.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Falha ao decodificar o campo \"$fieldContent\" na linha $lineNumber.';
  }

  @override
  String get exportFieldsPreset => 'Predefinição de campos de exportação';

  @override
  String get remove => 'Remover';

  @override
  String get manageExportColumns => 'Gerenciar colunas de exportação';

  @override
  String get buildIn => 'Integrar';

  @override
  String get csvTitle => 'CSV-título';

  @override
  String get recordFormat => 'Formato de gravação';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get errAccuracyLoss => 'Há perda de precisão esperada ao exportar com formatos de tempo personalizados.';

  @override
  String get bottomAppBars => 'Barras de diálogo inferiores';

  @override
  String get medications => 'Medicamentos';

  @override
  String get addMedication => 'Adicionar medicação';

  @override
  String get name => 'Nome';

  @override
  String get defaultDosis => 'Dose padrão';

  @override
  String get noMedication => 'Sem medicação';

  @override
  String get dosis => 'Dose';

  @override
  String get valueDistribution => 'Distribuição de valor';

  @override
  String get titleInCsv => 'Título em CSV';

  @override
  String get errBleNoPerms => 'Sem permissões de bluetooth';

  @override
  String get preferredPressureUnit => 'Unidade de pressão preferida';

  @override
  String get compactList => 'Lista de medição compacta';

  @override
  String get bluetoothDisabled => 'Bluetooth desativado';

  @override
  String get errMeasurementRead => 'Erro ao fazer a medição!';

  @override
  String get measurementSuccess => 'Medição realizada com sucesso!';

  @override
  String get connect => 'Conectar';

  @override
  String get bluetoothInput => 'Entrada bluetooth';

  @override
  String get aboutBleInput => 'Alguns dispositivos de medição são compatíveis com BLE GATT. Você pode parear esses dispositivos aqui e transmitir medições automaticamente ou desabilitar essa opção nas configurações.';

  @override
  String get scanningForDevices => 'Procurando dispositivos';

  @override
  String get tapToClose => 'Toque para fechar.';

  @override
  String get meanArterialPressure => 'Pressão arterial média';

  @override
  String get userID => 'ID do usuário';

  @override
  String get bodyMovementDetected => 'Movimento corporal detectado';

  @override
  String get cuffTooLoose => 'Punho muito frouxo';

  @override
  String get improperMeasurementPosition => 'Posição de medição inadequada';

  @override
  String get irregularPulseDetected => 'Pulso irregular detectado';

  @override
  String get pulseRateExceedsUpperLimit => 'A frequência de pulso excede o limite superior';

  @override
  String get pulseRateLessThanLowerLimit => 'A frequência de pulso é menor que o limite inferior';

  @override
  String get availableDevices => 'Dispositivos disponíveis';

  @override
  String get deleteAllMedicineIntakes => 'Apagar todas as ingestões de medicamentos';

  @override
  String get deleteAllNotes => 'Apagar todas as notas';

  @override
  String get date => 'Data';

  @override
  String get intakes => 'Ingestão de medicamentos';

  @override
  String get errFeatureNotSupported => 'Este recurso não está disponível nesta plataforma.';

  @override
  String get invalidZip => 'Arquivo zip inválido.';

  @override
  String get errCantCreateArchive => 'Não é possível criar o arquivo. Por favor, reporte o bug se possível.';

  @override
  String get activateWeightFeatures => 'Habilitar funções relacionadas ao peso';

  @override
  String get weight => 'Peso';

  @override
  String get enterWeight => 'Informe seu peso';

  @override
  String get selectMeasurementTitle => 'Selecione a medição para usar';

  @override
  String measurementIndex(int number) {
    return 'Medição #$number';
  }

  @override
  String get select => 'Selecionar';

  @override
  String get bloodPressure => 'Pressão sanguínea';

  @override
  String get preferredWeightUnit => 'Medida de peso preferida';
}
