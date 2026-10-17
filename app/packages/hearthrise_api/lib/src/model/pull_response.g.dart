// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullResponse _$PullResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['changes', 'cursor', 'hasMore']);
      final val = PullResponse(
        changes: $checkedConvert(
          'changes',
          (v) => (v as List<dynamic>)
              .map((e) => PulledChangeDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        cursor: $checkedConvert('cursor', (v) => (v as num).toInt()),
        hasMore: $checkedConvert('hasMore', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PullResponseToJson(PullResponse instance) =>
    <String, dynamic>{
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'cursor': instance.cursor,
      'hasMore': instance.hasMore,
    };
