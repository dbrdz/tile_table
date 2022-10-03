import 'package:colonel/command_exceptions.dart';

import '../../../cell/i_jcell.dart';
import '../../i_tile_dataset.dart';
import '../i_j_dataset_command.dart';

class ExpandSelectionDatasetCommand extends IJDatasetCommand {

  ExpandSelectionDatasetCommand({ required this.selectedCells });

  final List<IJCell> selectedCells;
  ITileDataset? _cachedDataset;

  @override
  Future<bool> execute(ITileDataset element) {
    _cachedDataset = element;
    for (var cell in selectedCells) {
      element.expandCellRight(cell);
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
        _cachedDataset!.collapseCellLeft(cell);
      }
      return Future.value(true);
    }
    throw CommandUndoException();
  }
}