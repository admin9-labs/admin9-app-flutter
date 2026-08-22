import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const root = process.argv[2] ?? 'docs/design-system/evidence/visual-references';
const write = process.argv.includes('--write');
const manifestPath = path.join(root, 'visual-assets.json');
const requiredScenarioLabels = {
  account: ['已登录列表', '长中文重排', '这是用于验证长中文内容增长的', '暂无可用账号能力', '列表载入失败', '重试'],
  auth: ['键盘焦点', '注册基准态', '创建账号', '请输入手机号或邮箱', '两次密码不一致', '内容不会被裁切', '信息：服务未接入', '登录替代态'],
  settings: ['设置基准态', '系统已开启高对比度', '设置暂未保存', '持久化错误', '重试', '选择状态', '选择主题', '跟随系统'],
  feedback: ['动作菜单', '暂不可用', '删除账号', '取消', '确认弹窗', '确认提交', '操作失败', '暂无内容', '重试', '已完成 45%', '按下状态', '禁用操作', '键盘焦点操作', '不确定进度', '设置已更新', '关闭'],
};
const expected = [];
const svgSources = new Map();
for (const platform of ['android', 'ios']) {
  for (const page of ['account', 'auth', 'settings', 'feedback']) {
    for (const extension of ['svg', 'png']) {
      expected.push(path.join(platform, `${page}.${extension}`));
    }
  }
}

const sha256 = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');
const pngSize = (buffer) => {
  if (buffer.toString('ascii', 1, 4) !== 'PNG') throw new Error('invalid PNG signature');
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
};

const assets = expected.map((relativePath) => {
  const filePath = path.join(root, relativePath);
  const buffer = fs.readFileSync(filePath);
  const page = path.basename(relativePath, path.extname(relativePath));
  let width;
  let height;
  if (relativePath.endsWith('.png')) {
    ({ width, height } = pngSize(buffer));
  } else {
    const source = buffer.toString('utf8');
    svgSources.set(relativePath, source);
    const match = source.match(/<svg[^>]*width="(\d+)"[^>]*height="(\d+)"/);
    if (!match) throw new Error(`${relativePath}: missing SVG dimensions`);
    width = Number(match[1]);
    height = Number(match[2]);
    for (const label of ['设计参考，非当前 App / 模拟器 / 设备截图', '浅色', '深色', 'App 特大 1.24 × 系统标准', '390lp', '同一 Admin9 可见契约', '系统交互差异单独验收', ...requiredScenarioLabels[page]]) {
      if (!source.includes(label)) throw new Error(`${relativePath}: missing label ${label}`);
    }
  }
  if (width !== 2400 || height !== 1200) {
    throw new Error(`${relativePath}: expected 2400x1200, got ${width}x${height}`);
  }
  return { path: relativePath, width, height, bytes: buffer.length, sha256: sha256(buffer) };
});

const normalizeAllowedPlatformDifferences = (source) => source.replace(
  /(<text data-platform-difference="([^"]+)"[^>]*>)[^<]*(<\/text>)/g,
  (_, open, key, close) => `${open}platform:${key}${close}`,
);

for (const page of ['account', 'auth', 'settings', 'feedback']) {
  const android = normalizeAllowedPlatformDifferences(svgSources.get(`android/${page}.svg`));
  const ios = normalizeAllowedPlatformDifferences(svgSources.get(`ios/${page}.svg`));
  if (android !== ios) {
    throw new Error(`${page}: visible Android/iOS structure drifted outside allowed annotations`);
  }
}

const manifest = {
  schemaVersion: '1.0.0',
  generator: 'docs/design-system/evidence/sources/generate_visual_references.mjs',
  reproduction: [
    'node docs/design-system/evidence/sources/generate_visual_references.mjs docs/design-system/evidence/visual-references',
    'for f in docs/design-system/evidence/visual-references/{android,ios}/*.svg; do sips -s format png "$f" --out "${f%.svg}.png"; done',
    'node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references'
  ],
  assets
};
const serialized = `${JSON.stringify(manifest, null, 2)}\n`;

if (write) {
  fs.writeFileSync(manifestPath, serialized);
  process.stdout.write(`${manifestPath}: updated (${assets.length} assets)\n`);
} else {
  const recorded = fs.readFileSync(manifestPath, 'utf8');
  if (recorded !== serialized) {
    throw new Error(`${manifestPath}: stale; regenerate with --write`);
  }
  process.stdout.write(`visual references: PASS (${assets.length} assets)\n`);
}
