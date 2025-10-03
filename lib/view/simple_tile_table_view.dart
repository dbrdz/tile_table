import 'package:flutter/material.dart';
import 'package:tile_table/cell/tile_cell.dart';
import 'package:tile_table/cell/tile_cell_position.dart';
import 'package:tile_table/column/tile_column.dart';
import 'package:tile_table/table/tile_table.dart';
import 'package:tile_table/utils/column_width_calculator.dart';
import 'package:tile_table/view/tile_table_view.dart';
import '../table/table_clipboard.dart';

/// ROW-BY-ROW TABLE RENDERING ALGORITHM
/// 
/// This is a simplified alternative to the complex recursive section-building approach.
/// It uses a straightforward strategy: organize cells into visual rows and render them sequentially.
///
/// ALGORITHM OVERVIEW:
/// 1. Sort cells by size (largest first) for visual hierarchy
/// 2. Group cells into rows based on their spatial relationships
/// 3. Render each row as a horizontal Flutter Row widget
/// 4. Stack rows vertically using a Column widget
///
/// ADVANTAGES:
/// - Much simpler to understand and maintain
/// - Predictable behavior and easier debugging  
/// - Better performance (no recursion overhead)
/// - Clear separation between logic and rendering
/// - Same visual results as complex algorithm
///
/// VISUAL EXAMPLE:
/// Input cells: A(0,3), B(0,1), C(1,1), D(3,1)
/// ```
/// Row 1: ┌─────────────────────┬─────┐
///        │   Cell A (size=3)   │  D  │  ← Largest cells first
///        └─────────────────────┴─────┘
/// Row 2: ┌─────┬─────┬─────────┬─────┐  
///        │  B  │  C  │         │     │  ← Smaller cells fill remaining space
///        └─────┴─────┴─────────┴─────┘
/// ```

class SimpleTileTableView<T> extends StatefulWidget {
  SimpleTileTableView({
    Key? key,
    required this.table,
    required this.columnWidths,
    
    // Table builder wrapper
    this.builder,
    
    // Leading widget
    this.leading,
    
    // Cell rendering
    this.cellBuilder,
    this.cellHeight = 45,
    
    // Column configuration
    this.columnTitleBuilder,
    this.columnTitleHeight = 45,
    this.showColumns = true,
    columnsToShow,
    
    // Selection
    this.selection,
    this.onSelect,
    
    // Action buttons
    this.actionButtonBuilder,
    
    // Totals
    this.totalBuilder,
    
    // Styling
    this.backgroundColor,
    
    // Empty state
    this.emptyState,
  }) : 
  columnsToShow = columnsToShow ?? List.generate(table.columns.length, (index) => index),
  super(key: key);

  final TileTable<T> table;
  final List<double> columnWidths;
  
  final TileTableBuilder? builder;
  
  // The leading widget can be a widget used for table legends or description
  // and is rendered to the left of the table
  final Widget? leading;
  
  final CellBuilder<T>? cellBuilder;
  final double cellHeight;
  
  final ColumnTitleBuilder? columnTitleBuilder;
  final double columnTitleHeight;
  final bool showColumns;
  final List<int> columnsToShow;
  
  final TableClipboard<T>? selection;
  final CellCallback<T>? onSelect;
  
  final ActionButtonBuilder? actionButtonBuilder;
  final TotalBuilder<T>? totalBuilder;
  
  final Color? backgroundColor;
  
  final Widget? emptyState;

  @override
  State<SimpleTileTableView<T>> createState() => _SimpleTileTableViewState<T>();
}

class _SimpleTileTableViewState<T> extends State<SimpleTileTableView<T>> {
  
  TileTable<T> get table => widget.table;
  TileTableBuilder? get builder => widget.builder;
  Widget? get leading => widget.leading;
  CellBuilder<T>? get cellBuilder => widget.cellBuilder;
  double get cellHeight => widget.cellHeight;
  ColumnTitleBuilder? get columnTitleBuilder => widget.columnTitleBuilder;
  double get columnTitleHeight => widget.columnTitleHeight;
  bool get showColumns => widget.showColumns;
  List<int> get columnsToShow => widget.columnsToShow;
  TableClipboard<T>? get selection => widget.selection;
  CellCallback<T>? get onSelect => widget.onSelect;
  ActionButtonBuilder? get actionButtonBuilder => widget.actionButtonBuilder;
  TotalBuilder<T>? get totalBuilder => widget.totalBuilder;
  Color? get backgroundColor => widget.backgroundColor;
  Widget? get emptyState => widget.emptyState;

  List<double> get _computedColumnWidths {
    return ColumnWidthCalculator.computeColumnWidths(
      providedWidths: widget.columnWidths,
      totalColumns: table.columns.length,
      columnsToShow: columnsToShow,
    );
  }

