import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const _sampleImageUrl =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80';

const _sampleAmenities = [
  StaysAmenity(label: 'Kitchen', icon: Icon(Icons.kitchen_outlined,   size: 16)),
  StaysAmenity(label: 'Pool',    icon: Icon(Icons.pool_outlined,       size: 16)),
  StaysAmenity(label: 'WiFi',    icon: Icon(Icons.wifi_outlined,        size: 16)),
];

// ---------------------------------------------------------------------------
// Widgetbook component
// ---------------------------------------------------------------------------

final staysPropertyCardComponent = WidgetbookComponent(
  name: 'StaysPropertyCard',
  useCases: [
    // ── Interactive ──────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final propertyName = context.knobs.string(
          label:        'Property name',
          initialValue: 'Casa Belvedere Luxury Villas',
        );
        final location = context.knobs.string(
          label:        'Location',
          initialValue: 'Kasauli, Himachal Pradesh',
        );
        final guestDetails = context.knobs.string(
          label:        'Guest details',
          initialValue: '6 guests • 2 rooms',
        );
        final showRating = context.knobs.boolean(
          label:        'Show rating',
          initialValue: true,
        );
        final additionalCount = context.knobs.int.slider(
          label:        'Additional amenities count',
          initialValue: 56,
          min:          0,
          max:          100,
        );
        final showViewAll = context.knobs.boolean(
          label:        'Show view all link',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingScale.spaceXl),
            child: StaysPropertyCard(
              imageUrl:                 _sampleImageUrl,
              propertyName:             propertyName,
              location:                 location,
              guestDetails:             guestDetails,
              amenities:                _sampleAmenities,
              additionalAmenitiesCount: additionalCount,
              ratingScore:              showRating ? 4.2 : null,
              ratingLabel:              showRating ? 'Excellent' : null,
              ratingCount:              showRating ? '2.4k ratings' : null,
              onViewAllAmenities:       showViewAll ? () {} : null,
              onTap:                    () {},
            ),
          ),
        );
      },
    ),

    // ── Default — full spec ───────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Default — full spec',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:    _sampleImageUrl,
            propertyName: 'Casa Belvedere Luxury Villas',
            location:     'Kasauli, Himachal Pradesh',
            guestDetails: '6 guests • 2 rooms',
            amenities:    _sampleAmenities,
            additionalAmenitiesCount: 56,
            ratingScore:  4.2,
            ratingLabel:  'Excellent',
            ratingCount:  '2.4k ratings',
            onViewAllAmenities: () {},
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── No rating pill ────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'No rating',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:     _sampleImageUrl,
            propertyName: 'The Tamara Coorg',
            location:     'Madikeri, Karnataka',
            guestDetails: '4 guests • 1 room',
            amenities:    _sampleAmenities,
            additionalAmenitiesCount: 12,
            onViewAllAmenities: () {},
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── No amenities ──────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'No amenities',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:     _sampleImageUrl,
            propertyName: 'Zostel Rishikesh',
            location:     'Rishikesh, Uttarakhand',
            guestDetails: '2 guests • 1 dorm bed',
            amenities:    const [],
            ratingScore:  3.8,
            ratingLabel:  'Good',
            ratingCount:  '340 ratings',
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── Long property name ────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — long property name',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl: _sampleImageUrl,
            propertyName:
                'The Leela Palace Udaipur Lake View Grand Heritage Collection',
            location:     'Lake Pichola, Udaipur, Rajasthan, India',
            guestDetails: '10 guests • 4 rooms • 2 bathrooms',
            amenities:    _sampleAmenities,
            additionalAmenitiesCount: 120,
            ratingScore:  4.9,
            ratingLabel:  'Extraordinary',
            ratingCount:  '8.1k ratings',
            onViewAllAmenities: () {},
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── Broken image ──────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — broken image',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl: 'https://invalid-url-that-will-fail.example.com/img.jpg',
            propertyName: 'Taj Falaknuma Palace',
            location:     'Hyderabad, Telangana',
            guestDetails: '8 guests • 3 rooms',
            amenities:    _sampleAmenities,
            additionalAmenitiesCount: 45,
            ratingScore:  4.8,
            ratingLabel:  'Exceptional',
            ratingCount:  '5.2k ratings',
            onViewAllAmenities: () {},
            onTap: () {},
          ),
        ),
      ),
    ),
  ],
);
