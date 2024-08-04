import 'package:colonel/command_base.dart';
import 'package:colonel/command_exceptions.dart';

import '../../../cell/tile_cell.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';

class DeleteEntryDatasetCommand extends DatasetCommand {
  DeleteEntryDatasetCommand({ required this.tableDataset, required this.entry });

  final TileCell entry;
  int? removedFrom; /// The index of the table that the cell was removed from.
  TileDataset tableDataset;

  @override
  Future<bool> execute() {
    assertCanExecute();
    removedFrom = tableDataset.removeEntry(entry);
    executionState = ExecutionState.executed;
    return Future.value(true);
  }

  @override
  bool get isUndoable => throw UnimplementedError();

  @override
  Future<bool> redo() {
    assertCanRedo();
    return execute().then((value) {
      executionState = ExecutionState.redone;
      return value;
    });
  }

  @override
  Future<bool> undo() {
    if (tableDataset != null) {
      tableDataset!.addEntry(removedFrom!, entry);
      return Future.value(true);
    }
    throw CommandUndoException();
  }
}