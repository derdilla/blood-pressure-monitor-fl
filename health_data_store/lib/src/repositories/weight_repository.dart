import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/repositories/repository.dart';
import 'package:health_data_store/src/types/note.dart';

/// Repository for accessing [Note]s stored in a [DatabaseManager] managed db.
abstract class NoteRepository extends Repository<Note> {}
