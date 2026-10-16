# hearthrise_api.api.HealthApi

## Load the API package
```dart
import 'package:hearthrise_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**health**](HealthApi.md#health) | **GET** /v1/health | 


# **health**
> Health health()



### Example
```dart
import 'package:hearthrise_api/api.dart';

final api = HearthriseApi().getHealthApi();

try {
    final response = api.health();
    print(response);
} catch on DioException (e) {
    print('Exception when calling HealthApi->health: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

