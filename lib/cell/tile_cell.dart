import 'package:uuid/uuid.dart';

import '../serializers/value_serializers.dart';
import 'tile_cell_position.dart';

class TileCell<T> {
  TileCell({ required this.location, required this.value, uuid }) :
    uuid = uuid ?? const Uuid().v4();

  @override
  String uuid;

  @override
  TileCellPosition location;

  @override
  T value;

  @override
  void grow() {
    location = TileCellPosition(start: location.start, size: location.size + 1);
  }

  @override
  void moveLeft() {
    if (location.start > 0) {
      location = TileCellPosition(start: location.start - 1, size: location.size);
    }
  }

  @override
  void moveRight() {
    location = TileCellPosition(start: location.start + 1, size: location.size);
  }

  @override
  void setStart(int start) {
    location = TileCellPosition(start: start, size: location.size);
  }

  @override
  void setSize(int newSize) {
    location = TileCellPosition(start: location.start, size: newSize);
  }

  @override
  void shrink() {
    if (location.size > 1) {
      location = TileCellPosition(start: location.start, size: location.size - 1);
    }
  }

  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "uuid": uuid,
    "location": location.toJson(),
    "value": valueSerializer(value)
  };

  static TileCell<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return TileCell<T>(
        uuid: json['uuid'] ?? const Uuid().v4(),
        location: TileCellPosition.fromJson(json["location"]),
        value: valueDeserializer(json["value"])
    );
  }
}