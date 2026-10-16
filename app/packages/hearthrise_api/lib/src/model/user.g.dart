// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('User', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'email']);
      final val = User(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
};
