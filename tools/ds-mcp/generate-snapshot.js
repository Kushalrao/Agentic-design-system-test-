#!/usr/bin/env node
/**
 * DS Snapshot Generator
 *
 * Combines Dart token files + knowledgebase markdown into a single
 * machine-readable JSON file that the MCP server reads at runtime.
 *
 * Usage: node tools/ds-mcp/generate-snapshot.js
 *        (or: melos run ds-mcp:generate)
 *
 * Output: tools/ds-mcp/ds-snapshot.json
 *
 * Regenerate whenever:
 *   - melos run tokens (token values changed)
 *   - knowledgebase/foundations/*.md edited
 *   - new component added to packages/ds/
 */

const fs   = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '../..');
const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf-8');

// ─── Markdown table parser ────────────────────────────────────────────────────

/**
 * Parse a markdown table section starting after `headerMatch` regex.
 * Returns array of objects keyed by column headers (lowercase, spaces→_).
 */
function parseMarkdownTable(content, headerMatch) {
  const start = content.search(headerMatch);
  if (start === -1) return [];

  const section = content.slice(start);
  const lines   = section.split('\n');
  const rows    = [];
  let   headers = null;

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed.startsWith('|')) {
      if (headers) break; // end of table
      continue;
    }
    const cells = trimmed.split('|').slice(1, -1).map(c => c.trim());
    if (!headers) {
      headers = cells.map(h => h.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z_]/g, ''));
      continue;
    }
    if (cells.every(c => /^[-:]+$/.test(c))) continue; // separator row
    if (cells.length !== headers.length) continue;

    const row = {};
    headers.forEach((h, i) => {
      // strip backticks and inline code markers
      row[h] = cells[i].replace(/`/g, '').trim();
    });
    rows.push(row);
  }
  return rows;
}

// ─── Foundation (size / weight / lineheight lookup) ───────────────────────────

function parseFoundation(content) {
  const lookup = {};
  const re = /static const double (\w+)\s*=\s*([\d.]+);/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    lookup[m[1]] = parseFloat(m[2]);
  }
  return lookup;
}

// ─── Color primitives (name → hex) ───────────────────────────────────────────

function parseColorPrimitives(content) {
  const map = {};
  const re = /static const Color (\w+) = Color\(0xFF([0-9A-Fa-f]{6})\)/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    map[m[1]] = '#' + m[2].toUpperCase();
  }
  return map;
}

// ─── ColorScale (field name → tier1 primitive name) ──────────────────────────

function parseColorScale(content) {
  const map = {};
  // Match lines like: brandPrimary:  ColorPrimitives.primaryScapia800,
  const re = /(\w+):\s+ColorPrimitives\.(\w+),/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    map[m[1]] = m[2];
  }
  return map;
}

// ─── Spacing scale (name → dp value) ─────────────────────────────────────────

function parseSpacingScale(content, primitives) {
  const map = {};
  // static const double spaceMd  = SpacingPrimitives.spacing9;
  const re = /static const double (\w+)\s*=\s*SpacingPrimitives\.spacing(\d+)/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    map[m[1]] = parseInt(m[2], 10);
  }
  return map;
}

// ─── Radius tokens (name → dp value) ─────────────────────────────────────────

function parseRadiusTokens(content) {
  const map = {};
  const re = /static const double (r\w+|full)\s*=\s*([\d.]+)/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    map[m[1]] = parseFloat(m[2]);
  }
  return map;
}

// ─── Opacity tokens (name → value) ───────────────────────────────────────────

function parseOpacityTokens(content) {
  const map = {};
  const re = /static const double (opacity\d+)\s*=\s*([\d.]+)/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    map[m[1]] = parseFloat(m[2]);
  }
  return map;
}

// ─── Typography scale (static name → size/weight/lh) ─────────────────────────

function parseTypographyScale(content, foundation) {
  const styles = {};

  // Strategy 1: parse TextStyle blocks directly (works for all styles including Pr-*/Dp-*)
  // Match: static const TextStyle name = TextStyle( ... );
  const blockRe = /static const TextStyle (\w+) = TextStyle\(([\s\S]*?)\);/g;
  let m;
  while ((m = blockRe.exec(content)) !== null) {
    const name  = m[1];
    const block = m[2];
    const entry = {};

    // fontSize: Foundation.fontSizeXX
    const sizeM = block.match(/fontSize:\s*Foundation\.(\w+)/);
    if (sizeM && foundation[sizeM[1]] !== undefined) entry.size = foundation[sizeM[1]];

    // fontWeight: FontWeight.wNNN
    const weightM = block.match(/fontWeight:\s*FontWeight\.w(\d+)/);
    if (weightM) entry.weight = parseInt(weightM[1], 10);

    // height: Foundation.fontLineheightXX / Foundation.fontSizeYY
    const lhM = block.match(/height:\s*Foundation\.(\w+)\s*\/\s*Foundation\.(\w+)/);
    if (lhM && foundation[lhM[1]] !== undefined) entry.lineheight = foundation[lhM[1]];

    styles[name] = entry;
  }

  // Strategy 2: fill any gaps via raw numeric tokens
  // static const double pSmallSize = Foundation.fontSize13;
  const numRe = /static const double (\w+)(Size|Weight|Lineheight)\s*=\s*Foundation\.(\w+)/gi;
  while ((m = numRe.exec(content)) !== null) {
    const styleName = m[1];
    const prop      = m[2].toLowerCase();
    const foundKey  = m[3];
    if (styles[styleName] && styles[styleName][prop] === undefined && foundation[foundKey] !== undefined) {
      styles[styleName][prop] = foundation[foundKey];
    }
  }

  return styles;
}

// ─── Color intent from knowledgebase/foundations/color.md ────────────────────

function parseColorIntent(content) {
  const intent = {};

  // Parse each token table section — headers: Token | Tier 1 reference | Hex | Intent
  const tableRe = /^\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|/m;
  const lines = content.split('\n');

  let inTable = false;
  let headers = null;

  for (const line of lines) {
    const t = line.trim();
    if (!t.startsWith('|')) { inTable = false; headers = null; continue; }

    const cells = t.split('|').slice(1, -1).map(c => c.trim().replace(/`/g, ''));
    if (!headers) {
      // detect header row
      const lower = cells.map(c => c.toLowerCase());
      if (lower.some(c => c.includes('token')) &&
          lower.some(c => c.includes('intent') || c.includes('use'))) {
        headers = lower;
        inTable = true;
      }
      continue;
    }
    if (cells.every(c => /^[-:]+$/.test(c))) continue;

    const tokenIdx  = headers.findIndex(h => h.includes('token'));
    const intentIdx = headers.findIndex(h => h.includes('intent') || h.includes('use_when') || h.includes('use when'));
    const doNotIdx  = headers.findIndex(h => h.includes('do not') || h.includes('not_use'));

    if (tokenIdx === -1 || intentIdx === -1) continue;
    const name = cells[tokenIdx];
    if (!name || name.startsWith('#') || name.startsWith('---')) continue;

    intent[name] = {
      intent:      cells[intentIdx] || '',
      doNotUseFor: doNotIdx !== -1 ? (cells[doNotIdx] || '') : '',
    };
  }

  return intent;
}

