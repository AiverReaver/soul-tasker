// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_google_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthGoogleRequest _$AuthGoogleRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthGoogleRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['idToken']);
      final val = AuthGoogleRequest(
        idToken: $checkedConvert('idToken', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AuthGoogleRequestToJson(AuthGoogleRequest instance) =>
    <String, dynamic>{'idToken': instance.idToken};
