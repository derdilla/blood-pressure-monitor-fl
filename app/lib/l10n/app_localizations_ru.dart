// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get title => 'Приложение для измерения артериального давления';

  @override
  String success(String msg) {
    return 'Успешно: $msg';
  }

  @override
  String get loading => 'загрузка…';

  @override
  String error(String msg) {
    return 'Ошибка: $msg';
  }

  @override
  String get errNaN => 'Пожалуйста, введите число';

  @override
  String get errLt30 => 'Число <= 30? Выключите проверку значений в настройках!';

  @override
  String get errUnrealistic => 'Нереалистичное значение? Выключите проверку значений в настройках!';

  @override
  String get errDiaGtSys => 'dia >= sys? Выключите проверку значений в настройках!';

  @override
  String errCantOpenURL(String url) {
    return 'Невозможно открыть URL: $url';
  }

  @override
  String get errNoFileOpened => 'файл не был открыт';

  @override
  String get errNotStarted => 'не начато';

  @override
  String get errNoValue => 'Пожалуйста, введите значение';

  @override
  String get errNotEnoughDataToGraph => 'Недостаточно данных, чтобы рисовать график.';

  @override
  String get errNoData => 'нет данных';

  @override
  String get errWrongImportFormat => 'Вы можете импортировать файлы только в форматах CSV или SQLite.';

  @override
  String get errNeedHeadline => 'Вы можете импортировать файлы только с заголовком.';

  @override
  String get errCantReadFile => 'Содержимое файла не может быть прочитано';

  @override
  String get errNotImportable => 'Файл не может быть импортирован';

  @override
  String get btnCancel => 'ОТМЕНА';

  @override
  String get btnSave => 'СОХРАНИТЬ';

  @override
  String get btnConfirm => 'OK';

  @override
  String get btnUndo => 'ОТМЕНА';

  @override
  String get sysLong => 'Систолическое';

  @override
  String get sysShort => 'САД';

  @override
  String get diaLong => 'Диастолическое';

  @override
  String get diaShort => 'ДАД';

  @override
  String get pulLong => 'Пульс';

  @override
  String get pulShort => 'ЧСС';

  @override
  String get addNote => 'Примечание (необязательно)';

  @override
  String get settings => 'Настройки';

  @override
  String get layout => 'Внешний вид';

  @override
  String get allowManualTimeInput => 'Разрешить ручной ввод времени';

  @override
  String get enterTimeFormatScreen => 'Формат времени';

  @override
  String get theme => 'Тема';

  @override
  String get system => 'Системная';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get iconSize => 'Размер иконок';

  @override
  String get graphLineThickness => 'Толщина линий';

  @override
  String get animationSpeed => 'Длительность анимации';

  @override
  String get accentColor => 'Цвет темы приложения';

  @override
  String get sysColor => 'Цвет систолического давления';

  @override
  String get diaColor => 'Цвет диастолического давления';

  @override
  String get pulColor => 'Цвет пульса';

  @override
  String get behavior => 'Поведение приложения';

  @override
  String get validateInputs => 'Проверять вводимые значения';

  @override
  String get confirmDeletion => 'Подтверждение удаления';

  @override
  String get age => 'Возраст';

  @override
  String get determineWarnValues => 'Определить предупредительные значения';

  @override
  String get aboutWarnValuesScreen => 'Что это';

  @override
  String get aboutWarnValuesScreenDesc => 'Подробнее о предупредительных значениях';

  @override
  String get sysWarn => 'Систолическое предупреждение';

  @override
  String get diaWarn => 'Диастолическое предупреждение';

  @override
  String get data => 'Данные';

  @override
  String get version => 'Версия';

  @override
  String versionOf(String version) {
    return 'Версия: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Номер сборки: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Имя пакета: $name';
  }

  @override
  String get exportImport => 'Экспорт / Импорт';

  @override
  String get exportDir => 'Место экспорта';

  @override
  String get exportAfterEveryInput => 'Экспортировать после каждой новой записи';

  @override
  String get exportAfterEveryInputDesc => 'Не рекомендуется (взрыв файла)';

  @override
  String get exportFormat => 'Формат экспортируемого файла';

  @override
  String get exportCustomEntries => 'Настроить поля';

  @override
  String get addEntry => 'Добавить поле';

  @override
  String get exportMimeType => 'Тип экспортируемого файла';

  @override
  String get exportCsvHeadline => 'Заголовок';

  @override
  String get exportCsvHeadlineDesc => 'Помогает различать типы';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite DB';

  @override
  String get text => 'текстовый файл';

  @override
  String get other => 'другое';

  @override
  String get fieldDelimiter => 'Разделитель полей';

  @override
  String get textDelimiter => 'Разделитель текста';

  @override
  String get export => 'ЭКСПОРТ';

  @override
  String get shared => 'общий';

  @override
  String get import => 'ИМПОРТ';

  @override
  String get sourceCode => 'Исходный код';

  @override
  String get licenses => 'Лицензии третьих сторон';

  @override
  String importSuccess(int count) {
    return 'Импортировано $count записей';
  }

  @override
  String get exportWarnConfigNotImportable => 'Привет! Просто дружеское предупреждение: текущая конфигурация экспорта не будет доступна для импорта. Чтобы исправить это, убедитесь, что вы установили тип экспорта как CSV, включили заголовок и включили один из доступных форматов времени.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Обратите внимание, что вы экспортируете не все поля: $fields $_temp0 отсутствуют.';
  }

  @override
  String get statistics => 'Статистика';

  @override
  String get measurementCount => 'Количество измерений';

  @override
  String get measurementsPerDay => 'Количество измерений за день';

  @override
  String get timeResolvedMetrics => 'Показатели по времени суток';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt мин.';
  }

  @override
  String maxOf(String txt) {
    return '$txt макс.';
  }

  @override
  String get warnValues => 'Предупредительные значения';

  @override
  String get warnAboutTxt1 => 'Значения warn имеют общий рекомендательный характер и не могут восприниматься как медицинские показания.';

  @override
  String get warnAboutTxt2 => 'Значения, зависящие от возраста по умолчанию, взяты из этого источника.';

  @override
  String get warnAboutTxt3 => 'Не стесняйтесь изменять значения в соответствии с вашими потребностями и следуйте рекомендациям вашего врача.';

  @override
  String get enterTimeFormatString => 'формат времени';

  @override
  String get now => 'сейчас';

  @override
  String get notes => 'Заметки';

  @override
  String get time => 'Время';

  @override
  String get confirmDelete => 'Подтвердите удаление';

  @override
  String get confirmDeleteDesc => 'Удалить эту запись? (Вы можете отключить эти подтверждения в настройках.)';

  @override
  String get deletionConfirmed => 'Запись удалена.';

  @override
  String get day => 'День';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'Год';

  @override
  String get lifetime => 'Жизнь';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Неделя $weekNum, $year';
  }

  @override
  String get last7Days => '7 дней';

  @override
  String get last30Days => '30 дней';

  @override
  String get allowMissingValues => 'Разрешить пропущенные значения';

  @override
  String get errTimeAfterNow => 'Выбранное время было сброшено, так как оно находится в будущем и ещё не наступило. Вы можете отключить эту проверку в настройках.';

  @override
  String get language => 'Язык';

  @override
  String get custom => 'Пользовательский';

  @override
  String get drawRegressionLines => 'Рисовать линии трендов';

  @override
  String get drawRegressionLinesDesc => 'Рисовать линии на графике посредством регрессии. Полезно лишь на больших интервалах.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return 'Значения кровяного давления с $start по $end';
  }

  @override
  String get fieldFormat => 'Формат поля';

  @override
  String get result => 'Результат:';

  @override
  String get pulsePressure => 'Пульсовое давление';

  @override
  String get addExportformat => 'Добавить формат для экспортирования';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get exportFieldFormatDocumentation => '## Переменные\nФормат экспортного поля поддерживает вставку значений для следующих переменных:\n- `\$TIMESTAMP:` Представляет время с эпохи Unix в миллисекундах.\n- `\$SYS:` Предоставляет значение, если оно доступно; в противном случае по умолчанию оно равно -1.\n- `\$DIA:` Предоставляет значение, если оно доступно; в противном случае значение по умолчанию равно -1.\n- `\$PUL:` Предоставляет значение, если оно доступно; в противном случае значение по умолчанию равно -1.\n- `\$NOTE:` Предоставляет значение, если оно доступно; в противном случае значение по умолчанию равно -1.\n- `\$COLOR:` Представляет цвет измерения в виде числа. (пример значения: `4291681337`)\n\nЕсли в записи артериального давления нет ни одного из вышеперечисленных заполнителей, они будут заменены на `null`.\n\n## Математика\nВнутри двойных скобок (\"`{}}`\") можно использовать основные математические операции.\n\nПоддерживаются следующие математические операции:\n- Операции: +, -, *, /, %, ^\n- Однопараметрические функции: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh \n- Двухпараметрические функции: log, nrt, pow\n- Константы: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nПолную спецификацию математического интерпретатора можно найти в документации [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter).\n\n## Порядок обработки\n1. замена переменной\n2. Математика';

  @override
  String get default_ => 'По умолчанию';

  @override
  String get exportPdfHeaderHeight => 'Высота заголовка';

  @override
  String get exportPdfCellHeight => 'Высота строки';

  @override
  String get exportPdfHeaderFontSize => 'Размер шрифта заголовка';

  @override
  String get exportPdfCellFontSize => 'Размер шрифта строки';

  @override
  String get average => 'Среднее';

  @override
  String get maximum => 'Максимум';

  @override
  String get minimum => 'Минимум';

  @override
  String get exportPdfExportTitle => 'Заголовок';

  @override
  String get exportPdfExportStatistics => 'Статистика';

  @override
  String get exportPdfExportData => 'Таблица данных';

  @override
  String get startWithAddMeasurementPage => 'Измерение при запуске';

  @override
  String get startWithAddMeasurementPageDescription => 'При запуске приложения отображается экран ввода измерений.';

  @override
  String get horizontalLines => 'Горизонтальные линии';

  @override
  String get linePositionY => 'Положение линии (y)';

  @override
  String get customGraphMarkings => 'Пользовательская маркировка';

  @override
  String get addLine => 'Добавить строку';

  @override
  String get useLegacyList => 'Используйте унаследованный список';

  @override
  String get addMeasurement => 'Добавить измерение';

  @override
  String get timestamp => 'Временная метка';

  @override
  String get note => 'Примечание';

  @override
  String get color => 'Цвет';

  @override
  String get exportSettings => 'Настройки резервного копирования';

  @override
  String get importSettings => 'Восстановление настроек';

  @override
  String get requiresAppRestart => 'Требуется перезапуск приложения';

  @override
  String get restartNow => 'Перезапустить сейчас';

  @override
  String get warnNeedsRestartForUsingApp => 'Файлы были удалены в этом сеансе. Перезапустите приложение, чтобы продолжить использование, вернувшись к другим частям приложения!';

  @override
  String get deleteAllMeasurements => 'Удалить все измерения';

  @override
  String get deleteAllSettings => 'Удалить все настройки';

  @override
  String get warnDeletionUnrecoverable => 'Этот шаг не подлежит восстановлению, если только вы не сделали резервную копию вручную. Вы действительно хотите удалить это?';

  @override
  String get enterTimeFormatDesc => 'Строка форматирования - это смесь предопределенных строк ICU/Skeleton и любого дополнительного текста, который вы хотели бы включить.\n\n[Если вам интересен полный список допустимых форматов, вы можете найти их прямо здесь.](screen://TimeFormattingHelp)\n\nПросто дружеское напоминание: использование более длинных или более коротких строк формата волшебным образом не изменит ширину столбцов таблицы, что может привести к некоторым неудобным разрывам строк и не отображению текста.\n\nпо умолчанию: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Толщина цвета';

  @override
  String get needlePinBarWidthDesc => 'Ширина линий, которые образуют цветные записи на графике.';

  @override
  String get errParseEmptyCsvFile => 'В файле csv недостаточно строк, чтобы разобрать запись.';

  @override
  String get errParseTimeNotRestoreable => 'Не существует столбца, позволяющего восстановить временную метку.';

  @override
  String errParseUnknownColumn(String title) {
    return 'Не существует столбца с заголовком \"$title\".';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return 'В строке $lineNumber меньше столбцов, чем в первой строке.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return 'Декодирование поля \"$fieldContent\" в строке $lineNumber не удалось.';
  }

  @override
  String get exportFieldsPreset => 'Предварительная настройка экспорта полей';

  @override
  String get remove => 'Удалить';

  @override
  String get manageExportColumns => 'Управление колонками экспорта';

  @override
  String get buildIn => 'Встроенный';

  @override
  String get csvTitle => 'CSV-титры';

  @override
  String get recordFormat => 'Формат записи';

  @override
  String get timeFormat => 'Формат времени';

  @override
  String get errAccuracyLoss => 'При экспорте с использованием пользовательских форматеров времени ожидается потеря точности.';

  @override
  String get bottomAppBars => 'Нижние диалоговые панели';

  @override
  String get medications => 'Лекарства';

  @override
  String get addMedication => 'Добавить лекарство';

  @override
  String get name => 'Имя';

  @override
  String get defaultDosis => 'Доза по умолчанию';

  @override
  String get noMedication => 'Нет лекарства';

  @override
  String get dosis => 'Доза';

  @override
  String get valueDistribution => 'Распределение стоимости';

  @override
  String get titleInCsv => 'Название в CSV';

  @override
  String get errBleNoPerms => 'Нет разрешений на использование bluetooth';

  @override
  String get preferredPressureUnit => 'Предпочтительная единица измерения давления';

  @override
  String get compactList => 'Компактный список измерений';

  @override
  String get bluetoothDisabled => 'Bluetooth отключен';

  @override
  String get errMeasurementRead => 'Ошибка при измерении!';

  @override
  String get measurementSuccess => 'Измерение выполнено успешно!';

  @override
  String get connect => 'Подключение';

  @override
  String get bluetoothInput => 'Вход Bluetooth';

  @override
  String get aboutBleInput => 'Некоторые измерительные устройства совместимы с BLE GATT. Вы можете сопрячь эти устройства здесь и автоматически передавать измерения или отключить эту опцию в настройках.';

  @override
  String get scanningForDevices => 'Сканирование для поиска устройств';

  @override
  String get tapToClose => 'Нажмите, чтобы закрыть.';

  @override
  String get meanArterialPressure => 'Среднее артериальное давление';

  @override
  String get userID => 'ID пользователя';

  @override
  String get bodyMovementDetected => 'Обнаружено движение тела';

  @override
  String get cuffTooLoose => 'Манжета слишком свободная';

  @override
  String get improperMeasurementPosition => 'Неправильное положение при измерении';

  @override
  String get irregularPulseDetected => 'Обнаружен нерегулярный пульс';

  @override
  String get pulseRateExceedsUpperLimit => 'Частота пульса превышает верхний предел';

  @override
  String get pulseRateLessThanLowerLimit => 'Частота пульса меньше нижнего предела';

  @override
  String get availableDevices => 'Доступные устройства';

  @override
  String get deleteAllMedicineIntakes => 'Удалить все приемы лекарств';

  @override
  String get deleteAllNotes => 'Удалить все заметки';

  @override
  String get date => 'Дата';

  @override
  String get intakes => 'Медицинский прием';

  @override
  String get errFeatureNotSupported => 'Эта функция недоступна на данной платформе.';

  @override
  String get invalidZip => 'Неверный файл zip.';

  @override
  String get errCantCreateArchive => 'Не удается создать архив. Пожалуйста, сообщите об ошибке, если это возможно.';

  @override
  String get activateWeightFeatures => 'Активируйте функции, связанные с весом';

  @override
  String get weight => 'Вес';

  @override
  String get enterWeight => 'Введите вес';

  @override
  String get selectMeasurementTitle => 'Выберите измерение для использования';

  @override
  String measurementIndex(int number) {
    return 'Измерение #$number';
  }

  @override
  String get select => 'Выберите';

  @override
  String get bloodPressure => 'Давление крови';

  @override
  String get preferredWeightUnit => 'Предпочтительный вес';

  @override
  String get disabled => 'Откючено';

  @override
  String get oldBluetoothInput => 'Стабильно';

  @override
  String get newBluetoothInputOldLib => 'Бета';

  @override
  String get newBluetoothInputCrossPlatform => 'Кросс-платформеннная бета';

  @override
  String get bluetoothInputDesc => 'Бета работает на большем количестве устройств, но меньше тестируется. Кросс-платформенная версия может работать и на не Андроиде и планируется заменить стабильную реализацию, как только она станет достаточно взрослой.';

  @override
  String get tapToSelect => 'Tap to select';
}
