import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:settings_annotation/src/annotations.dart';
import 'package:source_gen/source_gen.dart';


// TODO: handle nested changeNotifiers

Builder modelLibraryBuilder(BuilderOptions options) =>
    LibraryBuilder(ModelGenerator(), generatedExtension: '.store.dart');

class ModelGenerator extends Generator {
  const ModelGenerator();

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    // Get the settings type exposed by this package
    final settingTypeLibrary = await buildStep.resolver
        .libraryFor(AssetId.resolve(Uri.parse('package:settings_annotation/src/setting.dart')));
    final settingType = settingTypeLibrary.exportNamespace.get2('Setting') as InterfaceElement;

    final flutterFoundationLibrary = await buildStep.resolver
        .libraryFor(AssetId.resolve(Uri.parse('package:flutter/foundation.dart')));
    final changeNotifierType = flutterFoundationLibrary.exportNamespace.get2('ChangeNotifier') as InterfaceElement;

    // Class analysis
    final generateSettingsTypeChecker = TypeChecker.typeNamed(GenerateSettings);
    final classes = library.annotatedWith(generateSettingsTypeChecker);
    if (classes.isEmpty) return null;

    final out = <String>["part of '${library.element.uri}';"];

    for (final annotatedClassElement in classes) {
      assert(annotatedClassElement.element.kind == ElementKind.CLASS);
      final classElement = annotatedClassElement.element as ClassElement;

      if (!classElement.isConstructable) {
        throw "Can't instantiate class ${classElement.name}";
      }

      String name = classElement.name!;
      if (name.endsWith('Spec')) {
        name = name.substring(0, name.length - 4);
      }
      if (name.startsWith('_')) {
        name = name.substring(1, name.length);
      }
      final newClassName = name;
      out.add(
        'class $newClassName with ChangeNotifier {',
      );

      final classVariables = <_Variable>[];
      for (final fieldFragment in classElement.fields) {
        // Skip elements not intended as variables
        if (!fieldFragment.isPublic) continue;
        if (fieldFragment.getter == null) continue;
        if (fieldFragment.name == null) continue;

        final instanceType = fieldFragment.type.asInstanceOf(settingType);
        if (instanceType == null) continue;

        final outerType = fieldFragment.type;
        final innerType = instanceType.typeArguments.first;
        final varName = fieldFragment.name!;
        final comment = fieldFragment.documentationComment;
        final isChangeNotifier = fieldFragment.type
            .asInstanceOf(changeNotifierType) != null;

        classVariables.add(
          _Variable(
            innerType: innerType,
            outerType: outerType,
            name: varName,
            comment: comment,
            isChangeNotifier: isChangeNotifier,
          ),
        );
      }

      // constructor
      out.add('$newClassName({');
      for (final v in classVariables) {
        out.add('${v.nullableType} ${v.name},');
      }
      out.add('}) {');
      out.add('final defaultValues = ${classElement.name}();');
      for (final v in classVariables) {
        out.add('_${v.name} = defaultValues.${v.name};');
        out.add('_${v.name}.addListener(notifyListeners);');
        out.add('if (${v.name} != null) _${v.name}.value = ${v.name};');
      }
      out.add('}');
      out.add('');

      // deserialization factories
      out.add('/// Create a instance from a map created by [toMap].');
      out.add('factory $newClassName.fromMap(Map<String, dynamic> map) {');
      out.add('final n = $newClassName();');
      for (final v in classVariables) {
        out.add(
          "n._${v.name}.fromMapValue(map['${v.name}']);",
        );
      }
      out.add('return n;');
      out.add('}');
      out.add('');

      out.add('''
      /// Create a instance from a [String] created by [toJson].
      factory $newClassName.fromJson(String json) {
        try {
          return $newClassName.fromMap(jsonDecode(json));
        } catch (e) {
          assert(e is FormatException || e is TypeError);
          return $newClassName();
        }
      }
      ''');
      out.add('');

      // serialization
      out.add('/// Serialize the object to a restoreable map.');
      out.add('Map<String, dynamic> toMap() => <String, dynamic>{');
      for (final v in classVariables) {
        out.add("'${v.name}': _${v.name}.toMapValue(),");
      }
      out.add('};');
      out.add('');

      out.add('/// Serialize the object to a restoreable string.');
      out.add('String toJson() => jsonEncode(toMap());');
      out.add('');

      // helpers
      out.add('/// Copy all values from another instance.');
      out.add('void copyFrom($newClassName other) {');
      for (final v in classVariables) {
        // TODO: clone special types
        out.add('_${v.name} = other._${v.name};');
      }
      out.add('notifyListeners();');
      out.add('}');
      out.add('');

      out.add('/// Reset all fields to their default values.');
      out.add('void reset() => copyFrom($newClassName());');
      out.add('');

      out.add('@override');
      out.add('void dispose() {');
      for (final v in classVariables) {
        out.add('_${v.name}.dispose();');
      }
      out.add('super.dispose();');
      out.add('}');
      out.add('');


      // variables
      for (final v in classVariables) {
        out.add('late ${v.outerType} _${v.name};');
        if (v.comment != null) {
          out.add('${v.comment}');
        }
        out.add('${v.innerType} get ${v.name} => _${v.name}.value;');
        out.add('set ${v.name}(${v.innerType} v) => _${v.name}.value = v;');
        out.add('');
      }

      // ui
      out.add('late final uiElements = <Setting>[');
      for (final v in classVariables) {
        out.add('_${v.name},');
      }
      out.add('];');

      out.add('}'); // class $nameImpl
    }

    return out.join('\n');
  }
}

class _Variable {
  const _Variable({
    required this.innerType,
    required this.outerType,
    required this.name,
    required this.comment,
    required this.isChangeNotifier,
  });

  /// Type of the stored value.
  final DartType innerType;

  /// Type of the [Setting] object storing the value.
  final DartType outerType;

  final String name;

  final String? comment;

  final bool isChangeNotifier;

  String get nullableType =>
      '$innerType'
          '${(innerType.nullabilitySuffix == NullabilitySuffix.none) ? "?" : ""}';

  String get nonNullableType {
    final typeStr = innerType.toString();
    if (innerType.nullabilitySuffix == NullabilitySuffix.none) return typeStr;
    return typeStr.substring(0, typeStr.length - 1);
  }
}
