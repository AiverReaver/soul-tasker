import 'package:hearthrise_api/src/model/auth_google_request.dart';
import 'package:hearthrise_api/src/model/change_dto.dart';
import 'package:hearthrise_api/src/model/delete_account_request.dart';
import 'package:hearthrise_api/src/model/error.dart';
import 'package:hearthrise_api/src/model/health.dart';
import 'package:hearthrise_api/src/model/pull_response.dart';
import 'package:hearthrise_api/src/model/pulled_change_dto.dart';
import 'package:hearthrise_api/src/model/push_request.dart';
import 'package:hearthrise_api/src/model/push_response.dart';
import 'package:hearthrise_api/src/model/push_result.dart';
import 'package:hearthrise_api/src/model/session.dart';
import 'package:hearthrise_api/src/model/user.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AuthGoogleRequest':
          return AuthGoogleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangeDto':
          return ChangeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeleteAccountRequest':
          return DeleteAccountRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Error':
          return Error.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Health':
          return Health.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullResponse':
          return PullResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PulledChangeDto':
          return PulledChangeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushRequest':
          return PushRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushResponse':
          return PushResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushResult':
          return PushResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Session':
          return Session.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'User':
          return User.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }