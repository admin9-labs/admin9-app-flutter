import fs from 'node:fs';
import path from 'node:path';

const roots = ['docs/design-system', 'docs/architecture/admin9-ui-implementation-plan.md'];
const files = roots.flatMap((root) => {
  const stat = fs.statSync(root);
  if (stat.isFile()) return [root];
  const found = [];
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const target = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(target);
      else if (target.endsWith('.md')) found.push(target);
    }
  };
  visit(root);
  return found;
}).sort();

const errors = [];
const slug = (heading) => heading
  .trim()
  .toLowerCase()
  .replace(/[`*_]/g, '')
  .replace(/[^\p{Letter}\p{Number}\s-]/gu, '')
  .replace(/\s+/g, '-')
  .replace(/-+/g, '-');

for (const file of files) {
  const source = fs.readFileSync(file, 'utf8');
  const lines = source.split('\n');
  if (lines.some((line) => /[ \t]+$/.test(line))) {
    errors.push(`${file}: trailing whitespace`);
  }
  const fences = lines.filter((line) => /^\s*```/.test(line)).length;
  if (fences % 2 !== 0) errors.push(`${file}: unbalanced code fences`);

  for (let index = 0; index < lines.length; index += 1) {
    if (/^\|.*\|$/.test(lines[index]) &&
        (index === 0 || !/^\|.*\|$/.test(lines[index - 1]))) {
      const separator = lines[index + 1] ?? '';
      if (!/^\|(?:\s*:?-{3,}:?\s*\|)+$/.test(separator)) {
        errors.push(`${file}:${index + 1}: table missing separator row`);
      }
    }
  }

  for (const match of source.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)) {
    const link = match[1];
    if (/^(?:https?:|mailto:)/.test(link)) continue;
    const [relative, fragment] = link.split('#', 2);
    const target = relative ? path.resolve(path.dirname(file), relative) : file;
    if (!fs.existsSync(target)) {
      errors.push(`${file}: missing local link target ${link}`);
      continue;
    }
    if (!fragment || !target.endsWith('.md')) continue;
    const targetSource = fs.readFileSync(target, 'utf8');
    const anchors = new Set([
      ...[...targetSource.matchAll(/<a id="([^"]+)"><\/a>/g)].map((item) => item[1]),
      ...targetSource.split('\n')
        .filter((line) => /^#{1,6}\s+/.test(line))
        .map((line) => slug(line.replace(/^#{1,6}\s+/, ''))),
    ]);
    if (!anchors.has(decodeURIComponent(fragment))) {
      errors.push(`${file}: missing anchor ${link}`);
    }
  }
}

if (errors.length > 0) {
  for (const error of errors) process.stderr.write(`${error}\n`);
  process.exit(1);
}

process.stdout.write(`documentation: PASS (${files.length} Markdown files)\n`);
