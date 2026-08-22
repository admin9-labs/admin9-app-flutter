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
const platformText = (key, ...args) => text(...args).replace('<text ', `<text data-platform-difference="${esc(key)}" `);
const multilineText = (x, y, lines, size, color, weight = 400, lineHeight = 22, anchor = 'start') => lines.map((value, index) => text(x, y + index * lineHeight, value, size, color, weight, anchor)).join('');
const typeSize = (base, extraLarge) => extraLarge ? Math.round(base * 1.24 * 100) / 100 : base;

function chrome(p, platform, title, large = false, parent = '') {
  const titleSize = typeSize(20, large);
  let s = rect(0, 0, 390, 844, p.bg);
  s += rect(0, 0, 390, 44, p.surface);
  s += text(195, 28, '9:41', 12, p.text, 600, 'middle');
  s += rect(0, 44, 390, 64, p.surface);
  if (parent) {
    s += platformText('back-control', 18, 84, platform === 'ios' ? `‹ ${parent}` : `← ${parent}`, typeSize(14, large), p.primary, 650);
  }
  s += text(parent ? 132 : 20, 85, title, titleSize, p.text, 700);
  s += line(0, 108, 390, 108, p.outline, 0.6);
  return s;
}

function hit(x, y, w, h, p, label = '') {
  return rect(x, y, w, h, 'none', p.primary, 4, '5 4') + (label ? text(x + w, y - 4, label, 9, p.primary, 600, 'end') : '');
}

function platformHit(x, y, w, h, p, label, key) {
  return rect(x, y, w, h, 'none', p.primary, 4, '5 4') + platformText(key, x + w, y - 4, label, 9, p.primary, 600, 'end');
}

function button(x, y, w, label, p, variant = 'primary', large = false, platform = 'android') {
  const h = large ? 56 : 48;
  const fill = variant === 'primary' ? p.primary : variant === 'danger' ? p.danger : p.surface;
  const fg = variant === 'primary' ? p.onPrimary : variant === 'danger' ? (p === palettes.light ? '#FFFFFF' : '#111418') : p.primary;
  const stroke = variant === 'secondary' ? p.outline : 'none';
  return rect(x, y, w, h, fill, stroke, 8) + text(x + w / 2, y + (large ? 37 : 31), label, typeSize(16, large), fg, 650, 'middle') + hit(x, y, w, h, p, 'hit');
}

function field(x, y, w, label, value, p, large = false, error = '', platform = 'android', focused = false) {
  const h = large ? 62 : 54;
  let s = text(x, y - 8, label, typeSize(14, large), p.text, 600);
  const outline = error ? p.danger : p.outline;
  s += rect(x, y, w, h, p.surface, outline, 6);
  if (focused) s += `<rect x="${x - 2}" y="${y - 2}" width="${w + 4}" height="${h + 4}" rx="8" fill="none" stroke="${p.primary}" stroke-width="2"/>`;
  s += text(x + 14, y + (large ? 40 : 34), value, typeSize(16, large), value ? p.text : p.muted);
  if (error) {
    const lines = Array.isArray(error) ? error : [error];
    s += multilineText(x, y + h + (large ? 25 : 20), lines, typeSize(13, large), p.danger, 600, large ? 24 : 20);
  }
  return s;
}

function brandRow(y, label, trailing, p, large = false, danger = false) {
  const h = large ? 72 : 56;
  let s = rect(20, y, 350, h, p.surface);
  s += text(36, y + (large ? 45 : 35), label, typeSize(16, large), danger ? p.danger : p.text, 500);
  if (trailing) s += text(352, y + (large ? 45 : 35), trailing, typeSize(14, large), p.muted, 500, 'end');
  s += line(36, y + h, 370, y + h, p.outline, 0.5);
  return s;
}

function brandGroup(y, rows, p, large = false) {
  const h = large ? 72 : 56;
  let s = rect(20, y, 350, rows.length * h, p.surface, 'none', 8);
  rows.forEach((row, i) => {
    s += text(36, y + i * h + (large ? 45 : 33), row[0], typeSize(16, large), row[2] ? p.danger : p.text, 500);
    if (row[1]) s += text(350, y + i * h + (large ? 45 : 33), row[1], typeSize(14, large), p.muted, 500, 'end');
    if (i < rows.length - 1) s += line(36, y + (i + 1) * h, 370, y + (i + 1) * h, p.outline, 0.5);
  });
  return s;
}

