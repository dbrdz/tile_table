import 'package:colonel/command_exceptions.dart';
import 'package:tile_table/dataset/i_tile_dataset.dart';

import '../../../cell/i_jcell.dart';
import '../i_j_dataset_command.dart';

class UpdateEntryDatasetCommand<T> extends IJDatasetCommand<T> {
  UpdateEntryDatasetCommand({ required this.oldEntry, required this.newEntry });

  final IJCell<T> oldEntry;
  final IJCell<T> newEntry;

  ITileDataset<T>? _cachedDataset;

  JPosition? oldEntryLocation;
  T? oldEntryValue;

  @override
  Future<bool> execute(ITileDataset<T> element) async {
    _cachedDataset = element;
    if (element.dataset.any((element) => element.cells.contains(oldEntry))) {
      oldEntryLocation = oldEntry.location;
      oldEntryValue = oldEntry.value;

      oldEntry.location = newEntry.location;
      oldEntry.value = newEntry.value;
      return true;
    }
    throw Exception('Entry no part of dataset');
  }

  @override
  bool get isUndoable => true;

  @override
  Future<bool> redo() {
    if (_cachedDataset == null) {
      throw CommandRedoException();
    }
    return execute(_cachedDataset!);
  }

  @override
  Future<bool> undo() {
    if (_cachedDataset == null) {
      throw CommandUndoException();
    }
    return UpdateEntryDatasetCommand<T>(newEntry: oldEntry, oldEntry: newEntry).execute(_cachedDataset!);
  }
}