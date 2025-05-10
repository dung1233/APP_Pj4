import 'package:json_annotation/json_annotation.dart';
import 'permission.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  final String name;
  final String description;
  final List<Permission> permissions;

  Role({
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
