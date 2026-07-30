# Final-source physical iPhone delivery provenance

- Date: 2026-07-31 (Asia/Shanghai)
- Foundation base HEAD: `a31227b014ac5d5564735552c4e30851eca8707e`
  plus the reviewed unstaged Phase 6 fixes
- Device: Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2
- CoreDevice ID: `44C6E299-C645-56DD-8A6F-6E03EE2B631E`
- Hardware UDID: `00008150-000268290C44401C`
- Bundle: `com.admin9.app.foundation`, minimum iOS 13.0
- Team / authority: `J25XZRW743` /
  `Apple Development: qiyue feng (252TTDSH8C)`
- Runner bytes / SHA-256: 281,632 /
  `38ba0d654385fd3056591e20b46f436a7d644fff9c86af556ba1d468615ef3a1`
- Info.plist SHA-256:
  `81a9361e8c033fa426f36287a73aa55f7ba64edd264c60c4f6421713656c73d8`
- CodeResources SHA-256:
  `12370c78cd7a20d0cbb11db42af09f455f6fb7c1857b170b4d9f31070e8171f1`
- Full CDHash:
  `ba15ded10892924887028748921cae422ed48289567333f37a9fce678ca0e771`
- Installation URL:
  `file:///private/var/containers/Bundle/Application/5F4DB1C7-61E8-4931-98C8-D8E3BBBEE674/Runner.app/`
- Running executable / PID: matching installation URL plus `Runner` / `26739`

`flutter build ios --release` completed with automatic signing. `codesign
--verify --deep --strict` reported `valid on disk` and `satisfies its Designated
Requirement`. `devicectl` then installed the exact App, cold-launched it with
`--terminate-existing`, and the process inventory bound the running executable
to the new installation URL.

Result: **Pass** for final-source signed build, signature, physical install,
unlocked cold launch and process provenance. This does not prove VoiceOver
speech, real iOS keyboard behavior, Dynamic Type/safe-area observation or the
human edge-back gestures; those remain separate manual gates.

Raw records:

- `physical-iphone-v102-install.json` and `.log`;
- `physical-iphone-v102-launch.json` and `.log`;
- `physical-iphone-v102-processes.json` and `.log`.
