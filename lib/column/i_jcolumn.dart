import '../cell/i_jcell.dart';

/// The TableColumn interface describes the title of a cell. Since JTable2
/// is supposed to work like a spreadsheet, this interface would be the equivalent
/// of customizing the title of the columns that usually have "A, B, C, D" for
/// titles.
abstract class IJColumn {
  String get title;
  int get index;
  JPosition get location;

  Map<String, dynamic> toJson();
}