// ─── Color gaps from knowledgebase/foundations/color.md ──────────────────────

function parseColorGaps(content) {
  const gaps = [];
  const gapSection = content.match(/## Known gaps[\s\S]+?(?=\n---|\n## |$)/);
  if (!gapSection) return gaps;

  const rows = parseMarkdownTable(gapSection[0], /\|/);
  for (const row of rows) {
    // Columns: Figma value | What it is | Workaround | When to add a token
    const hex = Object.values(row)[0];
    if (!hex || hex.startsWith('-')) continue;
    gaps.push({
      hex:         hex,
      description: Object.values(row)[1] || '',
      workaround:  Object.values(row)[2] || '',
      whenToAdd:   Object.values(row)[3] || '',
    });
  }
  return gaps;
}

// ─── Typography intent from knowledgebase/foundations/typography.md ───────────

function parseTypographyIntent(content) {
  const intent = {};
  const lines = content.split('\n');
  let headers = null;

  for (const line of lines) {
    const t = line.trim();
    if (!t.startsWith('|')) { headers = null; continue; }
    const cells = t.split('|').slice(1, -1).map(c => c.trim().replace(/`/g, '').replace('TypographyScale.', ''));

    if (!headers) {
      const lower = cells.map(c => c.toLowerCase());
      // Look for tables with "static" or "style" column and "use when" column
      if ((lower.some(c => c === 'static' || c === 'style') || lower[0] === 'static') && lower.some(c => c.includes('use'))) {
        headers = lower;
      }
      continue;
    }
    if (cells.every(c => /^[-:|]+$/.test(c))) continue;

    const nameIdx    = 0; // first column is always the static name
    const useWhenIdx = headers.findIndex(h => h.includes('use'));
    if (useWhenIdx === -1) continue;

    const name = cells[nameIdx];
    if (!name || name.includes('---')) continue;
    intent[name] = cells[useWhenIdx] || '';
  }
  return intent;
}

// ─── Spacing intent from knowledgebase/foundations/spacing.md ────────────────

function parseSpacingIntent(content) {
  const intent = {};
  // Parse the main scale table
  const rows = parseMarkdownTable(content, /## The scale/);
  for (const row of rows) {
    // Token | Value | Use when
    const token   = Object.values(row)[0].replace('SpacingScale.', '');
    const useWhen = Object.values(row)[2] || '';
    if (token) intent[token] = useWhen;
  }
  return intent;
}

// ─── Component discovery ──────────────────────────────────────────────────────

function discoverComponents() {
  const componentsDir = path.join(ROOT, 'packages/ds/lib/src/components');
  const figmaDir      = path.join(ROOT, 'packages/ds/figma');
  const kbDir         = path.join(ROOT, 'knowledgebase/components');
  const components    = [];

  // Build figma node lookup from *.figma.js definition files
  const figmaNodes = {};
  if (fs.existsSync(figmaDir)) {
    for (const f of fs.readdirSync(figmaDir).filter(f => f.endsWith('.figma.js'))) {
      const src  = fs.readFileSync(path.join(figmaDir, f), 'utf-8');
      const node = src.match(/figmaNode:\s*['"]([^'"]+)['"]/)?.[1] || '';
      const comp = src.match(/component:\s*['"]([^'"]+)['"]/)?.[1] || '';
      const file = src.match(/source:\s*['"]([^'"]+)['"]/)?.[1] || '';
      if (comp) figmaNodes[comp] = { figmaNode: node, source: file };
    }
  }

  // Scan component directories
  function scanDir(dir) {
    if (!fs.existsSync(dir)) return;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        scanDir(path.join(dir, entry.name));
      } else if (entry.name.endsWith('.dart') && !entry.name.includes('_test')) {
        const src   = fs.readFileSync(path.join(dir, entry.name), 'utf-8');
        const match = src.match(/^class (\w+) extends Stateless|StatefulWidget/m)
                   || src.match(/class (\w+) extends StatelessWidget/m)
                   || src.match(/class (\w+) extends StatefulWidget/m);
        if (!match) continue;

        // extract class name from full match
        const classMatch = src.match(/^class (\w+) extends/m);
        if (!classMatch) continue;
        const className = classMatch[1];

        const relFile  = path.relative(ROOT, path.join(dir, entry.name));
        const kbFile   = path.join(kbDir, toKebab(className) + '.md');
        const figmaRef = figmaNodes[className] || {};

        components.push({
          name:             className,
          file:             relFile,
          figmaNode:        figmaRef.figmaNode || '',
          knowledgebaseDoc: fs.existsSync(kbFile)
                              ? path.relative(ROOT, kbFile)
                              : '',
        });
      }
    }
  }

  scanDir(componentsDir);
  return components;
}

function toKebab(str) {
  return str.replace(/([A-Z])/g, (m, l, i) => (i ? '_' : '') + l.toLowerCase())
            .replace(/^_/, '');
}

// ─── Main ─────────────────────────────────────────────────────────────────────

function main() {
  console.log('Generating DS snapshot...');

  // Read source files
  const foundation        = parseFoundation(read('packages/tokens/lib/src/foundation.dart'));
  const colorPrimitives   = parseColorPrimitives(read('packages/tokens/lib/src/color_primitives.dart'));
  const colorScaleFields  = parseColorScale(read('packages/tokens/lib/src/color_scale.dart'));
  const spacingValues     = parseSpacingScale(read('packages/tokens/lib/src/spacing_scale.dart'));
  const radiusValues      = parseRadiusTokens(read('packages/tokens/lib/src/radius_tokens.dart'));
  const opacityValues     = parseOpacityTokens(read('packages/tokens/lib/src/opacity_tokens.dart'));
  const typographyStyles  = parseTypographyScale(read('packages/tokens/lib/src/typography_scale.dart'), foundation);

  // Read knowledgebase for intent / use-when
  const colorMd      = read('knowledgebase/foundations/color.md');
  const typographyMd = read('knowledgebase/foundations/typography.md');
  const spacingMd    = read('knowledgebase/foundations/spacing.md');

  const colorIntent  = parseColorIntent(colorMd);
  const colorGaps    = parseColorGaps(colorMd);
  const typoIntent   = parseTypographyIntent(typographyMd);
  const spacingIntent = parseSpacingIntent(spacingMd);

  // ── Build snapshot ──────────────────────────────────────────────────────────

  // Colors
  const colors = Object.entries(colorScaleFields).map(([name, primitiveKey]) => ({
    name,
    dart:       `colors.${name}`,
    hex:        colorPrimitives[primitiveKey] || '',
    tier1:      `ColorPrimitives.${primitiveKey}`,
    intent:     colorIntent[name]?.intent     || '',
    doNotUseFor: colorIntent[name]?.doNotUseFor || '',
  }));

  // Spacing
  const spacing = Object.entries(spacingValues).map(([name, value]) => ({
    name,
    dart:    `SpacingScale.${name}`,
    valueDp: value,
    useWhen: spacingIntent[name] || '',
  }));

  // Radius
  const radius = Object.entries(radiusValues).map(([name, value]) => ({
    name,
    dart:    `RadiusTokens.${name}`,
    valueDp: value,
  }));

  // Opacity
  const opacity = Object.entries(opacityValues).map(([name, value]) => ({
    name,
    dart:  `OpacityTokens.${name}`,
    value: value,
  }));

  // Typography — determine font family by name prefix
  const familyOf = (name) => {
    if (/^pr/i.test(name)) return 'GT Ultra Median Trial';
    if (/^dp/i.test(name)) return 'GT Flaire Basic Trial';
    return 'Lexend Deca';
  };

  const typography = Object.entries(typographyStyles)
    .filter(([, v]) => v.size !== undefined)
    .map(([name, v]) => ({
      figmaName:  toFigmaName(name),
      dartStatic: `TypographyScale.${name}`,
      size:       v.size,
      weight:     v.weight,
      lineHeight: v.lineheight,
      fontFamily: familyOf(name),
      useWhen:    typoIntent[name] || '',
    }));

  // Components
  const components = discoverComponents();

  // ── Write snapshot ──────────────────────────────────────────────────────────

  const snapshot = {
    generatedAt: new Date().toISOString(),
    colors,
    colorGaps,
    spacing,
    radius,
    opacity,
    typography,
    components,
  };

  const outPath = path.join(__dirname, 'ds-snapshot.json');
  fs.writeFileSync(outPath, JSON.stringify(snapshot, null, 2));

  console.log(`✓ colors:     ${colors.length}`);
  console.log(`✓ color gaps: ${colorGaps.length}`);
  console.log(`✓ spacing:    ${spacing.length}`);
  console.log(`✓ radius:     ${radius.length}`);
  console.log(`✓ opacity:    ${opacity.length}`);
  console.log(`✓ typography: ${typography.length}`);
  console.log(`✓ components: ${components.length}`);
  console.log(`\nWrote ${outPath}`);
}

// Convert camelCase static name to Figma style name
// pMedium → P-Medium, hdSmall → Hd-Small, shdMedium → Shd-Medium
function toFigmaName(name) {
  const prefixes = ['shd', 'hd', 'lb', 'pr', 'dp', 'p'];
  for (const prefix of prefixes) {
    if (name.startsWith(prefix) && name.length > prefix.length) {
      const rest = name.slice(prefix.length);
      const size = rest.charAt(0).toUpperCase() + rest.slice(1);
      return prefix.charAt(0).toUpperCase() + prefix.slice(1) + '-' + size;
    }
  }
  return name;
}

main();
