# hearthrise_api.model.PulledChangeDto

## Load the model package
```dart
import 'package:hearthrise_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**table** | **String** |  | 
**id** | **String** |  | 
**op** | **String** |  | 
**seq** | **int** |  | 
**deviceId** | **String** |  | 
**updatedAt** | **String** |  | [optional] 
**deletedAt** | **String** |  | [optional] 
**row** | **Map&lt;String, Object&gt;** | Payload columns in snake_case, as in the app database. Absent on a delete. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


