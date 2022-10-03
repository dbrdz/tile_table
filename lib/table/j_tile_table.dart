import 'package:rxdart/rxdart.dart';

import '../cell/i_jcell.dart';
import '../cell/j_cell.dart';
import '../column/i_jcolumn.dart';
import '../column/jcolumn.dart';
import '../serializers/value_serializers.dart';
import 'i_tile_jtable.dart';

class JTileTable<T> extends IJTileTable<T> {
  JTileTable({
    required this.name,
    required this.columns,
    required this.cells,
  });

  @override
  String name;

  @override
  List<IJCell<T>> cells = [];

  @override
  List<IJColumn> columns = [];

  BehaviorSubject stream = BehaviorSubject();

  @override
  void expandCell(IJCell cell) {
    cell.location = JPosition(start: 0, size: columns.length);
  }

  @override
  void expandCellLeft(IJCell cell) {
    int currentCellSize = cell.location.size;
    int startingPoint = cell.location.start;
    if (startingPoint >= 1) {
      cell.location = JPosition(start: cell.location.start - 1, size: currentCellSize + 1);
    }
  }

  @override
  void expandCellRight(IJCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize < columns.length) {
      cell.location = JPosition(start: cell.location.start, size: currentCellSize + 1);
    }
  }

  @override
  List<IJCell<T>> getCellsByStartingPoint(int startingPoint) {
    return cells.where((element) => element.location.start == startingPoint)
        .toList();
  }

  @override
  void mergeCells(IJCell cell1, IJCell cell2) {
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

    cell1.location = JPosition(start: newStartingPoint, size: newSize);
    cell2.location = JPosition(start: newStartingPoint, size: newSize);
  }

  @override
  void collapseCellLeft(IJCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize > 1) {
      cell.location = JPosition(start: cell.location.start, size: currentCellSize - 1);
    }
  }

  @override
  void collapseCellRight(IJCell cell) {
    int currentCellSize = cell.location.size;
    if (currentCellSize > 1) {
      cell.location = JPosition(start: cell.location.start + 1, size: currentCellSize - 1);
    }
  }

  @override
  void splitCell(IJCell cell) {
    int cellSize = cell.location.size;
    for (int i = 0; i < cellSize; i++) {
      cells.add(
        JCell(value: cell.value, location: JPosition(start: cell.location.start + i, size: 1))
      );
    }
  }

  @override
  void addEntry(IJCell<T> entry) {
    commandRx.add(null);
    cells.add(entry);
  }

  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "name": name,
    "columns": columns.map((e) => e.toJson()).toList(),
    "cells": cells.map((e) => e.toJson(valueSerializer)).toList(),
  };

  static JTileTable<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return JTileTable<T>(
        name: json["name"],
        columns: json["columns"].map<IJColumn>((e) => JColumn.fromJson(e)).toList(),
        cells: (json["cells"] as Iterable<dynamic>).map<IJCell<T>>((e) => JCell.fromJson<T>(e, valueDeserializer)).toList()
    );
  }

  @override
  void removeEntry(IJCell<T> entry) {
    cells.remove(entry);
  }

  @override
  // TODO: implement deserializer
  ValueDeserializer get deserializer => throw UnimplementedError();

  @override
  // TODO: implement serializer
  ValueSerializer get serializer => throw UnimplementedError();
}