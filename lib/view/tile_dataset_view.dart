import 'package:flutter/material.dart';
import 'package:tile_table/cell/tile_cell.dart';
import 'package:tile_table/column/tile_column.dart';
import 'package:tile_table/table/tile_table.dart';

import '../dataset/tile_dataset.dart';
import '../table/table_clipboard.dart';
import 'tile_table_view.dart';

typedef LabelBuilder<T> = Widget Function(BuildContext context, String);
typedef DatasetCellBuilder<T> = Function(BuildContext context, TileTable<T> table, TileCell<T> cell, CommitCallback commit, VoidCallback? onTap);

typedef TableTotalBuilder<T> = Widget Function(BuildContext context, TileTable<T> table, TileColumn, List<TileCell<T>>);
typedef DatasetTotalBuilder<T> = Widget Function(BuildContext context, TileColumn, List<TileCell<T>>);
typedef ActionButtonBuilder<T> = Widget Function(
    BuildContext context, TileTable<T> table, TileColumn, int cellStartingAt
    );
typedef EmptyStateBuilder<T> = Widget Function(BuildContext context, TileTable<T> table);
typedef OnCellSelect<T> = Function(TileTable<T> table, TileCell<T> cell);
typedef DatasetBuilder<T> = Widget Function(BuildContext context, TileDataset dataset, Widget datasetWidget, double width, double height);

class TableViewOptions {
  List<int>? columnsToShow;
}

class TileDatasetView<T> extends StatefulWidget {
  const TileDatasetView({Key? key,
    required this.dataset,
    required this.columnWidths,

    // ------------- TOTALS RELATED PROPS ---------------
    this.tableTotalBuilder,
    this.datasetTotalBuilder,

    // ------------- COLUMN RELATED PROPS ---------------
    this.columnTitleBuilder,
    this.columnTitleHeight = 45,
    this.showColumns = true,
    this.columnsToShow,

    // ------------- LABEL RELATED PROPS ---------------
    this.labelBuilder,
    this.showTableLabels = true,
    this.showTableDividers = false,
    this.tableLabelWidth = 100,

    // ------------- CELL RELATED PROPS ---------------
    this.cellBuilder,
    this.cellHeight = 45,

    // ------------- SELECTION RELATED PROPS ---------------
    this.clipboard,
    this.onSelect,

    // ------------- ACTION BUTTON PROPS --------------
    this.actionButtonBuilder,

    // ------------- CUSTOMIZATION RELATED PROPS ------
    this.tableBackgroundColor,

    // ------------- TABLE BUILDER --------------------
    this.builder,

    // ------------- EMPTY STATE BUILDER --------------------
    this.emptyStateBuilder

  }) : super(key: key);

  final LabelBuilder? labelBuilder;
  final bool showTableLabels;
  final double tableLabelWidth;
  final TileDataset<T> dataset;

  final DatasetTotalBuilder<T>? datasetTotalBuilder;
  final TableTotalBuilder<T>? tableTotalBuilder;

  final ColumnTitleBuilder? columnTitleBuilder;
  final List<double> columnWidths;
  final bool showColumns;
  final List<int>? columnsToShow;

  final double columnTitleHeight;

  // ------------- CELL RELATED PROPS ---------------
  final double cellHeight;
  final DatasetCellBuilder<T>? cellBuilder;

  // ------------- SELECTION RELATED PROPS ---------------
  final TableClipboard<T>? clipboard;
  final OnCellSelect<T>? onSelect;

  // ------------- ACTION BUTTON PROPS ----------
  final ActionButtonBuilder<T>? actionButtonBuilder;

  final DatasetBuilder? builder;
  // ------------- DIVIDERS
  final bool showTableDividers;

  // ------------- STYLING PROPS ----------------
  final Color? tableBackgroundColor;

  final EmptyStateBuilder? emptyStateBuilder;

  @override
  State<StatefulWidget> createState() {
    return TileDatasetViewState<T>();
  }
}

class TileDatasetViewState<T> extends State<TileDatasetView<T>> {

  LabelBuilder? get labelBuilder => widget.labelBuilder;
  bool get _showTableLabels => widget.showTableLabels;
  double get _tableLabelWidth => widget.tableLabelWidth;

  TileDataset<T> get _dataset => widget.dataset;

  TableTotalBuilder<T>? get _tableTotalBuilder => widget.tableTotalBuilder;
  DatasetTotalBuilder<T>? get _datasetTotalBuilder => widget.datasetTotalBuilder;

  List<double> get _columnWidths => widget.columnWidths;
  double get columnTitleHeight => widget.columnTitleHeight;
  ColumnTitleBuilder? get _columnTitleBuilder => widget.columnTitleBuilder;
  List<int>? get _columnsToShow => widget.columnsToShow;

  double get cellHeight => widget.cellHeight;
  DatasetCellBuilder<T>? get cellBuilder => widget.cellBuilder;

  DatasetBuilder? get _builder => widget.builder;

  // ------------- SELECTION PROPS ----------
  OnCellSelect<T>? get onSelect => widget.onSelect;
  TableClipboard<T>? get selection => widget.clipboard;

