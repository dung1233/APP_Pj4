// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userID: (json['userID'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      accountType: json['accountType'] as String,
      points: (json['points'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      roles: (json['roles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      purchasedItems: json['purchasedItems'] as List<dynamic>,
      userProfile:
          UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userID': instance.userID,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'accountType': instance.accountType,
      'points': instance.points,
      'level': instance.level,
      'roles': instance.roles,
      'purchasedItems': instance.purchasedItems,
      'userProfile': instance.userProfile,
    };
