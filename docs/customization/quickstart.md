# App 与品牌定制 Quickstart

本文说明如何按需修改 Admin9 App Starter 的身份与品牌。整个流程是可选便利能力，
不是 fork 的使用条件，也不产生认证、兼容、支持或升级承诺。

## 1. 独立责任

fork 可依据 Apache 2.0 自由复制、修改、商用和发布，并自行决定 Git remote、分支、
版本、目录、架构和发布流程。本项目不追踪 fork，不要求固定来源 commit、指定 remote、
ownership、deviation、expiry、provenance、回流修复或验收登记。

fork 维护者自行负责安全、隐私、法律合规、第三方许可证、真实法务内容、依赖升级、
签名、商店规则、测试、交付和用户支持。Admin9 名称和 Logo 不能仅凭 Apache 2.0 被
用来宣称产品获得 Admin9 背书、认证或官方兼容，详见[商标说明](../../TRADEMARKS.md)。

## 2. 选择手工修改或配置工具

你可以直接修改自己的 fork，也可以使用仓库内的 App 配置工具。工具只处理身份与品牌，
不会检查项目来源或管理下游关系。

可选 schema 与示例位于：

- `docs/design-system/schema/app-config.schema.json`
- `docs/design-system/fixtures/app-config/valid.yaml`

配置文件使用 JSON 语法，因此同时是 YAML 1.2 的合法子集。schema 只包含 `app` 和
`brand` 数据，不含兼容性、来源、所有者、偏差、到期或审计字段。

## 3. 准备可选配置

在自己的工作分支执行：

```bash
cp docs/design-system/fixtures/app-config/valid.yaml app-config.yaml
mkdir -p assets/brand
cp docs/design-system/fixtures/app-config/assets/brand/logo.png assets/brand/logo.png
cp docs/design-system/fixtures/app-config/assets/brand/launch.png assets/brand/launch.png
```

然后修改 `app-config.yaml`：

- `app.name`：用户可见产品名；
- `app.version`：Flutter App 版本；
- `app.androidApplicationId`：Android namespace/application ID；
- `app.iosBundleId`：iOS bundle ID；
- `brand.primaryPair` / `secondaryPair`：light/dark 颜色；
- `brand.fontFamily`：可选字体名或 `null`；
- `brand.radiusDelta`：`-2` 至 `2`；
- `brand.logoPath`：至少 `1024x1024` 的方形 PNG；
- `brand.launchAssetPath`：方形 PNG 启动资源。

资源路径必须位于配置文件相邻的 `assets/` 子树内。示例 identity 和图片只用于演示，
不能不经审查直接当作正式产品资料。

修改 application ID 或 bundle ID 会改变安装、签名、推送、深链和商店升级身份。只有
确实准备迁移时才修改。Starter 上游自身仅改用户可见产品名，默认技术标识仍为
`com.admin9.app.foundation`。

## 4. 校验、应用与回验

```bash
dart run tool/design_system/validate_app_config.dart app-config.yaml
dart run tool/design_system/apply_app_config.dart app-config.yaml .
dart run tool/design_system/verify_app_config.dart app-config.yaml .
```

校验器检查 schema、未知字段、版本/标识格式、资源路径、PNG 尺寸和主色焦点对比度。
应用工具同步：

- `lib/app/app_identity.dart` 与 `lib/app/brand/app_brand_theme.dart`；
- `pubspec.yaml` 的描述、版本和资源；
- Android namespace/application ID、显示名、Kotlin package、图标与启动图；
- iOS bundle ID、显示名、图标与启动图。

应用前后都应审查完整 diff。回验器只说明输出与配置一致，不说明产品已通过安全、
合规、真机、商店、品牌授权或业务验收。

## 5. 添加真实业务

本仓库采用 feature-first 结构，业务代码可从 `lib/ui/features/<feature>/**` 开始。
上游公共 UI 的使用方式为：

```dart
import 'package:admin9_app_flutter/admin9_ui.dart';
```

如果 fork 修改 Dart package name，应同步自己的 package import。出现真实数据源后再在
所属 Feature 引入 Repository/Service；只有复杂且复用的业务规则才增加 Domain。
真实服务接入前保持“服务尚未接入”，不要创建模拟用户、会话、Token 或成功结果。

## 6. 建议验证

fork 可自行调整门禁；本上游仓库的完整验证入口是
[VALIDATION.md](../audit/VALIDATION.md)。至少应运行与修改范围相关的 format、analyze、
Widget 测试和 Android/iOS 构建，并在正式交付前完成真实签名、安装、冷启动、无障碍、
系统手势、键盘、安全区和法务内容验收。
