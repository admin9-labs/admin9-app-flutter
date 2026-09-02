# Media Scenario Sources

## Contract

The Media Feature uses fixed local fixtures and public HTTPS demonstration
sources through `LocalMediaScenarioRepository`. These sources demonstrate real
engine behavior without defining a production content backend. Deterministic
tests use local assets; network availability and platform decoding require fresh
runtime evidence and remain `Unknown` when not executed.

No source may receive an account, token, device identifier, advertising ID,
location, contacts, or user input. A derived product must replace public demo
sources with operator-controlled sources before claiming production service
availability.

## Registered Sources

| Scenario | Source | Purpose and provenance |
| --- | --- | --- |
| Article images | `assets/images/onboarding/*.jpg` | Licensed Unsplash photographs recorded in `assets/images/onboarding/README.md` |
| Local video | `assets/media/admin9_video_fixture.mp4` | Repository-generated H.264/AAC test pattern; generation recorded in the asset README |
| Network MP4 | `flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4` | Flutter documentation fixture |
| HLS VOD | Apple BipBop example playlist | Public HLS developer example; external availability is not deterministic evidence |
| HLS live | Unified Streaming stable live demo | Public playback demo; external availability is not a service guarantee |
| Local audio | `assets/media/admin9_audio_fixture.m4a` | Repository-generated AAC chord fixture; generation recorded in the asset README |
| Live audio | Radio Paradise AAC stream | Public listener stream; replace before production delivery |

All network locations are HTTPS. The App performs no automatic media prefetch;
requests start only after the user opens the corresponding scenario.
