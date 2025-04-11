// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get title => 'Kan Basıncı Uygulaması';

  @override
  String success(String msg) {
    return 'Başarılı: $msg';
  }

  @override
  String get loading => 'yükleniyor…';

  @override
  String error(String msg) {
    return 'Hata: $msg';
  }

  @override
  String get errNaN => 'Lütfen bir sayı girin';

  @override
  String get errLt30 => 'Numara <= 30? Ayarlardan doğrulamayı kapatın!';

  @override
  String get errUnrealistic => 'Gerçekçi olmayan değer? Ayarlardan doğrulamayı kapatın!';

  @override
  String get errDiaGtSys => 'dia >= sys? Ayarlardan doğrulamayı kapatın!';

  @override
  String errCantOpenURL(String url) {
    return 'URL açılamadı: $url';
  }

  @override
  String get errNoFileOpened => 'herhangi bir dosya açılmadı';

  @override
  String get errNotStarted => 'başlatılmadı';

  @override
  String get errNoValue => 'Lütfen bir değer girin';

  @override
  String get errNotEnoughDataToGraph => 'Grafik çizmeye yetecek kadar veri bulunmamakta.';

  @override
  String get errNoData => 'veri yok';

  @override
  String get errWrongImportFormat => 'Sadece CSV ve SQLite veritabanı biçiminde dosya aktarabilirsiniz.';

  @override
  String get errNeedHeadline => 'Sadece başlık bulunduran dosyaları aktarabilirsiniz.';

  @override
  String get errCantReadFile => 'Dosyanın içeriği okunamıyor';

  @override
  String get errNotImportable => 'Bu dosya aktarılamaz';

  @override
  String get btnCancel => 'İPTAL';

  @override
  String get btnSave => 'KAYDET';

  @override
  String get btnConfirm => 'TAMAM';

  @override
  String get btnUndo => 'GERİ AL';

  @override
  String get sysLong => 'Sistolik';

  @override
  String get sysShort => 'sys';

  @override
  String get diaLong => 'Diyastolik';

  @override
  String get diaShort => 'dia';

  @override
  String get pulLong => 'Nabız';

  @override
  String get pulShort => 'pul';

  @override
  String get addNote => 'Not (isteğe bağlı)';

  @override
  String get settings => 'Ayarlar';

  @override
  String get layout => 'Düzen';

  @override
  String get allowManualTimeInput => 'Elle süre girmeye izin ver';

  @override
  String get enterTimeFormatScreen => 'Zaman biçimi';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistem';

  @override
  String get dark => 'Koyu';

  @override
  String get light => 'Açık';

  @override
  String get iconSize => 'Simge boyutu';

  @override
  String get graphLineThickness => 'Çizgi kalınlığı';

  @override
  String get animationSpeed => 'Animasyon süresi';

  @override
  String get accentColor => 'Tema rengi';

  @override
  String get sysColor => 'Sistolik rengi';

  @override
  String get diaColor => 'Diyastolik rengi';

  @override
  String get pulColor => 'Nabız rengi';

  @override
  String get behavior => 'Davranış';

  @override
  String get validateInputs => 'Veri girişlerini doğrula';

  @override
  String get confirmDeletion => 'Silmeyi onayla';

  @override
  String get age => 'Yaş';

  @override
  String get determineWarnValues => 'Uyarı değerlerini belirle';

  @override
  String get aboutWarnValuesScreen => 'Hakkında';

  @override
  String get aboutWarnValuesScreenDesc => 'Uyarı değerleri hakkında daha çok bilgi';

  @override
  String get sysWarn => 'Sistolik uyarı';

  @override
  String get diaWarn => 'Diyastolik uyarı';

  @override
  String get data => 'Veri';

  @override
  String get version => 'Sürüm';

  @override
  String versionOf(String version) {
    return 'Sürüm: $version';
  }

  @override
  String buildNumberOf(String buildNumber) {
    return 'Sürüm numarası: $buildNumber';
  }

  @override
  String packageNameOf(String name) {
    return 'Paket adı: $name';
  }

  @override
  String get exportImport => 'Dışa aktar / İçe aktar';

  @override
  String get exportDir => 'Dışa aktarma dizini';

  @override
  String get exportAfterEveryInput => 'Her girişten sonra dışa aktar';

  @override
  String get exportAfterEveryInputDesc => 'Önerilmez (dosya patlaması)';

  @override
  String get exportFormat => 'Dışa aktarma biçimi';

  @override
  String get exportCustomEntries => 'Alanları kişileştir';

  @override
  String get addEntry => 'Alan ekle';

  @override
  String get exportMimeType => 'Dışa aktarılan medya türü';

  @override
  String get exportCsvHeadline => 'Başlık';

  @override
  String get exportCsvHeadlineDesc => 'Türleri ayırmakta yardımcı olur';

  @override
  String get csv => 'CSV';

  @override
  String get pdf => 'PDF';

  @override
  String get db => 'SQLite Veritabanı';

  @override
  String get text => 'metin';

  @override
  String get other => 'diğer';

  @override
  String get fieldDelimiter => 'Alan sınırlayıcı';

  @override
  String get textDelimiter => 'Metin sınırlayıcı';

  @override
  String get export => 'DIŞA AKTAR';

  @override
  String get shared => 'paylaşıldı';

  @override
  String get import => 'İÇE AKTAR';

  @override
  String get sourceCode => 'Kaynak kodu';

  @override
  String get licenses => '3. taraf lisanslar';

  @override
  String importSuccess(int count) {
    return '$count giriş içe aktarıldı';
  }

  @override
  String get exportWarnConfigNotImportable => 'Merhaba! Size dostça bir uyarı: Şu anki dışa aktarma ayarlarıyla içe aktarmak mümkün olmayacak. Bunu düzeltmek için dışa aktarma türünün CSV olduğuna emin olun ve uygun zaman biçimlerinden birini dahil edin.';

  @override
  String exportWarnNotEveryFieldExported(int count, String fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return 'Bütün alanları dışa aktarmıyorsunuz: $fields $_temp0 kayıp.';
  }

  @override
  String get statistics => 'İstatistikler';

  @override
  String get measurementCount => 'Ölçüm sayısı';

  @override
  String get measurementsPerDay => 'Günde ölçüm sayısı';

  @override
  String get timeResolvedMetrics => 'Günün saatine göre ölçümler';

  @override
  String avgOf(String txt) {
    return '$txt Ø';
  }

  @override
  String minOf(String txt) {
    return '$txt asg.';
  }

  @override
  String maxOf(String txt) {
    return '$txt azm.';
  }

  @override
  String get warnValues => 'Uyarı değerleri';

  @override
  String get warnAboutTxt1 => 'Uyarı değerleri sadece bir öneridir ve tıbbi bir tavsiye değildir.';

  @override
  String get warnAboutTxt2 => 'Varsayılan yaşa bağlı değerler bu kaynaktan alındı.';

  @override
  String get warnAboutTxt3 => 'Bu değerleri ihtiyacınıza göre değiştirebilirsiniz. Doktorunuzun tavsiyesine uyun.';

  @override
  String get enterTimeFormatString => 'zaman biçimi';

  @override
  String get now => 'şu an';

  @override
  String get notes => 'Notlar';

  @override
  String get time => 'Zaman';

  @override
  String get confirmDelete => 'Silmeyi onayla';

  @override
  String get confirmDeleteDesc => 'Bu girişi sil? (Bu onaylama mesajını ayarlardan kapatabilirsiniz.)';

  @override
  String get deletionConfirmed => 'Giriş silindi.';

  @override
  String get day => 'Gün';

  @override
  String get week => 'Hafta';

  @override
  String get month => 'Ay';

  @override
  String get year => 'Yıl';

  @override
  String get lifetime => 'Ömür boyu';

  @override
  String weekOfYear(int weekNum, int year) {
    return 'Hafta $weekNum, $year';
  }

  @override
  String get last7Days => '7 gün';

  @override
  String get last30Days => '30 gün';

  @override
  String get allowMissingValues => 'Kayıp değerlere izin ver';

  @override
  String get errTimeAfterNow => 'Seçilen zaman gelecekte. Bu doğrulamayı ayarlardan kapatabilirsiniz.';

  @override
  String get language => 'Dil';

  @override
  String get custom => 'Özel';

  @override
  String get drawRegressionLines => 'Eğilim çizgilerini çiz';

  @override
  String get drawRegressionLinesDesc => 'Grafikte regresyon çizgilerini çiz. Yalnızca geniş zaman aralıklarında kullanışlı.';

  @override
  String pdfDocumentTitle(String start, String end) {
    return '${start}den {end}e kan basıncı değerleri';
  }

  @override
  String get fieldFormat => 'Alan biçimi';

  @override
  String get result => 'Sonuç:';

  @override
  String get pulsePressure => 'Nabız basıncı';

  @override
  String get addExportformat => 'exportformat ekle';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get exportFieldFormatDocumentation => '## Değişkenler\nDışa aktarma alanı biçimi şu yerler için değer doldurabiliyor:\n- `\$TIMESTAMP:` Unix miladından itibaren geçen zamanı milisaniyede gösterir.\n- `\$SYS:` Eğer mevcutsa bir değer sağlar; yoksa -1 sağlar.\n- `\$DIA:` Eğer mevcutsa bir değer sağlar; yoksa -1 sağlar\n- `\$PUL:` Eğer mevcutsa bir değer sağlar; yoksa -1 sağlar\n- `\$NOTE:` Eğer mevcutsa bir değer sağlar; yoksa -1 sağlar\n- `\$COLOR:` Bir ölçümün rengini sayı olarak temsil eder. (örnek değer: `4291681337`)\n\nBu adı geçen yerlerden herhangi biri kan basıncı kaydında yoksa, -1 ile değiştirilir.\n\n## Matematik\nÇift süslü parantez içinde basit matematiksel işlemler yapabilirsiniz (\"`{{}}`\").\n\nAşağıdaki matematiksel işlemler desteklenir:\n- İşlemler: +, -, *, /, %, ^\n- Tek-parametreli fonksiyonlar: abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh\n- Çift-parametreli fonksiyonlar: log, nrt, pow\n- Sabit değişkenler: e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2\n\nMatematik işlemcisinin bütün ayrıntıları için [function_tree](https://pub.dev/documentation/function_tree/latest#interpreter)\'e bakabilirsiniz\n\n## İşlem önceliği\n1. Değişken değişimi\n2. Matematik';

  @override
  String get default_ => 'Varsayılan';

  @override
  String get exportPdfHeaderHeight => 'Başlık yüksekliği';

  @override
  String get exportPdfCellHeight => 'Satır yüksekliği';

  @override
  String get exportPdfHeaderFontSize => 'Başlık yazı tipi boyutu';

  @override
  String get exportPdfCellFontSize => 'Satır yazı tipi boyutu';

  @override
  String get average => 'Ortalama';

  @override
  String get maximum => 'Azami';

  @override
  String get minimum => 'Asgari';

  @override
  String get exportPdfExportTitle => 'Başlık';

  @override
  String get exportPdfExportStatistics => 'İstatislikler';

  @override
  String get exportPdfExportData => 'Veri tablosu';

  @override
  String get startWithAddMeasurementPage => 'Başlangıçta ölçüm';

  @override
  String get startWithAddMeasurementPageDescription => 'Uygulamanın açılışında, ölçüm giriş ekranı gösterilir.';

  @override
  String get horizontalLines => 'Yatay çizgiler';

  @override
  String get linePositionY => 'Çizgi konumu (y)';

  @override
  String get customGraphMarkings => 'Özel işaretler';

  @override
  String get addLine => 'Çizgi ekle';

  @override
  String get useLegacyList => 'Eski tip liste kullan';

  @override
  String get addMeasurement => 'Ölçüm ekle';

  @override
  String get timestamp => 'Zaman damgası';

  @override
  String get note => 'Not';

  @override
  String get color => 'Renk';

  @override
  String get exportSettings => 'Ayarları yedekle';

  @override
  String get importSettings => 'Ayarları geri yükle';

  @override
  String get requiresAppRestart => 'Uygulamanın yeniden başlatılmasını gerektirir';

  @override
  String get restartNow => 'Şimdi yeniden başlat';

  @override
  String get warnNeedsRestartForUsingApp => 'Bu oturumda dosyalar silindi. Uygulamanın diğer bölümlerine dönüp kullanmaya devam etmek için uygulamayı yeniden başlatın!';

  @override
  String get deleteAllMeasurements => 'Tüm ölçümleri sil';

  @override
  String get deleteAllSettings => 'Tüm ayarları sil';

  @override
  String get warnDeletionUnrecoverable => 'Elle bir yedekleme yapmadıysanız bu adım geri döndürülemez. Bunu gerçekten silmek istiyor musunuz?';

  @override
  String get enterTimeFormatDesc => 'Biçim stringi önceden tanımladan ICU/Skeleton stringlerinin ve eklemek istediğiniz herhangi başka metinin birleşimidir.\n\n[Tanımlanan biçimlerin bütünün bir listesini merak ettiyseniz burada bulabilirsiniz.](screen://TimeFormattingHelp)\n\nBir hatırlatma, uzun ya da kısa biçim String kullanmak tablodaki sütunların genişliğini değiştirmeyecek, ki bu da garip satır atlamalarına ve metnin gözükmemesine yol açabilir.\n\nvarsayılan: \"yy-MM-dd HH:mm\"';

  @override
  String get needlePinBarWidth => 'Renk kalınlığı';

  @override
  String get needlePinBarWidthDesc => 'Renkli girişlerin grafik üzerinde oluşturduğu çizgilerin genişliği.';

  @override
  String get errParseEmptyCsvFile => 'CSV dosyasında kaydı ayrıştırmak için yeterli satır yok.';

  @override
  String get errParseTimeNotRestoreable => 'Zaman damgasını geri yüklemeye izin veren bir sütun yok.';

  @override
  String errParseUnknownColumn(String title) {
    return '\"$title\" başlığına sahip bir sütun yok.';
  }

  @override
  String errParseLineTooShort(int lineNumber) {
    return '$lineNumber. satırda ilk satırdan daha az sütun var.';
  }

  @override
  String errParseFailedDecodingField(int lineNumber, String fieldContent) {
    return '$lineNumber. satırdaki \"$fieldContent\" alanının çözülmesi başarısız oldu.';
  }

  @override
  String get exportFieldsPreset => 'Alan ön ayarlarını dışa aktar';

  @override
  String get remove => 'Kaldır';

  @override
  String get manageExportColumns => 'Dışa aktarılan sütunları yönet';

  @override
  String get buildIn => 'Yerleşik';

  @override
  String get csvTitle => 'CSV-başlığı';

  @override
  String get recordFormat => 'Kayıt biçimi';

  @override
  String get timeFormat => 'Zaman biçimi';

  @override
  String get errAccuracyLoss => 'Özel zaman biçimlendiricilerle dışa aktarırken hassasiyet kaybı olabilir.';

  @override
  String get bottomAppBars => 'Alt iletişim kutusu çubukları';

  @override
  String get medications => 'İlaçlar';

  @override
  String get addMedication => 'İlaç ekle';

  @override
  String get name => 'Ad';

  @override
  String get defaultDosis => 'Öntanımlı doz';

  @override
  String get noMedication => 'İlaç yok';

  @override
  String get dosis => 'Doz';

  @override
  String get valueDistribution => 'Değer dağılımı';

  @override
  String get titleInCsv => 'CSV başlığı';

  @override
  String get errBleNoPerms => 'Bluetooth izinleri yok';

  @override
  String get preferredPressureUnit => 'Tercih edilen basınç birimi';

  @override
  String get compactList => 'Sıkışık ölçüm listesi';

  @override
  String get bluetoothDisabled => 'Bluetooth devre dışı';

  @override
  String get errMeasurementRead => 'Ölçüm alınırken hata oluştu!';

  @override
  String get measurementSuccess => 'Ölçüm başarıyla alındı!';

  @override
  String get connect => 'Bağlan';

  @override
  String get bluetoothInput => 'Bluetooth girişi';

  @override
  String get aboutBleInput => 'Bazı ölçüm aygıtları BLE GATT uyumludur. Bu aygıtları burada eşleştirebilir ve ölçümleri otomatik olarak iletebilir veya ayarlardan bu seçeneği devre dışı bırakabilirsiniz.';

  @override
  String get scanningForDevices => 'Aygıtlar taranıyor';

  @override
  String get tapToClose => 'Kapatmak için dokunun.';

  @override
  String get meanArterialPressure => 'Ortalama damar basıncı';

  @override
  String get userID => 'Kullanıcı kimliği';

  @override
  String get bodyMovementDetected => 'Vücut hareketi algılandı';

  @override
  String get cuffTooLoose => 'Bileklik çok gevşek';

  @override
  String get improperMeasurementPosition => 'Yanlış ölçüm konumu';

  @override
  String get irregularPulseDetected => 'Düzensiz nabız algılandı';

  @override
  String get pulseRateExceedsUpperLimit => 'Nabız hızı üst sınırı aşıyor';

  @override
  String get pulseRateLessThanLowerLimit => 'Nabız hızı alt sınırdan düşük';

  @override
  String get availableDevices => 'Kullanılabilir aygıtlar';

  @override
  String get deleteAllMedicineIntakes => 'Tüm ilaç alımlarını sil';

  @override
  String get deleteAllNotes => 'Tüm notları sil';

  @override
  String get date => 'Tarih';

  @override
  String get intakes => 'İlaç alımları';

  @override
  String get errFeatureNotSupported => 'Bu özellik bu platformda kullanılamıyor.';

  @override
  String get invalidZip => 'Geçersiz zip dosyası.';

  @override
  String get errCantCreateArchive => 'Arşiv oluşturulamıyor. Lütfen mümkünse hatayı bildirin.';

  @override
  String get activateWeightFeatures => 'Ağırlıkla ilgili özellikleri etkinleştir';

  @override
  String get weight => 'Ağırlık';

  @override
  String get enterWeight => 'Ağırlık girin';

  @override
  String get selectMeasurementTitle => 'Kullanılacak ölçüyü seçin';

  @override
  String measurementIndex(int number) {
    return 'Measurement #$number';
  }

  @override
  String get select => 'Seç';

  @override
  String get bloodPressure => 'Kan basıncı';

  @override
  String get preferredWeightUnit => 'Tercih edilen ağırlık birimi';

  @override
  String get disabled => 'Devre dışı';

  @override
  String get oldBluetoothInput => 'Kararlı';

  @override
  String get newBluetoothInputOldLib => 'Beta';

  @override
  String get newBluetoothInputCrossPlatform => 'Beta cross-platform';

  @override
  String get bluetoothInputDesc => 'The beta backend works on more devices but is less tested. The cross-platform version may work on non-android and is planned to supersede the stable implementation once mature enough.';

  @override
  String get tapToSelect => 'Seçmek için dokunun';
}
