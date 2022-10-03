import 'package:colonel/integration_mixin.dart';

import '../cell/i_jcell.dart';
import '../column/i_jcolumn.dart';
import '../serializers/value_serializers.dart';
import '../table/i_tile_jtable.dart';

abstract class ITileDataset<T> with RedoableMixin {
  String get name;
  List<IJTileTable<T>> get dataset;
  List<IJColumn> get columns;
  List<IJCell<T>> getCellsByStartingPoint(int startingPoint);

  void addEntry(int tableIndex, IJCell<T> entry);
  int removeEntry(IJCell<T> cell);

  // /// To merge two cells, they have to be right next to each other
  // /// or overlap. If there is any distance in the x-axis between the two cells
  // /// then they can't be merged.
  // void mergeCells(IJCell<T> cell1, IJCell<T> cell2);

  /// A cell can be split into multiple cells if the size of the cell is larger
  /// than 1.
  // void splitCell(IJCell<T> cell);
  void expandCell(IJCell<T> cell);
  void expandCellRight(IJCell<T> cell);
  void expandCellLeft(IJCell<T> cell);

  void collapseCellLeft(IJCell<T> cell);
  void collapseCellRight(IJCell<T> cell);

  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer);
}