//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hearthrise_api/src/model/pulled_change_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullResponse {
  /// Returns a new [PullResponse] instance.
  PullResponse({

    required  this.changes,

    required  this.cursor,

    required  this.hasMore,
  });

  @JsonKey(
    
    name: r'changes',
    required: true,
    includeIfNull: false,
  )


  final List<PulledChangeDto> changes;



  @JsonKey(
    
    name: r'cursor',
    required: true,
    includeIfNull: false,
  )


  final int cursor;



  @JsonKey(
    
    name: r'hasMore',
    required: true,
    includeIfNull: false,
  )


  final bool hasMore;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullResponse &&
      other.changes == changes &&
      other.cursor == cursor &&
      other.hasMore == hasMore;

    @override
    int get hashCode =>
        changes.hashCode +
        cursor.hashCode +
        hasMore.hashCode;

  factory PullResponse.fromJson(Map<String, dynamic> json) => _$PullResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PullResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

