/**
 * Figma Code Connect — DsStayStars
 *
 * Figma : Seasonal DLS › Stay stars  (node 489:1059)
 * Widget: packages/ds/lib/src/components/rating/ds_stay_stars.dart
 *
 * Publish: melos run code-connect:publish
 *
 * UPGRADE PATH — wire once Figma properties are confirmed in Dev Mode:
 * props: {
 *   showLabel: figma.boolean('Label', { true: true, false: false }),
 *   label: figma.string('Label'),
 * },
 * example: ({ showLabel, label }) =>
 *   `DsStayStars(starCount: 5, label: ${showLabel ? `'${label}'` : 'null'})`
 */

/** @type {import('../../tools/code-connect/parser').CodeConnectDef} */
module.exports = {
  figmaNode: 'https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=489-1059',
  component: 'DsStayStars',
  source:    'packages/ds/lib/src/components/rating/ds_stay_stars.dart',
  label:     'Flutter',
  language:  'dart',
  imports: ["import 'package:scapia_ds/scapia_ds.dart';"],
  example: `// With label
DsStayStars(starCount: 5, label: '5 star hotel')

// Stars only
DsStayStars(starCount: 5)`,
};
