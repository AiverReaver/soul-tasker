// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteAccountRequest _$DeleteAccountRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeleteAccountRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['idToken', 'confirm']);
  final val = DeleteAccountRequest(
    idToken: $checkedConvert('idToken', (v) => v as String),
    confirm: $checkedConvert('confirm', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$DeleteAccountRequestToJson(
  DeleteAccountRequest instance,
) => <String, dynamic>{
  'idToken': instance.idToken,
  'confirm': instance.confirm,
};
