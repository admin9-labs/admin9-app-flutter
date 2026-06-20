# App 第三方服务生产化落地计划

Last updated: 2026-06-06

## 文档性质

本文是暂缓实施的生产化规划，用于后续立项、拆任务和二次评审。
它不改变当前 Admin9 Core Delivery Baseline：`app/` 仍是静态数据 Flutter
原型，不纳入当前 backend/Admin 正式验收范围；本文也不创建 ADR、不修改迁移、
不安装 SDK、不恢复已经移除的 public-client 业务面。

## 背景与当前仓库事实

- `app/` 当前是 Flutter 静态原型，使用本地 repository、`provider` 和
  `shared_preferences`，登录、消息中心、一键登录和三方登录均为模拟体验。
- 后端已经具备会员基础能力：`members`、`member_auth_identities`、
  `member_sessions`、会员黑名单、会员认证配置和后台审计。
- 后台已有“会员认证配置”页面，可作为后续登录 provider 配置的起点。
- 后端当前是 Go + PostgreSQL + `pgx` + `net/http`，没有 Redis、Asynq、
  worker 命令或真实异步任务中心。
- `app/` 当前仅有 iOS、macOS、web 工程目录；正式做 Android 推送和一键登录
  前需要恢复或生成 Android 原生工程并完成签名、包名、厂商通道配置。

## 二次评估结论

不直接照搬“极光一体化全接”的方案。推荐采用：

1. 以手机号为主身份，`member_id + mobile` 是账号主线。
2. App 只拿授权 code、`loginToken`、设备 registration id；所有 secret、
   token 校验、手机号解密和第三方换取 openid/unionid 都在服务端完成。
3. 业务代码只依赖内部 provider 接口，极光、微信、Apple、短信服务商都放在
   服务商适配层后面，避免将业务流程绑定到单一厂商。
4. 第一版异步任务优先使用 PostgreSQL job/outbox；仅当吞吐、延迟、重试治理
   或运维观测超出数据库队列能力时，再另写 ADR 评估 Redis Streams。
5. JPush 推送、JVerification 一键登录、短信和社交登录要分阶段落地；不把
   HarmonyOS、QQ/微博、自动短信兜底、复杂通知按钮放入 V1。

## 分阶段路线

### Phase 0：决策与基础工程

- 新增 ADR 前置评审，明确 App 公共 API 正式纳入本仓库的前提、边界和验收。
- 生成或恢复 `app/android` 工程，确定包名、应用签名、URL scheme、
  Android notification channel 和厂商推送参数占位。
- 保留现有 iOS 工程，补齐 APNs、JPush、微信、Apple 登录所需能力项。
- 增加服务端配置边界：
  - `ADMIN9_JPUSH_APP_KEY`
  - `ADMIN9_JPUSH_MASTER_SECRET`
  - `ADMIN9_JVERIFY_APP_KEY`
  - `ADMIN9_JVERIFY_PRIVATE_KEY`
  - `ADMIN9_SMS_*`
  - 微信和 Apple OAuth 配置
- App 侧建立服务边界：`ApiClient`、`AuthRepository`、`DeviceRepository`、
  `MessageRepository`、`PushPlatformService`。页面和 ViewModel 不直接调用
  原生 SDK 或 HTTP 细节。
- 后台页面继续沿用 Admin9 Vue/Arco 模式，不改路由守卫、全局 store、拦截器
  和布局框架。

### Phase 1：App 账号与会话

- 复用现有 `members`、`member_auth_identities`、`member_sessions`，补齐 App
  认证 service/store；App token 继续使用服务端 opaque token + HMAC hash。
- 短信登录流程：发送验证码 -> 校验验证码 -> 创建或查找 member -> 检查冻结和
  黑名单 -> 写 `member_sessions` -> 返回 token 和用户摘要。
- 一键登录流程：App 获取 `loginToken`；服务端调用 JVerification 校验并解密
  手机号；失败时降级短信登录。
- 微信/Apple 流程：App 只提交授权 code 或 identity token；服务端换取
  openid/unionid/sub；首次登录必须绑定手机号后才发正式 token。
- V1 provider 范围：`mobile_sms`、`jverification_mobile`、`wechat`、`apple`。
  QQ/微博不进入第一版。
