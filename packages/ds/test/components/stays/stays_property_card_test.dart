import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

import '../../helpers/golden_helpers.dart';

// Minimal icon stubs for golden rendering (no real assets needed)
final _amenities = [
  StaysAmenity(
    label: 'Kitchen',
    icon:  Container(width: 16, height: 16, color: Colors.grey.shade300),
  ),
  StaysAmenity(
    label: 'Pool',
    icon:  Container(width: 16, height: 16, color: Colors.grey.shade300),
  ),
  StaysAmenity(
    label: 'WiFi',
    icon:  Container(width: 16, height: 16, color: Colors.grey.shade300),
  ),
];

void main() {
  setUpAll(loadDsFonts);

  group('StaysPropertyCard goldens', () {
    testWidgets('default — full spec', (tester) async {
      await expectGolden(
        tester,
        StaysPropertyCard(
          imageUrl:                '',
          propertyName:            'Casa Belvedere Luxury Villas',
          location:                'Kasauli, Himachal Pradesh',
          guestDetails:            '6 guests • 2 rooms',
          amenities:               _amenities,
          additionalAmenitiesCount: 56,
          ratingScore:             4.2,
          ratingLabel:             'Excellent',
          ratingCount:             '2.4k ratings',
        ),
        'goldens/stays_property_card_default.png',
      );
    });

    testWidgets('no rating', (tester) async {
      await expectGolden(
        tester,
        StaysPropertyCard(
          imageUrl:     '',
          propertyName: 'The Himalayan Retreat',
          location:     'Manali, Himachal Pradesh',
          guestDetails: '4 guests • 1 room',
          amenities:    _amenities,
        ),
        'goldens/stays_property_card_no_rating.png',
      );
    });

    testWidgets('long property name', (tester) async {
      await expectGolden(
        tester,
        StaysPropertyCard(
          imageUrl:                '',
          propertyName:
              'The Grand Heritage Colonial Estate and Spa Resort Retreat',
          location:                'Shimla, Himachal Pradesh, India',
          guestDetails:            '12 guests • 4 rooms',
          amenities:               _amenities,
          additionalAmenitiesCount: 98,
          ratingScore:             4.9,
          ratingLabel:             'Exceptional',
          ratingCount:             '12.3k ratings',
        ),
        'goldens/stays_property_card_long_name.png',
      );
    });

    testWidgets('no amenities', (tester) async {
      await expectGolden(
        tester,
        StaysPropertyCard(
          imageUrl:     '',
          propertyName: 'Minimal Mountain Cabin',
          location:     'Spiti Valley',
          guestDetails: '2 guests • 1 room',
          amenities:    [],
          ratingScore:  3.8,
          ratingLabel:  'Good',
          ratingCount:  '42 ratings',
        ),
        'goldens/stays_property_card_no_amenities.png',
      );
    });
  });
}