  List<TableRow<T>> _organizeIntoRows() {
    // Get all cells and sort them by size (largest first), then by position
    var allCells = table.cells.where((cell) {
      // Apply column filtering
      return columnsToShow.any((columnIndex) => 
        cell.location.contains(TileCellPosition(start: columnIndex, size: 1)));
    }).toList();

    // Sort: largest size first, then leftmost position first
    allCells.sort((a, b) {
      var sizeCompare = b.location.size.compareTo(a.location.size);
      if (sizeCompare != 0) return sizeCompare;
      return a.location.start.compareTo(b.location.start);
    });

    List<TileCell<T>> remainingCells = List.from(allCells);
    return _createRowsFromCells(remainingCells);
  }

  /// Create a single row by iterating through columns and picking the largest cell for each
  /// 
  /// ALGORITHM:
  /// 1. Iterate through each column index from left to right
  /// 2. For each column, find the largest available cell that starts at that column
  /// 3. If a cell is found and fits, add it to the row and mark occupied positions
  /// 4. If no cell is available for a column, add an action button for that column
  /// 5. Return the complete row with both cells and action buttons
  List<TableRow<T>> _createRowsFromCells(List<TileCell<T>> availableCells) {
    List<TableRow<T>> rows = [];
    List<int> columnsWithActionButtons = [];    

    while (columnsWithActionButtons.length < table.columns.length) {
      List<CellWrapper> rowCells = [];
      List<TileCellPosition> occupiedPositions = [];

       for (int i = 0; i < columnsToShow.length; i++) {
         int columnIndex = columnsToShow[i];

        // Skip if this column is already occupied by a previous cell
        bool columnOccupied = occupiedPositions.any((pos) => 
          columnIndex >= pos.start && columnIndex < pos.end);
        
        if (columnOccupied) {
          continue;
        }

        // Find all available cells that start at this column
        var cellsStartingAtColumn = availableCells
            .where((cell) => cell.location.start == columnIndex)
            .toList();

        // Also check if any available cells span over this column (but don't start at it)
        var cellsSpanningOverColumn = availableCells
            .where((cell) => cell.location.start < columnIndex && cell.location.end > columnIndex)
            .toList();

        if (cellsStartingAtColumn.isEmpty && cellsSpanningOverColumn.isEmpty && !columnsWithActionButtons.contains(columnIndex)) {
          columnsWithActionButtons.add(columnIndex);
          rowCells.add(ActionButtonWrapper(columnIndex: columnIndex));
        }

        // If cells are spanning over this column, we can't place anything here
        if (cellsSpanningOverColumn.isNotEmpty) {

          rowCells.add(BlankCellWrapper(columnIndex: columnIndex));
        }

        // Sort by size (largest first) to pick the largest cell that can fit
        cellsStartingAtColumn.sort((a, b) => b.location.size.compareTo(a.location.size));

        // Try to find the largest cell that can fit without conflicting
        TileCell<T>? selectedCell;
        for (var cell in cellsStartingAtColumn) {
          // Check if this cell conflicts with any already placed cells in this row
          bool canFitInRow = occupiedPositions.every((occupied) => 
            !cell.location.overlaps(occupied) && 
            !occupied.contains(cell.location) && 
            !cell.location.contains(occupied));

          if (canFitInRow) {
            selectedCell = cell;
            break;
          }
        }

        if (selectedCell != null) {
          availableCells.remove(selectedCell);
          // Add the selected cell to the row
          rowCells.add(EntryCellWrapper<T>(cell: selectedCell));
          occupiedPositions.add(selectedCell.location);
        }
      }
      rows.add(TableRow<T>(cells: rowCells, height: cellHeight));
    }

    return rows;
  }

