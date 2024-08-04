import 'package:colonel/command_base.dart';
import 'package:tile_table/table/tile_table.dart';
import '../../cell/tile_cell.dart';
import 'tile_table_command.dart';

class ExpandSelectionCommand extends TileTableCommand {
  ExpandSelectionCommand({ required this.selectedCells, required this.table });

  final List<TileCell> selectedCells;
  final TileTable table;

  @override
  Future<bool> execute() {
    assertCanExecute();
    for (var cell in selectedCells) {
      table.expandCellRight(cell);
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
      table.collapseCellLeft(cell);
    }
    executionState = ExecutionState.undone;
    return Future.value(true);
  }

}