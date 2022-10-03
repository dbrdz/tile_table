import '../cell/i_jcell.dart';
import '../column/i_jcolumn.dart';
import '../column/jcolumn.dart';
import '../serializers/value_serializers.dart';
import '../table/i_tile_jtable.dart';
import '../table/j_tile_table.dart';
import 'i_tile_dataset.dart';

class JTileDataset<T> extends ITileDataset<T>  {
  JTileDataset({ required this.name, required this.dataset, required this.columns });

  @override
  String name;

  @override
  List<IJTileTable<T>> dataset;

  @override
  List<IJColumn> columns;

  @override
  void addEntry(int tableIndex, IJCell<T> entry) {
    dataset[tableIndex].addEntry(entry);
  }

  @override
  void collapseCellLeft(IJCell<T> cell) {
    cell.shrink();
  }

  @override
  void collapseCellRight(IJCell<T> cell) {
    if (cell.location.end < columns.length) {
      cell.moveRight();
      cell.shrink();
    }
  }

  @override
  void expandCell(IJCell cell) {
    int newSize = columns.length;
    cell.setSize(newSize);
    cell.setStart(0);
  }

  @override
  void expandCellLeft(IJCell cell) {
    cell.moveLeft();
  }

  @override
  void expandCellRight(IJCell cell) {
    if (cell.location.end < columns.length) {
      cell.grow();
    }
  }

  @override
  List<IJCell<T>> getCellsByStartingPoint(int startingPoint) {
    return dataset.expand((element) => element.cells)
      .where((element) => element.location.size == startingPoint)
      .toList();
  }

  void splitCell(int tableIndex, IJCell cell) => throw UnimplementedError();
  
  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "name": name,
    "dataset": dataset.map((e) => e.toJson(valueSerializer)).toList(),
    "columns": columns.map((e) => e.toJson()).toList()
  };

  static JTileDataset<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return JTileDataset<T>(
        name: json["name"],
        dataset: (json["dataset"] as List<dynamic>).map<IJTileTable<T>>((e) => JTileTable.fromJson<T>(e, valueDeserializer)).toList(),
        columns: (json["columns"] as List<dynamic>).map((e) => JColumn.fromJson(e)).toList());
  }

  @override
  int removeEntry(IJCell<T> cell) {
    IJTileTable<T> table = dataset.firstWhere((element) => element.cells.contains(cell));
    table.removeEntry(cell);
    return dataset.indexOf(table);
  }
}