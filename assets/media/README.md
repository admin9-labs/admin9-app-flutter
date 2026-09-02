# Media Scenario Sources

Files in this directory are repository-generated deterministic fixtures for the
Media Feature. They contain no third-party recording or personal data. Network
fixtures are documented in `docs/media-sources.md` and are never required by
deterministic test suites.

| File | Encoding | Duration | SHA-256 |
| --- | --- | --- | --- |
| `admin9_video_fixture.mp4` | 1280x720 H.264 + 44.1kHz AAC mono | 8s | `667c6bcd0f28fab789334a754b2d998d7136f0d47792a94a95be1dfa34388273` |
| `admin9_audio_fixture.m4a` | 44.1kHz AAC mono | 20s | `e37922bb43e32ab164292a287cfdbc83ca099e7cbf7f9fa26003b4b8880f8681` |

Generation commands use FFmpeg 8.1.2:

```shell
ffmpeg -y -f lavfi -i testsrc2=size=1280x720:rate=30 \
  -f lavfi -i sine=frequency=440:sample_rate=44100 -t 8 \
  -c:v libx264 -pix_fmt yuv420p -preset veryfast -crf 25 \
  -c:a aac -b:a 96k -shortest assets/media/admin9_video_fixture.mp4

ffmpeg -y \
  -f lavfi -i sine=frequency=261.63:sample_rate=44100:duration=20 \
  -f lavfi -i sine=frequency=329.63:sample_rate=44100:duration=20 \
  -f lavfi -i sine=frequency=392:sample_rate=44100:duration=20 \
  -filter_complex \
  '[0:a][1:a][2:a]amix=inputs=3:normalize=0,volume=0.12,afade=t=in:st=0:d=1,afade=t=out:st=19:d=1[a]' \
  -map '[a]' -c:a aac -b:a 128k assets/media/admin9_audio_fixture.m4a
```
