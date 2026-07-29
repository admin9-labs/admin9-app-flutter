import fs from 'node:fs';
import path from 'node:path';

const outRoot = process.argv[2];
if (!outRoot) throw new Error('usage: node generate_visual_references.mjs <output-dir>');

const palettes = {
  light: { bg: '#F7F8FA', surface: '#FFFFFF', container: '#EEF1F4', text: '#171A1F', muted: '#4B5563', outline: '#687482', primary: '#2457A7', onPrimary: '#FFFFFF', danger: '#B3261E', warning: '#714B00', info: '#245A7A', success: '#246B45' },
  dark: { bg: '#111418', surface: '#191D22', container: '#242A31', text: '#F2F4F7', muted: '#C1C7D0', outline: '#929EAC', primary: '#AFC6FF', onPrimary: '#102A56', danger: '#FFB4AB', warning: '#F4C06A', info: '#A9D1EA', success: '#8FD5AA' },
};

const esc = (value) => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
const rect = (x, y, w, h, fill, stroke = 'none', r = 0, dash = '') => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}"${dash ? ` stroke-dasharray="${dash}"` : ''}/>`;
const line = (x1, y1, x2, y2, color, width = 1) => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-width="${width}"/>`;
const text = (x, y, value, size, color, weight = 400, anchor = 'start') => `<text x="${x}" y="${y}" font-size="${size}" font-weight="${weight}" fill="${color}" text-anchor="${anchor}" font-family="-apple-system,BlinkMacSystemFont,'Noto Sans CJK SC','PingFang SC',Arial,sans-serif">${esc(value)}</text>`;
const typeSize = (base, extraLarge) => extraLarge ? Math.round(base * 1.24 * 100) / 100 : base;

function chrome(p, platform, title, large = false, parent = '') {
  const titleSize = typeSize(20, large);
  let s = rect(0, 0, 390, 844, p.bg);
  s += rect(0, 0, 390, 44, p.surface);
  s += text(195, 28, '9:41', 12, p.text, 600, 'middle');
  s += rect(0, 44, 390, platform === 'ios' ? 54 : 64, p.surface);
  if (parent) s += text(18, platform === 'ios' ? 79 : 84, platform === 'ios' ? `‹ ${parent}` : '←', typeSize(16, large), p.primary, 600);
  s += text(platform === 'ios' ? 195 : 20, platform === 'ios' ? 80 : 85, title, titleSize, p.text, 700, platform === 'ios' ? 'middle' : 'start');
  s += line(0, platform === 'ios' ? 98 : 108, 390, platform === 'ios' ? 98 : 108, p.outline, 0.6);
  return s;
}

function hit(x, y, w, h, p, label = '') {
  return rect(x, y, w, h, 'none', p.primary, 4, '5 4') + (label ? text(x + w, y - 4, label, 9, p.primary, 600, 'end') : '');
}

function button(x, y, w, label, p, variant = 'primary', large = false, platform = 'android') {
  const h = large ? 56 : 48;
  const fill = variant === 'primary' ? p.primary : variant === 'danger' ? p.danger : p.surface;
  const fg = variant === 'primary' ? p.onPrimary : variant === 'danger' ? (p === palettes.light ? '#FFFFFF' : '#111418') : p.primary;
  const stroke = variant === 'secondary' ? p.outline : 'none';
  const platformStroke = platform === 'ios' && variant === 'primary' ? p.primary : stroke;
  return rect(x, y, w, h, fill, platformStroke, 8) + text(x + w / 2, y + (large ? 37 : 31), label, typeSize(16, large), fg, 650, 'middle') + hit(x, y, w, h, p, 'hit');
}

function field(x, y, w, label, value, p, large = false, error = '', platform = 'android') {
  const h = large ? 62 : 54;
  let s = text(x, y - 8, label, typeSize(14, large), p.text, 600);
  const fill = platform === 'ios' ? p.container : p.surface;
  const outline = error ? p.danger : platform === 'ios' ? p.muted : p.outline;
  s += rect(x, y, w, h, fill, outline, 6);
  s += text(x + 14, y + (large ? 40 : 34), value, typeSize(16, large), value ? p.text : p.muted);
  if (error) s += text(x, y + h + (large ? 25 : 20), error, typeSize(13, large), p.danger, 600);
  return s;
}

function androidRow(y, label, trailing, p, large = false, danger = false) {
  const h = large ? 72 : 56;
  let s = rect(20, y, 350, h, p.surface);
  s += text(36, y + (large ? 45 : 35), label, typeSize(16, large), danger ? p.danger : p.text, 500);
  if (trailing) s += text(352, y + (large ? 45 : 35), trailing, typeSize(14, large), p.muted, 500, 'end');
  s += line(36, y + h, 370, y + h, p.outline, 0.5);
  return s;
}

function iosGroup(y, rows, p, large = false) {
  const h = large ? 72 : 52;
  let s = rect(20, y, 350, rows.length * h, p.surface, 'none', 8);
  rows.forEach((row, i) => {
    s += text(36, y + i * h + (large ? 45 : 33), row[0], typeSize(16, large), row[2] ? p.danger : p.text, 500);
    if (row[1]) s += text(350, y + i * h + (large ? 45 : 33), row[1], typeSize(14, large), p.muted, 500, 'end');
    if (i < rows.length - 1) s += line(36, y + (i + 1) * h, 370, y + (i + 1) * h, p.outline, 0.5);
  });
  return s;
}

function switchControl(x, y, p, on = true, platform = 'android') {
  const w = platform === 'ios' ? 50 : 48;
  const h = platform === 'ios' ? 30 : 28;
  let s = rect(x, y, w, h, on ? p.primary : p.outline, 'none', h / 2);
  s += `<circle cx="${on ? x + w - h / 2 : x + h / 2}" cy="${y + h / 2}" r="${h / 2 - 3}" fill="${p.surface}"/>`;
  s += hit(x - 2, y - 9, Math.max(52, w + 4), 48, p, platform === 'ios' ? '44pt+' : '48dp');
  return s;
}

function bottomNavigation(platform, p, large = false) {
  const y = 790;
  let s = rect(0, y, 390, 54, p.surface);
  s += line(0, y, 390, y, p.outline, 0.6);
  s += text(98, y + 24, platform === 'ios' ? '⌂' : '○', typeSize(17, large), p.muted, 600, 'middle');
  s += text(98, y + 43, '首页', typeSize(11, large), p.muted, 500, 'middle');
  s += text(292, y + 24, platform === 'ios' ? '●' : '●', typeSize(17, large), p.primary, 600, 'middle');
  s += text(292, y + 43, '我的', typeSize(11, large), p.primary, 650, 'middle');
  s += hit(50, y + 3, 96, 48, p, platform === 'ios' ? '44pt+' : '48dp');
  s += hit(244, y + 3, 96, 48, p, platform === 'ios' ? '44pt+' : '48dp');
  return s;
}

function account(platform, theme, large, variant = 'guest') {
  const p = palettes[theme];
  let s = chrome(p, platform, '我的', large);
  let y = platform === 'ios' ? 122 : 132;
  const signedIn = variant !== 'guest';
  const missing = variant === 'missing';
  s += text(20, y, signedIn ? (missing ? '已登录用户' : '林晓') : '访客', typeSize(21, large), p.text, 700);
  s += text(20, y + (large ? 34 : 25), missing ? '身份辅助字段缺失，不推断验证状态' : signedIn ? 'sample@example.com · 示例身份数据' : '登录后可使用账号能力', typeSize(14, large), p.muted);
  y += large ? 54 : 44;
  if (!signedIn && !large) {
    s += button(20, y, 350, '登录', p, 'primary', large, platform);
    y += 60;
    s += text(20, y + 18, '注册账号', 15, p.primary, 600);
    s += text(350, y + 18, '账号找回', 15, p.primary, 600, 'end');
    s += hit(16, y - 10, 120, 48, p); s += hit(254, y - 10, 120, 48, p);
    y += 56;
  } else {
    const accountRows = [['账号资料', '›'], ['账号安全', '›']];
    s += platform === 'ios' ? iosGroup(y, accountRows, p, large) : accountRows.map((r, i) => androidRow(y + i * (large ? 72 : 56), r[0], r[1], p, large)).join('');
    y += (large ? 72 : 56) * 2 + 24;
  }
  s += text(20, y, '应用', typeSize(13, large), p.muted, 650);
  y += 12;
  s += platform === 'ios' ? iosGroup(y, [['设置', '›']], p, large) : androidRow(y, '设置', '›', p, large);
  y += large ? 92 : 72;
  s += text(20, y, '支持与法务', typeSize(13, large), p.muted, 650);
  y += 12;
  const rows = [['用户协议', '›'], ['隐私政策', '›'], ['关于', '›']];
  s += platform === 'ios' ? iosGroup(y, rows, p, large) : rows.map((r, i) => androidRow(y + i * (large ? 72 : 56), r[0], r[1], p, large)).join('');
  if (signedIn) {
    s += rect(20, 724, 350, 52, p.surface, p.danger, 8);
    s += text(195, 756, '退出登录（滚动终点）', typeSize(14, large), p.danger, 650, 'middle');
  }
  s += bottomNavigation(platform, p, large);
  return s;
}

function auth(platform, theme, large, variant = 'register') {
  const p = palettes[theme];
  const login = variant === 'login';
  const errorState = variant === 'error';
  let s = chrome(p, platform, login ? '登录' : '注册', large, '我的');
  let y = platform === 'ios' ? 140 : 150;
  s += text(20, y, login ? '欢迎回来' : '创建账号', typeSize(22, large), p.text, 700);
  s += text(20, y + (large ? 32 : 28), '当前版本仅验证表单，服务尚未接入', typeSize(14, large), p.muted);
  y += 72;
  s += field(20, y, 350, '账号', errorState ? '' : 'admin9@example.com', p, large, errorState ? '请输入账号' : '', platform);
  y += large ? 118 : 82;
  s += field(20, y, 350, login ? '密码' : '新密码', '••••••••', p, large, '', platform);
  s += hit(318, y + 3, 48, 48, p, 'toggle');
  y += large ? 98 : 82;
  if (!login) {
    s += field(20, y, 350, '确认密码', '••••••', p, large, errorState ? '两次密码不一致' : '', platform);
    y += large ? 124 : 82;
  }
  s += button(20, y, 350, login ? '登录' : '注册', p, 'primary', large, platform);
  y += large ? 74 : 64;
  s += text(20, y + 12, login ? '注册账号' : '返回登录', typeSize(14, large), p.primary, 600);
  if (login) s += text(350, y + 12, '账号找回', typeSize(14, large), p.primary, 600, 'end');
  s += hit(16, y - 10, 120, 48, p);
  if (login) s += hit(254, y - 10, 120, 48, p);
  y += 48;
  const noticeH = large ? 78 : 62;
  s += rect(20, y, 350, noticeH, p.container, p.info, 6);
  s += text(36, y + (large ? 27 : 24), '信息：服务未接入', typeSize(14, large), p.info, 700);
  s += text(36, y + (large ? 55 : 45), '保留输入，不创建会话', typeSize(13, large), p.text);
  s += text(195, 820, large ? '错误推动布局增长；整页滚动' : 'Next → Next → Done；首错聚焦', typeSize(11, large), p.muted, 500, 'middle');
  return s;
}

function settings(platform, theme, large, variant = 'main') {
  const p = palettes[theme];
  const selection = variant === 'selection';
  let s = chrome(p, platform, selection ? '主题' : '设置', large, selection ? '设置' : '我的');
  const rowH = large ? 78 : (platform === 'ios' ? 52 : 56);
  let y = platform === 'ios' ? 126 : 132;
  if (selection) {
    s += text(20, y, '选择主题', 13, p.muted, 650); y += 12;
    const options = [['跟随系统', platform === 'ios' ? '✓' : '◉'], ['浅色', platform === 'ios' ? '' : '○'], ['深色', platform === 'ios' ? '' : '○']];
    s += platform === 'ios' ? iosGroup(y, options, p, false) : options.map((r, i) => androidRow(y + i * rowH, r[0], r[1], p, false)).join('');
    s += text(24, y + rowH * 3 + 34, '选择立即生效；当前项具有 selected 语义', 13, p.muted);
    s += text(195, 820, '用户主动返回设置；焦点恢复到主题行', typeSize(11, large), p.muted, 500, 'middle');
    return s;
  }
  s += text(20, y, '外观', typeSize(13, large), p.muted, 650); y += 12;
  const appearance = [['主题', '跟随系统  ›'], ['App 字号', '标准  ›']];
  s += platform === 'ios' ? iosGroup(y, appearance, p, large) : appearance.map((r, i) => androidRow(y + i * rowH, r[0], r[1], p, large)).join('');
  y += rowH * 2 + 34;
  s += text(20, y, '辅助功能', typeSize(13, large), p.muted, 650); y += 12;
  const labels = ['灰度', '高对比度', '减少动态效果'];
  if (platform === 'ios') {
    s += rect(20, y, 350, rowH * 3, p.surface, 'none', 8);
    labels.forEach((label, i) => {
      const yy = y + i * rowH;
      s += text(36, yy + (large ? 45 : 33), label, typeSize(16, large), p.text, 500);
      s += switchControl(300, yy + (large ? 23 : 11), p, i === 1, platform);
      if (i < 2) s += line(36, yy + rowH, 370, yy + rowH, p.outline, 0.5);
    });
  } else {
    labels.forEach((label, i) => {
      const yy = y + i * rowH;
      s += androidRow(yy, label, '', p, large);
      s += switchControl(300, yy + (large ? 25 : 14), p, i === 1, platform);
    });
  }
  y += rowH * 3 + 18;
  s += rect(20, y, 350, large ? 104 : 78, p.container, p.info, 6);
  s += text(36, y + (large ? 29 : 25), '系统已开启高对比度，当前仍有效', typeSize(14, large), p.text, 650);
  s += text(36, y + (large ? 59 : 48), '开关表示 App 偏好；有效值 = 系统 OR App', typeSize(12, large), p.muted);
  if (large) s += text(36, y + 86, 'App 设置不能削弱系统要求', typeSize(12, large), p.muted);
  s += text(195, 820, '选择立即生效；无保存按钮', typeSize(11, large), p.muted, 500, 'middle');
  return s;
}

function board(platform, page) {
  const title = { account: '个人中心', auth: '认证表单', settings: '设置' }[page];
  const render = { account, auth, settings }[page];
  const alternate = { account: 'signed', auth: 'login', settings: 'selection' }[page];
  const extraLarge = { account: 'missing', auth: 'error', settings: 'main' }[page];
  const base = { account: 'guest', auth: 'register', settings: 'main' }[page];
  const states = [
    { x: 65, theme: 'light', large: false, variant: base, label: '浅色 · 标准字号 · 390lp · 基准态' },
    { x: 625, theme: 'dark', large: false, variant: base, label: '深色 · 标准字号 · 390lp · 同一基准态' },
    { x: 1185, theme: 'light', large: true, variant: extraLarge, label: '浅色 · App 特大 1.24 × 系统标准 · 390lp' },
    { x: 1745, theme: 'light', large: false, variant: alternate, label: '浅色 · 标准字号 · 关键替代态' },
  ];
  let s = `<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="1200" viewBox="0 0 2400 1200">`;
  s += rect(0, 0, 2400, 1200, '#E9EDF2');
  s += text(70, 54, `Admin9 Design System · ${platform === 'android' ? 'Android / Material 3' : 'iOS / Cupertino'} · ${title}`, 26, '#171A1F', 750);
  s += text(70, 84, '设计参考，非当前 App / 模拟器 / 设备截图', 15, '#4B5563', 500);
  for (const state of states) {
    s += text(state.x + 195, 112, state.label, 14, '#334155', 650, 'middle');
    s += `<g transform="translate(${state.x},130)">${render(platform, state.theme, state.large, state.variant)}</g>`;
  }
  s += rect(70, 1010, 2260, 140, '#FFFFFF', '#B8C1CC', 8);
  s += text(94, 1042, '校准标注', 16, '#171A1F', 700);
  s += text(94, 1072, '虚线 = hit bounds；实线容器 = visual bounds。Android ≥48×48dp，iOS ≥44×44pt。', 14, '#334155');
  s += text(94, 1100, '关键状态：按下使用语义 state layer；焦点使用 2px ring；禁用保留文字/形状；错误、未接入、系统强制状态均有文字说明。', 14, '#334155');
  s += text(94, 1128, '第三画布字体 = 标准语义字号 × 1.24；容器按内容增长。320/360/600、横屏、设备读屏和系统手势由后续门禁验证。', 14, '#334155');
  s += '</svg>';
  return s;
}

for (const platform of ['android', 'ios']) {
  const dir = path.join(outRoot, platform);
  fs.mkdirSync(dir, { recursive: true });
  for (const page of ['account', 'auth', 'settings']) {
    fs.writeFileSync(path.join(dir, `${page}.svg`), board(platform, page));
  }
}
