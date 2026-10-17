# hearthrise_api.api.AuthApi

## Load the API package
```dart
import 'package:hearthrise_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authGoogle**](AuthApi.md#authgoogle) | **POST** /v1/auth/google | 
[**logout**](AuthApi.md#logout) | **POST** /v1/auth/logout | 
[**me**](AuthApi.md#me) | **GET** /v1/me | 


# **authGoogle**
> Session authGoogle(authGoogleRequest)



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getAuthApi();
final AuthGoogleRequest authGoogleRequest = ; // AuthGoogleRequest | 

try {
    final response = api.authGoogle(authGoogleRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authGoogleRequest** | [**AuthGoogleRequest**](AuthGoogleRequest.md)|  | 

### Return type

[**Session**](Session.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout()



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getAuthApi();

try {
    api.logout();
} catch on DioException (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[session](../README.md#session)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **me**
> User me()



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getAuthApi();

try {
    final response = api.me();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->me: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[session](../README.md#session)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

