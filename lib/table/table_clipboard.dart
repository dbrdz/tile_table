import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../cell/i_jcell.dart';

class TableClipboard<T> {
  TableClipboard({ required this.selectedCells });

  final BehaviorSubject listener = BehaviorSubject<TableClipboard>();

  List<IJCell<T>> selectedCells;
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

  void selectCell(IJCell<T> cell) {
    selectedActionButtons.clear();
    selectedCells.clear();
    selectedCells.add(cell);
    listener.add(this);
  }

  void addToSelection(IJCell<T> cell) {
    selectedCells.add(cell);
    listener.add(this);
  }

  bool isCellSelected(IJCell<T> cell) {
    return selectedCells.contains(cell);
  }

  bool isCellInClipBoard(IJCell<T> cell) {
    return clipboard.contains(cell);
  }

  void copySelection() {
    clipboard.clear();
    clipboard.addAll(selectedCells);
    listener.add(this);
  }

  void clearClipboard() {
    clipboard.clear();
    listener.add(this);
  }
}