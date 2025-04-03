// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseResponse _$PurchaseResponseFromJson(Map<String, dynamic> json) =>
    PurchaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      remainingPoints: (json['remainingPoints'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PurchaseResponseToJson(PurchaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'remainingPoints': instance.remainingPoints,
    };
