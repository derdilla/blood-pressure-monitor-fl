import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/iso_lang_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should have unique names for all languages provided in localizations', () {
    final allNames = <String>[];
    for (final locale in AppLocalizations.supportedLocales) {
      final name = getDisplayLanguage(locale);
      expect(allNames, isNot(contains(name)));
      allNames.add(name);
    }
  });
  test('should start all names in upper case', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final firstChar = getDisplayLanguage(locale)[0];
      expect(firstChar, equals(firstChar.toUpperCase()));
    }
  });
  test('should not store names where no localization present', () {
    final tmp = debugPrint;
    int printCounts = 0;
    debugPrint = (String? s, {int? wrapWidth}) {
      printCounts += 1;
    };
    for (final c1 in 'abcdefghijklmnopqrstuvwxyz'.characters) {
      for (final c2 in 'abcdefghijklmnopqrstuvwxyz'.characters) {
        if (AppLocalizations.supportedLocales.where(
            (e) => e.toLanguageTag() == '$c1$c2',).isNotEmpty) {
          continue;
        }
        expect(() => getDisplayLanguage(Locale('$c1$c2')),
          throwsAssertionError,
          reason: 'Lang $c1$c2 does not exist'
        );
        expect(printCounts, greaterThan(1));
        printCounts = 0;
      }
    }
    debugPrint = tmp;
  });
}
