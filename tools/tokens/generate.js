#!/usr/bin/env node
// Scapia token pipeline — Figma REST API → Dart token files
// Tier structure mirrors Figma exactly: Tier 2 holds Dart references to Tier 1 constants.
// Usage: node tools/tokens/generate.js
//        FIGMA_ACCESS_TOKEN=xxx node tools/tokens/generate.js

const https = require('https');
const fs = require('fs');
const path = require('path');

// ─── Config ───────────────────────────────────────────────────────────────────

const FILE_KEY = 'Fdq3lgwdEqbcIM0SrWnb6V';
const OUT_DIR = path.resolve(__dirname, '../../packages/tokens/lib/src');
const HEADER = [
  '// GENERATED — do not edit manually. Run `melos run tokens` to regenerate.',
  '// ignore_for_file: lines_longer_than_80_chars',
  '',
].join('\n');

// Maps Figma collection name → Dart class that owns its constants.
// Used when resolving Tier 2 aliases to Dart references.
const TIER1_CLASS = {
  'Color Primitives': { dartClass: 'ColorPrimitives', stripPrefix: 'color/' },
  'Foundation':       { dartClass: 'Foundation',      stripPrefix: '' },
};

// ─── Figma data source ────────────────────────────────────────────────────────
// Two modes:
//   1. Local snapshot (default): reads figma-variables.json exported via the
//      Desktop Bridge plugin. Refresh it with `melos run tokens:export` (Claude).
//   2. REST API (--fresh flag): requires a PAT with file_variables:read scope.
//      Set FIGMA_ACCESS_TOKEN env var and run: node generate.js --fresh

const SNAPSHOT_PATH = path.resolve(__dirname, 'figma-variables.json');
const FRESH = process.argv.includes('--fresh');

function getToken() {
  if (process.env.FIGMA_ACCESS_TOKEN) return process.env.FIGMA_ACCESS_TOKEN;
  try {
    const mcp = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../.mcp.json'), 'utf8'));
    return mcp.mcpServers['figma-console'].env.FIGMA_ACCESS_TOKEN;
  } catch {
    throw new Error('FIGMA_ACCESS_TOKEN not set and .mcp.json not readable.');
  }
}

function fetchVariablesFromRest(token) {
  return new Promise((resolve, reject) => {
    https.get(
      {
        hostname: 'api.figma.com',
        path: `/v1/files/${FILE_KEY}/variables/local`,
        headers: { 'X-Figma-Token': token },
      },
      res => {
        let raw = '';
        res.on('data', c => (raw += c));
        res.on('end', () => {
          try { resolve(JSON.parse(raw)); } catch (e) { reject(e); }
        });
      }
    ).on('error', reject);
  });
}

