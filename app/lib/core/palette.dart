import 'package:material_ui/material_ui.dart';

/// The design's 22 colour tokens. One instance per [Biome]; widgets read the
/// active one with `context.palette`.
@immutable
class HearthPalette extends ThemeExtension<HearthPalette> {
  const HearthPalette({
    required this.void_,
    required this.ground,
    required this.ground2,
    required this.voidfall,
    required this.shell,
    required this.raised,
    required this.raised2,
    required this.seam,
    required this.struckBg,
    required this.struckEdge,
    required this.deep,
    required this.silk,
    required this.silkHi,
    required this.onSilk,
    required this.bone,
    required this.text,
    required this.ash,
    required this.shard,
    required this.dim,
    required this.ink,
    required this.mote,
    required this.mask,
  });

  final Color void_, ground, ground2, voidfall;
  final Color shell, raised, raised2, seam, struckBg, struckEdge, deep;
  final Color silk, silkHi, onSilk;
  final Color bone, text, ash, shard, dim, ink, mote, mask;

  List<Color> get _all => [
    void_, ground, ground2, voidfall, shell, raised, raised2, seam, struckBg,
    struckEdge, deep, silk, silkHi, onSilk, bone, text, ash, shard, dim, ink,
    mote, mask, //
  ];

  @override
  HearthPalette copyWith({
    Color? void_,
    Color? ground,
    Color? ground2,
    Color? voidfall,
    Color? shell,
    Color? raised,
    Color? raised2,
    Color? seam,
    Color? struckBg,
    Color? struckEdge,
    Color? deep,
    Color? silk,
    Color? silkHi,
    Color? onSilk,
    Color? bone,
    Color? text,
    Color? ash,
    Color? shard,
    Color? dim,
    Color? ink,
    Color? mote,
    Color? mask,
  }) => HearthPalette(
    void_: void_ ?? this.void_,
    ground: ground ?? this.ground,
    ground2: ground2 ?? this.ground2,
    voidfall: voidfall ?? this.voidfall,
    shell: shell ?? this.shell,
    raised: raised ?? this.raised,
    raised2: raised2 ?? this.raised2,
    seam: seam ?? this.seam,
    struckBg: struckBg ?? this.struckBg,
    struckEdge: struckEdge ?? this.struckEdge,
    deep: deep ?? this.deep,
    silk: silk ?? this.silk,
    silkHi: silkHi ?? this.silkHi,
    onSilk: onSilk ?? this.onSilk,
    bone: bone ?? this.bone,
    text: text ?? this.text,
    ash: ash ?? this.ash,
    shard: shard ?? this.shard,
    dim: dim ?? this.dim,
    ink: ink ?? this.ink,
    mote: mote ?? this.mote,
    mask: mask ?? this.mask,
  );

