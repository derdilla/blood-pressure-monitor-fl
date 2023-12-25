*developer documentation - users can safely ignore this*

## Goal

The goal of this style guideline is to make dart code maintainable and to reduce time spent on structuring code. If there is no way to write a specific piece of code that follows this style, feel free to propose changes and use more efficient style.

### File structure

- One class per file (exceptions: `StatefulWidget` and `sealed` classes).
- Widgets in the `components` directory don't require any `Provider` as an ancestor.
- Files with widgets that fill the whole screen are suffixed with either `_screen` or `_dialoge`. The corresponding widgets end in `Screen` or `Dialogue`
- Closely related files are grouped in a subdirectory

### Code

- 2 spaces indentation
- partially extract build to hidden methods where the main build method becomes hard to read