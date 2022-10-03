import 'package:colonel/command_exceptions.dart';

import '../../../cell/i_jcell.dart';
import '../../i_tile_dataset.dart';
import '../i_j_dataset_command.dart';

class AddEntriesDatasetCommand extends IJDatasetCommand {

  AddEntriesDatasetCommand({ required this.entries, required this.index });

  final List<IJCell> entries;
  final int index;

  ITileDataset? _cachedDataset;

  @override
  Future<bool> execute(ITileDataset element) {
    _cachedDataset = element;
    if (index < element.dataset.length && index >= 0) {
      return Future(() {
        for (var entry in entries) {
          element.dataset[index].addEntry(entry);
        }
        return true;
      });
    }
    throw Exception("No table with index $index exists");
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

    if (index < _cachedDataset!.dataset.length && index >= 0) {
      return Future(() {
        for (var entry in entries) {
          _cachedDataset!.dataset[index].removeEntry(entry);
        }
        return true;
      });
    }

    throw Exception("No table with index $index exists");
  }
}