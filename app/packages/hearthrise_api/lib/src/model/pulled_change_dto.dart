//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'pulled_change_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PulledChangeDto {
  /// Returns a new [PulledChangeDto] instance.
  PulledChangeDto({

    required  this.table,

    required  this.id,

    required  this.op,

    required  this.seq,

    required  this.deviceId,

     this.updatedAt,

     this.deletedAt,

     this.row,
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
    
    name: r'op',
    required: true,
    includeIfNull: false,
  )


  final PulledChangeDtoOpEnum op;



  @JsonKey(
    
    name: r'seq',
    required: true,
    includeIfNull: false,
  )


  final int seq;



  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final String? updatedAt;



  @JsonKey(
    
    name: r'deletedAt',
    required: false,
    includeIfNull: false,
  )


  final String? deletedAt;



      /// Payload columns in snake_case, as in the app database. Absent on a delete.
  @JsonKey(
    
    name: r'row',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? row;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PulledChangeDto &&
      other.table == table &&
      other.id == id &&
      other.op == op &&
      other.seq == seq &&
      other.deviceId == deviceId &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.row == row;

    @override
    int get hashCode =>
        table.hashCode +
        id.hashCode +
        op.hashCode +
        seq.hashCode +
        deviceId.hashCode +
        updatedAt.hashCode +
        deletedAt.hashCode +
        row.hashCode;

  factory PulledChangeDto.fromJson(Map<String, dynamic> json) => _$PulledChangeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PulledChangeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PulledChangeDtoOpEnum {
@JsonValue(r'upsert')
upsert(r'upsert'),
@JsonValue(r'delete')
delete(r'delete');

const PulledChangeDtoOpEnum(this.value);

final String value;

@override
String toString() => value;
}


