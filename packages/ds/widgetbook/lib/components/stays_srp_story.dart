import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

// ---------------------------------------------------------------------------
// Sample data constants used across use-cases
// ---------------------------------------------------------------------------

const _sampleImageUrl =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80';

// ---------------------------------------------------------------------------
// Widgetbook component
// ---------------------------------------------------------------------------

final staysSrpComponent = WidgetbookComponent(
  name: 'StaysSrpCard',
  useCases: [
    // ── Interactive (all knobs) ──────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final hotelName = context.knobs.string(
          label: 'Hotel name',
          initialValue: 'Grand Mercure Phuket Patong',
        );
        final location = context.knobs.string(
          label: 'Location',
          initialValue: 'Shimla, India',
        );
        final price = context.knobs.string(
          label: 'Price/night',
          initialValue: '₹10,360',
        );
        final discount = context.knobs.int.slider(
          label: 'Discount %',
          initialValue: 20,
          min: 0,
          max: 60,
        );
        final rewards = context.knobs.string(
          label: 'Rewards amount',
          initialValue: '₹4,600',
        );
        final stars = context.knobs.int.slider(
          label: 'Stars',
          initialValue: 5,
          min: 1,
          max: 5,
        );
        final showRating = context.knobs.boolean(
          label: 'Show rating',
          initialValue: true,
        );
        final showShortlist = context.knobs.boolean(
          label: 'Shortlist button',
          initialValue: true,
        );
        final imageIndex = context.knobs.int.slider(
          label: 'Image index',
          initialValue: 0,
          min: 0,
          max: 5,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingScale.spaceXl),
            child: StaysSrpCard(
              imageUrl: _sampleImageUrl,
              hotelName: hotelName,
              starCount: stars,
              location: location,
              pricePerNight: price,
              discountPercent: discount,
              taxesLabel: '+ 1,243 taxes & fees',
              rewardsAmount: rewards,
              ratingScore: showRating ? 4.2 : null,
              ratingLabel: showRating ? 'Excellent' : null,
              ratingCount: showRating ? '2.4k ratings' : null,
              offers: const ['Book with ₹0', 'Free cancellation'],
              currentImageIndex: imageIndex,
              totalImages: 6,
              onShortlistTap: showShortlist ? () {} : null,
              onTap: () {},
            ),
          ),
        );
      },
    ),

    // ── Default (full design spec) ───────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Default — full spec',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysSrpCard(
            imageUrl: _sampleImageUrl,
            hotelName: 'Grand Mercure Phuket Patong',
            starCount: 5,
            location: 'Shimla, India',
            pricePerNight: '₹10,360',
            discountPercent: 20,
            taxesLabel: '+ 1,243 taxes & fees',
            rewardsAmount: '₹4,600',
            ratingScore: 4.2,
            ratingLabel: 'Excellent',
            ratingCount: '2.4k ratings',
            offers: const ['Book with ₹0', 'Free cancellation'],
            currentImageIndex: 0,
            totalImages: 6,
            onShortlistTap: () {},
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── No offers / no discount ──────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Minimal — no offers, no discount',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysSrpCard(
            imageUrl: _sampleImageUrl,
            hotelName: 'The Oberoi Cecil',
            starCount: 4,
            location: 'Shimla, India',
            pricePerNight: '₹8,200',
            discountPercent: 0,
            taxesLabel: '+ 984 taxes & fees',
            rewardsAmount: '₹3,280',
            currentImageIndex: 0,
            totalImages: 1,
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── Long hotel name edge case ────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — long hotel name',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysSrpCard(
            imageUrl: _sampleImageUrl,
            hotelName:
                'Radisson Blu Resort & Spa Alibaug Beach Grand Collection',
            starCount: 5,
            location: 'Alibaug, Maharashtra, India',
            pricePerNight: '₹22,500',
            discountPercent: 35,
            taxesLabel: '+ 2,700 taxes & fees',
            rewardsAmount: '₹9,000',
            ratingScore: 4.7,
            ratingLabel: 'Exceptional',
            ratingCount: '1.1k ratings',
            offers: const [
              'Book with ₹0',
              'Free cancellation',
              'Breakfast included',
            ],
            currentImageIndex: 2,
            totalImages: 8,
            onShortlistTap: () {},
            onTap: () {},
          ),
        ),
      ),
    ),

    // ── Image error fallback ─────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — broken image',
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.spaceXl),
          child: StaysSrpCard(
            imageUrl: 'https://invalid-url-that-will-fail.example.com/img.jpg',
            hotelName: 'Taj Lake Palace',
            starCount: 5,
            location: 'Udaipur, Rajasthan',
            pricePerNight: '₹45,000',
            discountPercent: 10,
            taxesLabel: '+ 5,400 taxes & fees',
            rewardsAmount: '₹18,000',
            ratingScore: 4.9,
            ratingLabel: 'Extraordinary',
            ratingCount: '3.2k ratings',
            offers: const ['Free cancellation'],
            currentImageIndex: 0,
            totalImages: 4,
            onShortlistTap: () {},
          ),
        ),
      ),
    ),
  ],
);
