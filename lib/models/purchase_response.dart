// purchase_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'purchase_response.g.dart';

@JsonSerializable()
class PurchaseResponse {
  final bool success;
  final String message;
  final int? remainingPoints;

  PurchaseResponse({
    required this.success,
    required this.message,
    this.remainingPoints,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseResponseToJson(this);
}
