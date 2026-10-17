// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeDto _$ChangeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChangeDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['table', 'id', 'op']);
      final val = ChangeDto(
        table: $checkedConvert('table', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String),
        op: $checkedConvert(
          'op',
          (v) => $enumDecode(_$ChangeDtoOpEnumEnumMap, v),
        ),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
        deletedAt: $checkedConvert('deletedAt', (v) => v as String?),
        row: $checkedConvert('row', (v) => v as Map<String, dynamic>?),
      );
      return val;
    });

Map<String, dynamic> _$ChangeDtoToJson(ChangeDto instance) => <String, dynamic>{
  'table': instance.table,
  'id': instance.id,
  'op': _$ChangeDtoOpEnumEnumMap[instance.op]!,
  'updatedAt': ?instance.updatedAt,
  'deletedAt': ?instance.deletedAt,
  'row': ?instance.row,
};

const _$ChangeDtoOpEnumEnumMap = {
  ChangeDtoOpEnum.upsert: 'upsert',
  ChangeDtoOpEnum.delete: 'delete',
};
