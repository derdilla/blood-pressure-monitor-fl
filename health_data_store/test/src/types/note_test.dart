import 'package:health_data_store/src/types/note.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final time = DateTime.now();
    final note = Note(
      time: time,
      note: 'testNote',
      color: 0xFF42A5F5,
    );
    expect(note.time, equals(time));
    expect(note.color, equals(0xFF42A5F5));
    expect(note.note, equals('testNote'));
    expect(note, equals(Note(
      time: time,
      note: 'testNote',
      color: 0xFF42A5F5,
    )));
  });
}

Note mockNote({
  int? time,
  String? note,
  int? color,
}) => Note(
  time: time!=null ? DateTime.fromMillisecondsSinceEpoch(time) : DateTime.now(),
  note: note,
  color: color,
);
