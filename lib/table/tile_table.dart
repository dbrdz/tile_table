import 'package:colonel/integration_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tile_table/cell/tile_cell.dart';
import 'package:tile_table/cell/tile_cell_position.dart';
import 'package:tile_table/column/tile_column.dart';
import '../serializers/value_serializers.dart';

class TileTable<T> with CommandMixin {
  TileTable({
    required this.name,
    required this.columns,
    required this.cells,
  });

  @override
  String name;

  @override
  List<TileCell<T>> cells = [];

  @override
  List<TileColumn> columns = [];

  BehaviorSubject stream = BehaviorSubject();

  @override
  void expandCell(TileCell cell) {
    cell.location = TileCellPosition(start: 0, size: columns.length);
  }

  @override
  void expandCellLeft(TileCell cell) {
    int currentCellSize = cell.location.size;
    int startingPoint = cell.location.start;
    if (startingPoint >= 1) {
      cell.location = TileCellPosition(start: cell.location.start - 1, size: currentCellSize + 1);
    }
  }

  @override
  void expandCellRight(TileCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize < columns.length) {
      cell.location = TileCellPosition(start: cell.location.start, size: currentCellSize + 1);
    }
  }

  @override
  List<TileCell<T>> getCellsByStartingPoint(int startingPoint) {
    return cells.where((element) => element.location.start == startingPoint)
        .toList();
  }

  @override
  void mergeCells(TileCell cell1, TileCell cell2) {
    if (!cell1.location.overlaps(cell2.location) && !cell1.location.isAdjacentTo(cell2.location)) {
      throw Exception("Cells are not right next to each other");
    }

    int newStartingPoint = cell1.location.start < cell2.location.start
        ? cell1.location.start
        : cell2.location.start;

    int newEndingPoint = cell2.location.end > cell1.location.start
      ? cell2.location.end
      : cell2.location.end;

    int newSize = newEndingPoint - newStartingPoint;

    cell1.location = TileCellPosition(start: newStartingPoint, size: newSize);
    cell2.location = TileCellPosition(start: newStartingPoint, size: newSize);
  }

  @override
  void collapseCellLeft(TileCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize > 1) {
      cell.location = TileCellPosition(start: cell.location.start, size: currentCellSize - 1);
    }
  }

  @override
  void collapseCellRight(TileCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize > 1) {
      cell.location = TileCellPosition(start: cell.location.start + 1, size: currentCellSize - 1);
    }
  }

  @override
  void splitCell(TileCell cell) {
    int cellSize = cell.location.size;
    for (int i = 0; i < cellSize; i++) {
      cells.add(
        TileCell(value: cell.value, location: TileCellPosition(start: cell.location.start + i, size: 1))
      );
    }
  }

  @override
  void addEntry(TileCell<T> entry) {
    commandRx.add(null);
    cells.add(entry);
  }

  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "name": name,
    "columns": columns.map((e) => e.toJson()).toList(),
    "cells": cells.map((e) => e.toJson(valueSerializer)).toList(),
  };

  static TileTable<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return TileTable<T>(
      name: json["name"],
      columns: json["columns"].map<TileColumn>((e) => TileColumn.fromJson(e)).toList(),
      cells: (json["cells"] as Iterable<dynamic>).map<TileCell<T>>((e) => TileCell.fromJson<T>(e, valueDeserializer)).toList()
    );
  }

  @override
  void removeEntry(TileCell<T> entry) {
    cells.remove(entry);
  }

  @override
  ValueDeserializer get deserializer => throw UnimplementedError();

  @override
  ValueSerializer get serializer => throw UnimplementedError();
}