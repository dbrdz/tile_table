import 'package:colonel/command_base.dart';
import 'package:colonel/command_exceptions.dart';

import '../../../cell/tile_cell.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';

class MoveSelectionRightDatasetCommand extends DatasetCommand {

  MoveSelectionRightDatasetCommand({ required this.tableDataset, required this.selectedCells });

  final List<TileCell> selectedCells;
  TileDataset tableDataset;

  @override
  Future<bool> execute() {
    assertCanExecute();
    int columnCount = tableDataset.columns.length;
    for (var cell in selectedCells) {
      if (cell.location.end < columnCount) {
        cell.moveRight();
      }
    }
    executionState = ExecutionState.executed;
    return Future.value(true);
  }

  @override
  bool get isUndoable => true;

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
    assertCanUndo();
    for (var cell in selectedCells) {
      cell.moveLeft();
    }
    executionState = ExecutionState.undone;
    return Future.value(true);
  }
}