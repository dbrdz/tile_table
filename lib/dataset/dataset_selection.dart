import '../cell/tile_cell.dart';

class DatasetSelection {
  DatasetSelection({ required this.selectedCells });

  /// This selected cell list represents the selected cells for all tables
  /// in the dataset. The index of each list matches the index of the tables in
  /// the dataset.
  List<List<TileCell>> selectedCells;

  void addToSelection(int table, TileCell cell) {
    selectedCells[table].add(cell);
  }

  void clearSelection() {
    for (List<TileCell> tableSelection in selectedCells) {
      tableSelection.clear();
    }
  }

  void select(int tableIndex, TileCell cell) {
    clearSelection();
    selectedCells[tableIndex].add(cell);
  }
}