- 最小 API 草案：
  - `POST /api/auth/sms/send`
  - `POST /api/auth/sms/login`
  - `POST /api/auth/one-click/login`
  - `POST /api/auth/oauth/login`
  - `POST /api/auth/mobile/bind`
  - `POST /api/auth/logout`
  - `GET /api/auth/me`
- 安全规则：验证码按 IP+手机号限流；验证码只保存 hash、用途、过期时间和尝试
  次数；冻结或黑名单用户禁止登录；失败和退出写入登录日志。

### Phase 2：设备绑定与推送基础

- 新增 `member_devices` 草案字段：`member_id`、`platform`、`vendor`、
  `jpush_registration_id`、`device_fingerprint`、`app_version`、
  `push_enabled`、`last_seen_at`、`revoked_at`。
- App 必须在用户同意隐私政策之后初始化 JPush/JVerification；未同意前不得
  初始化采集型 SDK。
- 登录后上报设备：`POST /api/devices/register`。退出登录仅解绑当前
  member 关系，不强删设备历史。
- 推送点击统一使用 deep link：
  - `app://news/{id}`
  - `app://notice/{id}`
  - `app://activity/{id}`
  - `app://message-center`
- V1 通知样式只支持普通通知、大文本、大图、收件箱聚合；自定义按钮、强提醒
  和复杂厂商特性后置。
- iOS 和 Android 必须分别真机验收；macOS/web 继续保持原型兼容，不承诺推送
  能力。

### Phase 3：后台推送任务与站内消息

- 新增表草案：
  - `app_messages`：会员消息、系统消息、业务消息、已读状态、跳转 payload。
  - `notification_tasks`：后台创建的推送任务、目标类型、标题、内容、样式、
    计划时间、状态。
  - `notification_deliveries`：按批次、设备或会员记录发送结果、第三方
    message id 和失败原因。
  - `app_jobs`：PostgreSQL job/outbox，负责推送、短信、欢迎消息和失败重试。
- 后台新增“消息推送”页面，放在“系统管理”或单独“运营触达”二级菜单。
- 权限草案：
  - `system.notification-task.view`
  - `system.notification-task.create`
  - `system.notification-task.cancel`
  - `system.notification-task.retry`
  - `system.notification-task.approve`
- 推送任务状态草案：`draft`、`pending_approval`、`scheduled`、`sending`、
  `sent`、`partial_failed`、`failed`、`cancelled`。
- 推送目标 V1：全体、指定会员、会员标签、会员状态；暂不做人群画像、地理
  围栏、阅读行为圈选。
- 新增 `admin9 worker --config ...` 草案命令，轮询 `app_jobs`，使用
  `FOR UPDATE SKIP LOCKED` 锁任务，支持最大重试、下次重试时间和错误快照。
- 推送调用通过 `NotificationProvider` 接口；第一实现为 `JPushProvider`，
  失败时保留第三方原始错误码和 request id。

### Phase 4：短信服务

- 新增表草案：`sms_codes`、`sms_tasks`、`sms_deliveries`；验证码短信和通知
  短信分开建模。
- 验证码短信走同步请求加服务商发送；政务通知短信走 `app_jobs`，必须保留
  后台操作记录。
- 极光短信错误映射为内部错误：超频、验证码无效、验证码过期、模板审核中、
  余额不足、退订、敏感词。
- V1 不做“推送未达自动补短信”；只保留人工创建短信任务。自动兜底需要在 P2
  基于推送回执、短信授权、频控、费用预算和审批规则另行开启。
- 后台短信配置继续走 `system_configs`，但密钥只保存 placeholder、开关和模板
  编号，不保存明文 secret。

### Phase 5：Flutter App UI 改造

- 登录页改为三段式：手机号验证码登录为默认入口，本机号码一键登录为次入口，
  微信和 Apple 放底部；QQ/微博隐藏。
- 三方首次登录后进入“绑定手机号”页；绑定成功后才进入 App。
- “我的”页从本地模拟改为真实 session，展示手机号脱敏、登录方式和设备状态。
- 消息中心从静态 repository 改为接口驱动，支持未读、已读、系统消息、互动
  消息；本地静态数据仅保留为 mock/fallback。
- 协议页面改为后端协议配置接口；隐私政策必须明确列出 JPush、JVerification、
  短信、微信、Apple 的数据用途和第三方共享说明。
