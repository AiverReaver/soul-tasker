// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulled_change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulledChangeDto _$PulledChangeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PulledChangeDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['table', 'id', 'op', 'seq', 'deviceId'],
      );
      final val = PulledChangeDto(
        table: $checkedConvert('table', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String),
        op: $checkedConvert(
          'op',
          (v) => $enumDecode(_$PulledChangeDtoOpEnumEnumMap, v),
        ),
        seq: $checkedConvert('seq', (v) => (v as num).toInt()),
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
        deletedAt: $checkedConvert('deletedAt', (v) => v as String?),
        row: $checkedConvert('row', (v) => v as Map<String, dynamic>?),
      );
      return val;
    });

Map<String, dynamic> _$PulledChangeDtoToJson(PulledChangeDto instance) =>
    <String, dynamic>{
      'table': instance.table,
      'id': instance.id,
      'op': _$PulledChangeDtoOpEnumEnumMap[instance.op]!,
      'seq': instance.seq,
      'deviceId': instance.deviceId,
      'updatedAt': ?instance.updatedAt,
      'deletedAt': ?instance.deletedAt,
      'row': ?instance.row,
    };

const _$PulledChangeDtoOpEnumEnumMap = {
  PulledChangeDtoOpEnum.upsert: 'upsert',
  PulledChangeDtoOpEnum.delete: 'delete',
};
