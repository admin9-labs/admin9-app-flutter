import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const root = process.argv[2] ?? 'docs/design-system/evidence/visual-references';
const write = process.argv.includes('--write');
const manifestPath = path.join(root, 'visual-assets.json');
const expected = [];
for (const platform of ['android', 'ios']) {
  for (const page of ['account', 'auth', 'settings']) {
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
  let width;
  let height;
  if (relativePath.endsWith('.png')) {
    ({ width, height } = pngSize(buffer));
  } else {
    const source = buffer.toString('utf8');
    const match = source.match(/<svg[^>]*width="(\d+)"[^>]*height="(\d+)"/);
    if (!match) throw new Error(`${relativePath}: missing SVG dimensions`);
    width = Number(match[1]);
    height = Number(match[2]);
    for (const label of ['设计参考，非当前 App / 模拟器 / 设备截图', 'App 特大 1.24 × 系统标准', '同一基准态', '390lp', '19.84', '17.36', '13.64']) {
      if (!source.includes(label)) throw new Error(`${relativePath}: missing label ${label}`);
    }
  }
  if (width !== 2400 || height !== 1200) {
    throw new Error(`${relativePath}: expected 2400x1200, got ${width}x${height}`);
  }
  return { path: relativePath, width, height, bytes: buffer.length, sha256: sha256(buffer) };
});

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
