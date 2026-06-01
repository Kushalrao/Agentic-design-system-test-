#!/usr/bin/env node
/**
 * Scapia DS — MCP Server (contributor surface)
 *
 * Serves design system knowledge to Claude Code while building DS components.
 * Reads from ds-snapshot.json — run `melos run ds-mcp:generate` first.
 *
 * Add to .mcp.json:
 *   "ds": {
 *     "command": "node",
 *     "args": ["tools/ds-mcp/server.js"],
 *     "cwd": "<repo-root>"
 *   }
 */

const { McpServer }             = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StdioServerTransport }  = require('@modelcontextprotocol/sdk/server/stdio.js');
const { z }                     = require('zod');
const path                      = require('path');
const fs                        = require('fs');

// ─── Load snapshot ────────────────────────────────────────────────────────────

const SNAPSHOT_PATH = path.join(__dirname, 'ds-snapshot.json');

function loadSnapshot() {
  if (!fs.existsSync(SNAPSHOT_PATH)) {
    throw new Error(
      'ds-snapshot.json not found. Run: melos run ds-mcp:generate'
    );
  }
  return JSON.parse(fs.readFileSync(SNAPSHOT_PATH, 'utf-8'));
}

let ds = loadSnapshot();

// ─── Server ───────────────────────────────────────────────────────────────────

const server = new McpServer({
  name:    'scapia-ds',
  version: '1.0.0',
});

// ─── Tool: check_token ────────────────────────────────────────────────────────

server.tool(
  'check_token',
  'Check if a hex color value has a Tier 2 token in the DS. Returns the exact token or reports it as not found — never guesses a closest match.',
  { hex: z.string().describe('Hex color value, e.g. #CE3E00 or CE3E00') },
  async ({ hex }) => {
    const normalized = hex.startsWith('#') ? hex.toUpperCase() : '#' + hex.toUpperCase();

    // Exact match in Tier 2 tokens
    const match = ds.colors.find(c => c.hex.toUpperCase() === normalized);
    if (match) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:       true,
            dart:        match.dart,
            name:        match.name,
            hex:         match.hex,
            intent:      match.intent,
            doNotUseFor: match.doNotUseFor,
          }),
        }],
      };
    }

    // Check documented gaps
    const gap = ds.colorGaps.find(g => g.hex.toUpperCase() === normalized);
    if (gap) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:            false,
            isDocumentedGap:  true,
            hex:              normalized,
            description:      gap.description,
            currentWorkaround: gap.workaround,
            action:           'Stop and ask the user how to handle this gap. Do not silently use the workaround.',
          }),
        }],
      };
    }

    // Not found, not a documented gap
    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          found:  false,
          hex:    normalized,
          action: 'No Tier 2 token exists for this value. Stop and ask the user what token to use or whether to add one.',
        }),
      }],
    };
  }
);

// ─── Tool: get_typography_style ───────────────────────────────────────────────

server.tool(
  'get_typography_style',
  'Get the Dart TypographyScale static for a Figma text style name.',
  { figmaName: z.string().describe('Figma text style name, e.g. P-Medium or Hd-Small') },
  async ({ figmaName }) => {
    const normalizedInput = figmaName.trim().toLowerCase();
    const match = ds.typography.find(
      t => t.figmaName.toLowerCase() === normalizedInput
    );

    if (match) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:      true,
            figmaName:  match.figmaName,
            dartStatic: match.dartStatic,
            size:       match.size,
            weight:     match.weight,
            lineHeight: match.lineHeight,
            fontFamily: match.fontFamily,
            useWhen:    match.useWhen,
            usage:      `${match.dartStatic}.copyWith(color: colors.yourToken)`,
          }),
        }],
      };
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          found:  false,
          input:  figmaName,
          action: 'No matching TypographyScale static. Check the Figma style name or run melos run ds-mcp:generate to refresh.',
          available: ds.typography.map(t => t.figmaName),
        }),
      }],
    };
  }
);

// ─── Tool: get_spacing_token ──────────────────────────────────────────────────

server.tool(
  'get_spacing_token',
  'Get the SpacingScale token for a specific dp value. Returns not-found if no exact match.',
  { valueDp: z.number().describe('Spacing value in dp, e.g. 9') },
  async ({ valueDp }) => {
    const match = ds.spacing.find(s => s.valueDp === valueDp);

    if (match) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:   true,
            dart:    match.dart,
            name:    match.name,
            valueDp: match.valueDp,
            useWhen: match.useWhen,
          }),
        }],
      };
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          found:     false,
          valueDp,
          action:    'No SpacingScale token for this exact value. Stop and ask the user what to use.',
          available: ds.spacing.map(s => ({ name: s.name, valueDp: s.valueDp })),
        }),
      }],
    };
  }
);

// ─── Tool: get_radius_token ───────────────────────────────────────────────────

server.tool(
  'get_radius_token',
  'Get the RadiusTokens constant for a specific dp value.',
  { valueDp: z.number().describe('Border radius value in dp, e.g. 20') },
  async ({ valueDp }) => {
    const match = ds.radius.find(r => r.valueDp === valueDp);

    if (match) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:   true,
            dart:    match.dart,
            name:    match.name,
            valueDp: match.valueDp,
          }),
        }],
      };
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          found:     false,
          valueDp,
          action:    'No RadiusTokens constant for this exact value. Stop and ask the user what to use.',
          available: ds.radius.map(r => ({ name: r.name, valueDp: r.valueDp })),
        }),
      }],
    };
  }
);

// ─── Tool: list_components ────────────────────────────────────────────────────

server.tool(
  'list_components',
  'List all DS components. Use at the start of every component implementation to check for reuse before building anything.',
  {},
  async () => ({
    content: [{
      type: 'text',
      text: JSON.stringify({
        count:      ds.components.length,
        components: ds.components.map(c => ({
          name:             c.name,
          file:             c.file,
          hasFigmaNode:     !!c.figmaNode,
          hasKnowledgebase: !!c.knowledgebaseDoc,
        })),
        generatedAt: ds.generatedAt,
      }),
    }],
  })
);

// ─── Tool: get_component ─────────────────────────────────────────────────────

server.tool(
  'get_component',
  'Get full details for a DS component by name.',
  { name: z.string().describe('Component class name, e.g. DsButton or StaysSrpCard') },
  async ({ name }) => {
    const match = ds.components.find(
      c => c.name.toLowerCase() === name.toLowerCase()
    );

    if (match) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            found:           true,
            name:            match.name,
            file:            match.file,
            figmaNode:       match.figmaNode || null,
            knowledgebaseDoc: match.knowledgebaseDoc || null,
          }),
        }],
      };
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          found:      false,
          name,
          available:  ds.components.map(c => c.name),
        }),
      }],
    };
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
