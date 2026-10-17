//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'delete_account_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeleteAccountRequest {
  /// Returns a new [DeleteAccountRequest] instance.
  DeleteAccountRequest({

    required  this.idToken,

    required  this.confirm,
  });

  @JsonKey(
    
    name: r'idToken',
    required: true,
    includeIfNull: false,
  )


  final String idToken;



  @JsonKey(
    
    name: r'confirm',
    required: true,
    includeIfNull: false,
  )


  final bool confirm;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeleteAccountRequest &&
      other.idToken == idToken &&
      other.confirm == confirm;

    @override
    int get hashCode =>
        idToken.hashCode +
        confirm.hashCode;

  factory DeleteAccountRequest.fromJson(Map<String, dynamic> json) => _$DeleteAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

