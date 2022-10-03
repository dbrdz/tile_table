import '../cell/i_jcell.dart';

class DatasetSelection {
  DatasetSelection({ required this.selectedCells });

  /// This selected cell list represents the selected cells for all tables
  /// in the dataset. The index of each list matches the index of the tables in
  /// the dataset.
  List<List<IJCell>> selectedCells;

  void addToSelection(int table, IJCell cell) {
    selectedCells[table].add(cell);
  }

  void clearSelection() {
    for (List<IJCell> tableSelection in selectedCells) {
      tableSelection.clear();
    }
  }

  void select(int tableIndex, IJCell cell) {
    clearSelection();
    selectedCells[tableIndex].add(cell);
  }
}