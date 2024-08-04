import '../../../cell/tile_cell.dart';
import '../../../cell/tile_cell_position.dart';
import '../../tile_dataset.dart';
import '../dataset_command.dart';

class UpdateEntryDatasetCommand<T> extends DatasetCommand<T> {
  UpdateEntryDatasetCommand({ required this.tableDataset, required this.oldEntry, required this.newEntry });

  final TileCell<T> oldEntry;
  final TileCell<T> newEntry;

  TileDataset<T> tableDataset;
  TileCellPosition? oldEntryLocation;
  T? oldEntryValue;

  @override
  Future<bool> execute() async {
    if (tableDataset.dataset.any((element) => element.cells.contains(oldEntry))) {
      oldEntryLocation = oldEntry.location;
      oldEntryValue = oldEntry.value;

      oldEntry.location = newEntry.location;
      oldEntry.value = newEntry.value;
      return true;
    }
    throw Exception('Entry no part of dataset');
  }

  @override
  bool get isUndoable => true;

  @override
  Future<bool> redo() {
   assertCanRedo();
    return execute();
  }

  @override
  Future<bool> undo() {
    assertCanUndo();
    return UpdateEntryDatasetCommand<T>(newEntry: oldEntry, oldEntry: newEntry, tableDataset: tableDataset).execute();
  }
}