function switchControl(x, y, p, on = true, platform = 'android') {
  const w = 48;
  const h = 28;
  let s = rect(x, y, w, h, on ? p.primary : p.outline, 'none', h / 2);
  s += `<circle cx="${on ? x + w - h / 2 : x + h / 2}" cy="${y + h / 2}" r="${h / 2 - 3}" fill="${p.surface}"/>`;
  s += platformHit(x - 2, y - 9, Math.max(52, w + 4), 48, p, platform === 'ios' ? '44pt+' : '48dp', 'switch-hit-minimum');
  return s;
}

function bottomNavigation(platform, p, large = false) {
  const y = 790;
  let s = rect(0, y, 390, 54, p.surface);
  s += line(0, y, 390, y, p.outline, 0.6);
  s += text(98, y + 24, '⌂', typeSize(17, large), p.muted, 600, 'middle');
  s += text(98, y + 43, '首页', typeSize(11, large), p.muted, 500, 'middle');
  s += text(292, y + 24, '●', typeSize(17, large), p.primary, 600, 'middle');
  s += text(292, y + 43, '我的', typeSize(11, large), p.primary, 650, 'middle');
  s += platformHit(50, y + 3, 96, 48, p, platform === 'ios' ? '44pt+' : '48dp', 'navigation-hit-minimum');
  s += platformHit(244, y + 3, 96, 48, p, platform === 'ios' ? '44pt+' : '48dp', 'navigation-hit-minimum');
  return s;
}

