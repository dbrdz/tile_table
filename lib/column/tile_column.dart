import '../cell/tile_cell_position.dart';
import 'tile_column.dart';

class TileTableColumn implements TileColumn {
  TileTableColumn({ required this.index, required this.title });

  @override
  int index;

  @override
  String title;

  @override
  TileCellPosition get location => TileCellPosition(start: index, size: 1);

  @override
  Map<String, dynamic> toJson() => {
    "index": index,
    "title": title
  };

  static TileTableColumn fromJson(Map<String, dynamic> json) {
    return TileTableColumn(
        index: json["index"],
        title: json["title"]);
  }
}