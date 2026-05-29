/**
 * Figma Code Connect — StaysSrpCard
 *
 * Figma : Alt Stays › SRP  (node 2608:5110)
 * Widget: packages/ds/lib/src/components/stays/stays_srp_card.dart
 *
 * Publish: melos run code-connect:publish
 *          (requires FIGMA_ACCESS_TOKEN env var)
 *
 * ──────────────────────────────────────────────────────────────────────
 * CURRENT STATE — no Figma component properties
 * ──────────────────────────────────────────────────────────────────────
 * The SRP component in Figma is a static frame with no component
 * properties. The snippet below is a static example. When the designer
 * adds Figma component properties, wire them by adding a `props` field:
 *
 *   // If designer adds a text property "Hotel name":
 *   // → the `example` string stays static here; dynamic wiring requires
 *   //   upgrading to a JSX-style template (React parser) or adding
 *   //   figma.string() / figma.boolean() calls via a TypeScript build.
 *
 *   Available named text descendants (future property candidates):
 *   'Hotel name'     → hotelName
 *   'Location text'  → location
 *   'Price'          → pricePerNight
 *   'Rating text'    → ratingScore
 *   'Rating title'   → ratingLabel
 *   'Rating count'   → ratingCount
 *   'Taxes and fees' → taxesLabel
 *   'Rewards text'   → rewardsAmount
 */

/** @type {import('../../tools/code-connect/parser').CodeConnectDef} */
module.exports = {
  figmaNode: 'https://www.figma.com/design/dZsOJpJ6G3Fs7WgrYSqt3P/Alt-Stays?node-id=2608-5110',
  component: 'StaysSrpCard',
  source:    'packages/ds/lib/src/components/stays/stays_srp_card.dart',
  label:     'Flutter',
  language:  'dart',
  imports: [
    "import 'package:scapia_ds/scapia_ds.dart';",
  ],
  example: `StaysSrpCard(
  imageUrl: 'https://example.com/hotel.jpg',
  hotelName: 'Grand Mercure Phuket Patong',
  starCount: 5,
  location: 'Shimla, India',
  pricePerNight: '₹ 10,360',
  discountPercent: 20,
  taxesLabel: '+ 1,243 taxes & fees',
  rewardsAmount: '₹4,600',
  ratingScore: 4.2,
  ratingLabel: 'Excellent',
  ratingCount: '2.4k ratings',
  offers: const ['Book with ₹0', 'Free cancellation'],
  onShortlistTap: () {},
  onTap: () {},
)`,
};
