// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: (json['itemId'] as num).toInt(),
      name: json['name'] as String,
      points: (json['pointsRequired'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationInDays: (json['durationInDays'] as num).toInt(),
      itemType: json['itemType'] as String,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'itemId': instance.id,
      'name': instance.name,
      'pointsRequired': instance.points,
      'quantity': instance.quantity,
      'description': instance.description,
      'price': instance.price,
      'durationInDays': instance.durationInDays,
      'itemType': instance.itemType,
    };
