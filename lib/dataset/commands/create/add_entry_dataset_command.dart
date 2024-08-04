import 'package:colonel/command_base.dart';
import 'package:colonel/command_exceptions.dart';

import '../../../cell/tile_cell.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';

class AddEntriesDatasetCommand<T> extends DatasetCommand<T> {
  AddEntriesDatasetCommand({ required this.tableDataset, required this.entries, required this.index });

  final List<TileCell<T>> entries;
  final int index;
  TileDataset<T> tableDataset;

  @override
  Future<bool> execute() {
    if (index < tableDataset.dataset.length && index >= 0) {
      return Future(() {
        for (var entry in entries) {
          tableDataset.dataset[index].addEntry(entry);
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
    if (tableDataset == null) {
      throw CommandRedoException();
    }
    return execute().then((value) {
      executionState = ExecutionState.redone;
      return value;
    });
  }

  @override
  Future<bool> undo() {
    assertCanUndo();
    if (index < tableDataset!.dataset.length && index >= 0) {
      return Future(() {
        for (var entry in entries) {
          tableDataset!.dataset[index].removeEntry(entry);
        }
        return true;
      });
    }
    executionState = ExecutionState.undone;
    throw Exception("No table with index $index exists");
  }
}
