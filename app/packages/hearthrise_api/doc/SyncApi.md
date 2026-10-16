# hearthrise_api.api.SyncApi

## Load the API package
```dart
import 'package:hearthrise_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**syncPull**](SyncApi.md#syncpull) | **GET** /v1/sync/pull | 
[**syncPush**](SyncApi.md#syncpush) | **POST** /v1/sync/push | 


# **syncPull**
> PullResponse syncPull(since)



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getSyncApi();
final int since = 56; // int | 

try {
    final response = api.syncPull(since);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SyncApi->syncPull: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **int**|  | 

### Return type

[**PullResponse**](PullResponse.md)

### Authorization

[session](../README.md#session)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPush**
> PushResponse syncPush(pushRequest)



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getSyncApi();
final PushRequest pushRequest = ; // PushRequest | 

try {
    final response = api.syncPush(pushRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SyncApi->syncPush: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushRequest** | [**PushRequest**](PushRequest.md)|  | 

### Return type

[**PushResponse**](PushResponse.md)

### Authorization

[session](../README.md#session)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