async function loadVariables() {
  if (!FRESH && fs.existsSync(SNAPSHOT_PATH)) {
    console.log('  ✓ Using local snapshot (figma-variables.json). Run with --fresh to re-fetch.');
    return JSON.parse(fs.readFileSync(SNAPSHOT_PATH, 'utf8'));
  }
  console.log('  → Fetching from Figma REST API (requires file_variables:read scope)…');
  const token = getToken();
  const data = await fetchVariablesFromRest(token);
  if (!data.meta) throw new Error(`Figma API error: ${JSON.stringify(data).slice(0, 300)}`);
  fs.writeFileSync(SNAPSHOT_PATH, JSON.stringify(data, null, 2));
  console.log('  ✓ Snapshot saved to figma-variables.json');
  return data;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function toCamelCase(parts) {
  return parts
    .flatMap(p => p.split(/[-_]/))
    .map((seg, i) =>
      i === 0
        ? seg.toLowerCase()
        : seg.charAt(0).toUpperCase() + seg.slice(1).toLowerCase()
    )
    .join('');
}

// Token name → valid Dart identifier, stripping an optional leading prefix.
function dartId(tokenName, stripPrefix = '') {
  let n = tokenName;
  if (stripPrefix && n.startsWith(stripPrefix)) n = n.slice(stripPrefix.length);
  return toCamelCase(n.split('/').filter(Boolean));
}

// Figma RGBA (0–1 floats) → Flutter Color literal.
function toFlutterColor({ r, g, b, a = 1 }) {
  const h = v => Math.round(v * 255).toString(16).padStart(2, '0').toUpperCase();
  return `Color(0x${h(a)}${h(r)}${h(g)}${h(b)})`;
}

// Resolve a VARIABLE_ALIAS to a Dart Tier 1 reference (e.g. ColorPrimitives.orange500).
// Returns null if the alias target is not a known Tier 1 collection.
function aliasRef(aliasId, varLookup) {
  const entry = varLookup[aliasId];
  if (!entry) return null;
  const tier1 = TIER1_CLASS[entry.colName];
  if (!tier1) return null;
  const name = dartId(entry.v.name, tier1.stripPrefix);
  return `${tier1.dartClass}.${name}`;
}

function writeFile(filename, content) {
  const full = path.join(OUT_DIR, filename);
  fs.writeFileSync(full, content, 'utf8');
  console.log(`    ✓ ${filename}`);
}

// ─── Dart generators ──────────────────────────────────────────────────────────

// Tier 1 — abstract final class with static const raw values.
function genTier1StaticClass({ className, imports = [], tokens, stripPrefix, fieldFn }) {
  const importLines = imports.map(i => `import '${i}';`).join('\n');
  const fields = tokens.map(t => fieldFn(t, dartId(t.name, stripPrefix))).filter(Boolean);
  return [
    HEADER,
    importLines,
    '',
    `abstract final class ${className} {`,
    ...fields,
    '}',
    '',
  ].join('\n');
}

// Tier 2 — abstract final class where each constant references a Tier 1 constant.
// Falls back to an inline value if the variable has no alias (shouldn't happen in a well-structured DS).
function genTier2StaticClass({ className, imports = [], tokens, stripPrefix, dartType, varLookup, rawFallback }) {
  const importLines = imports.map(i => `import '${i}';`).join('\n');
  const fields = tokens.map(t => {
    const name = dartId(t.name, stripPrefix);
    const raw = t.rawValue;
    let value;

    if (raw && raw.type === 'VARIABLE_ALIAS') {
      value = aliasRef(raw.id, varLookup);
    }
    if (!value && raw && raw.type !== 'VARIABLE_ALIAS') {
      value = rawFallback(raw); // graceful fallback for non-alias Tier 2 tokens
    }
    if (!value) return null;

    return `  static const ${dartType} ${name} = ${value};`;
  }).filter(Boolean);

  return [
    HEADER,
    importLines,
    '',
    `abstract final class ${className} {`,
    ...fields,
    '}',
    '',
  ].join('\n');
}

// Tier 2 colors — ThemeExtension so light/dark modes can swap the semantic layer
// while Tier 1 primitives stay constant (the full palette never changes per theme).
// Each field in the `light` static const references a Tier 1 primitive → mirrors Figma aliases.
function genColorScaleExtension({ tokens, varLookup }) {
  const className = 'ColorScale';

  const props = tokens.map(t => {
    const name = dartId(t.name, 'color/');
    const raw = t.rawValue;
    let lightValue;

    if (raw && raw.type === 'VARIABLE_ALIAS') {
      lightValue = aliasRef(raw.id, varLookup); // e.g. ColorPrimitives.orange500
    }
    if (!lightValue && raw && raw.r !== undefined) {
      lightValue = toFlutterColor(raw);
    }
    if (!lightValue) return null;
    return { name, lightValue };
  }).filter(Boolean);

  const fields     = props.map(p => `  final Color ${p.name};`).join('\n');
  const ctorParams = props.map(p => `    required this.${p.name},`).join('\n');
  const lightConst = props.map(p => `    ${p.name}: ${p.lightValue},`).join('\n');
  const copyParams = props.map(p => `    Color? ${p.name},`).join('\n');
  const copyBody   = props.map(p => `        ${p.name}: ${p.name} ?? this.${p.name},`).join('\n');
  const lerpBody   = props.map(p => `      ${p.name}: Color.lerp(${p.name}, other.${p.name}, t)!,`).join('\n');

  return [
    HEADER,
    `import 'package:flutter/material.dart';`,
    `import 'color_primitives.dart';`,
    '',
    `@immutable`,
    `class ${className} extends ThemeExtension<${className}> {`,
    `  const ${className}({`,
    ctorParams,
    `  });`,
    '',
    fields,
    '',
    `  // Tier 2 light mode — each value is a reference to a Tier 1 primitive,`,
    `  // mirroring the alias chain in Figma. Swap for dark/brand modes later.`,
    `  static const light = ${className}(`,
    lightConst,
    `  );`,
    '',
    `  @override`,
    `  ${className} copyWith({`,
    copyParams,
    `  }) =>`,
    `      ${className}(`,
    copyBody,
    `      );`,
    '',
    `  @override`,
    `  ${className} lerp(ThemeExtension<${className}>? other, double t) {`,
    `    if (other is! ${className}) return this;`,
    `    return ${className}(`,
    lerpBody,
    `    );`,
    `  }`,
    `}`,
    '',
  ].join('\n');
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('🎨 Scapia token pipeline\n');

  const resp = await loadVariables();
  const { variableCollections, variables } = resp.meta;
  console.log(`  ✓ Loaded ${Object.keys(variables).length} variables across ${Object.keys(variableCollections).length} collections\n`);

  // Flat lookup: variableId → { v, colName, modeId }
  const varLookup = {};
  for (const [id, v] of Object.entries(variables)) {
    const col = variableCollections[v.variableCollectionId];
    varLookup[id] = { v, colName: col?.name, modeId: col?.defaultModeId };
  }

  // Helper: all tokens for a named collection
  function tokensOf(colName) {
    const col = Object.values(variableCollections).find(c => c.name === colName);
    if (!col) return [];
    return col.variableIds
      .map(id => {
        const v = variables[id];
        if (!v) return null;
        return { id, name: v.name, type: v.resolvedType, rawValue: v.valuesByMode[col.defaultModeId] };
      })
      .filter(Boolean);
  }

  // Helper: find a collection by partial name match
  function findCol(includes, excludes = []) {
    return Object.values(variableCollections).find(c => {
      const n = c.name.toLowerCase();
      return includes.every(s => n.includes(s)) && excludes.every(s => !n.includes(s));
    });
  }

  fs.mkdirSync(OUT_DIR, { recursive: true });
  console.log('  Writing Dart files:\n');

  // ── Tier 1: Color Primitives → ColorPrimitives ────────────────────────
  const colorPrimTokens = tokensOf('Color Primitives').filter(t => t.type === 'COLOR');
  writeFile('color_primitives.dart', genTier1StaticClass({
    className: 'ColorPrimitives',
    imports: ['package:flutter/material.dart'],
    tokens: colorPrimTokens,
    stripPrefix: 'color/',
    fieldFn: (t, name) => {
      if (!t.rawValue || t.rawValue.r === undefined) return null;
      return `  static const Color ${name} = ${toFlutterColor(t.rawValue)};`;
    },
  }));

  // ── Tier 2: Color Scale → ColorScale (ThemeExtension) ─────────────────
  const colorScaleTokens = tokensOf('Color Scale').filter(t => t.type === 'COLOR');
  writeFile('color_scale.dart', genColorScaleExtension({
    tokens: colorScaleTokens,
    varLookup,
  }));

  // ── Tier 1: Foundation → Foundation ───────────────────────────────────
  const foundationTokens = tokensOf('Foundation');
  writeFile('foundation.dart', genTier1StaticClass({
    className: 'Foundation',
    imports: [],
    tokens: foundationTokens,
    stripPrefix: '',
    fieldFn: (t, name) => {
      if (t.type === 'FLOAT') return `  static const double ${name} = ${t.rawValue};`;
      if (t.type === 'STRING') return `  static const String ${name} = '${t.rawValue}';`;
      return null;
    },
  }));

  // ── Tier 2: Type Scale → TypographyScale ──────────────────────────────
  const typeScaleTokens = tokensOf('Type Scale').filter(t => t.type === 'FLOAT');
  if (typeScaleTokens.length) {
    writeFile('typography_scale.dart', genTier2StaticClass({
      className: 'TypographyScale',
      imports: [`foundation.dart`],
      tokens: typeScaleTokens,
      stripPrefix: 'type/',
      dartType: 'double',
      varLookup,
      rawFallback: v => `${v}`,
    }));
  }

  // ── Tier 1: Spacing Primitives ───────────────────────────────────────────────
  const spacingPrimCol = findCol(['spacing'], ['scale']);
  if (spacingPrimCol) {
    TIER1_CLASS[spacingPrimCol.name] = { dartClass: 'SpacingPrimitives', stripPrefix: '' };
    const spPrimTokens = tokensOf(spacingPrimCol.name).filter(t => t.type === 'FLOAT');
    writeFile('spacing_primitives.dart', genTier1StaticClass({
      className: 'SpacingPrimitives',
      imports: [],
      tokens: spPrimTokens,
      stripPrefix: '',
      fieldFn: (t, name) => `  static const double ${name} = ${t.rawValue};`,
    }));
  }

  // ── Tier 2: Spacing Scale → SpacingScale ──────────────────────────────
  const spacingScaleCol = findCol(['spacing', 'scale']);
  if (spacingScaleCol) {
    const spScaleTokens = tokensOf(spacingScaleCol.name).filter(t => t.type === 'FLOAT');
    const imports = spacingPrimCol ? [`spacing_primitives.dart`] : [];
    writeFile('spacing_scale.dart', genTier2StaticClass({
      className: 'SpacingScale',
      imports,
      tokens: spScaleTokens,
      stripPrefix: 'spacing/',
      dartType: 'double',
      varLookup,
      rawFallback: v => `${v}`,
    }));
  }

  // ── Radius ───────────────────────────────────────────────────────────────────
  const radiusCol = findCol(['radius']);
  if (radiusCol) {
    const radiusTokens = tokensOf(radiusCol.name).filter(t => t.type === 'FLOAT');
    writeFile('radius_tokens.dart', genTier1StaticClass({
      className: 'RadiusTokens',
      imports: [],
      tokens: radiusTokens,
      stripPrefix: 'radius/',
      fieldFn: (t, name) => `  static const double ${name} = ${t.rawValue};`,
    }));
  }

  console.log('\n✅ Token pipeline complete.');
  console.log('   Run: dart analyze packages/tokens\n');
}

main().catch(e => {
  console.error('\n❌ Pipeline failed:', e.message);
  process.exit(1);
});
