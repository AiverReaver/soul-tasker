//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'auth_google_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthGoogleRequest {
  /// Returns a new [AuthGoogleRequest] instance.
  AuthGoogleRequest({

    required  this.idToken,
  });

      /// A Google ID token for the Web client id.
  @JsonKey(
    
    name: r'idToken',
    required: true,
    includeIfNull: false,
  )


  final String idToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuthGoogleRequest &&
      other.idToken == idToken;

    @override
    int get hashCode =>
        idToken.hashCode;

  factory AuthGoogleRequest.fromJson(Map<String, dynamic> json) => _$AuthGoogleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthGoogleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

