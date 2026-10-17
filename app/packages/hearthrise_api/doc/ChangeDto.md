# hearthrise_api.model.ChangeDto

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
**updatedAt** | **String** | Required on an upsert of a mutable table. | [optional] 
**deletedAt** | **String** |  | [optional] 
**row** | **Map&lt;String, Object&gt;** | Payload columns in snake_case, as in the app database. Absent on a delete. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