function account(platform, theme, large, variant = 'guest') {
  const p = palettes[theme];
  let s = chrome(p, platform, '我的', large);
  if (variant === 'long') {
    s += text(20, 140, '长中文重排', typeSize(13, large), p.muted, 650);
    s += multilineText(20, 178, ['这是用于验证长中文重排的', '账号显示名称'], typeSize(20, large), p.text, 700, large ? 34 : 28);
    s += text(20, large ? 252 : 230, 'sample.long.identity@example.com', typeSize(13, large), p.muted);
    const groupY = large ? 282 : 260;
    s += rect(20, groupY, 350, large ? 228 : 198, p.surface, 'none', 8);
    s += multilineText(36, groupY + (large ? 42 : 36), ['这是用于验证长中文内容增长的', '账号资料设置名称'], typeSize(16, large), p.text, 500, large ? 30 : 24);
    s += text(36, groupY + (large ? 114 : 96), '一个较长的当前值会换到下一行', typeSize(14, large), p.muted, 500);
    s += line(36, groupY + (large ? 142 : 122), 370, groupY + (large ? 142 : 122), p.outline, 0.5);
    s += text(36, groupY + (large ? 190 : 166), '账号安全', typeSize(16, large), p.text, 500);
    s += text(350, groupY + (large ? 190 : 166), '›', typeSize(14, large), p.muted, 500, 'end');
    s += bottomNavigation(platform, p, large);
    return s;
  }
  if (variant === 'emptyError') {
    s += text(20, 144, '账号能力', typeSize(13, large), p.muted, 650);
    s += rect(20, 162, 350, 148, p.surface, p.outline, 8);
    s += text(195, 208, '暂无可用账号能力', typeSize(18, large), p.text, 700, 'middle');
    s += multilineText(195, 244, ['当前状态没有列表项，', '底部导航仍保持可用。'], typeSize(13, large), p.muted, 400, 22, 'middle');
    s += rect(20, 338, 350, 174, p.surface, p.danger, 8);
    s += text(195, 386, '列表载入失败', typeSize(18, large), p.text, 700, 'middle');
    s += multilineText(195, 422, ['请检查网络后重试，', '现有导航状态保持不变。'], typeSize(13, large), p.muted, 400, 22, 'middle');
    s += text(195, 488, '重试', typeSize(14, large), p.primary, 650, 'middle');
    s += bottomNavigation(platform, p, large);
    return s;
  }
  let y = 132;
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
    s += brandGroup(y, accountRows, p, large);
    y += (large ? 72 : 56) * 2 + 24;
  }
  s += text(20, y, '应用', typeSize(13, large), p.muted, 650);
  y += 12;
  s += brandGroup(y, [['设置', '›']], p, large);
  y += large ? 92 : 72;
  s += text(20, y, '支持与法务', typeSize(13, large), p.muted, 650);
  y += 12;
  const rows = [['用户协议', '›'], ['隐私政策', '›'], ['关于', '›']];
  s += brandGroup(y, rows, p, large);
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
  const focused = variant === 'focused';
  let s = chrome(p, platform, login ? '登录' : '注册', large, '我的');
  let y = 150;
  s += text(20, y, login ? '欢迎回来' : '创建账号', typeSize(22, large), p.text, 700);
  s += text(20, y + (large ? 32 : 28), '当前版本仅验证表单，服务尚未接入', typeSize(14, large), p.muted);
  y += 72;
  s += field(20, y, 350, '账号', errorState ? '' : 'admin9@example.com', p, large, errorState ? ['请输入手机号或邮箱，', '内容不会被裁切。'] : '', platform, focused);
  y += large ? (errorState ? 148 : 118) : (errorState ? 108 : 82);
  s += field(20, y, 350, login ? '密码' : '新密码', '••••••••', p, large, '', platform);
  s += hit(318, y + 3, 48, 48, p, 'toggle');
  y += large ? 98 : 82;
  if (!login) {
    s += field(20, y, 350, '确认密码', '••••••', p, large, errorState ? ['两次密码不一致，', '请重新输入确认密码。'] : '', platform);
    y += large ? (errorState ? 146 : 124) : (errorState ? 108 : 82);
  }
  s += button(20, y, 350, login ? '登录' : '注册', p, 'primary', large, platform);
  y += large ? 66 : 64;
  s += text(20, y + 12, login ? '注册账号' : '返回登录', typeSize(14, large), p.primary, 600);
  if (login) s += text(350, y + 12, '账号找回', typeSize(14, large), p.primary, 600, 'end');
  s += hit(16, y - 10, 120, 48, p);
  if (login) s += hit(254, y - 10, 120, 48, p);
  y += large ? 40 : 48;
  const noticeH = large ? 70 : 62;
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
  const rowH = large ? 78 : 56;
  let y = 132;
  if (selection) {
    s += text(20, y, '选择主题', 13, p.muted, 650); y += 12;
    const options = [['跟随系统', '✓'], ['浅色', ''], ['深色', '']];
    s += brandGroup(y, options, p, false);
    s += text(24, y + rowH * 3 + 34, '选择立即生效；当前项具有 selected 语义', 13, p.muted);
    s += text(195, 820, '用户主动返回设置；焦点恢复到主题行', typeSize(11, large), p.muted, 500, 'middle');
    return s;
  }
  s += text(20, y, '外观', typeSize(13, large), p.muted, 650); y += 12;
  const appearance = [['主题', '跟随系统  ›'], ['App 字号', '标准  ›']];
  s += brandGroup(y, appearance, p, large);
  y += rowH * 2 + 34;
  s += text(20, y, '辅助功能', typeSize(13, large), p.muted, 650); y += 12;
  const labels = ['灰度', '高对比度', '减少动态效果'];
  s += rect(20, y, 350, rowH * 3, p.surface, 'none', 8);
  labels.forEach((label, i) => {
    const yy = y + i * rowH;
    s += text(36, yy + (large ? 45 : 35), label, typeSize(16, large), p.text, 500);
    s += switchControl(300, yy + (large ? 25 : 14), p, i === 1, platform);
    if (i < 2) s += line(36, yy + rowH, 370, yy + rowH, p.outline, 0.5);
  });
  y += rowH * 3 + 18;
  const persistenceError = variant === 'error';
  s += rect(20, y, 350, large ? 118 : 78, p.container, persistenceError ? p.danger : p.info, 6);
  s += text(36, y + (large ? 29 : 25), persistenceError ? '设置暂未保存' : '系统已开启高对比度，当前仍有效', typeSize(14, large), p.text, 650);
  s += multilineText(36, y + (large ? 59 : 48), persistenceError ? ['当前显示值尚未持久化，', '可重试且不会丢失当前选择。'] : ['开关表示 App 偏好；有效值 = 系统 OR App', ...(large ? ['App 设置不能削弱系统要求'] : [])], typeSize(12, large), p.muted, 400, large ? 25 : 20);
  if (persistenceError) s += text(350, y + (large ? 105 : 68), '重试', typeSize(13, large), p.primary, 650, 'end');
  s += text(195, 820, '选择立即生效；无保存按钮', typeSize(11, large), p.muted, 500, 'middle');
  return s;
}

