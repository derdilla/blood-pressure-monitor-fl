import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConvertUtil', () {
    test('parseBool should parse valid boolean correctly', () {
      expect(ConvertUtil.parseBool(true), true);
      expect(ConvertUtil.parseBool(false), false);
      expect(ConvertUtil.parseBool(1), true);
      expect(ConvertUtil.parseBool(1.0), true);
      expect(ConvertUtil.parseBool(0), false);
      expect(ConvertUtil.parseBool(0.0), false);
      expect(ConvertUtil.parseBool('true'), true);
      expect(ConvertUtil.parseBool('false'), false);
    });
    test('parseBool should parse invalid values as null', () {
      expect(ConvertUtil.parseBool('test'), null);
      expect(ConvertUtil.parseBool(132), null);
      expect(ConvertUtil.parseBool(-1), null);
      expect(ConvertUtil.parseBool({'test': 5}), null);
      expect(ConvertUtil.parseBool(null), null);
      expect(ConvertUtil.parseBool(1.1), null);
    });

    test('parseInt should parse valid values correctly', () {
      expect(ConvertUtil.parseInt(123), 123);
      expect(ConvertUtil.parseInt(534), 534);
      expect(ConvertUtil.parseInt(-1123), -1123);
      expect(ConvertUtil.parseInt(1.0), 1);
      expect(ConvertUtil.parseInt(0), 0);
      expect(ConvertUtil.parseInt('0'), 0);
      expect(ConvertUtil.parseInt('1321.0'), 1321);
      expect(ConvertUtil.parseInt('-1234'), -1234);
    });
    test('parseInt should parse invalid values as null', () {
      expect(ConvertUtil.parseInt('test'), null);
      expect(ConvertUtil.parseInt(true), null);
      expect(ConvertUtil.parseInt(1.2), null);
      expect(ConvertUtil.parseInt({'test': 5}), null);
      expect(ConvertUtil.parseInt(null), null);
      expect(ConvertUtil.parseInt('123test'), null);
    });

    test('parseDouble should parse valid values correctly', () {
      expect(ConvertUtil.parseDouble(123.123), 123.123);
      expect(ConvertUtil.parseDouble(534), 534.0);
      expect(ConvertUtil.parseDouble(-1123.543), -1123.543);
      expect(ConvertUtil.parseDouble(1.0), 1.0);
      expect(ConvertUtil.parseDouble(0.0), 0.0);
      expect(ConvertUtil.parseDouble('0'), 0.0);
      expect(ConvertUtil.parseDouble('1321.1234'), 1321.1234);
      expect(ConvertUtil.parseDouble('-1234.654'), -1234.654);
    });
    test('parseDouble should parse invalid values as null', () {
      expect(ConvertUtil.parseDouble('test'), null);
      expect(ConvertUtil.parseDouble(true), null);
      expect(ConvertUtil.parseDouble({'test': 5}), null);
      expect(ConvertUtil.parseDouble(null), null);
      expect(ConvertUtil.parseDouble('123test'), null);
      expect(ConvertUtil.parseDouble('1234.1234.1234'), null);
    });

    test('parseString should parse valid values correctly', () {
      expect(ConvertUtil.parseString('123.123'), '123.123');
      expect(ConvertUtil.parseString('dasdhjsadjka'), 'dasdhjsadjka');
      expect(ConvertUtil.parseString(123), '123');
      expect(ConvertUtil.parseString(true), 'true');
      expect(ConvertUtil.parseString(0.123), '0.123');
      expect(ConvertUtil.parseString('null'), 'null');
    });
    test('parseString should parse invalid values as null', () {
      expect(ConvertUtil.parseString(const Locale('test')), null);
      expect(ConvertUtil.parseString({'test': 5}), null);
    });

    test('parseMaterialColor should parse valid values correctly', () {
      expect(ConvertUtil.parseColor(Colors.deepOrange), Colors.deepOrange);
      expect(ConvertUtil.parseColor(Colors.grey)?.value, Colors.grey.value);
      expect(ConvertUtil.parseColor(Colors.grey.value)?.value, Colors.grey.value);
      expect(ConvertUtil.parseColor(Colors.deepOrange.value)?.value, Colors.deepOrange.value);
      expect(ConvertUtil.parseColor(0xff000000)?.value, 0xff000000);
      expect(ConvertUtil.parseColor('0x00ff0000')?.value, 0x00ff0000);
      expect(ConvertUtil.parseColor(const Color(0x00ff0000))?.value, 0x00ff0000);
    });
    test('parseMaterialColor should parse invalid values as null', () {
      expect(ConvertUtil.parseColor('test'), null);
      expect(ConvertUtil.parseString({'test': 5}), null);
    });

    test('parseLocale should not crash', () {
      expect(ConvertUtil.parseLocale(const Locale('test')), const Locale('test'));
      expect(ConvertUtil.parseLocale('DE'), const Locale('DE'));
      expect(ConvertUtil.parseLocale(15), null);
      expect(ConvertUtil.parseLocale(false), null);
      expect(ConvertUtil.parseLocale('123'), const Locale('123'));
    });
    test('parseLocale should return null for string "NULL"', () {
      expect(ConvertUtil.parseLocale('NULL'), null);
      expect(ConvertUtil.parseLocale('null'), null);
      expect(ConvertUtil.parseLocale('NuLl'), null);
    });

    test('parseList should convert valid values correctly', () {
      expect(ConvertUtil.parseList<int>([1234,567,89,0]), [1234,567,89,0]);
      expect(ConvertUtil.parseList<String>(['1234','567','89','0', 'test']), ['1234','567','89','0', 'test']);
      expect(ConvertUtil.parseList<String>(<dynamic>['1234','567','89','0', 'test']), ['1234','567','89','0', 'test']);
      expect(ConvertUtil.parseList<String>([]), []);
    });
    test('parseList should parse invalid values as null', () {
      expect(ConvertUtil.parseList<int>(['1234','567','89','0', 'test']), null);
      expect(ConvertUtil.parseList<String>({'test': 5}), null);
      expect(ConvertUtil.parseList<String>([1234,567,89,0]), null);
      expect(ConvertUtil.parseList<String>('tests'), null);
    });

    test('parseThemeMode should convert values correctly', () {
      expect(ConvertUtil.parseThemeMode(ThemeMode.system.serialize()), ThemeMode.system);
      expect(ConvertUtil.parseThemeMode(ThemeMode.dark.serialize()), ThemeMode.dark);
      expect(ConvertUtil.parseThemeMode(ThemeMode.light.serialize()), ThemeMode.light);
      expect(ConvertUtil.parseThemeMode(null), null);
    });
  });
}
