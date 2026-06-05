/**
 * Figma Code Connect — StaysPropertyCard
 *
 * Figma : Alt Stays › Hotel review  (node 2675:5319)
 * Widget: packages/ds/lib/src/components/stays/stays_property_card.dart
 *
 * Publish: melos run code-connect:publish
 *          (requires FIGMA_ACCESS_TOKEN env var)
 */

/** @type {import('../../tools/code-connect/parser').CodeConnectDef} */
module.exports = {
  figmaNode: 'https://www.figma.com/design/dZsOJpJ6G3Fs7WgrYSqt3P/Alt-Stays?node-id=2675-5319',
  component: 'StaysPropertyCard',
  source:    'packages/ds/lib/src/components/stays/stays_property_card.dart',
  label:     'Flutter',
  language:  'dart',
  imports: [
    "import 'package:scapia_ds/scapia_ds.dart';",
  ],
  example: `StaysPropertyCard(
  imageUrl: 'https://example.com/property.jpg',
  propertyName: 'Casa Belvedere Luxury Villas',
  location: 'Kasauli, Himachal Pradesh',
  guestDetails: '6 guests • 2 rooms',
  amenities: const [
    StaysAmenity(label: 'Kitchen', icon: Icon(Icons.kitchen_outlined, size: 16)),
    StaysAmenity(label: 'Pool',    icon: Icon(Icons.pool_outlined,    size: 16)),
    StaysAmenity(label: 'WiFi',    icon: Icon(Icons.wifi_outlined,    size: 16)),
  ],
  additionalAmenitiesCount: 56,
  ratingScore: 4.2,
  ratingLabel: 'Excellent',
  ratingCount: '2.4k ratings',
  onViewAllAmenities: () {},
  onTap: () {},
)`,
};
