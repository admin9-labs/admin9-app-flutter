import '../../domain/models/foundation_models.dart';

class FoundationRepository {
  const FoundationRepository();

  List<FoundationMessage> get messages {
    return const [
      FoundationMessage(
        id: 'm1',
        category: MessageCategory.system,
        title: '账号安全和外观设置已支持本地保存。',
        time: '2026-06-06 13:00:34',
        unread: true,
      ),
      FoundationMessage(
        id: 'm2',
        category: MessageCategory.system,
        title: '欢迎使用西昌发布。',
        time: '2026-06-06 12:44:56',
        unread: true,
      ),
      FoundationMessage(
        id: 'm3',
        category: MessageCategory.comments,
        title: '你关注的线索有了新的编辑回复。',
        time: '2026-06-05 18:21:09',
      ),
      FoundationMessage(
        id: 'm4',
        category: MessageCategory.likes,
        title: '你收藏的专题更新了 2 条新内容。',
        time: '2026-06-05 09:12:18',
      ),
    ];
  }

  List<ReportContact> get reportContacts {
    return const [
      ReportContact(label: '举报电话', value: '028-69981277', iconKey: 'phone'),
      ReportContact(label: '举报电话', value: '028-962377', iconKey: 'phone'),
      ReportContact(
        label: '举报邮箱',
        value: 'foundation-demo@example.com',
        iconKey: 'mail',
      ),
    ];
  }

  AgreementDocument agreement(String id) {
    return switch (id) {
      'privacy' => const AgreementDocument(
        id: 'privacy',
        title: '隐私政策',
        content:
            '本隐私政策适用于西昌发布客户端原型内已提供的本地功能。我们仅为展示新闻浏览、互动、登录演示、举报反馈、设置保存和启动页体验而处理必要信息。\n\n'
            '一、信息收集范围：当您浏览内容时，应用会读取本地静态栏目和稿件数据；当您使用登录演示、收藏、评论入口、举报反馈或设置功能时，应用会在设备本地保存手机号脱敏展示、偏好设置、积分变动、已读或缓存状态等原型数据。未经您主动操作，应用不会采集通讯录、相册、精确位置、麦克风或摄像头内容。\n\n'
            '二、使用目的与存储：上述信息用于维持页面状态、展示账号体验、保存外观偏好、避免重复展示启动页以及协助您理解产品流程。当前原型默认使用本机 SharedPreferences、临时缓存目录和内存仓库保存数据，不会把这些原型数据上传至后台生产服务。\n\n'
            '三、设备权限与缓存：如后续功能需要访问相册、相机、定位或通知，将在触发具体功能前单独说明并请求授权。启动页图片缓存仅在您同意隐私政策并完成引导后才会尝试写入，拒绝同意时不会创建同意记录或预加载缓存。\n\n'
            '四、共享、撤回与停止使用：当前原型不向第三方共享个人信息。您可以通过退出登录、清理应用数据或停止使用来撤回本地授权效果；撤回后，与账号演示和本地偏好相关的能力可能无法继续提供。举报电话和邮箱仅用于展示联系渠道，提交真实举报时请以页面展示渠道与当地主管部门要求为准。\n\n'
            '五、联系我们：如对个人信息处理或原型数据有疑问，可通过“有害信息举报”“意见反馈”页面展示的电话或邮箱联系。',
      ),
      'mobile-auth' => const AgreementDocument(
        id: 'mobile-auth',
        title: '本机号码认证服务条款',
        content:
            '本机号码认证在当前客户端中为原型演示能力，用于说明一键登录和手机号登录的交互流程，不代表真实运营商认证结果。\n\n'
            '一、认证目的：在真实服务中，本机号码认证通常用于核验您当前设备号码并减少手动输入；本原型仅展示授权、校验、失败提示和会话写入流程。\n\n'
            '二、授权与撤回：您可以选择不同意登录协议，此时不会写入登录会话。您也可以退出登录或清理本地数据来撤回原型会话状态。\n\n'
            '三、数据边界：当前原型不会调用真实运营商 SDK，不会向运营商或生产认证服务提交号码。页面中的脱敏号码和验证码仅用于本地演示。',
      ),
      _ => const AgreementDocument(
        id: 'user',
        title: '用户协议',
        content:
            '欢迎使用西昌发布客户端原型。您在使用前应阅读并理解本协议及隐私政策；点击同意后，可以进入首页、栏目、直播、服务、我的等原型功能。\n\n'
            '一、服务内容：本客户端用于展示本地新闻资讯、专题、直播入口、便民服务、积分任务、举报反馈和个人中心等移动端体验。当前 Flutter 仓库为静态数据原型，不包含正式后台发布、真实支付、真实短信或生产账号认证能力。\n\n'
            '二、账号与登录：手机号登录、本机号码认证和第三方登录入口仅用于演示交互。您应使用合法信息参与后续正式服务，不得冒用他人身份、绕过认证或利用原型界面误导他人。\n\n'
            '三、内容与互动：您在评论、反馈、举报等入口提交内容时，应遵守法律法规、公序良俗和平台治理要求，不得发布违法违规、侵权、骚扰、虚假或危害网络安全的信息。原型中的评论、点赞、收藏、积分和消息数据主要保存在本地，用于展示功能流程。\n\n'
            '四、知识产权与使用限制：客户端界面、栏目结构、示例稿件和视觉素材仅用于项目演示和测试，不得未经授权复制、分发或用于商业宣传。您不得反向破坏、干扰缓存或利用漏洞影响他人使用。\n\n'
            '五、停止使用与反馈：如您不同意本协议或隐私政策，可以选择暂不使用；已进入应用后，也可以退出登录、清理本地数据或停止使用。发现有害信息或产品问题时，可通过举报反馈渠道联系我们。',
      ),
    };
  }
}
