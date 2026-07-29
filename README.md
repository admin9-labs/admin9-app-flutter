# Admin9 App Foundation

Admin9 App Foundation 是仅面向 Android 和 iOS 的通用 Flutter App 骨架。它提供稳定移动端宿主和通用账户页面，不包含客户业务、媒体能力、后端连接或桌面/Web 目标。

## 当前能力

- Flutter 启动、生命周期观察和全局错误边界
- Admin9 名称、品牌资源、Android/iOS 应用身份和静态启动体验
- Material 3 深浅色主题、字体大小、增强对比度、减少动态效果和全局灰度
- 基于 `SharedPreferences` 的本地外观偏好和首次启动隐私同意
- “首页、我的”两项一级导航与统一页面结构
- 游客/会话边界及登录、注册、密码和账户相关表单入口
- 个人中心、账号资料、账号安全、账号注销、设置、法务、关于和联系方式页面

认证与账户操作当前只提供导航、表单结构、本地校验和统一的“服务尚未接入”状态。项目不会创建模拟用户、模拟会话、Token，也不会发送短信、邮件或验证码。协议、政策和联系方式在正式资料接入前只保留明确的空状态。

## 结构

```text
lib/
├── app/                 # 启动门禁、Provider 组合根和两项一级导航
├── core/                # 品牌、错误、生命周期、路由、偏好、主题和共享组件
└── ui/features/         # home、auth、account、settings、legal、about
```

View 保持声明式；ChangeNotifier ViewModel 只维护 UI 状态与命令。现阶段没有真实数据源，因此不创建 Repository、HTTP Client、API Service 或 Domain 层。

详细边界见 [DESIGN.md](DESIGN.md) 和 [架构计划](docs/architecture/admin9-app-foundation.md)。

## 开发与验证

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release --no-codesign
git diff --check
```

本仓库不提供 macOS、Web 或浏览器版本。未接入正式服务前，不应把任何认证操作描述为可完成。
