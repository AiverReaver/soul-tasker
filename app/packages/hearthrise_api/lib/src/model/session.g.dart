// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Session', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token', 'expiresAt', 'user']);
      final val = Session(
        token: $checkedConvert('token', (v) => v as String),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
        user: $checkedConvert(
          'user',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'token': instance.token,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};