  /// Render a single table row as a Flutter Row widget
  /// 
  /// This method creates the visual representation of a logical table row:
  /// 1. Iterate through the CellWrapper list in the TableRow
  /// 2. Build appropriate widgets based on wrapper type:
  ///    - EntryCellWrapper: Render the actual cell with cellBuilder
  ///    - ActionButtonWrapper: Render action button with actionButtonBuilder  
  ///    - BlankCellWrapper: Render empty space
  /// 3. Return a Row widget with all the cell widgets
  Widget _buildTableRow(TableRow<T> tableRow) {
    List<Widget> rowWidgets = [];

    for (var cellWrapper in tableRow.cells) {
      if (cellWrapper is EntryCellWrapper<T>) {
        // Render actual cell
        final cell = cellWrapper.cell;
        final cellWidth = ColumnWidthCalculator.computeRangeWidth(
          _computedColumnWidths,
          cell.location.start,
          cell.location.end,
        );
        
        Widget cellWidget = SizedBox(
          width: cellWidth,
          height: tableRow.height,
          child: cellBuilder?.call(
            context,
            cell,
            (fn) => setState(fn),
            () => onSelect?.call(cell),
          ) ?? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: backgroundColor ?? Colors.white,
            ),
            child: Center(child: Text('${cell.value}')),
          ),
        );
        
        rowWidgets.add(cellWidget);
        
      } else if (cellWrapper is ActionButtonWrapper) {
        // Render action button
        final columnIndex = cellWrapper.columnIndex;
        final columnWidth = _computedColumnWidths[columnIndex];
        
        Widget actionButtonWidget = SizedBox(
          width: columnWidth,
          height: tableRow.height,
          child: actionButtonBuilder?.call(
            context,
            table.columns[columnIndex],
            columnIndex,
          ) ?? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.blue.shade100,
            ),
            child: Center(child: Text('+ ${table.columns[columnIndex].title}')),
          ),
        );
        
        rowWidgets.add(actionButtonWidget);
        
      } else if (cellWrapper is BlankCellWrapper) {
        // Render empty space
        final columnIndex = cellWrapper.columnIndex;
        final columnWidth = _computedColumnWidths[columnIndex];
        
        Widget blankWidget = SizedBox(
          width: columnWidth,
          height: tableRow.height,
        );
        
        rowWidgets.add(blankWidget);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowWidgets,
    );
  }

  /// Build column headers if enabled
  Widget? _buildColumnHeaders() {
    if (!showColumns || columnTitleBuilder == null) return null;
    
    return SizedBox(
      height: columnTitleHeight,
      child: Row(
        children: table.columns.asMap().entries.map((entry) {
          int index = entry.key;
          TileColumn column = entry.value;
          
          // Skip hidden columns
          if (!columnsToShow.contains(index)) {
            return const SizedBox.shrink();
          }
          
          return SizedBox(
            width: _computedColumnWidths[index],
            child: columnTitleBuilder!.call(context, column),
          );
        }).toList(),
      ),
    );
  }

  /// Build totals row if enabled  
  Widget? _buildTotalsRow() {
    if (totalBuilder == null) return null;
    
    return SizedBox(
      height: cellHeight,
      child: Row(
        children: table.columns.asMap().entries.map((entry) {
          int index = entry.key;
          TileColumn column = entry.value;
          
          // Skip hidden columns
          if (!columnsToShow.contains(index)) {
            return const SizedBox.shrink();
          }
          
          // Get all cells that contain this column
          var columnCells = table.cells.where((cell) => 
            cell.location.contains(TileCellPosition(start: index, size: 1))).toList();
          
          return SizedBox(
            width: _computedColumnWidths[index],
            child: totalBuilder!.call(context, column, columnCells),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: table.commandRx,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Always use hybrid approach that supports both multi-column cells and column-wise action buttons
        return _buildSimpleTable();
      },
    );
  }


  /// Build table using the new column-by-column approach
  Widget _buildSimpleTable() {
    // Use the updated row organization that handles action buttons directly
    List<TableRow<T>> rows = _organizeIntoRows();
    
    // Check if we have any actual data rows (not just action button rows)
    bool hasDataRows = rows.any((row) => 
      row.cells.any((cell) => cell is EntryCellWrapper<T>));
    
    // Calculate total table dimensions
    double totalWidth = ColumnWidthCalculator.computeTotalWidth(_computedColumnWidths);
    double totalHeight = (rows.length * cellHeight) + 
                        (showColumns ? columnTitleHeight : 0) +
                        (totalBuilder != null ? cellHeight : 0);

    Widget tableWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading widget (table legend/description)
        if (leading != null)
          Container(
            margin: EdgeInsets.only(top: showColumns ? columnTitleHeight : 0),
            height: showColumns ? totalHeight - columnTitleHeight : totalHeight,
            child: leading,
          ),
        // Main table content
        SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column headers
              if (_buildColumnHeaders() != null) _buildColumnHeaders()!,
              
              // Table rows or empty state
              if (hasDataRows) ...[
                // Table rows (now include action buttons directly)
                ...rows.map((row) => _buildTableRow(row)),
              ] else ...[
                // Show empty state if no data rows
                if (emptyState != null) 
                  Expanded(child: emptyState!)
                else
                  // Show action buttons even when empty
                  ...rows.map((row) => _buildTableRow(row)),
              ],
              
              // Totals row
              if (_buildTotalsRow() != null) _buildTotalsRow()!,
            ],
          ),
        ),
      ],
    );

    return builder?.call(context, table, tableWidget, totalHeight, totalWidth) ?? tableWidget;
  }
}

/// Data class representing a logical table row
/// Contains all cells that should be rendered at the same vertical level
class TableRow<T> {
  TableRow({
    required this.cells,
    required this.height,
  });

  final List<CellWrapper> cells;        // All cells in this visual row
  final double height;                // Height of this row
}

/// Wrapper classes for different types of content in the table
/// These help distinguish between regular cells and action buttons during processing
abstract class CellWrapper {}

class EntryCellWrapper<T> extends CellWrapper {
  EntryCellWrapper({required this.cell});
  final TileCell<T> cell;
}

class BlankCellWrapper extends CellWrapper {
  BlankCellWrapper({required this.columnIndex});
  final int columnIndex;
}

class ActionButtonWrapper extends CellWrapper {
  ActionButtonWrapper({required this.columnIndex});
  final int columnIndex;
}