- 所有 SDK 初始化和授权弹窗必须在同意协议之后发生；测试覆盖未同意时点击
  一键登录或三方登录不会初始化 SDK。

### Phase 6：合规、运维与观测

- App Store 审核准备：测试账号、后台服务可访问、微信登录对应 Apple 登录入口、
  隐私清单、第三方 SDK 列表。
- Android 上架准备：隐私政策、SDK 合规声明、权限用途说明、厂商通道配置、
  通知权限引导。
- 服务端观测：推送和短信请求日志、任务耗时、失败率、重试次数、第三方错误码、
  余额预警。
- 运维开关：按 provider 禁用登录入口、禁用推送发送、禁用短信通知；禁用后
  App 只隐藏入口或降级，不崩溃。
- 数据保护：手机号、openid、unionid、registration id、验证码、token、secret
  不进明文审计；导出和日志只展示脱敏值。

## 接口与数据模型草案

以下内容只用于规划和拆任务。真正实施前必须补 ADR、API 契约、迁移设计和验收
脚本。

| 类型 | 草案 |
| --- | --- |
| App 认证 | `/api/auth/sms/send`, `/api/auth/sms/login`, `/api/auth/one-click/login`, `/api/auth/oauth/login`, `/api/auth/mobile/bind`, `/api/auth/logout`, `/api/auth/me` |
| 设备 | `/api/devices/register` |
| 消息 | `/api/messages`, `/api/messages/{id}/read` |
| 后台推送 | `/api/admin/notification-tasks`, `/api/admin/notification-tasks/{id}/cancel`, `/api/admin/notification-tasks/{id}/retry` |
| 现有表复用 | `members`, `member_auth_identities`, `member_sessions`, `system_configs`, `login_logs`, `operation_logs` |
| 新表草案 | `member_devices`, `app_messages`, `notification_tasks`, `notification_deliveries`, `app_jobs`, `sms_codes`, `sms_tasks`, `sms_deliveries` |

## 风险与暂不实施项

- HarmonyOS：作为后续硬约束单独评估，不用 Flutter 插件字段或服务端参数替代
  端侧工程验收。
- QQ/微博：不进 V1；客户明确要求后再评估插件维护状态、账号开放平台审核和
  上架风险。
- 自动短信兜底：不进 V1；必须先有用户授权、频控、费用预算、审批和推送回执
  判断。
- Redis Streams：不进 V1；先走 PostgreSQL job/outbox，超过能力边界后另写 ADR。
- 复杂通知按钮和自定义布局：不进 V1；系统展示受 Android/iOS/厂商通道约束，
  不能承诺完全由后端参数无代码控制。
- 服务商控制台：日常运营不依赖第三方控制台，但证书、包名、厂商通道、短信
  模板审核仍需要在服务商或平台侧完成。

## 验证与验收建议

- 后端：`go test ./... -count=1`、`go vet ./...`、`./scripts/verify.sh`；新增
  App auth、验证码、设备绑定、任务状态流转、JPush/JSMS mock provider 单测。
- Admin 前端：`pnpm type:check`、`pnpm build`；验证菜单权限、任务列表、
  创建/取消/重试、详情抽屉和错误展示。
- Flutter：`dart format --set-exit-if-changed lib test`、`flutter analyze`、
  `flutter test`；新增登录态、协议拦截、绑定手机号、消息中心、推送 deep link
  单测。
- 真机：iPhone APNs/JPush、Android 厂商通道、弱网短信登录、一键登录失败降级、
  微信/Apple 登录、通知点击跳转。
- 验收脚本：新增 `backend/scripts/app-acceptance.sh`，覆盖短信登录、App token、
  设备上报、站内消息、后台推送任务创建和 worker 消费。

## 官方依据

- [JPush REST API Server Overview](https://docs.jiguang.cn/en/jpush/server/push/server_overview/)
- [JPush Push API v3](https://docs.jiguang.cn/jpush/server/push/rest_api_v3_push)
- [JVerification loginTokenVerify API](https://docs.jiguang.cn/jverification/server/rest_api/loginTokenVerify_api)
- [JSMS REST API Summary](https://docs.jiguang.cn/jsms/server/rest_api_summary)
- [Apple App Review Guidelines 4.8 Login Services](https://developer.apple.com/app-store/review/guidelines/)
