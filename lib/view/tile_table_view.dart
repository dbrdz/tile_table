import 'package:flutter/material.dart';
import 'package:tile_table/column/tile_column.dart';
import 'package:tile_table/table/tile_table.dart';

import '../cell/tile_cell.dart';
import '../cell/tile_cell_position.dart';
import '../table/table_clipboard.dart';
import 'cell_group_container.dart';

typedef CellBuilder<T> = Widget Function(BuildContext context,  TileCell<T> cell, CommitCallback commit, VoidCallback? onTap);
typedef ColumnTitleBuilder = Widget Function(BuildContext context, TileColumn column);
typedef ActionButtonBuilder = Widget Function(BuildContext context, TileColumn column, int startingIndex);
typedef TotalBuilder<T> = Widget Function(BuildContext context, TileColumn column, List<TileCell<T>> columnCells);
typedef CommitCallback = void Function(VoidCallback);
typedef CellCallback<T> = void Function(TileCell<T>);
typedef TileTableBuilder = Widget Function(BuildContext context, TileTable table, Widget tableWidget, double tableHeight, double tableWidth);

class TileTableView<T> extends StatefulWidget {
  const TileTableView({
    Key? key,
    required this.table,
    this.builder,
    this.leading,
    this.showColumns = true,
    this.columnsToShow,
    this.columnWidths = const [],
    this.columnTitleHeight = 45,
    this.cellHeight = 45,
    this.columnTitleBuilder,
    this.totalBuilder,
    this.cellBuilder,
    this.actionButtonBuilder,
    this.backgroundColor,
    this.selection,
    this.onSelect,
    this.emptyState
  }) : super(key: key);

  final TileTable<T> table;
  final TileTableBuilder? builder;
  // The leading widget can be a widget used for table legends or description
  // and is rendered to the left of the table
  final Widget? leading;
  final List<double> columnWidths;
  final double columnTitleHeight;
  final double cellHeight;

  final bool showColumns;
  final List<int>? columnsToShow;

  final ActionButtonBuilder? actionButtonBuilder;
  final ColumnTitleBuilder? columnTitleBuilder;
  final TotalBuilder<T>? totalBuilder;
  final CellBuilder<T>? cellBuilder;

  // ------------------ SELECTION PROPS ------------------ //
  final TableClipboard<T>? selection;
  final CellCallback<T>? onSelect;

  final Widget? emptyState;

  final Color? backgroundColor;

  @override
  State<StatefulWidget> createState() {
    return TileTableViewState<T>();
  }
}

class TileTableViewState<T> extends State<TileTableView<T>> {

  // ------------- DATA  ------------------
  TileTable<T> get table => (widget.table);

  // ------------- CHILD WIDGETS ------------------
  Widget? get _leading => widget.leading;

  // ------------- BUILDERS ---------------
  TileTableBuilder? get _builder => widget.builder;
  CellBuilder<T>? get _cellBuilder => widget.cellBuilder;
  ColumnTitleBuilder? get _columnTitleBuilder => widget.columnTitleBuilder;
  TotalBuilder<T>? get _totalBuilder => widget.totalBuilder;

  // ------------- FLAGS ------------------
  bool get _showColumns => widget.showColumns;
  List<int>? get _columnsToShow => widget.columnsToShow;

  // ------------- SELECTION PROPS ---------------
  TableClipboard<T>? get selection => widget.selection;
  CellCallback<T>? get onSelect => widget.onSelect;

  // ------------- STYLING PROPS ------------------
  List<double>? get columnWidths => widget.columnWidths;
  double get columnTitleHeight => widget.columnTitleHeight;
  double get cellHeight => widget.cellHeight;
  Color? get _backgroundColor => widget.backgroundColor;

  // ------------- INTERNAL STATE ---------
  List<Map<int, List<CellWrapper>>> cellsByColumnAndSize = [];

  // Action buttons
  // Column action buttons are cells that are not entries in the table
  // but work as a button that can toggle the creation of a new entry.
  ActionButtonBuilder? get _actionButtonBuilder => widget.actionButtonBuilder;
  // A list that tells the table builder which columns have already action buttons.
  List<bool>? _actionButtonsDrawn;
  final List<CellWrapper> _processedCells = [];

  Widget? get _emptyState => widget.emptyState;