function feedback(platform, theme, large, variant = 'dialog') {
  const p = palettes[theme];
  let s = chrome(p, platform, '状态与反馈', large, '首页');
  if (variant === 'menu') {
    s += text(20, 140, '动作菜单', 13, p.muted, 650);
    s += rect(20, 158, 350, 330, p.surface, p.outline, 8);
    s += text(36, 190, '账号操作', 14, p.muted, 650);
    const items = [['查看详情', p.text], ['复制信息', p.text], ['暂不可用', p.muted], ['删除账号', p.danger]];
    items.forEach((item, index) => {
      const yy = 212 + index * 56;
      s += text(36, yy + 34, item[0], 15, item[1], 500);
      if (index < items.length - 1) s += line(36, yy + 56, 354, yy + 56, p.outline, 0.5);
    });
    s += line(36, 444, 354, 444, p.outline, 0.8);
    s += text(195, 476, '取消', 15, p.primary, 650, 'middle');
  } else if (variant === 'dialog') {
    s += text(20, 140, '确认弹窗', 13, p.muted, 650);
    s += rect(0, 108, 390, 682, '#00000066');
    const dialogY = large ? 244 : 264;
    const dialogH = large ? 260 : 224;
    s += rect(36, dialogY, 318, dialogH, p.surface, p.outline, 8);
    s += text(60, dialogY + 42, '确认提交', typeSize(20, large), p.text, 700);
    s += text(60, dialogY + (large ? 88 : 78), '提交后将更新当前设置，是否继续？', typeSize(14, large), p.text);
    s += line(60, dialogY + dialogH - 70, 330, dialogY + dialogH - 70, p.outline, 0.5);
    s += text(184, dialogY + dialogH - 28, '取消', typeSize(14, large), p.muted, 650, 'end');
    s += text(326, dialogY + dialogH - 28, '继续', typeSize(14, large), p.primary, 700, 'end');
    s += hit(74, dialogY + dialogH - 62, 120, 48, p);
    s += hit(218, dialogY + dialogH - 62, 120, 48, p);
  } else if (variant === 'states') {
    s += text(20, 140, '大字号异常状态', typeSize(13, large), p.muted, 650);
    s += rect(20, 158, 350, 156, p.surface, p.danger, 8);
    s += text(38, 196, '操作失败', typeSize(17, large), p.text, 700);
    s += multilineText(38, 234, ['无法载入当前内容，', '请检查网络连接后重试。'], typeSize(14, large), p.text, 400, 28);
    s += text(350, 296, '重试', typeSize(14, large), p.primary, 650, 'end');
    s += rect(20, 338, 350, 132, p.surface, p.outline, 8);
    s += text(195, 382, '暂无内容', typeSize(17, large), p.text, 700, 'middle');
    s += multilineText(195, 418, ['只有存在真实下一步时，', '空状态才显示操作。'], typeSize(13, large), p.muted, 400, 25, 'middle');
    s += text(20, 504, '已完成 45%', typeSize(14, large), p.text, 650);
    s += rect(20, 524, 350, 10, p.container, 'none', 5);
    s += rect(20, 524, 158, 10, p.primary, 'none', 5);
  } else {
    s += text(20, 140, '交互状态', 13, p.muted, 650);
    s += rect(20, 166, 166, 48, p.primary, 'none', 8);
    s += rect(20, 166, 166, 48, '#0000001A', 'none', 8);
    s += text(103, 197, '按下状态', 15, p.onPrimary, 650, 'middle');
    s += rect(204, 166, 166, 48, p.container, p.outline, 8);
    s += text(287, 197, '禁用操作', 15, p.muted, 650, 'middle');
    s += rect(18, 236, 354, 58, 'none', p.primary, 8);
    s += `<rect x="16" y="234" width="358" height="62" rx="10" fill="none" stroke="${p.primary}" stroke-width="2"/>`;
    s += text(195, 271, '键盘焦点操作', 15, p.primary, 650, 'middle');
    s += rect(20, 326, 350, 82, p.surface, 'none', 8);
    s += `<circle cx="50" cy="367" r="11" fill="none" stroke="${p.primary}" stroke-width="3" stroke-dasharray="45 20"/>`;
    s += text(78, 363, '正在载入', 15, p.text, 650);
    s += text(78, 385, '不确定进度', 12, p.muted);
    s += rect(20, 438, 350, 82, p.container, p.info, 8);
    s += text(38, 472, '设置已更新', 14, p.text, 700);
    s += text(350, 497, '关闭', 13, p.primary, 650, 'end');
  }
  s += platformText('modal-behavior', 195, 820, platform === 'ios' ? '保留 iOS 模态焦点、边缘返回与安全区' : '保留 Android 模态焦点、系统返回与安全区', typeSize(11, large), p.muted, 500, 'middle');
  return s;
}

