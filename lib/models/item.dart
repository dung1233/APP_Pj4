import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  @JsonKey(name: 'itemId')
  final int id;

  final String name;

  @JsonKey(name: 'pointsRequired')
  final int points;

  final int quantity;

  final String description;

  final double price;

  @JsonKey(name: 'durationInDays')
  final int durationInDays;

  @JsonKey(name: 'itemType')
  final String? itemType;

  Item({
    required this.id,
    required this.name,
    required this.points,
    required this.quantity,
    required this.description,
    required this.price,
    required this.durationInDays,
    this.itemType,
  });

  // Tạo factory constructor để chuyển đổi từ JSON sang Dart object
  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  // Phương thức chuyển đổi từ Dart object sang JSON
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  // Có thể thêm phương thức toString() để debug tiện hơn
  @override
  String toString() {
    return 'Item{id: $id, name: $name, points: $points, quantity: $quantity, description: $description, price: $price, durationInDays: $durationInDays, itemType: $itemType}';
  }
}
