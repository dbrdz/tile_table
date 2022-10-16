import 'package:flutter/material.dart';

import '../cell/i_jcell.dart';
import '../column/i_jcolumn.dart';
import '../dataset/i_tile_dataset.dart';
import '../dataset/j_tile_dataset.dart';
import '../table/i_tile_jtable.dart';
import '../table/table_clipboard.dart';
import 'j_tile_table_view.dart';

typedef LabelBuilder<T> = Widget Function(BuildContext context, String);
typedef DatasetCellBuilder<T> = Function(BuildContext context, IJTileTable<T> table, IJCell<T> cell, CommitCallback commit, VoidCallback? onTap);

typedef TableTotalBuilder<T> = Widget Function(BuildContext context, IJTileTable<T> table, IJColumn, List<IJCell<T>>);
typedef DatasetTotalBuilder<T> = Widget Function(BuildContext context, IJColumn, List<IJCell<T>>);
typedef ActionButtonBuilder<T> = Widget Function(
    BuildContext context, IJTileTable<T> table, IJColumn, int cellStartingAt
    );

typedef OnCellSelect<T> = Function(IJTileTable<T> table, IJCell<T> cell);
typedef DatasetBuilder<T> = Widget Function(BuildContext context, JTileDataset dataset, Widget datasetWidget, double width, double height);

class JTileDatasetView<T> extends StatefulWidget {
  const JTileDatasetView({Key? key,
    required this.dataset,
    required this.columnWidths,

    // ------------- TOTALS RELATED PROPS ---------------
    this.tableTotalBuilder,
    this.datasetTotalBuilder,

    // ------------- COLUMN RELATED PROPS ---------------
    this.columnTitleBuilder,
    this.columnTitleHeight = 45,
    this.showColumns = true,

    // ------------- LABEL RELATED PROPS ---------------
    this.labelBuilder,
    this.showTableLabels = true,
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
    this.builder


  }) : super(key: key);

  final LabelBuilder? labelBuilder;
  final bool showTableLabels;
  final double tableLabelWidth;
  final ITileDataset<T> dataset;

  final DatasetTotalBuilder<T>? datasetTotalBuilder;
  final TableTotalBuilder<T>? tableTotalBuilder;

  final ColumnTitleBuilder? columnTitleBuilder;
  final List<double> columnWidths;
  final bool showColumns;

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

  // ------------- STYLING PROPS ----------------
  final Color? tableBackgroundColor;

  @override
  State<StatefulWidget> createState() {
    return JTileDatasetViewState<T>();
  }
}

class JTileDatasetViewState<T> extends State<JTileDatasetView<T>> {

  LabelBuilder? get labelBuilder => widget.labelBuilder;
  bool get _showTableLabels => widget.showTableLabels;
  double get _tableLabelWidth => widget.tableLabelWidth;

  ITileDataset<T> get _dataset => widget.dataset;

  TableTotalBuilder<T>? get _tableTotalBuilder => widget.tableTotalBuilder;
  DatasetTotalBuilder<T>? get _datasetTotalBuilder => widget.datasetTotalBuilder;

  List<double> get _columnWidths => widget.columnWidths;
  double get columnTitleHeight => widget.columnTitleHeight;
  ColumnTitleBuilder? get _columnTitleBuilder => widget.columnTitleBuilder;

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

  final List<IJCell<T>> clipBoard = [];

  List<double> _datasetHeights = [];
  double _datasetWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<IJTileTable<T>> tables = _dataset.dataset;
    _datasetHeights.clear();

    final double tableWidth = _columnWidths.reduce((value, element) => value + element);

    return Column(
        children: [
          /// --------------------- COLUMN ROW ---------------------------------- ///
          Container(
            // color: Colors.green,
            margin: EdgeInsets.only(left: _showTableLabels ? _tableLabelWidth : 0.0),
            height: columnTitleHeight,
            width: tableWidth,
            child: Row(
                children: List.generate(
                    tables.first.columns.length,
                        (index) {
                      final IJColumn column = tables.first.columns[index];
                      return Container(
                        alignment: Alignment.center,
                        width: _columnWidths[index],
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
                IJTileTable<T> table = tables[index];
                return [
                  SizedBox(
                    height: 30,
                    width: tableWidth,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        //   child: Text(table.name),
                        // ),
                        // const Expanded(
                        //   child: Divider(),
                        // ),
                      ],
                    ),
                  ),
                  /// --------------------- TABLE BODY  ---------------------------------- ///
                  JTileTableView<T>(
                    table: table,
                    backgroundColor: tableBackgroundColor,
                    selection: selection,
                    cellHeight: cellHeight,
                    columnTitleHeight: columnTitleHeight,
                    leading: _showTableLabels ? labelBuilder?.call(context, table.name) : null,
                    showColumns: false,
                    onSelect: (IJCell<T> cell) {
                      onSelect?.call(table, cell);
                    },
                    builder: (BuildContext context, IJTileTable table, Widget datasetWidget, double height, double width) {
                      return datasetWidget;
                    },
                    totalBuilder: _tableTotalBuilder != null
                        ? (context, column, columnCells) => _tableTotalBuilder!.call(context, table, column, columnCells)
                        : null,
                    columnTitleBuilder: _columnTitleBuilder,
                    cellBuilder: (BuildContext context, IJCell<T> cell, CommitCallback commit, VoidCallback? onTap) {
                      return cellBuilder?.call(context, table, cell, commit, onTap) ??
                          Text(cell.value.toString());
                    },
                    actionButtonBuilder: actionButtonBuilder != null
                        ? (context, column, startingAt) {
                            return actionButtonBuilder!.call(context, table, column, startingAt);
                          }
                        : null,
                    columnWidths: _columnWidths,
                  ),
                ];
              }
          ).expand((element) => element).toList(),
          if (_datasetTotalBuilder != null)
            SizedBox(
              height: 30,
              width: tableWidth,
              child: Row(
                children: const [
                  Expanded(
                    child:  Divider(),
                  ),
                  Text("Totals"),
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
                ...List.generate(_columnWidths.length, (index) =>
                    SizedBox(
                      height: cellHeight,
                      width: _columnWidths[index],
                      child: _datasetTotalBuilder!.call(context, _dataset.dataset.first.columns[index], _dataset.getCellsByStartingPoint(index)),
                    )
                )
              ],
            )

          /// --------------------- DATASET FOOTER ----------------------------- ///
        ]);
  }
}