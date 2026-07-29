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
  `5eae14cab5d184fef3bc9bc522661bbb7c0b0603df79228ff09df26b7f15a314`
- Subset coverage: ASCII, common CJK punctuation, and Han glyphs present in
  `lib/` and `test/` when the Phase 5 fixture was generated.
- License: SIL Open Font License 1.1, in `OFL.txt`.

The subset was generated with FontTools `pyftsubset`; regenerate it whenever a
Golden introduces a Chinese glyph not present in the fixture. The repository's
runtime default remains the Android/iOS system font.
