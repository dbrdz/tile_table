import 'package:uuid/uuid.dart';

import '../serializers/value_serializers.dart';
import 'i_jcell.dart';

class JCell<T> implements IJCell<T> {
  JCell({ required this.location, required this.value, uuid }) :
    uuid = uuid ?? const Uuid().v4();

  @override
  String uuid;

  @override
  JPosition location;

  @override
  T value;

  @override
  void grow() {
    location = JPosition(start: location.start, size: location.size + 1);
  }

  @override
  void moveLeft() {
    if (location.start > 0) {
      location = JPosition(start: location.start - 1, size: location.size);
    }
  }

  @override
  void moveRight() {
    location = JPosition(start: location.start + 1, size: location.size);
  }

  @override
  void setStart(int start) {
    location = JPosition(start: start, size: location.size);
  }

  @override
  void setSize(int newSize) {
    location = JPosition(start: location.start, size: newSize);
  }

  @override
  void shrink() {
    if (location.size > 1) {
      location = JPosition(start: location.start, size: location.size - 1);
    }
  }

  @override
  Map<String, dynamic> toJson(ValueSerializer<T> valueSerializer) => {
    "uuid": uuid,
    "location": location.toJson(),
    "value": valueSerializer(value)
  };

  static JCell<T> fromJson<T>(Map<String, dynamic> json, ValueDeserializer<T> valueDeserializer) {
    return JCell<T>(
        uuid: json['uuid'] ?? const Uuid().v4(),
        location: JPosition.fromJson(json["location"]),
        value: valueDeserializer(json["value"])
    );
  }
}