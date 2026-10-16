//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hearthrise_api/src/model/push_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushResponse {
  /// Returns a new [PushResponse] instance.
  PushResponse({

    required  this.results,
  });

  @JsonKey(
    
    name: r'results',
    required: true,
    includeIfNull: false,
  )


  final List<PushResult> results;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushResponse &&
      other.results == results;

    @override
    int get hashCode =>
        results.hashCode;

  factory PushResponse.fromJson(Map<String, dynamic> json) => _$PushResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

