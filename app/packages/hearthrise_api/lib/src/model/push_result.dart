//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'push_result.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushResult {
  /// Returns a new [PushResult] instance.
  PushResult({

    required  this.table,

    required  this.id,

    required  this.status,

     this.reason,

     this.message,
  });

  @JsonKey(
    
    name: r'table',
    required: true,
    includeIfNull: false,
  )


  final String table;



  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PushResultStatusEnum status;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final PushResultReasonEnum? reason;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushResult &&
      other.table == table &&
      other.id == id &&
      other.status == status &&
      other.reason == reason &&
      other.message == message;

    @override
    int get hashCode =>
        table.hashCode +
        id.hashCode +
        status.hashCode +
        reason.hashCode +
        message.hashCode;

  factory PushResult.fromJson(Map<String, dynamic> json) => _$PushResultFromJson(json);

  Map<String, dynamic> toJson() => _$PushResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PushResultStatusEnum {
@JsonValue(r'applied')
applied(r'applied'),
@JsonValue(r'ignored')
ignored(r'ignored'),
@JsonValue(r'rejected')
rejected(r'rejected');

const PushResultStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PushResultReasonEnum {
@JsonValue(r'clock')
clock(r'clock'),
@JsonValue(r'malformed')
malformed(r'malformed');

const PushResultReasonEnum(this.value);

final String value;

@override
String toString() => value;
}


