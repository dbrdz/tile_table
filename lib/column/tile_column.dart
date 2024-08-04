import '../cell/tile_cell_position.dart';

class TileColumn {
  TileColumn({ required this.index, required this.title });

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

  static TileColumn fromJson(Map<String, dynamic> json) {
    return TileColumn(
        index: json["index"],
        title: json["title"]);
  }
}