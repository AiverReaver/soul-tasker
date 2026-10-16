// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deviceId', 'changes']);
      final val = PushRequest(
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        changes: $checkedConvert(
          'changes',
          (v) => (v as List<dynamic>)
              .map((e) => ChangeDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };
