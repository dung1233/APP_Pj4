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

  Item({
    required this.id,
    required this.name,
    required this.points,
    required this.quantity,
    required this.description,
  });

  // Tạo factory constructor để chuyển đổi từ JSON sang Dart object
  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  // Phương thức chuyển đổi từ Dart object sang JSON
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  // Có thể thêm phương thức toString() để debug tiện hơn
  @override
  String toString() {
    return 'Item{id: $id, name: $name, points: $points, quantity: $quantity, description: $description}';
  }
}
