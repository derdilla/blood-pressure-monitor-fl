
import 'dart:math';

import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../test/model/analyzer_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Statistics screen', (WidgetTester tester) async {
    await TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('en');
    await tester.pumpWidget(MaterialApp(
      darkTheme: _buildTheme(ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [AppLocalizations.delegate,], locale: Locale('en'),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => IntervalStoreManager(IntervalStorage(), IntervalStorage(), IntervalStorage())),
          ChangeNotifierProvider(create: (c) => Settings()),
        ],
        child: RepositoryProvider<BloodPressureRepository>(
          create: (c) {
            final rng = Random();
            final repo = _MockRepo();
            repo.records = [
              for (int i = 0; i < 144; i++)
                mockRecord(
                  time: DateTime.fromMillisecondsSinceEpoch(1000*60*60*24*265*40 + i * 1000*60*60*8),
                  sys: 130 + (rng.nextInt(40) - 20) - (i ~/ 8),
                  dia: 85 + (rng.nextInt(30) - 15) - (i ~/ 9),
                  pul: 70 + (rng.nextInt(40) - 20) - (i ~/ 8),
                ),
            ];
            return repo;
          },
          child: StatisticsScreen(),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('04-example_stats');
  });
}

class _MockRepo extends BloodPressureRepository {
  List<BloodPressureRecord> records = [];

  @override
  Future<void> add(BloodPressureRecord value) => throw UnimplementedError();

  @override
  Future<List<BloodPressureRecord>> get(DateRange range) async => records;

  @override
  Future<void> remove(BloodPressureRecord value) => throw UnimplementedError();

  @override
  Stream subscribe() => Stream.empty();
}

// Copy of app method
ThemeData _buildTheme(ColorScheme colorScheme) {
  final inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      width: 3,
      // Through black background outlineVariant has enough contrast.
      color: (colorScheme.brightness == Brightness.dark)
          ? colorScheme.outlineVariant
          : colorScheme.outline,
    ),
    borderRadius: BorderRadius.circular(20),
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 5,
      border: inputBorder,
      enabledBorder: inputBorder,
    ),
    scaffoldBackgroundColor: colorScheme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
