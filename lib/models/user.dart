import 'package:json_annotation/json_annotation.dart';
import 'role.dart';
import 'user_profile.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int userID;
  final String name;
  final String email;
  final String password;
  final String accountType;
  final int points;
  final int level;
  final List<Role> roles;
  final List<dynamic> purchasedItems;
  final UserProfile userProfile;

  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.accountType,
    required this.points,
    required this.level,
    required this.roles,
    required this.purchasedItems,
    required this.userProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
