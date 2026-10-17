// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushResponse _$PushResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['results']);
      final val = PushResponse(
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => PushResult.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushResponseToJson(PushResponse instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
