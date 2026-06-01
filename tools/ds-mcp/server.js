#!/usr/bin/env node
/**
 * Scapia DS — MCP Server  (contributor surface)
 *
 * v2 improvements:
 *   1. Auto-regenerates snapshot at startup if any source file is newer
 *      → zero drift, zero manual steps
 *   2. get_color_guidance  — pairing rules + depth model from color.md
 *   3. get_spacing_recipe  — composition recipes from spacing.md
 *   4. get_typography_guidance — choosing guidance from typography.md
 *
 * Why guidance tools read markdown live (not from snapshot):
 *   The snapshot is the data layer (token values, names, intents).
 *   The knowledgebase is the guidance layer (relationships, decisions, DON'Ts).
 *   Stuffing guidance into the snapshot would bloat it and duplicate the
 *   knowledgebase. Reading markdown at query time keeps both layers clean.
 *   Response size stays small — one section per call, parsed to JSON.
 */

const { McpServer }            = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { z }                    = require('zod');
const path                     = require('path');
const fs                       = require('fs');
const { execSync }             = require('child_process');

const SNAPSHOT_PATH = path.join(__dirname, 'ds-snapshot.json');
const ROOT          = path.resolve(__dirname, '../..');

// ─── Auto-freshness ───────────────────────────────────────────────────────────
//
// At startup: compare snapshot mtime vs source files.
// If any source is newer → regenerate before serving.
// No manual `melos run ds-mcp:generate` needed.

const _WATCH = [
  'packages/tokens/lib/src/color_scale.dart',
  'packages/tokens/lib/src/color_primitives.dart',
  'packages/tokens/lib/src/typography_scale.dart',
  'packages/tokens/lib/src/spacing_scale.dart',
  'packages/tokens/lib/src/radius_tokens.dart',
  'packages/tokens/lib/src/opacity_tokens.dart',
  'packages/tokens/lib/src/foundation.dart',
  'knowledgebase/foundations/color.md',
  'knowledgebase/foundations/typography.md',
  'knowledgebase/foundations/spacing.md',
].map(f => path.join(ROOT, f));

function _ensureFresh() {
  const exists = fs.existsSync(SNAPSHOT_PATH);
  if (!exists) { _regen(); return; }

  const snapshotMtime = fs.statSync(SNAPSHOT_PATH).mtimeMs;
  const stale = _WATCH.some(f => {
    try { return fs.statSync(f).mtimeMs > snapshotMtime; }
    catch { return false; }
  });
  if (stale) _regen();
}

function _regen() {
  process.stderr.write('[ds-mcp] Source files changed — regenerating snapshot...\n');
  try {
    execSync(`node "${path.join(__dirname, 'generate-snapshot.js')}"`, {
      cwd: ROOT, stdio: 'pipe',
    });
    process.stderr.write('[ds-mcp] Snapshot up to date ✓\n');
  } catch (err) {
    process.stderr.write(`[ds-mcp] Warning: snapshot regeneration failed — ${err.message}\n`);
    process.stderr.write('[ds-mcp] Serving last known snapshot. Run melos run ds-mcp:generate to fix.\n');
  }
}

function _loadSnapshot() {
  if (!fs.existsSync(SNAPSHOT_PATH)) {
    throw new Error('ds-snapshot.json not found. Run: melos run ds-mcp:generate');
  }
  return JSON.parse(fs.readFileSync(SNAPSHOT_PATH, 'utf-8'));
}

// ─── Markdown helpers ──────────────────────────────────────────────────────────

/**
 * Extract the content of a markdown section (from heading to next same-level heading).
 */
