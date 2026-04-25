Builds settings classes from specification. This helps reduce errors introduced through manually repeated code.

## Usage

```dart
@GenerateSettings
class _SettingsSpec {
  final dateFormatString = Setting<String>(initialValue: 'yyyy-MM-dd HH:mm');

  final graphLineThickness = Setting<double>(initialValue: 3);

  final animationSpeed = Setting<int>(initialValue: 150);
}
```

For more examples see the existing [settings](../app/lib/model/storage) in the app.
