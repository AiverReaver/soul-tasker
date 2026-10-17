//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'health.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Health {
  /// Returns a new [Health] instance.
  Health({

    required  this.status,

    required  this.version,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Health &&
      other.status == status &&
      other.version == version;

    @override
    int get hashCode =>
        status.hashCode +
        version.hashCode;

  factory Health.fromJson(Map<String, dynamic> json) => _$HealthFromJson(json);

  Map<String, dynamic> toJson() => _$HealthToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

