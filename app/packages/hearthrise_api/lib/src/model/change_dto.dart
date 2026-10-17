//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'change_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeDto {
  /// Returns a new [ChangeDto] instance.
  ChangeDto({

    required  this.table,

    required  this.id,

    required  this.op,

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


  final ChangeDtoOpEnum op;



      /// Required on an upsert of a mutable table.
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
    bool operator ==(Object other) => identical(this, other) || other is ChangeDto &&
      other.table == table &&
      other.id == id &&
      other.op == op &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.row == row;

    @override
    int get hashCode =>
        table.hashCode +
        id.hashCode +
        op.hashCode +
        updatedAt.hashCode +
        deletedAt.hashCode +
        row.hashCode;

  factory ChangeDto.fromJson(Map<String, dynamic> json) => _$ChangeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ChangeDtoOpEnum {
@JsonValue(r'upsert')
upsert(r'upsert'),
@JsonValue(r'delete')
delete(r'delete');

const ChangeDtoOpEnum(this.value);

final String value;

@override
String toString() => value;
}


