/// Utility class for calculating column widths in tile tables.
/// 
/// This class centralizes the logic for computing column widths based on
/// provided widths and visible column filters.
class ColumnWidthCalculator {
  /// Default width for columns when no specific width is provided.
  static const double defaultColumnWidth = 200.0;

  /// Computes the actual column widths based on provided widths and visible columns.
  /// 
  /// [providedWidths] - The list of column widths provided by the user.
  /// If null, defaults to [defaultColumnWidth] for all columns.
  /// 
  /// [totalColumns] - The total number of columns in the table.
  /// 
  /// [columnsToShow] - Optional list of column indices to show.
  /// Columns not in this list will have width 0 (hidden).
  /// 
  /// Returns a list of computed widths for each column.
  static List<double> computeColumnWidths({
    required List<double>? providedWidths,
    required int totalColumns,
    List<int>? columnsToShow,
  }) {
    // Step 1: Initialize widths with provided values or defaults
    List<double> widths = [];
    if (providedWidths == null) {
      widths.addAll(List.generate(totalColumns, (index) => defaultColumnWidth));
    } else {
      widths.addAll(providedWidths);
    }

    // Step 2: Apply column visibility filter
    if (columnsToShow != null) {
      widths = List.generate(widths.length, (index) {
        if (columnsToShow.contains(index)) {
          return widths[index];
        }
        return 0.0; // Hidden columns have 0 width
      });
    }

    return widths;
  }

  /// Computes the total width of all visible columns.
  /// 
  /// [columnWidths] - The list of individual column widths.
  /// 
  /// Returns the sum of all column widths.
  /// Returns 0.0 if the list is empty.
  static double computeTotalWidth(List<double> columnWidths) {
    if (columnWidths.isEmpty) {
      return 0.0;
    }
    return columnWidths.reduce((value, element) => value + element);
  }

  /// Computes the width of a range of columns.
  /// 
  /// [columnWidths] - The list of individual column widths.
  /// [startIndex] - The starting column index (inclusive).
  /// [endIndex] - The ending column index (exclusive).
  /// 
  /// Returns the sum of widths for the specified range.
  /// Returns 0.0 if the range is empty.
  static double computeRangeWidth(
    List<double> columnWidths,
    int startIndex,
    int endIndex,
  ) {
    final clampedEnd = endIndex.clamp(startIndex, columnWidths.length);
    if (startIndex >= clampedEnd) {
      return 0.0; // Empty range
    }
    return columnWidths
        .getRange(startIndex, clampedEnd)
        .reduce((value, element) => value + element);
  }
}
