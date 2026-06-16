/**
 * Figma Code Connect — DsApBenefits
 *
 * Figma : Seasonal DLS › AP benefits  (node 557:81)
 * Widget: packages/ds/lib/src/components/benefits/ds_ap_benefits.dart
 *
 * Publish: melos run code-connect:publish
 *
 * UPGRADE PATH — wire once Figma properties are confirmed in Dev Mode:
 * props: {
 *   heading:    figma.string('Heading'),
 *   rewardText: figma.string('Benefits'),
 *   state: figma.enum('State', {
 *     'Active':     'DsApBenefitsState.active',
 *     'Activated':  'DsApBenefitsState.activated',
 *     'Inactive':   'DsApBenefitsState.inactive',
 *   }),
 * },
 */

/** @type {import('../../tools/code-connect/parser').CodeConnectDef} */
module.exports = {
  figmaNode: 'https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=557-81',
  component: 'DsApBenefits',
  source:    'packages/ds/lib/src/components/benefits/ds_ap_benefits.dart',
  label:     'Flutter',
  language:  'dart',
  imports:   ["import 'package:scapia_ds/scapia_ds.dart';"],
  example: `// Active
DsApBenefits(
  heading: 'Free shopping',
  rewardText: 'Get ₹1,000 back',
  state: DsApBenefitsState.active,
)

// Activated
DsApBenefits(
  heading: 'Free shopping',
  rewardText: 'Get ₹1,000 back',
  state: DsApBenefitsState.activated,
)

// Inactive
DsApBenefits(
  heading: 'Free shopping',
  rewardText: 'Get ₹1,000 back',
  state: DsApBenefitsState.inactive,
)`,
};
