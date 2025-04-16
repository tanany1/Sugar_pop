// Hive model for blood sugar readings
import 'package:hive_flutter/adapters.dart';

@HiveType(typeId: 0)
class BloodSugarReading extends HiveObject {
  @HiveField(0)
  final int value;

  @HiveField(1)
  final DateTime timestamp;

  BloodSugarReading({required this.value, required this.timestamp});
}

// Hive adapter for BloodSugarReading
class BloodSugarReadingAdapter extends TypeAdapter<BloodSugarReading> {
  @override
  final typeId = 0;

  @override
  BloodSugarReading read(BinaryReader reader) {
    return BloodSugarReading(
      value: reader.readInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, BloodSugarReading obj) {
    writer.writeInt(obj.value);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}