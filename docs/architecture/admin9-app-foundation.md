# Admin9 App Foundation Architecture Plan

## Target Structure

```text
main.dart
app/
  admin9_app.dart
  admin9_shell.dart
  privacy_gate.dart
core/
  branding/
  errors/
  lifecycle/
  navigation/
  preferences/
  theme/
  widgets/
ui/features/
  home/
  auth/
  account/
  settings/
  legal/
  about/
```

## Ownership

- `main.dart` 初始化 Flutter、SharedPreferences 和全局错误捕获。
- `app/` 是 Provider 组合根、隐私门禁和一级导航宿主。
- `core/` 只放跨页面且已有消费者的宿主能力。
- 每个 feature 只包含实际页面及其必要 ViewModel/模型。
- `AppPreferences` 是唯一持久化入口；仅保存外观、无障碍和隐私同意。
- `SessionController` 不持久化用户或会话，当前永远不会由认证表单切换为已登录。

## Navigation

底部 `NavigationBar` 仅有“首页”和“我的”。二级页面通过命名路由进入，统一使用 `FoundationPage`。路由表是静态、显式、可审计的页面映射。

## Delivery Gates

1. 静态搜索不含旧品牌、媒体业务、域名、HTTP Client、Token 或平台网络例外。
2. 格式化、分析、定向 Widget 测试和完整测试通过。
3. Android release 与 iOS 无签名 release 构建通过。
4. 回读 Android label/applicationId/icon 与 iOS display name/bundle ID/icon。
5. `git diff --check` 通过，且归档分支/tag 仍指向清理前同一提交。
