//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hearthrise_api/src/model/change_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushRequest {
  /// Returns a new [PushRequest] instance.
  PushRequest({

    required  this.deviceId,

    required  this.changes,
  });

  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'changes',
    required: true,
    includeIfNull: false,
  )


  final List<ChangeDto> changes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushRequest &&
      other.deviceId == deviceId &&
      other.changes == changes;

    @override
    int get hashCode =>
        deviceId.hashCode +
        changes.hashCode;

  factory PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

