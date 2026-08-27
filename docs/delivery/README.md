# Admin9 App Starter 交付

本文是当前仓库唯一的交付与设备证据入口。它记录证据边界，不授权签名、安装、真机写入、
Tag、push 或发布。构建命令见[验证入口](../validation/README.md)，历史原始结论见
[历史记录](../HISTORY.md)。

## 当前交付边界

- 当前项目仍是 Starter，不是已发布业务产品。
- Android/iOS release 编译是构建证据，不是真机验收。
- Golden 是确定性渲染证据，不是系统手势、真实输入法或读屏证据。
- 未在精确源码和产物上执行的设备项目保持 `Unknown`；不得由旧记录升级。
- 最终品牌方向、双端真机体验、签名发布和商店交付均未获授权。

`design-system-v2.0.0` 是源码正式版，只提供 GitHub 自动生成的源码归档，不附带 APK、
IPA 或 unsigned iOS App。当前源码的 Android release 和 iOS no-codesign 编译只作为构建
证据，不升级签名、安装、真机或商店交付结论。

## 已保护交接制品

清理开始前，以下两个忽略目录中的制品与既有交接记录精确匹配，已复制到仓库外保存，
后续构建不会覆盖保存副本：

| 平台 | 制品 | 大小 | SHA-256 | 已证明 | 未证明 |
| --- | --- | ---: | --- | --- | --- |
| Android | release APK | 51,005,113 bytes | `033da5010261a37bc0d62c188e7596a2fb82cdf7a8a6cfb8bfea7c65a26b5bc8` | 本地 release 构建 | 当前源码构建、真机安装、冷启动、性能或体验 |
| iOS | development-signed IPA | 7,211,488 bytes | `4280712752943f402ce23d5e23cbdefc4f4ed1b719dae244b713db71d1f8ddf3` | archive 完整、签名 bundle 可校验 | 当前源码构建、当前设备安装、冷启动、读屏或体验 |

IPA 内 `Payload/Runner.app` 是该 iOS 制品唯一可复验 App bundle。其 bundle ID 为
`com.admin9.app.foundation`，版本为 `1.0.0 (1)`，签名 Team ID 为 `J25XZRW743`。
以相对路径排序生成的逐文件 SHA-256 清单自身 SHA-256 为
`5d0151072acb44fdb2121d52b5cab044a50beb50fdfadb40d0fe309267df0b1e`。

`build/ios/iphoneos/Runner.app` 是易漂移的构建输出，不是上述 IPA 的替代来源，也不得
作为交付权威引用。需要检查 IPA 时直接解压并校验 Payload：

```bash
delivery_tmp="$(mktemp -d)"
trap 'rm -rf "$delivery_tmp"' EXIT
unzip -q "build/ios/ipa/Admin9 App Starter.ipa" -d "$delivery_tmp"
codesign --verify --deep --strict --verbose=2 \
  "$delivery_tmp/Payload/Runner.app"
```

## 设备状态

| 能力 | Android | iOS | 边界 |
| --- | --- | --- | --- |
| 重复模拟器构建、安装、冷启动与最小导航 smoke | `Pass`（历史固定源码，两轮） | `Pass`（历史固定源码，两轮） | 只证明当时固定模拟器和最小流程 |
| 登录/注册、设置、反馈与返回的交互模拟器记录 | `Unknown` | 已记录单平台观察 | 不构成双端完整验收 |
| 真实 IME、密码管理器和自动填充 | `Unknown` | `Unknown` | 自动化不替代系统输入 |
| TalkBack / VoiceOver | `Unknown` | `Unknown` | Flutter Semantics 测试不等于真实读屏输出 |
| Android predictive back / iOS edge back | `Unknown` | `Unknown` | 最小 smoke 的程序化返回不等于手势交付 |
| 当前双端真机安装、冷启动与业务流程 | `Unknown` | `Unknown` | 未执行，不得升级 |
| 最终品牌方向与双端同一产品判断 | `Pending` | `Pending` | 由用户/产品批准 |

历史模拟器 `Pass` 只绑定当时记录的源码和产物。此基线清理不改变产品或平台职责，因此
不重跑真机；后续任何与路由、系统交互、可见 UI、平台工程或依赖相关的变更，都必须在
新源码和新产物上重新选择受影响设备门禁。

当前树保留的最小历史原始证据及其完整性清单见
[历史设备证据](../history/device-evidence/README.md)。

## 交付检查

1. 从 clean 工作树执行[完整验证](../validation/README.md)。
2. 记录源码 commit、工具链、package/bundle、版本、制品大小和 SHA-256。
3. 只为明确授权的目标设备执行安装、冷启动与交互。
4. 分开记录自动化、Golden、模拟器、真机、读屏、签名和人工品牌结论。
5. 对未执行项目写 `Unknown` 或 `Pending`，不沿用近似制品或漂移 build 目录。
