import 'package:colonel/command_base.dart';
import '../../../cell/tile_cell.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';
import 'move_selection_to_next_set.dart';

class MoveSelectionToPreviousSet extends DatasetCommand {

  MoveSelectionToPreviousSet({ required this.tableDataset, required this.selectedCells });

  final List<TileCell> selectedCells;
  int? tableIndex;
  TileDataset tableDataset;

  @override
  Future<bool> execute() {
    assertCanExecute();
    return Future(() {
      for (var cell in selectedCells) {
        tableIndex = tableDataset.dataset.indexWhere((element) => element.cells.contains(cell));
        if (tableIndex! > 0){
          tableDataset.dataset[tableIndex!].removeEntry(cell);
          tableDataset.dataset[tableIndex! - 1].addEntry(cell);
        }
      }
      executionState = ExecutionState.executed;
      return true;
    });
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
    return MoveSelectionToNextSet(tableDataset: tableDataset, selectedCells: selectedCells).execute().then((value) {
      executionState = ExecutionState.undone;
      return value;
    });
  }
}