  List<double> get _computedColumnWidths {
    List<double> widths = [];
    if (columnWidths == null) {
      widths.addAll(List.generate(table.columns.length, (index) => 200));
    } else {
      widths.addAll(columnWidths!);
    }

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

  /// This method is used to organized the cells by starting index and by size.
  /// The algorithm then grabs this list and renders the cells in ascending
  /// column order followed by descending size order.
  ///
  /// note: This method gets executed every time the widget gets render.
  ///  (gets called from the build method)
  void _buildColumnCellMap() {
    cellsByColumnAndSize.clear();
    _processedCells.clear();
    for (int i = 0; i < table.columns.length; i++) {
      Map<int, List<CellWrapper>> cellsMap = {};
      final List<TileCell<T>> columnCells = table.getCellsByStartingPoint(i);

      for (var cell in columnCells) {
        if (_columnsToShow != null) {
          if (!_columnsToShow!.any((columnIndex) => cell.location.contains(TileCellPosition(start: columnIndex, size: 1)))) {
            continue;
          }
        }

        final int size = cell.location.size;
        List<CellWrapper> sizeList = cellsMap.putIfAbsent(size, () => []);
        sizeList.add(
          EntryCellWrapper<T>(cell: cell)
        );
      }
      if (_actionButtonBuilder != null) {
        if (_columnsToShow?.contains(i) ?? true) {
          cellsMap.putIfAbsent(1, () => []).add(ActionButtonWrapper());
        }
      }

      cellsByColumnAndSize.add(cellsMap);
    }
  }

  /// Used to re-render the table
  void refresh(VoidCallback changes) {
    setState(changes);
  }

  Widget buildActionButton(BuildContext context, int index) {
    return SizedBox(
      height: cellHeight,
      width: _computedColumnWidths[index],
      child: _actionButtonBuilder!.call(context, table.columns[index], index),
    );
  }

  TableSectionInfo? buildTableSection(int cellsStartingAt, TileCellPosition? parentPosition, { bool buildSubsection = true, bool buildAdjacent = true }) {

    if (
    (cellsStartingAt >= cellsByColumnAndSize.length ||
        cellsByColumnAndSize.every((element) => element.isEmpty))
    ) {
      return null;
    }

    Map<int, List<CellWrapper>> cellsBySize = cellsByColumnAndSize[cellsStartingAt];

    /// It could be the case that there are no cells at the current starting point
    /// but that the adjacent group of cells has some cells in it. If we can't find
    /// any cells at this starting point then set the size to 1 so that when we
    /// build the adjacent group of cells we do it calling the buildTableSection
    /// method with a starting point of one more than the current one.
    int currentCellSize = cellsBySize.isEmpty
        ? 0
        : cellsBySize.keys.reduce((value, element) => value > element ? value : element);

    TileCellPosition currentPosition = TileCellPosition(start: cellsStartingAt, size: currentCellSize);
    List<CellWrapper> cells = cellsBySize.isEmpty ? [] : cellsBySize.remove(currentCellSize)!;
    _processedCells.addAll(cells);

    int adjacentStartingPoint = currentCellSize != 0
        ? cellsStartingAt + currentCellSize
        : cellsStartingAt + 1;

    TableSectionInfo? adjacentSection = buildTableSection(adjacentStartingPoint, parentPosition);

    // If there are no more cells (aka cell size is 0) and if the adjacent
    // cell group is null then we have an empty row which means we must return null.
    if (adjacentSection == null && currentCellSize == 0) {
      return null;
    }

    bool drawSubsection = !table.cells.any((element) => element.location.overlaps(currentPosition));

    TableSectionInfo? subsection = drawSubsection
        ? buildTableSection(cellsStartingAt, currentPosition)
        : null;

    TableSectionInfo? lowerSection = buildTableSection(cellsStartingAt, parentPosition);

    double mainSectionHeight = cellHeight * cells.length.clamp(1, double.infinity) + ((cells.length - 1)) + (subsection?.height ?? 0); // + (actionButtons.bottomActionButton?.height ?? 0);
    double adjacentSectionHeight = (adjacentSection?.height ?? 0); // + (actionButtons.adjacentActionButton?.height ?? 0);
    double lowerSectionHeight = lowerSection?.height ?? 0;

    double totalHeight = mainSectionHeight;

    if (adjacentSectionHeight > mainSectionHeight) {
      totalHeight = adjacentSectionHeight;
    }

    totalHeight += lowerSectionHeight;
    late double sectionWidth;

    if (currentCellSize == 0) {
      sectionWidth = _computedColumnWidths[cellsStartingAt];
    } else {
      sectionWidth = _computedColumnWidths.getRange(cellsStartingAt,
          (cellsStartingAt + currentCellSize).clamp(1, _computedColumnWidths.length))
          .reduce((value, element) => value + element);
    }

    Widget sectionWidget = SizedBox(
      height: totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: sectionWidth,
                height: mainSectionHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cells.isNotEmpty)
                      CellGroupContainer<T>(
                        selection: selection,
                        key: UniqueKey(),
                        cells: cells.whereType<EntryCellWrapper<T>>().map((e) => e.cell).toList(),
                        cellBuilder: _cellBuilder,
                        cellHeight: cellHeight,
                        onSelect: (TileCell<T> cell) {
                          onSelect?.call(cell);
                        },
                        commit: refresh,
                      ),
                    if (cells.whereType<ActionButtonWrapper>().isNotEmpty)
                      buildActionButton(context, cellsStartingAt),
                    if (subsection != null)
                      subsection.widget,
                  ],
                ),
              ),
              if (adjacentSection != null)
                adjacentSection.widget,
            ],
          ),

          if (lowerSection != null)
            SizedBox(
              height: lowerSectionHeight,
              child: lowerSection.widget
            )
        ],
      ),
    );

    return TableSectionInfo(
      widget: sectionWidget,
      height: totalHeight
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildColumnCellMap();

    TableSectionInfo? tableBody = buildTableSection(0, null);
    double tableWidth = _computedColumnWidths.reduce((value, element) => value + element);
    double tableHeight = tableBody?.height ?? 0.0;

    if (_totalBuilder != null) {
      tableHeight += cellHeight;
    }

    if (_showColumns) {
      tableHeight += columnTitleHeight;
    }

    Widget tableWidget = SizedBox(
      height: tableHeight + 2,
      child: StreamBuilder(
        stream: table.commandRx,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Row(
            children: [
              if (tableBody != null || _totalBuilder != null)
                Container(
                  margin: EdgeInsets.only(top: _showColumns ? columnTitleHeight : 0),
                  height: _showColumns ? tableHeight - columnTitleHeight : tableHeight,
                  child: _leading,
                ),
              Column(
                children: [
                  if (_showColumns)
                    SizedBox(
                      // color: Colors.green,
                      height: columnTitleHeight,
                      width: tableWidth,
                      child: Row(
                          children: List.generate(
                              table.columns.length,
                                  (index) {
                                final TileColumn column = table.columns[index];
                                return Container(
                                  alignment: Alignment.center,
                                  width: _computedColumnWidths[index],
                                  height: columnTitleHeight,
                                  child: _columnTitleBuilder?.call(context, column) ?? Text(column.title),
                                );
                              }
                          )
                      ),
                    ),
                  tableBody != null
                      ?  Container(
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      // border: Border.all(color: Colors.black12, strokeAlign: StrokeAlign.inside)
                    ),
                    height: tableBody.height + 2,
                    width: tableWidth + 2,
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        tableBody.widget,
                      ],
                    ),
                  )
                      : _emptyState ?? Container(),

                  if (_totalBuilder != null)
                    Container(
                      decoration: BoxDecoration(
                          color: _backgroundColor ?? Theme.of(context).colorScheme.background,
                          border: Border.all(
                              color: Colors.black12,
                              strokeAlign: BorderSide.strokeAlignInside
                          )
                      ),
                      height: cellHeight,
                      width: tableWidth,
                      child: Row(
                          children: (_columnsToShow?.map((e) => table.columns[e]) ?? table.columns)
                          .map((e) => Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: .5,
                                    // strokeAlign: StrokeAlign.outside
                                  )
                              ),
                              width: _computedColumnWidths[e.index],
                              child: _totalBuilder!.call(
                                  context,
                                  e,
                                  table.cells.where((element) => element.location.contains(e.location)).toList()
                              )
                          )).toList()
                      ),
                    ),
                ],
              )
            ],
          );
        },
      ),
    );

    return _builder?.call(context, table, tableWidget, tableHeight, tableWidth) ?? tableWidget;
  }
}

abstract class CellWrapper {

}

class EntryCellWrapper<T> extends CellWrapper {
  EntryCellWrapper({ required this.cell });
  final TileCell<T> cell;
}

class ActionButtonWrapper extends CellWrapper {}

class TableSectionInfo {
  TableSectionInfo({ required this.widget, required this.height });

  final Widget widget;
  final double height;
}

class ActionButtonInfo {
  ActionButtonInfo({ this.adjacentActionButton, this.bottomActionButton });
  TableSectionInfo? adjacentActionButton;
  TableSectionInfo? bottomActionButton;
}
