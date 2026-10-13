import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Record ids are uuid v4 so they stay unique across devices (Stage 7 sync).
String newId() => _uuid.v4();
