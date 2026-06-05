/**
 * Figma Code Connect — DsScapiaScore
 *
 * Figma : Seasonal DLS › Scapia score  (node 482:244)
 * Widget: packages/ds/lib/src/components/rating/ds_scapia_score.dart
 *
 * Publish: melos run code-connect:publish
 *          (requires FIGMA_ACCESS_TOKEN env var)
 *
 * UPGRADE PATH — wire once Figma properties are confirmed in Dev Mode:
 * props: {
 *   state: figma.enum('State', {
 *     'With label':    'withLabel',
 *     'without label': 'withoutLabel',
 *   }),
 * },
 * example: ({ state }) =>
 *   state === 'withLabel'
 *     ? `DsScapiaScore(score: 4.2, label: 'Excellent', count: '2.4k ratings')`
 *     : `DsScapiaScore(score: 4.2)`
 */

/** @type {import('../../tools/code-connect/parser').CodeConnectDef} */
module.exports = {
  figmaNode: 'https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=482-244',
  component: 'DsScapiaScore',
  source:    'packages/ds/lib/src/components/rating/ds_scapia_score.dart',
  label:     'Flutter',
  language:  'dart',
  imports: [
    "import 'package:scapia_ds/scapia_ds.dart';",
  ],
  example: `// With label (State=With label)
DsScapiaScore(
  score: 4.2,
  label: 'Excellent',
  count: '2.4k ratings',
)

// Without label (State=without label)
DsScapiaScore(score: 4.2)`,
};
