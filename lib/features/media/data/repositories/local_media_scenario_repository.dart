import '../models/media_scenario.dart';
import 'media_scenario_repository.dart';

final class LocalMediaScenarioRepository implements MediaScenarioRepository {
  const LocalMediaScenarioRepository();

  @override
  MediaCatalog load() => const MediaCatalog(
    article: ArticleScenario(
      id: 'admin9-mobile-baseline',
      title: '从组件到可交付 App',
      summary: '通过真实启动、路由、状态与媒体生命周期验证移动端工程基线。',
      paragraphs: [
        '一个完整的移动应用不能只证明组件能够渲染。启动状态、隐私选择、导航栈和持久化必须在同一产品流程中协同工作。',
        '媒体场景进一步检验手势竞争、网络失败、前后台切换和系统控制。页面展示的是固定原型内容，底层能力仍由真实引擎执行。',
        '所有平台结论都绑定当前源码和当前设备证据。未执行的构建、安装和系统行为不会被描述为已经支持。',
      ],
      images: [
        MediaImageSource(
          kind: MediaImageKind.asset,
          location: 'assets/images/onboarding/collaborate.jpg',
          semanticLabel: '团队在办公室使用电脑协作',
        ),
        MediaImageSource(
          kind: MediaImageKind.asset,
          location: 'assets/images/onboarding/read.jpg',
          semanticLabel: '床上的书、手机和咖啡',
        ),
        MediaImageSource(
          kind: MediaImageKind.asset,
          location: 'assets/images/onboarding/act.jpg',
          semanticLabel: '使用手机处理日常事务',
        ),
      ],
    ),
    videos: [
      VideoScenario(
        id: 'local',
        title: '本地视频',
        description: '仓库内 H.264/AAC MP4，用于确定性播放与生命周期验证。',
        kind: VideoScenarioKind.local,
        location: 'assets/media/admin9_video_fixture.mp4',
      ),
      VideoScenario(
        id: 'network-mp4',
        title: '网络 MP4',
        description: 'Flutter 官方公开测试视频。',
        kind: VideoScenarioKind.networkMp4,
        location: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      VideoScenario(
        id: 'hls-vod',
        title: 'HLS 点播',
        description: 'Apple HLS 示例点播清单。',
        kind: VideoScenarioKind.hlsVod,
        location: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8',
      ),
      VideoScenario(
        id: 'hls-live',
        title: 'HLS 直播',
        description: 'Unified Streaming 公开直播测试源。',
        kind: VideoScenarioKind.hlsLive,
        location: 'https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8',
      ),
    ],
    audio: [
      AudioScenario(
        id: 'local-audio',
        title: 'Admin9 本地音频',
        artist: 'Admin9 Media Fixture',
        kind: AudioScenarioKind.onDemand,
        location: 'assets/media/admin9_audio_fixture.m4a',
      ),
      AudioScenario(
        id: 'live-audio',
        title: 'Radio Paradise 直播',
        artist: 'Radio Paradise',
        kind: AudioScenarioKind.live,
        location: 'https://stream.radioparadise.com/aac-320',
      ),
    ],
  );
}
