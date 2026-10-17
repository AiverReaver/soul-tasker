# hearthrise_api.api.AccountApi

## Load the API package
```dart
import 'package:hearthrise_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAccount**](AccountApi.md#deleteaccount) | **DELETE** /v1/account | 


# **deleteAccount**
> deleteAccount()



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getAccountApi();

try {
    api.deleteAccount();
} catch on DioException (e) {
    print('Exception when calling AccountApi->deleteAccount: $e\n');
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

