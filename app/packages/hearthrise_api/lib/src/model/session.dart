//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hearthrise_api/src/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Session {
  /// Returns a new [Session] instance.
  Session({

    required  this.token,

    required  this.expiresAt,

    required  this.user,
  });

      /// Opaque bearer token; only its hash is stored.
  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;



  @JsonKey(
    
    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final User user;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Session &&
      other.token == token &&
      other.expiresAt == expiresAt &&
      other.user == user;

    @override
    int get hashCode =>
        token.hashCode +
        expiresAt.hashCode +
        user.hashCode;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