  // ------------- ACTION BUTTON PROPS ----------
  ActionButtonBuilder<T>? get actionButtonBuilder => widget.actionButtonBuilder;

  // ------------- CUSTOMIZATION RELATED PROPS ------
  Color? get tableBackgroundColor => widget.tableBackgroundColor;

  // ------------- DIVIDERS
  bool get _showTableDividers => widget.showTableDividers;

  // ------------- EMPTY STATE BUILDER
  EmptyStateBuilder? get _emptyStateBuilder => widget.emptyStateBuilder;

  final List<TileCell<T>> clipBoard = [];

  List<double> _datasetHeights = [];
  double _datasetWidth = 0;

  List<double> get _computedColumnWidths {
    List<double> widths = [];
    widths.addAll(_columnWidths!);

    if (_columnsToShow != null) {
      widths = List.generate(widths.length, (index) {
        if (_columnsToShow != null) {
          if (_columnsToShow!.contains(index)) {
            return widths[index];
          }
          return 0;
        }
        return widths[index];
      });
    }
    return widths;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TileTable<T>> tables = _dataset.dataset;
    _datasetHeights.clear();

    final double tableWidth = _computedColumnWidths.reduce((value, element) => value + element);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --------------------- COLUMN ROW ---------------------------------- ///
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _showTableLabels ? _tableLabelWidth : 0.0),
            height: columnTitleHeight,
            width: tableWidth,
            child: Row(
                children: List.generate(
                    _columnsToShow?.length ?? tables.first.columns.length,
                        (index) {
                      int columnIndex = _columnsToShow?[index] ?? index;
                      final TileColumn column = tables.first.columns[columnIndex];

                      return Container(
                        key: ValueKey("column-${column.index}"),
                        alignment: Alignment.center,
                        width: _computedColumnWidths[columnIndex],
                        height: columnTitleHeight,
                        child: _columnTitleBuilder?.call(context, column) ?? Text(column.title),
                      );
                    }
                )
            ),
          ),
          ...List.generate(
              tables.length,
                  (index) {
                TileTable<T> table = tables[index];
                return [
                  // It doesn't make sense to show the divider lines if the table body is empty. Whenever
                  // there is something in the table body being rendered then we can show the divider lines,
                  // this only happens whenere there is a defined empty state, when there is some data or when an action button is defined
                  if (_showTableDividers && (table.cells.isNotEmpty || _emptyStateBuilder != null || actionButtonBuilder != null))
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 30,
                      width: tableWidth,
                      margin: EdgeInsets.only(left: _showTableLabels ? _tableLabelWidth : 0.0),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),
                    ),
                  /// --------------------- TABLE BODY  ---------------------------------- ///
                  TileTableView<T>(
                    table: table,
                    backgroundColor: tableBackgroundColor,
                    selection: selection,
                    cellHeight: cellHeight,
                    columnTitleHeight: columnTitleHeight,
                    leading: _showTableLabels ? labelBuilder?.call(context, table.name) : null,
                    showColumns: false,
                    columnsToShow: _columnsToShow,
                    onSelect: (TileCell<T> cell) {
                      onSelect?.call(table, cell);
                    },
                    builder: (BuildContext context, TileTable table, Widget datasetWidget, double height, double width) {
                      return datasetWidget;
                    },
                    totalBuilder: _tableTotalBuilder != null
                        ? (context, column, columnCells) => _tableTotalBuilder!.call(context, table, column, columnCells)
                        : null,
                    columnTitleBuilder: _columnTitleBuilder,
                    cellBuilder: (BuildContext context, TileCell<T> cell, CommitCallback commit, VoidCallback? onTap) {
                      return cellBuilder?.call(context, table, cell, commit, onTap) ??
                          Text(cell.value.toString());
                    },
                    actionButtonBuilder: actionButtonBuilder != null
                        ? (context, column, startingAt) {
                            return actionButtonBuilder!.call(context, table, column, startingAt);
                          }
                        : null,
                    columnWidths: _computedColumnWidths,
                    emptyState: _emptyStateBuilder?.call(context, table),
                  ),
                ];
              }
          ).expand((element) => element).toList(),
          if (_datasetTotalBuilder != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 30,
              margin: EdgeInsets.only(left: _showTableLabels ? _tableLabelWidth : 0.0),
              width: tableWidth,
              child: Row(
                children: const [
                  Expanded(
                    child:  Divider(),
                  ),
                ],
              ),
            ),

          /// --------------------- DATASET TOTAL BUILDER ---------------------- ///
          if (_datasetTotalBuilder != null)
            Row(
              children: [
                if (labelBuilder != null)
                  labelBuilder!.call(context, 'total'),
                ...List.generate(_columnsToShow?.length ?? _columnWidths.length, (index) {
                  int columnIndex = _columnsToShow?[index] ?? index;
                  return SizedBox(
                    height: cellHeight,
                    width: _computedColumnWidths[columnIndex],
                    child: _datasetTotalBuilder!.call(context, _dataset.dataset.first.columns[columnIndex], _dataset.getCellsByStartingPoint(columnIndex)),
                  );
                }

                )
              ],
            )

          /// --------------------- DATASET FOOTER ----------------------------- ///
        ]);
  }
}