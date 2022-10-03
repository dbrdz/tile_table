import 'package:colonel/command_exceptions.dart';

import '../../../cell/i_jcell.dart';
import '../../i_tile_dataset.dart';
import '../i_j_dataset_command.dart';

class MoveSelectionRightDatasetCommand extends IJDatasetCommand {

  MoveSelectionRightDatasetCommand({ required this.selectedCells });

  final List<IJCell> selectedCells;
  ITileDataset? _cachedDataset;

  @override
  Future<bool> execute(ITileDataset element) {
    _cachedDataset = element;
    int columnCount = element.columns.length;
    for (var cell in selectedCells) {
      if (cell.location.end < columnCount) {
        cell.moveRight();
      }
    }
    return Future.value(true);
  }

  @override
  bool get isUndoable => true;

  @override
  Future<bool> redo() {
    if (_cachedDataset != null) {
      return execute(_cachedDataset!);
    }
    throw CommandRedoException();
  }

  @override
  Future<bool> undo() {
    if (_cachedDataset != null) {
      for (var cell in selectedCells) {
        cell.moveLeft();
      }
      return Future.value(true);
    }
    throw CommandUndoException();
  }
}