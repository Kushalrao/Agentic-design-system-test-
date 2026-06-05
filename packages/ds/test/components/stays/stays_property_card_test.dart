import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: child),
      ),
    );

const _testAmenities = [
  StaysAmenity(label: 'Kitchen', icon: Icon(Icons.kitchen_outlined,  size: 16)),
  StaysAmenity(label: 'Pool',    icon: Icon(Icons.pool_outlined,      size: 16)),
  StaysAmenity(label: 'WiFi',    icon: Icon(Icons.wifi_outlined,       size: 16)),
];

void main() {
  group('StaysPropertyCard — goldens', () {
    // ── Full card (with rating + amenities + view-all) ─────────────────────
    testWidgets('full spec', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl:                 'https://example.com/img.jpg',
          propertyName:             'Casa Belvedere Luxury Villas',
          location:                 'Kasauli, Himachal Pradesh',
          guestDetails:             '6 guests • 2 rooms',
          amenities:                _testAmenities,
          additionalAmenitiesCount: 56,
          ratingScore:              4.2,
          ratingLabel:              'Excellent',
          ratingCount:              '2.4k ratings',
          onViewAllAmenities:       () {},
          onTap:                    () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_full_spec.png'),
      );
    });

    // ── No rating pill ──────────────────────────────────────────────────────
    testWidgets('no rating', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl:     'https://example.com/img.jpg',
          propertyName: 'The Tamara Coorg',
          location:     'Madikeri, Karnataka',
          guestDetails: '4 guests • 1 room',
          amenities:    _testAmenities,
          additionalAmenitiesCount: 12,
          onViewAllAmenities: () {},
          onTap: () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_no_rating.png'),
      );
    });

    // ── No amenities row ────────────────────────────────────────────────────
    testWidgets('no amenities', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl:     'https://example.com/img.jpg',
          propertyName: 'Zostel Rishikesh',
          location:     'Rishikesh, Uttarakhand',
          guestDetails: '2 guests • 1 dorm bed',
          amenities:    const [],
          ratingScore:  3.8,
          ratingLabel:  'Good',
          ratingCount:  '340 ratings',
          onTap: () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_no_amenities.png'),
      );
    });

    // ── No view-all link ────────────────────────────────────────────────────
    testWidgets('no view all link', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl:     'https://example.com/img.jpg',
          propertyName: 'Moustache Pushkar',
          location:     'Pushkar, Rajasthan',
          guestDetails: '2 guests • 1 room',
          amenities:    _testAmenities,
          additionalAmenitiesCount: 8,
          ratingScore:  4.4,
          ratingLabel:  'Very Good',
          ratingCount:  '1.2k ratings',
          onTap: () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_no_view_all.png'),
      );
    });

    // ── Long property name (2-line truncation) ──────────────────────────────
    testWidgets('long property name', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl: 'https://example.com/img.jpg',
          propertyName:
              'The Leela Palace Udaipur Lake View Grand Heritage Collection',
          location:     'Lake Pichola, Udaipur, Rajasthan, India',
          guestDetails: '10 guests • 4 rooms • 2 bathrooms',
          amenities:    _testAmenities,
          additionalAmenitiesCount: 120,
          ratingScore:  4.9,
          ratingLabel:  'Extraordinary',
          ratingCount:  '8.1k ratings',
          onViewAllAmenities: () {},
          onTap: () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_long_name.png'),
      );
    });

    // ── No overflow chip (additionalAmenitiesCount = 0) ─────────────────────
    testWidgets('no overflow chip', (tester) async {
      await tester.pumpWidget(_wrap(
        StaysPropertyCard(
          imageUrl:     'https://example.com/img.jpg',
          propertyName: 'FabHotel Prime Riverside',
          location:     'Munnar, Kerala',
          guestDetails: '2 guests • 1 room',
          amenities: const [
            StaysAmenity(label: 'Kitchen', icon: Icon(Icons.kitchen_outlined, size: 16)),
          ],
          additionalAmenitiesCount: 0,
          ratingScore: 4.1,
          ratingLabel: 'Very Good',
          ratingCount: '620 ratings',
          onViewAllAmenities: () {},
          onTap: () {},
        ),
      ));
      await expectLater(
        find.byType(StaysPropertyCard),
        matchesGoldenFile('goldens/stays_property_card_no_overflow.png'),
      );
    });
  });
}
