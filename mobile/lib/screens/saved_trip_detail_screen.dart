import 'package:flutter/material.dart';

import '../data/stage1_catalog.dart';
import '../models/saved_trip.dart';
import '../models/trip_plan.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/auth_look.dart';
import '../widgets/blended_scene.dart';

class SavedTripDetailScreen extends StatelessWidget {
  const SavedTripDetailScreen({
    super.key,
    required this.trip,
    required this.onDelete,
  });

  final SavedTrip trip;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final plan = trip.trip;
    final destination = _destinationName(trip.destinationId);

    return Scaffold(
      backgroundColor: AppTheme.introCanvas,
      body: Stack(
        children: [
          const AuthSkyBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      key: const Key('saved-detail-back'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      color: AuthLook.ink,
                    ),
                    const Expanded(
                      child: Text('Saved trip', style: AuthLook.headline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlendedScene(
                  image: DestinationArt.photoFor(trip.destinationId),
                  height: 188,
                  overlay: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 28,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${trip.requestedDays} requested days',
                          style: const TextStyle(
                            color: Color(0xF0FFFFFF),
                            fontFamily: 'PlayfairDisplay',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (plan == null)
                  const Text(
                    'This saved trip has no itinerary details.',
                    style: AuthLook.subtitle,
                  )
                else
                  ...plan.days.map(_dayCard),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  key: const Key('saved-detail-delete'),
                  label: 'Delete trip',
                  onPressed: () async {
                    await onDelete();
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(DayPlan day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
          leading: CircleAvatar(
            backgroundColor: AppTheme.introTeal,
            foregroundColor: Colors.white,
            child: Text(
              '${day.dayNumber}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          title: Text(
            'Day ${day.dayNumber}',
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontStyle: FontStyle.italic,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            day.places.isEmpty
                ? 'No places for this day.'
                : day.places.map((place) => place.name).join(', '),
          ),
        ),
      ),
    );
  }
}

String _destinationName(String destinationId) {
  final match = Stage1Catalog.destinations.where(
    (item) => item.id == destinationId,
  );
  return match.isEmpty ? destinationId : match.first.name;
}
