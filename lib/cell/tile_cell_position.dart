import '../serializers/value_serializers.dart';

class TileCellPosition {

  const TileCellPosition({ required this.start, required this.size });
  final int start;
  final int size;
  int get end => start + size;

  bool overlaps(TileCellPosition other) {
    // Adjacent positions
    if (other.start >= end || start >= other.end) {
      return false;
    }
    // one is contained within another
    if (start <= other.start && other.end <= end) {
      return false;
    }

    if (other.start <= start && end <= other.end) {
      return false;
    }

    return true;
  }

  bool contains(TileCellPosition other) {
    // one is contained within another
    if (start <= other.start && other.end <= end) {
      return true;
    }

    return false;
  }

  bool isContainedBy(TileCellPosition other) {
    if (other.start <= start && end <= other.end) {
      return true;
    }

    return false;
  }

  bool isAdjacentTo(TileCellPosition other) {
    throw Exception("NOT IMPLEMENTED");
  }

  Map<String, dynamic> toJson() => {
    "start": start,
    "size": size
  };

  static TileCellPosition fromJson(Map<String, dynamic> json) {
    return TileCellPosition(
        start: json["start"],
        size: json["size"]
    );
  }
}

abstract class TileCell<T> {
  String get uuid;

  TileCellPosition get location;
  set location(TileCellPosition newPosition);
  T get value;
  set value(T entry);

  void setStart(int start);
  void setSize(int newSize);

  void moveLeft();
  void moveRight();

  void grow();
  void shrink();

  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer);
}