import '../cell/i_jcell.dart';
import 'i_jcolumn.dart';

class JColumn implements IJColumn {
  JColumn({ required this.index, required this.title });

  @override
  int index;

  @override
  String title;

  @override
  JPosition get location => JPosition(start: index, size: 1);

  @override
  Map<String, dynamic> toJson() => {
    "index": index,
    "title": title
  };

  static JColumn fromJson(Map<String, dynamic> json) {
    return JColumn(
        index: json["index"],
        title: json["title"]);
  }
}