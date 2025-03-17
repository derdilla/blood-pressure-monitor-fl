import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';

/// Supporting information left by the enduser.
@freezed
class Note with _$Note {
  /// Create supporting information from the enduser.
  const factory Note({
    /// Timestamp when the note was taken.
    required DateTime time,

    /// Content of the note.
    String? note,

    /// ARGB color in number format.
    ///
    /// Can also be obtained through the `Colors.toARGB32()` method in `dart:ui`.
    /// Sample value: `0xFF42A5F5`
    int? color,
  }) = _Notes;
}
