# Admin9 App Starter 架构

## 1. 定位与范围

Admin9 App Starter 是仅面向 Android/iOS 的开源 Flutter 起步工程。当前上游维护：

- App Host、启动、错误边界、隐私门禁和显式路由；
- 公共 Design System、平台映射、无障碍和质量门禁；
- 默认 App identity 与 Brand Theme；
- 本地外观、无障碍和隐私选择；
- feature-first 示例页面与真实“服务尚未接入”边界；
- 可选 App/Brand 配置工具。

它不维护或治理任何下游项目，不提供兼容认证、下游迁移、交付、安全维护、合规审查
或支持承诺。fork 依据 Apache 2.0 独立使用并自行负责。

## 2. 代码边界

| 边界 | 当前上游职责 | 上游代码位置 |
| --- | --- | --- |
| Core | Token、公共 `App*` 组件、平台适配、无障碍和质量行为 | `lib/core/design_system/`、`lib/admin9_ui.dart` |
| Brand | 默认颜色、字体选择、圆角特征、Logo 和启动资源 | `lib/app/brand/`、原生资源目录 |
| Business | 本仓库真实页面、文案、状态和 Feature 行为 | `lib/ui/features/`、`lib/ui/shared/` |
| App Host | 启动、组合、隐私门禁、导航、identity、设置和法务宿主 | `lib/app/` |

这些是准备合入本上游仓库的依赖和维护边界，不是对 fork 的附加许可条件。fork 可以
独立修改目录、依赖和架构。

Business 使用公共 UI 时经 `lib/admin9_ui.dart`。Core 不依赖 Feature 的实体、
ViewModel、Repository、Service、Provider、Session、权限或业务内容。App Host 仅通过
明确 allowlist 使用组合所需的 Core internals。

## 3. Feature-first 与复杂度

页面和局部状态位于 `lib/ui/features/<feature>/**`。首个真实消费者保留在所属 Feature；
只有本仓库第二个 Feature 出现相同职责时，才移入 `lib/ui/shared/`。只有跨业务且稳定的
通用责任才进入 Core 并公开到 `lib/admin9_ui.dart`。

当前没有真实远程数据源，所以不创建空的 Repository、Service 或 Domain。接入真实
数据源后，由拥有该数据的 Feature 引入所需层次；复杂且复用的业务规则出现后，再考虑
Domain。

## 4. 运行时真实性

App 默认且真实地处于游客状态。`SessionController` 只表达游客/会话边界，当前启动和
认证表单没有创建真实会话的路径。认证和账号敏感操作只做本地校验，并明确显示
“服务尚未接入”；不创建模拟用户、Token、验证码、会话或成功结果。

隐私门禁只持久化用户的本地同意选择。外观与无障碍选项只持久化 App 偏好；系统设置是
运行时输入。法务页面在正式文本缺失时显示明确空状态，不编造主体、备案号、地址、电话
或条款。

## 5. 平台与 Design System

公共 `App*` 组件在 Core 内提供统一的第一方 Admin9 可见组件语言，Feature 不直接
选择平台交互控件。系统字号、Bold Text、高对比度、减少动态、灰度、命中区、
Semantics、焦点、键盘、安全区与返回手势由
[Design System](../design-system/README.md) 定义并保留平台职责。

Design System 中的规范词只约束准备合入本上游仓库的实现和贡献，不约束独立 fork。
自动化证明确定性行为；真机、读屏、系统手势、真实 IME、签名安装与冷启动必须绑定
实际源码和产物记录，不能由 Widget 测试或无签名构建替代。

## 6. 可选 App/Brand 配置

仓库没有必需的 manifest。`app-config.yaml` 是使用者主动选择的便利输入，只包含：

- App 名称、版本、Android application ID 与 iOS bundle ID；
- 主色/辅色的 light/dark 配对；
- 可选字体、受限圆角变化、Logo 与启动图路径。

schema 不包含上游 commit、Design System 组合、remote、ownership、compatibility、
deviation、expiry 或 provenance。校验通过只证明配置数据满足本工具要求；生成回验通过
只证明目标文件与配置一致，二者都不构成认证或兼容承诺。

工具可以更新 Dart identity、Brand Theme、`pubspec.yaml`、Android 原生 identity/
资源及 iOS 原生 identity/资源。完整步骤见[可选定制 Quickstart](../customization/quickstart.md)。

本次默认产品名统一为 `Admin9 App Starter`，但不修改：

- Dart package：`admin9_app_flutter`；
- Android namespace/application ID 与 Kotlin package：`com.admin9.app.foundation`；
- iOS bundle ID：`com.admin9.app.foundation`。

这些技术标识涉及 package import、安装覆盖和签名，应由单独、明确的迁移决定处理。

## 7. 上游质量与发布

上游保留：Flutter format/analyze/test、Android/iOS 构建、导入边界、公共 API parity、
Gallery release exclusion、响应式/Golden/无障碍检查、文档链接校验、SemVer 和 Changelog。
`CODEOWNERS` 与 `OWNERS.md` 只描述本上游仓库的评审责任。

既有 Git Tag 和历史验收记录不修改、不重打；它们记录当时的 Foundation 实现和事实，
不再是当前 Starter 的下游合同。历史入口见[历史记录](../HISTORY.md)。当前变更先进入
Changelog 的 `Unreleased`，正式发布仍需独立的版本与 Tag 决策。

## 8. 当前明确未提供

当前不提供真实后端认证、OIDC、Token 生命周期、消息、推送、反馈、收藏、历史、媒体、
搜索、直播、商城、远程配置、flavor、动态模块、Web、Desktop、macOS 或独立发布的 UI
package。未来只有出现真实责任与验证需求时，才在对应 Feature 或独立 package 中实现。
