import 'package:colonel/command_base.dart';
import '../../../cell/tile_cell.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';

class MoveSelectionLeftDatasetCommand extends DatasetCommand {

  MoveSelectionLeftDatasetCommand({ required this.tableDataset, required this.selectedCells });

  final List<TileCell> selectedCells;
  TileDataset? tableDataset;

  @override
  Future<bool> execute() {
    assertCanExecute();
    for (var cell in selectedCells) {
      cell.moveLeft();
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
      cell.moveRight();
    }
    executionState = ExecutionState.undone;
    return Future.value(true);
  }
}
