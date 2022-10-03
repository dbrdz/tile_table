import 'package:colonel/integration_mixin.dart';

import '../cell/i_jcell.dart';
import '../column/i_jcolumn.dart';
import '../serializers/value_serializers.dart';

abstract class IJTileTable<T> with RedoableMixin {
  String get name;
  List<IJCell<T>> get cells;
  List<IJColumn> get columns;
  ValueSerializer get serializer;
  ValueDeserializer get deserializer;

  List<IJCell<T>> getCellsByStartingPoint(int startingPoint);

  void addEntry(IJCell<T> entry);
  void removeEntry(IJCell<T> entry);

  /// To merge two cells, they have to be right next to each other
  /// or overlap. If there is any distance in the x-axis between the two cells
  /// then they can't be merged.
  void mergeCells(IJCell cell1, IJCell cell2);

  /// A cell can be split into mulitple cells if the size of the cell is larger
  /// than 1.
  void splitCell(IJCell cell);
  void expandCell(IJCell cell);
  void expandCellRight(IJCell cell);
  void expandCellLeft(IJCell cell);

  void collapseCellLeft(IJCell cell);
  void collapseCellRight(IJCell cell);

  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer);
}