import 'package:colonel/command_exceptions.dart';

import '../../cell/i_jcell.dart';
import '../i_tile_jtable.dart';
import 'i_j_tile_table_command.dart';

class ExpandSelectionCommand extends IJTileTableCommand {
  ExpandSelectionCommand({ required this.selectedCells });

  final List<IJCell> selectedCells;
  IJTileTable? _table;

  @override
  Future<bool> execute(IJTileTable element) {
    _table = element;
    for (var cell in selectedCells) {
      element.expandCellRight(cell);
    }
    return Future.value(true);
  }

  @override
  bool get isUndoable => true;

  @override
  Future<bool> redo() {
    if (_table != null) {
      return execute(_table!);
    }
    throw CommandRedoException();
  }

  @override
  Future<bool> undo() {
    if (_table != null) {
      for (var cell in selectedCells) {
        _table!.collapseCellLeft(cell);
      }
      return Future.value(true);
    }
    throw CommandUndoException();
  }

}