// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title => '血压记录';

  @override
  String success(String msg) {
    return '成功：$msg';
  }

  @override
  String get loading => '正在载入…';

  @override
  String error(String msg) {
    return '错误：$msg';
  }

  @override
  String get errNaN => '请输入数字';

  @override
  String get errLt30 => '数字<=30？请在设置中关闭验证！';

  @override
  String get errUnrealistic => '不符实际的数值？请在设置中关闭验证！';

  @override
  String get errDiaGtSys => '低压>=高压？请在设置中关闭验证！';

  @override
  String errCantOpenURL(String url) {
    return '无法打开网址：$url';
  }

  @override
  String get errNoFileOpened => '没有打开的文件';

  @override
  String get errNotStarted => '没有启动';

  @override
  String get errNoValue => '请输入数值';

  @override
  String get errNotEnoughDataToGraph => '数据太少，无法绘制图表。';

  @override
  String get errNoData => '没有数据';

  @override
  String get errWrongImportFormat => '只能导入csv和SQLite数据库格式的文件。';

  @override
  String get errNeedHeadline => '只能导入有标题行的文件。';

  @override
  String get errCantReadFile => '文件内容无法读取';

  @override
  String get errNotImportable => '此文件无法导入';

  @override
  String get btnCancel => '取消';

  @override
  String get btnSave => '保存';

  @override
  String get btnConfirm => '确定';

  @override
  String get btnUndo => '撤销';

  @override
  String get sysLong => '高压';

  @override
  String get sysShort => '高压';

  @override
  String get diaLong => '低压';

  @override
  String get diaShort => '低压';

  @override
  String get pulLong => '脉搏';

  @override
  String get pulShort => '脉搏';

  @override
  String get addNote => '备注（选填）';

  @override
  String get settings => '设置';

  @override
  String get layout => '布局';

  @override
  String get allowManualTimeInput => '允许手动输入时间';

  @override
  String get enterTimeFormatScreen => '时间格式';

  @override
  String get theme => '主题';

  @override
  String get system => '系统';

  @override
  String get dark => '暗色';

  @override
  String get light => '亮色';

  @override
  String get iconSize => '图标大小';

  @override
  String get graphLineThickness => '线条粗细';

  @override
  String get animationSpeed => '动画时长';

  @override
  String get accentColor => '主题颜色';

  @override
  String get sysColor => '高压颜色';

  @override
  String get diaColor => '低压颜色';

  @override
  String get pulColor => '脉搏颜色';

  @override
  String get behavior => '行为';

  @override
  String get validateInputs => '验证输入';

  @override
  String get confirmDeletion => '确认删除';

  @override
  String get age => '年龄';

  @override
  String get determineWarnValues => '设置警戒值';

  @override
  String get aboutWarnValuesScreen => '关于';

  @override
  String get aboutWarnValuesScreenDesc => '关于警告值的更多信息';

  @override
  String get sysWarn => '高压警告';

  @override
  String get diaWarn => '低压警告';

  @override
  String get data => '数据';

  @override
  String get version => '版本';

  @override
  String versionOf(String version) {
    return '版本：$version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return '版本号：$buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return '软件包名称：$name';
  }

  @override
  String get exportImport => '导出/导入';

  @override
  String get exportDir => '导出目录';

  @override
  String get exportAfterEveryInput => '每次记录后导出';

  @override
  String get exportAfterEveryInputDesc => '不推荐（会导致文件数量激增）';

  @override
  String get exportFormat => '导出格式';

  @override
  String get exportCustomEntries => '自定义字段';

  @override
  String get addEntry => '添加字段';

  @override
  String get exportMimeType => '导出MIME类型';

  @override
  String get exportCsvHeadline => '标题行';

  @override
  String get exportCsvHeadlineDesc => '有助于区分类型';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite数据';

  @override
  String get text => '文本';

  @override
  String get other => '其他';

  @override
  String get fieldDelimiter => '字段分隔符';

  @override
  String get textDelimiter => '文本分隔符';

  @override
  String get export => '导出';

  @override
  String get shared => '已分享';

  @override
  String get import => '导入';

  @override
  String get sourceCode => '源代码';

  @override
  String get licenses => '第3方许可协议';

  @override
  String importSuccess(int count) {
    return '已成功导入$count条记录';
  }

  @override
  String get exportWarnConfigNotImportable => '友情提示：当前的导出配置将导致无法导入。要修复此问题，请确定将导出类型设置为CSV——带有标题行，标题行中包含“diastolic”、“systolic”、“pulse”、“notes”，以及有效的时间格式。';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    return '请注意你没有导出所有字段：缺少 $fields 个字段。';
  }

  @override
  String get statistics => '统计';

  @override
  String get measurementCount => '测量次数';

  @override
  String get measurementsPerDay => '日测量次数';

  @override
  String get timeResolvedMetrics => '按一天中不同时间的度量';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt最低';
  }

  @override
  String maxOf(String txt) {
    return '$txt最高';
  }

  @override
  String get warnValues => '警告值';

  @override
  String get warnAboutTxt1 => '警告值仅供参考，并非医学建议。';

  @override
  String get warnAboutTxt2 => '不同年龄的默认参考值来源于此。';

  @override
  String get warnAboutTxt3 => '您可以按需随意修改此值，请遵从医生的建议。';

  @override
  String get enterTimeFormatString => '时间格式';

  @override
  String get now => '现在';

  @override
  String get notes => '备注';

  @override
  String get time => '时间';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteDesc => '确定要删除此记录吗？（您可以在设置中关闭这些确认。）';

  @override
  String get deletionConfirmed => '记录已删除。';

  @override
  String get day => '日';

  @override
  String get week => '周';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get lifetime => '终身';

  @override
  String weekOfYear(int weekNum, int year) {
    return '$year年第$weekNum周';
  }

  @override
  String get last7Days => '最近七天';

  @override
  String get last30Days => '最近三十天';

  @override
  String get allowMissingValues => '允许空缺';

  @override
  String get errTimeAfterNow => '当所选的时间在未来时会发生这个错误。如果是这样，本应用在尝试更改前会重置时间（不是整个选中的时间）为当前时间。';

  @override
  String get language => '语言';

  @override
  String get custom => '样式';

  @override
  String get drawRegressionLines => '画出趋势线';

  @override
  String get drawRegressionLinesDesc => '绘制回归线。仅对大间隔有用。';

  @override
  String pdfDocumentTitle(String start, String end) {
    return '$start 到 $end 之间的血压';
  }

  @override
  String get fieldFormat => '字段格式';

  @override
  String get result => '结果：';

  @override
  String get pulsePressure => '收缩压和舒张压之间的差异';

  @override
  String get addExportformat => '添加导出格式';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get exportFieldFormatDocumentation => '## 变量\n导出格式字段支持插入以下占位符的数值：\n- `\$TIMESTAMP:` 表示自 Unix 纪元以来的时间，单位毫秒\n- `\$SYS:` 如果有的话，提供一个值；否则默认为 -1.\n- `\$DIA:` 如果有的话，提供一个值；否则，默认为 -1.\n- `\$PUL:` 如果有的话，提供一个值；否则，默认为 -1.\n- `\$NOTE:` 如果有的话，提供一个值；否则，默认为 -1.\n- `\$COLOR:` 代表测量的颜色数值（示例值: `4291681337`）\n\n如果以上提及字段中的任何一个没有出现在血压记录中，它们将被 `null`代替。\n\n## Math\n你可以在双括号 (\"`{{}}`\") 内使用基本的数学计算。\n\n支持以下运算符：\n- 操作: +, -, *, /, %, ^\n- 一个参数的函数: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh\n- 两个参数的函数: log, nrt, pow\n- 常数: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\n完整的数学解释器规范可参见 [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter) 文档。\n\n## 处理顺序\n1. 变量替换\n2. Math';

  @override
  String get default_ => '默认';

  @override
  String get exportPdfHeaderHeight => '页眉高度';

  @override
  String get exportPdfCellHeight => '行高';

  @override
  String get exportPdfHeaderFontSize => '页眉字体大小';

  @override
  String get exportPdfCellFontSize => '行字体大小';

  @override
  String get average => '平均值';

  @override
  String get maximum => '最大值';

  @override
  String get minimum => '最小值';

  @override
  String get exportPdfExportTitle => '标题';

  @override
  String get exportPdfExportStatistics => '统计数字';

  @override
  String get exportPdfExportData => '数据表格';

  @override
  String get startWithAddMeasurementPage => '启动时的测量';

  @override
  String get startWithAddMeasurementPageDescription => '应用启动时显示的测量输入屏幕。';

  @override
  String get horizontalLines => '水平线';

  @override
  String get linePositionY => '行位置 (y)';

  @override
  String get customGraphMarkings => '自定义记号';

  @override
  String get addLine => '添加行';

  @override
  String get useLegacyList => '使用旧式列表';

  @override
  String get addMeasurement => '添加测量';

  @override
  String get timestamp => '时间戳';

  @override
  String get note => '附注';

  @override
  String get color => '颜色';

  @override
  String get exportSettings => '备份设置';

  @override
  String get importSettings => '还原设置';

  @override
  String get requiresAppRestart => '需要重启应用';

  @override
  String get restartNow => '立即重启';

  @override
  String get warnNeedsRestartForUsingApp => '文件在此会话中被删除了。重启本应用继续使用将返回到应用的其他部分！';

  @override
  String get deleteAllMeasurements => '删除所有测量';

  @override
  String get deleteAllSettings => '删除所有设置';

  @override
  String get warnDeletionUnrecoverable => '除非你人工备份，否则此步骤是不可逆的。你真要删除这个吗？';

  @override
  String get enterTimeFormatDesc => '格式化字符串是一个预定义的ICU/Skeleton字符串和您想要包含的其他文字的混合体。\n\n[点击即可查看可用的格式化字符串的完整列表。](screen://TimeFormattingHelp)\n\n友情提示：使用更长或更短的格式字符串不会改变表的列宽，还可能导致意外的换行和文字显示不全。\n\n默认：\"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => '颜色厚度';

  @override
  String get needlePinBarWidthDesc => '图表上有色条目的宽度。';

  @override
  String get errParseEmptyCsvFile => 'csv 文件中行数不足以解析记录。';

  @override
  String get errParseTimeNotRestoreable => '没有允许恢复时间戳的列。';

  @override
  String errParseUnknownColumn(String title) {
    return '没有名为 \"$title\"的列。';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return '行 $lineNumber 的列数少于第一行。';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return '解码行 $lineNumber 中的 \"$fieldContent\"字段失败了。';
  }

  @override
  String get exportFieldsPreset => '导出字段预设';

  @override
  String get remove => '删除';

  @override
  String get manageExportColumns => '管理导出列';

  @override
  String get buildIn => '内置';

  @override
  String get csvTitle => 'CSV标题';

  @override
  String get recordFormat => '记录格式';

  @override
  String get timeFormat => '时间格式';

  @override
  String get errAccuracyLoss => '使用自定义时间格式导出预计会损失精度。';

  @override
  String get bottomAppBars => '底部对话栏';

  @override
  String get medications => '服药';

  @override
  String get addMedication => '添加药物';

  @override
  String get name => '名称';

  @override
  String get defaultDosis => '默认剂量';

  @override
  String get noMedication => '没有药物';

  @override
  String get dosis => '剂量';

  @override
  String get valueDistribution => '值分布';

  @override
  String get titleInCsv => 'CSV 标题';

  @override
  String get errBleNoPerms => '没有蓝牙权限';

  @override
  String get preferredPressureUnit => '首选的血压单位';

  @override
  String get compactList => '紧凑测量列表';

  @override
  String get bluetoothDisabled => '停用了蓝牙';

  @override
  String get errMeasurementRead => '测量时发生错误！';

  @override
  String get measurementSuccess => '测量成功！';

  @override
  String get connect => '连接';

  @override
  String get bluetoothInput => '蓝牙输入';

  @override
  String get aboutBleInput => '某些测量设备兼容 BLE GATT。你可以在此配对这些设备并自动传输测量数据或在设置中停用此选项。';

  @override
  String get scanningForDevices => '扫描设备';

  @override
  String get tapToClose => '轻按关闭。';

  @override
  String get meanArterialPressure => '表示动脉压';

  @override
  String get userID => '用户 ID';

  @override
  String get bodyMovementDetected => '检测到身体移动';

  @override
  String get cuffTooLoose => '袖带太松';

  @override
  String get improperMeasurementPosition => '测量方位不恰当';

  @override
  String get irregularPulseDetected => '检测到不规律的心跳';

  @override
  String get pulseRateExceedsUpperLimit => '心率超出上限';

  @override
  String get pulseRateLessThanLowerLimit => '心率低于下限';

  @override
  String get availableDevices => '可用的设备';

  @override
  String get deleteAllMedicineIntakes => '删除所有药品摄入量';

  @override
  String get deleteAllNotes => '删除所有附注';

  @override
  String get date => '日期';

  @override
  String get intakes => '服药';

  @override
  String get errFeatureNotSupported => '这个功能在这个平台上不可用。';

  @override
  String get invalidZip => '无效的 ZIP 文件。';

  @override
  String get errCantCreateArchive => '无法创建存档。如果可能请报告 Bug。';

  @override
  String get activateWeightFeatures => '激活体重相关功能';

  @override
  String get weight => '体重';

  @override
  String get enterWeight => '输入体重';

  @override
  String get selectMeasurementTitle => '选择要使用的测量';

  @override
  String measurementIndex(int number) {
    return '测量#$number';
  }

  @override
  String get select => '选择';

  @override
  String get bloodPressure => '血压';

  @override
  String get preferredWeightUnit => '首选体重单位';

  @override
  String get disabled => '已停用';

  @override
  String get oldBluetoothInput => '稳定';

  @override
  String get newBluetoothInputOldLib => '测试';

  @override
  String get newBluetoothInputCrossPlatform => '跨平台（测试）';

  @override
  String get bluetoothInputDesc => '测试版本后端可以在更多设备上工作，但未经充分测试。该跨平台版本可以在非 android 设备上工作，并且按计划在足够成熟后将取代稳定版。';

  @override
  String get tapToSelect => '轻按选择';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get title => '血壓記錄';

  @override
  String success(String msg) {
    return '成功: $msg';
  }

  @override
  String get loading => '讀取中…';

  @override
  String error(String msg) {
    return '發生錯誤: $msg';
  }

  @override
  String get errNaN => '請輸入數字';

  @override
  String get errLt30 => '數字 <= 30? 請在設定中關閉輸入驗證！';

  @override
  String get errUnrealistic => '不切實際的數值？請在設定中關閉輸入驗證！';

  @override
  String get errDiaGtSys => '舒張壓 >= 收縮壓？ 請在設定中關閉輸入驗證！';

  @override
  String errCantOpenURL(String url) {
    return '無法打開 URL: $url';
  }

  @override
  String get errNoFileOpened => '沒有打開任何檔案';

  @override
  String get errNotStarted => '尚未啟動';

  @override
  String get errNoValue => '請輸入數值';

  @override
  String get errNotEnoughDataToGraph => '沒有足夠的資料來繪製圖表。';

  @override
  String get errNoData => '沒有資料';

  @override
  String get errWrongImportFormat => '您只能匯入 CSV 和 SQLite 資料庫格式的檔案。';

  @override
  String get errNeedHeadline => '您只能匯入有標題列的檔案。';

  @override
  String get errCantReadFile => '檔案內容無法讀取';

  @override
  String get errNotImportable => '這個檔案無法匯入';

  @override
  String get btnCancel => '取消';

  @override
  String get btnSave => '儲存';

  @override
  String get btnConfirm => '確定';

  @override
  String get btnUndo => '復原';

  @override
  String get sysLong => '收縮壓';

  @override
  String get sysShort => '收縮壓';

  @override
  String get diaLong => '舒張壓';

  @override
  String get diaShort => '舒張壓';

  @override
  String get pulLong => '脈搏';

  @override
  String get pulShort => '脈搏';

  @override
  String get addNote => '備註（選擇性）';

  @override
  String get settings => '設定';

  @override
  String get layout => '格式';

  @override
  String get allowManualTimeInput => '允許手動輸入時間';

  @override
  String get enterTimeFormatScreen => '時間格式';

  @override
  String get theme => '主題';

  @override
  String get system => '跟隨系統';

  @override
  String get dark => '暗色';

  @override
  String get light => '亮色';

  @override
  String get iconSize => '圖示大小';

  @override
  String get graphLineThickness => '線條粗細';

  @override
  String get animationSpeed => '動畫持續時間';

  @override
  String get accentColor => '主題色彩';

  @override
  String get sysColor => '收縮壓顏色';

  @override
  String get diaColor => '舒張壓顏色';

  @override
  String get pulColor => '脈搏顏色';

  @override
  String get behavior => '行為';

  @override
  String get validateInputs => '輸入驗證';

  @override
  String get confirmDeletion => '確認刪除';

  @override
  String get age => '年齡';

  @override
  String get determineWarnValues => '決定警告數值';

  @override
  String get aboutWarnValuesScreen => '關於';

  @override
  String get aboutWarnValuesScreenDesc => '警告數值的更多資訊';

  @override
  String get sysWarn => '收縮壓警告';

  @override
  String get diaWarn => '舒張壓警告';

  @override
  String get data => '資料';

  @override
  String get version => '版本';

  @override
  String versionOf(String version) {
    return '版本: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return '版本號碼: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return '套件名稱: $name';
  }

  @override
  String get exportImport => '匯出 / 匯入';

  @override
  String get exportDir => '匯出目錄';

  @override
  String get exportAfterEveryInput => '每次輸入完畢後匯出';

  @override
  String get exportAfterEveryInputDesc => '不建議 (檔案會過大)';

  @override
  String get exportFormat => '匯出格式';

  @override
  String get exportCustomEntries => '自訂欄位';

  @override
  String get addEntry => '增加欄位';

  @override
  String get exportMimeType => '匯出媒體類型';

  @override
  String get exportCsvHeadline => '標題列';

  @override
  String get exportCsvHeadlineDesc => '有助於區分類型';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite 資料庫';

  @override
  String get text => '文字';

  @override
  String get other => '其它';

  @override
  String get fieldDelimiter => '字段格式';

  @override
  String get textDelimiter => '文字分隔符號';

  @override
  String get export => '匯出';

  @override
  String get shared => '已分享';

  @override
  String get import => '匯入';

  @override
  String get sourceCode => '原始碼';

  @override
  String get licenses => '第三方授權協議';

  @override
  String importSuccess(int count) {
    return '已成功匯入 $count 筆記錄';
  }

  @override
  String get exportWarnConfigNotImportable => '嘿! 溫馨提醒: 目前的匯出設定將導致無法匯入。如要繼續，請確認您設定的匯出格式是 CSV，啟用標題列，並且包含一種有效的時間格式。';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return '請注意，您並沒有匯出所有欄位: $fields $_temp0 遺失。';
  }

  @override
  String get statistics => '統計';

  @override
  String get measurementCount => '測量次數';

  @override
  String get measurementsPerDay => '日測量次數';

  @override
  String get timeResolvedMetrics => '時段指標';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt 最低.';
  }

  @override
  String maxOf(String txt) {
    return '$txt 最高.';
  }

  @override
  String get warnValues => '警告值';

  @override
  String get warnAboutTxt1 => '警告值僅供參考，並不是醫學建議。';

  @override
  String get warnAboutTxt2 => '預設的年齡參考值由此而來。';

  @override
  String get warnAboutTxt3 => '根據您的需求自由調整數值，並且遵照醫生的指示。';

  @override
  String get enterTimeFormatString => '時間格式';

  @override
  String get now => '現在';

  @override
  String get notes => '備註';

  @override
  String get time => '時間';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String get confirmDeleteDesc => '刪除這筆記錄嗎? (您可以從設定把這個通知關掉。)';

  @override
  String get deletionConfirmed => '記錄已刪除。';

  @override
  String get day => '天';

  @override
  String get week => '週';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get lifetime => '終身';

  @override
  String weekOfYear(int weekNum, int year) {
    return '週 $weekNum, $year';
  }

  @override
  String get last7Days => '7天';

  @override
  String get last30Days => '30天';

  @override
  String get allowMissingValues => '允許遺失的數值';

  @override
  String get errTimeAfterNow => '所選擇的時段已被重設，因為它發生在此時刻之後。您可以在設定中關閉此驗證。';

  @override
  String get language => '語言';

  @override
  String get custom => '自定';

  @override
  String get drawRegressionLines => '繪製趨勢線';

  @override
  String get drawRegressionLinesDesc => '在圖表中繪製迴歸線。僅適用於大的區間。';

  @override
  String pdfDocumentTitle(String start, String end) {
    return '血壓數值從 $start 到 $end';
  }

  @override
  String get fieldFormat => '字段格式';

  @override
  String get result => '結果:';

  @override
  String get pulsePressure => '血壓';

  @override
  String get addExportformat => '增加匯出格式';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';
}