  @override
  HearthPalette lerp(HearthPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HearthPalette(
      void_: l(void_, other.void_),
      ground: l(ground, other.ground),
      ground2: l(ground2, other.ground2),
      voidfall: l(voidfall, other.voidfall),
      shell: l(shell, other.shell),
      raised: l(raised, other.raised),
      raised2: l(raised2, other.raised2),
      seam: l(seam, other.seam),
      struckBg: l(struckBg, other.struckBg),
      struckEdge: l(struckEdge, other.struckEdge),
      deep: l(deep, other.deep),
      silk: l(silk, other.silk),
      silkHi: l(silkHi, other.silkHi),
      onSilk: l(onSilk, other.onSilk),
      bone: l(bone, other.bone),
      text: l(text, other.text),
      ash: l(ash, other.ash),
      shard: l(shard, other.shard),
      dim: l(dim, other.dim),
      ink: l(ink, other.ink),
      mote: l(mote, other.mote),
      mask: l(mask, other.mask),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HearthPalette &&
      _all.indexed.every((e) => e.$2 == other._all[e.$1]);

  @override
  int get hashCode => Object.hashAll(_all);
}

extension HearthPaletteContext on BuildContext {
  HearthPalette get palette =>
      Theme.of(this).extension<HearthPalette>() ?? Biome.pharloom.palette;
}

/// The database stores the index: add new biomes only at the end.
enum Biome {
  pharloom('Pharloom', Brightness.dark, _pharloom),
  docks('Deep Docks', Brightness.dark, _docks),
  choral('Choral Chambers', Brightness.light, _choral),
  moss('Moss Grotto', Brightness.light, _moss),
  greymoor('Greymoor', Brightness.dark, _greymoor);

  const Biome(this.label, this.brightness, this.palette);

  final String label;
  final Brightness brightness;
  final HearthPalette palette;
}

const _pharloom = HearthPalette(
  void_: Color(0xFF09060C),
  ground: Color(0xFF140B1C),
  ground2: Color(0xFF0D0811),
  voidfall: Color(0xFF060408),
  shell: Color(0xFF130E17),
  raised: Color(0xFF221828),
  raised2: Color(0xFF1C1420),
  seam: Color(0xFF3A2F3E),
  struckBg: Color(0xFF0F0B12),
  struckEdge: Color(0xFF241C28),
  deep: Color(0xFF7A2638),
  silk: Color(0xFFE8566D),
  silkHi: Color(0xFFEF6E83),
  onSilk: Color(0xFF09060C),
  bone: Color(0xFFF4EBDD),
  text: Color(0xFFE6DDCB),
  ash: Color(0xFFA79BA6),
  shard: Color(0xFFE9DFCB),
  dim: Color(0xFF5F5463),
  ink: Color(0xFF050307),
  mote: Color(0xFFB7A8D6),
  mask: Color(0xFFF4EBDD),
);

const _docks = HearthPalette(
  void_: Color(0xFF0B0806),
  ground: Color(0xFF1F120A),
  ground2: Color(0xFF120B07),
  voidfall: Color(0xFF070504),
  shell: Color(0xFF16100C),
  raised: Color(0xFF2B1B10),
  raised2: Color(0xFF21150E),
  seam: Color(0xFF403126),
  struckBg: Color(0xFF110C09),
  struckEdge: Color(0xFF2A2019),
  deep: Color(0xFF8C3B12),
  silk: Color(0xFFFF7A2E),
  silkHi: Color(0xFFFF9550),
  onSilk: Color(0xFF160A03),
  bone: Color(0xFFFBE9D4),
  text: Color(0xFFEDDCC6),
  ash: Color(0xFFB3A291),
  shard: Color(0xFFF4BB84),
  dim: Color(0xFF6D5C4D),
  ink: Color(0xFF050302),
  mote: Color(0xFFFFAE63),
  mask: Color(0xFFEAD9C4),
);

const _choral = HearthPalette(
  void_: Color(0xFFEFE6D1),
  ground: Color(0xFFFBF3E0),
  ground2: Color(0xFFF4EAD3),
  voidfall: Color(0xFFE8DCC2),
  shell: Color(0xFFFFFAF0),
  raised: Color(0xFFF5E6C2),
  raised2: Color(0xFFFBF1DA),
  seam: Color(0xFFD6C49C),
  struckBg: Color(0xFFF1E8D3),
  struckEdge: Color(0xFFE3D6B7),
  deep: Color(0xFFB8913F),
  silk: Color(0xFF94640F),
  silkHi: Color(0xFFA87414),
  onSilk: Color(0xFFFFFAF0),
  bone: Color(0xFF2A1E0F),
  text: Color(0xFF3B2D1B),
  ash: Color(
    0xFF6B5A41,
  ), // Design hex C49030 is 2.4:1 on shell; darkened to meet the 3:1 gate.
  shard: Color(0xFFB8872D),
  dim: Color(0xFFB7A37F),
  ink: Color(0xFF2A1E0F),
  mote: Color(0xFFC49030),
  mask: Color(0xFFFFFAF0),
);

const _moss = HearthPalette(
  void_: Color(0xFFE7EEDC),
  ground: Color(0xFFF2F6E8),
  ground2: Color(0xFFE9EFDD),
  voidfall: Color(0xFFDFE7D0),
  shell: Color(0xFFFBFDF5),
  raised: Color(0xFFE4EECF),
  raised2: Color(0xFFF1F6E6),
  seam: Color(0xFFC3D2A8),
  struckBg: Color(0xFFEEF2E4),
  struckEdge: Color(0xFFD9E2C8),
  deep: Color(0xFF7FA05A),
  silk: Color(0xFF3D6B2C),
  silkHi: Color(0xFF4A7D36),
  onSilk: Color(0xFFFBFDF5),
  bone: Color(0xFF1C2A1A),
  text: Color(0xFF2A3A27),
  ash: Color(
    0xFF5A6B52,
  ), // Design hex 8DB255 is 2.2:1 on shell; darkened to meet the 3:1 gate.
  shard: Color(0xFF7C9C4A),
  dim: Color(0xFFA9B894),
  ink: Color(0xFF1C2A1A),
  mote: Color(0xFF8DB255),
  mask: Color(0xFFFBFDF5),
);

const _greymoor = HearthPalette(
  void_: Color(0xFF0A0D11),
  ground: Color(0xFF131B24),
  ground2: Color(0xFF0D1218),
  voidfall: Color(0xFF080A0D),
  shell: Color(0xFF111820),
  raised: Color(0xFF1C2733),
  raised2: Color(0xFF16202A),
  seam: Color(0xFF2E3B48),
  struckBg: Color(0xFF0D1218),
  struckEdge: Color(0xFF1D2630),
  deep: Color(0xFF2F4A62),
  silk: Color(0xFF7FB2D9),
  silkHi: Color(0xFF98C4E6),
  onSilk: Color(0xFF08121C),
  bone: Color(0xFFE9EEF2),
  text: Color(0xFFD5DDE3),
  ash: Color(0xFF9AA7B2),
  shard: Color(0xFFCFDBE4),
  dim: Color(0xFF4F5D6A),
  ink: Color(0xFF04070A),
  mote: Color(0xFFA9C3D6),
  mask: Color(0xFFE3E9EE),
);
