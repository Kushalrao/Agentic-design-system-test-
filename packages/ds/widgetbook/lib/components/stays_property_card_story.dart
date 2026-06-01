import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

final _amenities = [
  StaysAmenity(
    label: 'Kitchen',
    icon:  const Icon(Icons.kitchen_outlined, size: 16),
  ),
  StaysAmenity(
    label: 'Pool',
    icon:  const Icon(Icons.pool_outlined, size: 16),
  ),
  StaysAmenity(
    label: 'WiFi',
    icon:  const Icon(Icons.wifi_outlined, size: 16),
  ),
];

const _sampleImage =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80';

final staysPropertyCardComponent = WidgetbookComponent(
  name: 'StaysPropertyCard',
  useCases: [
    // ── Interactive ────────────────────────────────────────────────────────
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
        final showViewAll = context.knobs.boolean(
          label:        'Show view all',
          initialValue: true,
        );
        final additionalCount = context.knobs.int.slider(
          label:        'Additional amenities count',
          initialValue: 56,
          min:          0,
          max:          100,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingScale.spaceXl),
            child: StaysPropertyCard(
              imageUrl:                _sampleImage,
              propertyName:            propertyName,
              location:                location,
              guestDetails:            guestDetails,
              amenities:               _amenities,
              additionalAmenitiesCount: additionalCount,
              ratingScore:             showRating ? 4.2 : null,
              ratingLabel:             showRating ? 'Excellent' : null,
              ratingCount:             showRating ? '2.4k ratings' : null,
              onViewAllAmenities:      showViewAll ? () {} : null,
              onTap:                   () {},
            ),
          ),
        );
      },
    ),

    // ── Default — full spec ────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Default — full spec',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:                _sampleImage,
            propertyName:            'Casa Belvedere Luxury Villas',
            location:                'Kasauli, Himachal Pradesh',
            guestDetails:            '6 guests • 2 rooms',
            amenities:               _amenities,
            additionalAmenitiesCount: 56,
            ratingScore:             4.2,
            ratingLabel:             'Excellent',
            ratingCount:             '2.4k ratings',
            onViewAllAmenities:      () {},
            onTap:                   () {},
          ),
        ),
      ),
    ),

    // ── No rating ─────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'No rating',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:                _sampleImage,
            propertyName:            'The Himalayan Retreat',
            location:                'Manali, Himachal Pradesh',
            guestDetails:            '4 guests • 1 room',
            amenities:               _amenities.take(2).toList(),
            additionalAmenitiesCount: 12,
            onViewAllAmenities:      () {},
            onTap:                   () {},
          ),
        ),
      ),
    ),

    // ── Edge — long property name ──────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — long property name',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:                _sampleImage,
            propertyName:
                'The Grand Heritage Colonial Estate and Spa Resort Retreat',
            location:                'Shimla, Himachal Pradesh, India',
            guestDetails:            '12 guests • 4 rooms • 2 bathrooms',
            amenities:               _amenities,
            additionalAmenitiesCount: 98,
            ratingScore:             4.9,
            ratingLabel:             'Exceptional',
            ratingCount:             '12.3k ratings',
            onViewAllAmenities:      () {},
            onTap:                   () {},
          ),
        ),
      ),
    ),

    // ── Edge — broken image ────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — broken image',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysPropertyCard(
            imageUrl:     'https://invalid-url.example.com/img.jpg',
            propertyName: 'Mountain View Cottage',
            location:     'Dharamshala, Himachal Pradesh',
            guestDetails: '2 guests • 1 room',
            amenities:    _amenities.take(1).toList(),
            ratingScore:  4.1,
            ratingLabel:  'Very Good',
            ratingCount:  '340 ratings',
            onTap:        () {},
          ),
        ),
      ),
    ),
  ],
);
