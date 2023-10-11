*developer documentation - users can safely ignore this*

### Used compressions

Blood pressure monitor uses dart code obfuscation to effectively reduce the app size by 2-3 MB from v1.5.6 onwards.

For reading stack traces of and error messages use the debug symbol files from the github release and follow [the flutter docs](https://docs.flutter.dev/deployment/obfuscate#read-an-obfuscated-stack-trace).

Unused icons are shaken from the font during release compilation.

### Ineffective compressions

- Pro guard rules are not important as flutter already uses R8.
- `android.enableR8.fullMode=true` has no effect, although further R8 configuration can be investigated.
- Using the old apk behavior of compressing native libraries shows no to little improvements and is worse for Google play distribution.