function _section(content, heading) {
  const idx = content.indexOf(heading);
  if (idx === -1) return '';
  const rest  = content.slice(idx + heading.length);
  const level = (heading.match(/^#+/) || ['##'])[0].length;
  const next  = rest.search(new RegExp(`^#{1,${level}}[^#]`, 'm'));
  return next === -1 ? rest : rest.slice(0, next);
}

/**
 * Parse a markdown table into an array of plain objects.
 */
function _table(content) {
  const rows    = [];
  let   headers = null;
  for (const line of content.split('\n')) {
    const t = line.trim();
    if (!t.startsWith('|')) { if (headers) break; continue; }
    const cells = t.split('|').slice(1, -1).map(c => c.trim().replace(/`/g, ''));
    if (!headers) {
      headers = cells.map(h => h.toLowerCase().replace(/\W+/g, '_').replace(/^_|_$/g, ''));
      continue;
    }
    if (cells.every(c => /^[-:|]+$/.test(c))) continue;
    if (cells.length !== headers.length) continue;
    const row = {};
    headers.forEach((h, i) => { row[h] = cells[i]; });
    rows.push(row);
  }
  return rows;
}

// ─── Bootstrap ────────────────────────────────────────────────────────────────

_ensureFresh();
let ds = _loadSnapshot();

// ─── Server ───────────────────────────────────────────────────────────────────

const server = new McpServer({ name: 'scapia-ds', version: '2.0.0' });

// ─── Tool: check_token ────────────────────────────────────────────────────────

server.tool(
  'check_token',
  'Check if a hex color has a Tier 2 token. Returns exact match (with doNotUseFor) or gap — never guesses. If doNotUseFor might apply, follow up with get_color_guidance.',
  { hex: z.string().describe('Hex color, e.g. #CE3E00') },
  async ({ hex }) => {
    const n = hex.startsWith('#') ? hex.toUpperCase() : '#' + hex.toUpperCase();
    const match = ds.colors.find(c => c.hex.toUpperCase() === n);
    if (match) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:       true,
        dart:        match.dart,
        name:        match.name,
        hex:         match.hex,
        intent:      match.intent,
        doNotUseFor: match.doNotUseFor,
        tip:         match.doNotUseFor
          ? `doNotUseFor is set — call get_color_guidance("${match.name}") if this context might apply`
          : null,
      })}]};
    }
    const gap = ds.colorGaps.find(g => g.hex.toUpperCase() === n);
    if (gap) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:           false,
        isDocumentedGap: true,
        hex:             n,
        description:     gap.description,
        workaround:      gap.workaround,
        action:          'Stop and ask the user how to handle this gap. Do not silently use the workaround.',
      })}]};
    }
    return { content: [{ type: 'text', text: JSON.stringify({
      found:  false,
      hex:    n,
      action: 'No Tier 2 token exists. Stop and ask the user what token to use or whether to add one.',
    })}]};
  }
);

// ─── Tool: get_color_guidance ─────────────────────────────────────────────────

server.tool(
  'get_color_guidance',
  [
    'Full usage guidance for a ColorScale token from the Seasonal DLS knowledgebase.',
    'Use this when check_token returns a doNotUseFor that might apply to your context.',
    'Returns: pairing rules (what fills/texts pair with this token), depth model context,',
    'and interactive state mappings. Answers "is my usage correct?" not just "does the token exist?"',
  ].join(' '),
  { tokenName: z.string().describe('ColorScale field name, e.g. brandPrimary, backgroundSecondary') },
  async ({ tokenName }) => {
    const token = ds.colors.find(c => c.name === tokenName);
    if (!token) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found: false, tokenName,
        available: ds.colors.map(c => c.name),
      })}]};
    }

    const colorMd = fs.readFileSync(path.join(ROOT, 'knowledgebase/foundations/color.md'), 'utf-8');

    // Extract the pairing rules table
    const pairingSection = _section(colorMd, '## Pairing rules');
    const allPairingRules = _table(pairingSection);

    // Extract the interactive states table
    const statesSection = _section(colorMd, '## Interactive states');
    const interactiveStates = _table(statesSection);

    // Extract the depth model paragraph (between "Depth model" and the next code block end)
    const depthIdx = colorMd.indexOf('**Depth model:**');
    const depthRaw = depthIdx !== -1
      ? colorMd.slice(depthIdx, colorMd.indexOf('\n---', depthIdx)).trim()
      : null;

    // Filter pairing rules relevant to this token (mention the token name)
    const relevantRules = allPairingRules.filter(r =>
      Object.values(r).join(' ').toLowerCase().includes(tokenName.toLowerCase())
    );

    return { content: [{ type: 'text', text: JSON.stringify({
      found:       true,
      name:        token.name,
      dart:        token.dart,
      hex:         token.hex,
      intent:      token.intent,
      doNotUseFor: token.doNotUseFor,
      pairingRules: relevantRules.length > 0 ? relevantRules : allPairingRules,
      depthModel:  depthRaw,
      interactiveStates,
    })}]};
  }
);

// ─── Tool: get_spacing_recipe ─────────────────────────────────────────────────

const _RECIPES = {
  icon_label:          '### Icon + label on one line',
  component_padding:   '### Component internal padding',
  vertical_rhythm:     '### Vertical rhythm in a Column',
  card:                '### Card internal padding',
  page_margins:        '### Page margins',
  sections:            '### Between major sections',
  list_item:           '### List items',
};

server.tool(
  'get_spacing_recipe',
  [
    'Get the Seasonal DLS composition recipe for a specific UI layout pattern.',
    'Returns SpacingScale tokens and guidance from spacing.md.',
    'Use during Phase 4 when deciding spacing between elements — more precise than',
    'just get_spacing_token(dp) because it gives intent, not just value.',
    'Patterns: icon_label, component_padding, vertical_rhythm, card, page_margins, sections, list_item',
  ].join(' '),
  { pattern: z.string().describe('Pattern name: icon_label | component_padding | vertical_rhythm | card | page_margins | sections | list_item') },
  async ({ pattern }) => {
    const heading = _RECIPES[pattern.toLowerCase().replace(/[^a-z_]/g, '_')];
    if (!heading) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found: false, pattern,
        available: Object.keys(_RECIPES),
      })}]};
    }

    const spacingMd = fs.readFileSync(path.join(ROOT, 'knowledgebase/foundations/spacing.md'), 'utf-8');
    const content   = _section(spacingMd, heading);

    if (!content.trim()) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found: false, pattern, reason: 'Section not found in spacing.md',
      })}]};
    }

    // Extract SpacingScale token references from the section
    const tokenRefs = [...content.matchAll(/SpacingScale\.(\w+)/g)].map(m => m[1]);
    const unique    = [...new Set(tokenRefs)];

    // Resolve tokens from snapshot
    const resolvedTokens = unique.map(name => {
      const t = ds.spacing.find(s => s.name === name);
      return t ? { name, dart: t.dart, valueDp: t.valueDp, useWhen: t.useWhen } : { name };
    });

    return { content: [{ type: 'text', text: JSON.stringify({
      found:      true,
      pattern,
      guidance:   content.trim(),
      tokens:     resolvedTokens,
    })}]};
  }
);

// ─── Tool: get_typography_guidance ───────────────────────────────────────────

server.tool(
  'get_typography_guidance',
  [
    'Full usage guidance for a TypographyScale style including:',
    'when to use it, when NOT to use it, color pairings, and',
    'how to choose between visually similar styles (e.g. P-Medium vs Shd-Small).',
    'Use after get_typography_style when you need to validate your style choice.',
  ].join(' '),
  { figmaName: z.string().describe('Figma text style name, e.g. P-Medium, Hd-Small, Shd-Small') },
  async ({ figmaName }) => {
    const style = ds.typography.find(
      t => t.figmaName.toLowerCase() === figmaName.trim().toLowerCase()
    );
    if (!style) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found: false, figmaName,
        available: ds.typography.map(t => t.figmaName),
      })}]};
    }

    const typoMd = fs.readFileSync(path.join(ROOT, 'knowledgebase/foundations/typography.md'), 'utf-8');

    // Extract the "Choosing between similar styles" section
    const choosingSection = _section(typoMd, '## Choosing between similar styles');

    // Extract the color pairing table
    const colorPairingSection = _section(typoMd, '## Color pairing');
    const colorPairings = _table(colorPairingSection);

    // Extract "What NOT to use" section
    const notToUseSection = _section(typoMd, '## What NOT to use');

    // Find paragraphs in choosing section that mention this style's base name
    const baseName = style.figmaName.replace(/-.*/, '').toLowerCase(); // e.g. "p", "hd", "shd"
    const choosingLines = choosingSection
      .split('\n')
      .filter(l => l.toLowerCase().includes(style.figmaName.toLowerCase()) ||
                   l.toLowerCase().includes(baseName));

    return { content: [{ type: 'text', text: JSON.stringify({
      found:      true,
      figmaName:  style.figmaName,
      dartStatic: style.dartStatic,
      usage:      `${style.dartStatic}.copyWith(color: colors.yourToken)`,
      size:       style.size,
      weight:     style.weight,
      lineHeight: style.lineHeight,
      fontFamily: style.fontFamily,
      useWhen:    style.useWhen,
      colorPairings,
      choosingGuidance: choosingLines.join('\n').trim() || choosingSection.trim(),
      doNotUse: notToUseSection.trim(),
    })}]};
  }
);

// ─── Existing tools (unchanged) ───────────────────────────────────────────────

server.tool(
  'get_typography_style',
  'Get the Dart TypographyScale static for a Figma text style name.',
  { figmaName: z.string().describe('Figma text style name, e.g. P-Medium or Hd-Small') },
  async ({ figmaName }) => {
    const match = ds.typography.find(
      t => t.figmaName.toLowerCase() === figmaName.trim().toLowerCase()
    );
    if (match) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:      true,
        figmaName:  match.figmaName,
        dartStatic: match.dartStatic,
        size:       match.size,
        weight:     match.weight,
        lineHeight: match.lineHeight,
        fontFamily: match.fontFamily,
        useWhen:    match.useWhen,
        usage:      `${match.dartStatic}.copyWith(color: colors.yourToken)`,
      })}]};
    }
    return { content: [{ type: 'text', text: JSON.stringify({
      found:     false,
      input:     figmaName,
      action:    'No matching TypographyScale static. Check the Figma style name.',
      available: ds.typography.map(t => t.figmaName),
    })}]};
  }
);

server.tool(
  'get_spacing_token',
  'Get the SpacingScale token for a specific dp value.',
  { valueDp: z.number().describe('Spacing value in dp, e.g. 9') },
  async ({ valueDp }) => {
    const match = ds.spacing.find(s => s.valueDp === valueDp);
    if (match) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:   true,
        dart:    match.dart,
        name:    match.name,
        valueDp: match.valueDp,
        useWhen: match.useWhen,
        tip:     `For layout pattern context, call get_spacing_recipe with the pattern name`,
      })}]};
    }
    return { content: [{ type: 'text', text: JSON.stringify({
      found:     false,
      valueDp,
      action:    'No SpacingScale token for this exact value. Stop and ask the user what to use.',
      available: ds.spacing.map(s => ({ name: s.name, valueDp: s.valueDp })),
    })}]};
  }
);

server.tool(
  'get_radius_token',
  'Get the RadiusTokens constant for a specific dp value.',
  { valueDp: z.number().describe('Border radius value in dp, e.g. 20') },
  async ({ valueDp }) => {
    const match = ds.radius.find(r => r.valueDp === valueDp);
    if (match) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:   true,
        dart:    match.dart,
        name:    match.name,
        valueDp: match.valueDp,
      })}]};
    }
    return { content: [{ type: 'text', text: JSON.stringify({
      found:     false,
      valueDp,
      action:    'No RadiusTokens constant. Stop and ask the user what to use.',
      available: ds.radius.map(r => ({ name: r.name, valueDp: r.valueDp })),
    })}]};
  }
);

server.tool(
  'list_components',
  'List all Seasonal DLS components. Call at Phase 0.5 of every component build — reuse check before writing any code.',
  {},
  async () => ({
    content: [{ type: 'text', text: JSON.stringify({
      count:      ds.components.length,
      components: ds.components.map(c => ({
        name:             c.name,
        file:             c.file,
        hasFigmaNode:     !!c.figmaNode,
        hasKnowledgebase: !!c.knowledgebaseDoc,
      })),
      generatedAt: ds.generatedAt,
    })}],
  })
);

server.tool(
  'get_component',
  'Get full details for a Seasonal DLS component by name.',
  { name: z.string().describe('Component class name, e.g. DsButton or StaysSrpCard') },
  async ({ name }) => {
    const match = ds.components.find(
      c => c.name.toLowerCase() === name.toLowerCase()
    );
    if (match) {
      return { content: [{ type: 'text', text: JSON.stringify({
        found:           true,
        name:            match.name,
        file:            match.file,
        figmaNode:       match.figmaNode || null,
        knowledgebaseDoc: match.knowledgebaseDoc || null,
      })}]};
    }
    return { content: [{ type: 'text', text: JSON.stringify({
      found:     false,
      name,
      available: ds.components.map(c => c.name),
    })}]};
  }
);

// ─── Start ────────────────────────────────────────────────────────────────────

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(err => {
  process.stderr.write(`DS MCP server error: ${err.message}\n`);
  process.exit(1);
});
