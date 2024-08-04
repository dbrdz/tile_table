import 'package:colonel/integration_mixin.dart';

import '../cell/tile_cell.dart';
import '../cell/tile_cell_position.dart';
import '../column/tile_column.dart';
import '../serializers/value_serializers.dart';
import '../table/tile_table.dart';

class TileDataset<T> with CommandMixin {
  TileDataset({ required this.name, required this.dataset, required this.columns });

  @override
  String name;

  @override
  List<TileTable<T>> dataset;

  @override
  List<TileColumn> columns;

  @override
  void addEntry(int tableIndex, TileCell<T> entry) {
    dataset[tableIndex].addEntry(entry);
  }

  @override
  void collapseCellLeft(TileCell<T> cell) {
    cell.shrink();
  }

  @override
  void collapseCellRight(TileCell<T> cell) {
    if (cell.location.end < columns.length) {
      cell.moveRight();
      cell.shrink();
    }
  }

  @override
  void expandCell(TileCell cell) {
    int newSize = columns.length;
    cell.setSize(newSize);
    cell.setStart(0);
  }

  @override
  void expandCellLeft(TileCell cell) {
    cell.moveLeft();
  }

  @override
  void expandCellRight(TileCell cell) {
    if (cell.location.end < columns.length) {
      cell.grow();
    }
  }

  @override
  List<TileCell<T>> getCellsByStartingPoint(int startingPoint) {
    return dataset.expand((element) => element.cells)
      .where((element) => element.location.contains(TileCellPosition(start: startingPoint, size: 1)))
      .toList();
  }

  void splitCell(int tableIndex, TileCell cell) => throw UnimplementedError();
  
  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "name": name,
    "dataset": dataset.map((e) => e.toJson(valueSerializer)).toList(),
    "columns": columns.map((e) => e.toJson()).toList()
  };

  static TileDataset<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return TileDataset<T>(
        name: json["name"],
        dataset: (json["dataset"] as List<dynamic>).map<TileTable<T>>((e) => TileTable.fromJson<T>(e, valueDeserializer)).toList(),
        columns: (json["columns"] as List<dynamic>).map((e) => TileColumn.fromJson(e)).toList());
  }

  @override
  int removeEntry(TileCell<T> cell) {
    TileTable<T> table = dataset.firstWhere((element) => element.cells.contains(cell));
    table.removeEntry(cell);
    return dataset.indexOf(table);
  }
}