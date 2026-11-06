/// The cast of original hand-drawn bosses (see BossArt). Each is its own
/// silhouette with its own idle motion, all in the same ink and palette
/// tokens. Stored on each boss by index: only append; never reorder.
enum BossDesign {
  /// Porcelain mask, horns, ragged cloak and a quill lance.
  porcelain,

  /// A crowned lord grown heavy with grafted arms that will not keep still.
  grafted,

  /// A winged helm and a blade, a scarlet bloom opening behind.
  rotBloom,

  /// A towering lady in a wide hat, one hand of long claws raised.
  matron,

  /// A mutated mass with a great shoulder eye and a beating heart.
  host,

  /// An old horned wyrm, ember in its jaw.
  wyrm,

  /// A gaunt girl who shrinks from a guttering lantern, face hidden in hair.
  lightless,

  /// A hunched hulk whose back is a field of swelling, glowing cysts.
  blister,
}

/// The design for a boss with none stored (a row from before designs, or
/// from an older phone): picked from its id, so it never changes.
BossDesign bossDesignFor(String id) {
  // FNV-1a: String.hashCode is not promised stable between runs.
  var h = 0x811c9dc5;
  for (final c in id.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return BossDesign.values[h % BossDesign.values.length];
}
