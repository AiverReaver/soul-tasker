// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushResult _$PushResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushResult', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['table', 'id', 'status']);
      final val = PushResult(
        table: $checkedConvert('table', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$PushResultStatusEnumEnumMap, v),
        ),
        reason: $checkedConvert(
          'reason',
          (v) => $enumDecodeNullable(_$PushResultReasonEnumEnumMap, v),
        ),
        message: $checkedConvert('message', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PushResultToJson(PushResult instance) =>
    <String, dynamic>{
      'table': instance.table,
      'id': instance.id,
      'status': _$PushResultStatusEnumEnumMap[instance.status]!,
      'reason': ?_$PushResultReasonEnumEnumMap[instance.reason],
      'message': ?instance.message,
    };

const _$PushResultStatusEnumEnumMap = {
  PushResultStatusEnum.applied: 'applied',
  PushResultStatusEnum.ignored: 'ignored',
  PushResultStatusEnum.rejected: 'rejected',
};

const _$PushResultReasonEnumEnumMap = {
  PushResultReasonEnum.clock: 'clock',
  PushResultReasonEnum.malformed: 'malformed',
};
