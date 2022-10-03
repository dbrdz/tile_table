import 'package:colonel/command_exceptions.dart';

import '../../../cell/i_jcell.dart';
import '../../i_tile_dataset.dart';
import '../i_j_dataset_command.dart';

class DeleteEntryDatasetCommand extends IJDatasetCommand {
  DeleteEntryDatasetCommand({ required this.entry });

  final IJCell entry;
  int? removedFrom; /// The index of the table that the cell was removed from.
  ITileDataset? cachedDataset;

  @override
  Future<bool> execute(ITileDataset element) {
    cachedDataset = element;
    removedFrom = element.removeEntry(entry);
    return Future.value(true);
  }

  @override
  // TODO: implement isUndoable
  bool get isUndoable => throw UnimplementedError();

  @override
  Future<bool> redo() {
    if (cachedDataset != null) {
      execute(cachedDataset!);
      return Future.value(true);
    }
    throw CommandRedoException();
  }

  @override
  Future<bool> undo() {
    if (cachedDataset != null) {
      cachedDataset!.addEntry(removedFrom!, entry);
      return Future.value(true);
    }
    throw CommandUndoException();
  }
}