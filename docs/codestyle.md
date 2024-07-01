*developer documentation - users can safely ignore this*

# Code-style guideline

The goal of this style guideline is to make dart code maintainable and to reduce time spent on structuring code. If there is no way to write a specific piece of code that follows this style, feel free to propose changes and use more efficient style.

## Code structure structure

- One class per file (exceptions: `StatefulWidget` and `sealed` classes).
- Widgets in the `components` directory don't require any data repository as an ancestor.
- Files with widgets that fill the whole screen are suffixed with either `_screen` or `_dialoge`. The corresponding widgets end in `Screen` or `Dialoge`
- Closely related files are grouped in a subdirectory

### Top level directories

- `components`: Single purpose widgets that could be their own package
- `features`: UI and logic of app components that does the heavy lifting
- `screens`: Structure and layout of features
- `model`: logic shared by features or that hasn't been merged with its corresponding feature
- `data_util`: Builder widgets that provide access to data
- `platform_integration`: Bindings to native code
- `l10n`: localizations

## Code

- 2 spaces indentation
- partially extract build to hidden methods where the main build method becomes hard to read
- Try to create useful documentation for every method / class you create. In case you find yourself looking at a methods source code to figure out a particular aspect of it, add that information to the documentation.
- Avoid using `Navigator.of` and prefer calling `Navigator.pop` and `Navigator.push` directly  

Refer to [effective dart](https://dart.dev/effective-dart) for inspiration in case you find yourself spending too much time making style decisions.