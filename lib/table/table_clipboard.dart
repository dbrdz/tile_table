import 'package:rxdart/rxdart.dart';

import '../cell/i_jcell.dart';

class TableSelection<T> {
  TableSelection({ required this.datasetIndex, required this.cell });
  final int datasetIndex;
  final IJCell<T> cell;
}

class TableClipboard<T> {
  TableClipboard({ required this.selectedCells });

  final BehaviorSubject listener = BehaviorSubject<TableClipboard>();

  List<TableSelection<T>> selectedCells;
  List<IJCell<T>> clipboard = [];
  List<String> selectedActionButtons = [];

  void clearActionButtonSelection() {
    selectedActionButtons.clear();
    listener.add(this);
  }

  void addActionButtonToSelection(String id) {
    selectedActionButtons.add(id);
    listener.add(this);
  }

  void selectActionButton(String id) {
    selectedCells.clear();
    selectedActionButtons.clear();
    selectedActionButtons.add(id);
    listener.add(this);
  }

  bool isActionButtonSelected(String index) {
    return selectedActionButtons.contains(index);
  }

  void clearCellSelection() {
    selectedCells.clear();
    listener.add(this);
  }

  void selectCell(IJCell<T> cell, int tableIndex) {
    selectedActionButtons.clear();
    selectedCells.clear();
    selectedCells.add(TableSelection(datasetIndex: tableIndex, cell: cell));
    listener.add(this);
  }

  void addToSelection(IJCell<T> cell, int tableIndex) {
    selectedCells.add(TableSelection(datasetIndex: tableIndex, cell: cell));
    listener.add(this);
  }

  bool isCellSelected(IJCell<T> cell) {
    return selectedCells.any((element) => element.cell == cell);
  }

  bool isCellInClipBoard(IJCell<T> cell) {
    return clipboard.contains(cell);
  }

  void clearClipboard() {
    clipboard.clear();
    listener.add(this);
  }
}