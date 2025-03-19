// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_out.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      day: fields[0] as int?,
      img: fields[1] as String?,
      icon: fields[2] as String?,
      exerciseName: fields[3] as String?,
      sets: fields[4] as int?,
      reps: fields[5] as int?,
      duration: fields[6] as int?,
      restDay: fields[7] as bool?,
      distance: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.img)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.exerciseName)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.restDay)
      ..writeByte(8)
      ..write(obj.distance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      day: (json['day'] as num?)?.toInt(),
      img: json['img'] as String?,
      icon: json['icon'] as String?,
      exerciseName: json['exerciseName'] as String?,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      restDay: json['restDay'] as bool?,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'day': instance.day,
      'img': instance.img,
      'icon': instance.icon,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'restDay': instance.restDay,
      'distance': instance.distance,
    };