function board(platform, page) {
  const title = { account: '主导航与列表', auth: '登录与注册', settings: '设置表单', feedback: '弹窗与反馈' }[page];
  const render = { account, auth, settings, feedback }[page];
  const variants = {
    account: ['signed', 'signed', 'long', 'emptyError'],
    auth: ['focused', 'register', 'error', 'login'],
    settings: ['main', 'main', 'error', 'selection'],
    feedback: ['menu', 'dialog', 'states', 'interaction'],
  }[page];
  const labels = {
    account: ['已登录列表', '已登录列表', '长中文重排', '空状态与可恢复错误'],
    auth: ['键盘焦点', '注册基准态', '长中文错误', '登录替代态'],
    settings: ['设置基准态', '设置基准态', '持久化错误', '选择状态'],
    feedback: ['动作菜单', '确认弹窗', '错误·空态·确定进度', '按下·禁用·焦点·反馈'],
  }[page];
  const states = [
    { x: 65, theme: 'light', large: false, variant: variants[0], label: `浅色 · 标准字号 · 390lp · ${labels[0]}` },
    { x: 625, theme: 'dark', large: false, variant: variants[1], label: `深色 · 标准字号 · 390lp · ${labels[1]}` },
    { x: 1185, theme: 'light', large: true, variant: variants[2], label: `浅色 · App 特大 1.24 × 系统标准 · 390lp · ${labels[2]}` },
    { x: 1745, theme: 'light', large: false, variant: variants[3], label: `浅色 · 标准字号 · 390lp · ${labels[3]}` },
  ];
  let s = `<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="1200" viewBox="0 0 2400 1200">`;
  s += rect(0, 0, 2400, 1200, '#E9EDF2');
  s += platformText('board-platform-title', 70, 54, `Admin9 Design System · ${platform === 'android' ? 'Android' : 'iOS'} · ${title}`, 26, '#171A1F', 750);
  s += text(70, 84, '设计参考，非当前 App / 模拟器 / 设备截图', 15, '#4B5563', 500);
  s += text(2330, 84, '同一 Admin9 可见契约', 15, '#2457A7', 650, 'end');
  for (const state of states) {
    s += text(state.x + 195, 112, state.label, 14, '#334155', 650, 'middle');
    s += `<g transform="translate(${state.x},130)">${render(platform, state.theme, state.large, state.variant)}</g>`;
  }
  s += rect(70, 1010, 2260, 140, '#FFFFFF', '#B8C1CC', 8);
  s += text(94, 1042, '校准标注', 16, '#171A1F', 700);
  s += text(94, 1072, '虚线 = hit bounds；实线容器 = visual bounds。Android ≥48×48dp，iOS ≥44×44pt。', 14, '#334155');
  s += text(94, 1100, '关键状态：按下使用语义 state layer；焦点使用 2px ring；禁用保留文字/形状；错误、未接入、系统强制状态均有文字说明。', 14, '#334155');
  s += text(94, 1128, '第三画布字体 = 标准语义字号 × 1.24；容器按内容增长。系统交互差异单独验收；320/360/600、横屏与设备读屏由后续门禁验证。', 14, '#334155');
  s += '</svg>';
  return s;
}

for (const platform of ['android', 'ios']) {
  const dir = path.join(outRoot, platform);
  fs.mkdirSync(dir, { recursive: true });
  for (const page of ['account', 'auth', 'settings', 'feedback']) {
    fs.writeFileSync(path.join(dir, `${page}.svg`), board(platform, page));
  }
}
