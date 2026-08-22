# Golden CJK font fixture

`Admin9GoldenCJK-Regular.otf` is a test-only subset of Noto Sans CJK SC
Regular. It prevents Flutter's deterministic Golden test environment from
rendering Chinese text as missing-glyph boxes. It is loaded with `FontLoader`
from tests and is not declared in `pubspec.yaml`, bundled in the App, or used by
the runtime typography system.

- Upstream source: `notofonts/noto-cjk`,
  `Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf`
- Upstream SHA-256:
  `2c76254f6fc379fddfce0a7e84fb5385bb135d3e399294f6eeb6680d0365b74b`
- Subset SHA-256:
  `6c6f8964c79de069e6dadd48f5c0016ffaa83b713ef2b03c0ad9076815aa3769`
- Subset coverage: ASCII, common CJK punctuation, and Han glyphs present in
  `lib/` and `test/` when the G2 supervision fixture was generated.
- Subset tool: FontTools `4.59.1`.
- License: SIL Open Font License 1.1, in `OFL.txt`.

The subset was generated with FontTools `pyftsubset`; regenerate it whenever a
Golden introduces a Chinese glyph not present in the fixture. The repository's
runtime default remains the Android/iOS system font.
