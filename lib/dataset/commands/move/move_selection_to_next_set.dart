import 'package:colonel/command_exceptions.dart';

import '../../../cell/i_jcell.dart';
import '../../i_tile_dataset.dart';
import '../i_j_dataset_command.dart';
import 'move_selection_to_previous_set.dart';

class MoveSelectionToNextSet extends IJDatasetCommand {

  MoveSelectionToNextSet({ required this.selectedCells });

  final List<IJCell> selectedCells;
  int? tableIndex;
  ITileDataset? _cachedDataset;

  @override
  Future<bool> execute(ITileDataset element) {
    return Future(() {
      _cachedDataset = element;
      for (var cell in selectedCells) {
        tableIndex = element.dataset.indexWhere((element) => element.cells.contains(cell));
        if (tableIndex! < (element.dataset.length - 1)){
          element.dataset[tableIndex!].removeEntry(cell);
          element.dataset[tableIndex! + 1].addEntry(cell);
        }
      }
      return true;
    });
  }

  @override
  bool get isUndoable => true;

  @override
  Future<bool> redo() {
    if (_cachedDataset != null) {
      execute(_cachedDataset!);
    }
    throw CommandRedoException();
  }

  @override
  Future<bool> undo() {
    if (_cachedDataset != null) {
      MoveSelectionToPreviousSet(selectedCells: selectedCells).execute(_cachedDataset!);
    }

    throw CommandUndoException();
  }

}