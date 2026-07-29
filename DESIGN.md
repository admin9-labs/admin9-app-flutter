# Admin9 App Foundation Design

## Product Boundary

Admin9 App Foundation 是 Android/iOS 通用 App 骨架，不是客户产品、行业模板、媒体基座、多租户运行时或动态模块平台。Admin9 是唯一骨架品牌；第二个真实业务项目出现前，不提前抽象业务扩展插槽。

项目只包含两层：

1. 稳定 App 宿主：启动、生命周期、错误边界、品牌资源、Material 3、外观与无障碍、本地偏好、隐私门禁、导航和统一页面结构。
2. 通用基础页面：首页、我的、认证入口、账户页、设置、法务和关于。

## Architecture

- 使用 Provider、ChangeNotifier 和 SharedPreferences。
- 按真实页面域组织 `home`、`auth`、`account`、`settings`、`legal`、`about`。
- View 只负责布局、简单条件显示、表单控件和导航。
- ViewModel 只负责 UI 状态、输入校验结果和命令状态。
- SharedPreferences 由 `AppPreferences` 封装；业务 ViewModel 不直接访问平台插件。
- 没有真实数据源时不创建 Repository、Service、Domain、用例或 DTO。
- 使用 Flutter Navigator 的命名路由和 `onGenerateRoute`；不引入路由框架、模块注册表或动态插件。

## Session And Authentication

App 默认且真实地处于游客状态。`SessionController` 明确游客与已认证会话边界，但当前没有任何命令能创建已认证会话。所有认证和账户敏感操作：

- 执行本地必填、格式、长度和确认值校验；
- 校验通过后进入确定的“服务尚未接入”状态；
- 不发送网络请求、验证码、短信或邮件；
- 不保存用户、密码、Token 或模拟会话；
- 不显示成功结果。

## Appearance And Accessibility

Material 3 主题提供系统/浅色/深色模式。用户偏好持久化包括字体级别、全局灰度、增强对比度和减少动态效果。应用字体缩放会与系统文字缩放相乘并限制在可用范围内，不覆盖系统无障碍设置。

## Privacy And Legal

首次启动显示隐私门禁；同意后只保存布尔偏好。未同意时不能进入主页面。用户协议和隐私政策页面有稳定资源标识，但正式文本为空时只显示“正式内容尚未提供”，不编造主体、备案号、地址、电话或条款。

## Platform Identity

只保留 `android/` 与 `ios/`。开发包身份统一为 `com.admin9.app.foundation`，显示名称为 `Admin9`。主包不声明业务网络权限或明文传输例外。Admin9 图标与启动资源为静态本地资源。

## Non-Goals

不接后端，不实现真实认证、OIDC、Token、消息、推送、反馈、收藏、历史、媒体频道、稿件、搜索、直播、爆料、服务、积分、活动、商城、H5、WebView、远程 Splash、远程配置、flavor、多 package、macOS 或 Web。
