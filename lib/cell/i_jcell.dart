import '../serializers/value_serializers.dart';

class JPosition {

  const JPosition({ required this.start, required this.size });
  final int start;
  final int size;
  int get end => start + size;

  bool overlaps(JPosition other) {
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

  bool contains(JPosition other) {
    // one is contained within another
    if (start <= other.start && other.end <= end) {
      return true;
    }

    return false;
  }

  bool isContainedBy(JPosition other) {
    if (other.start <= start && end <= other.end) {
      return true;
    }

    return false;
  }

  bool isAdjacentTo(JPosition other) {
    throw Exception("NOT IMPLEMENTED");
  }

  Map<String, dynamic> toJson() => {
    "start": start,
    "size": size
  };

  static JPosition fromJson(Map<String, dynamic> json) {
    return JPosition(
        start: json["start"],
        size: json["size"]
    );
  }
}

abstract class IJCell<T> {
  String get uuid;

  JPosition get location;
  set location(JPosition newPosition);
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