import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Fixed namespace for [systemId]; never change it, or old ids stop
/// matching new ones.
const _systemNamespace = '5b0f3c3e-6a51-4d8e-9a43-2f1d7c9e8b60';

/// Record ids are uuid v4 so they stay unique across devices (Stage 7 sync).
String newId() => _uuid.v4();

/// The id of a record the app makes for a reason two phones can share, such
/// as a missed day (Stage 7 plan D6): a uuid v5 of [parts], so both phones
/// write the same id and the merge keeps one.
String systemId(List<Object> parts) => _uuid.v5(
  _systemNamespace,
  // Length-prefixed, so ('ab', 'c') and ('a', 'bc') differ.
  [for (final p in parts) '${'$p'.length}:$p'].join('|'),
);
