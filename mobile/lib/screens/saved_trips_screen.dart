import 'package:flutter/material.dart';

import '../data/stage1_catalog.dart';
import '../models/auth_session.dart';
import '../models/saved_trip.dart';
import '../models/trip_plan.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/auth_look.dart';
import '../widgets/blended_scene.dart';
import '../widgets/paper_plane_mark.dart';

class SavedTripsScreen extends StatelessWidget {
  const SavedTripsScreen({
    super.key,
    required this.session,
    required this.trips,
    required this.loading,
    required this.draftPlan,
    required this.onLogin,
    required this.onSignup,
    required this.onAccount,
    required this.onPlanTrip,
    required this.onRetry,
    required this.onSaveDraft,
    required this.onOpenTrip,
    this.error,
    this.saving = false,
  });

  final AuthSession? session;
  final List<SavedTrip> trips;
  final bool loading;
  final String? error;
  final TripPlan? draftPlan;
  final bool saving;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onAccount;
  final VoidCallback onPlanTrip;
  final VoidCallback onRetry;
  final VoidCallback onSaveDraft;
  final ValueChanged<SavedTrip> onOpenTrip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AuthSkyBackdrop(),
        SafeArea(
          child: session == null
              ? _GuestSaved(onLogin: onLogin, onSignup: onSignup)
              : _SignedInSaved(
                  session: session!,
                  trips: trips,
                  loading: loading,
                  error: error,
                  draftPlan: draftPlan,
                  saving: saving,
                  onAccount: onAccount,
                  onPlanTrip: onPlanTrip,
                  onRetry: onRetry,
                  onSaveDraft: onSaveDraft,
                  onOpenTrip: onOpenTrip,
                ),
        ),
      ],
    );
  }
}

class _GuestSaved extends StatelessWidget {
  const _GuestSaved({required this.onLogin, required this.onSignup});

  final VoidCallback onLogin;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      children: [
        const AuthBrand(planeSize: 40),
        const SizedBox(height: 22),
        const Text(
          'Saved trips',
          textAlign: TextAlign.center,
          style: AuthLook.headline,
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep itineraries on your account',
          textAlign: TextAlign.center,
          style: AuthLook.subtitle,
        ),
        const SizedBox(height: 28),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AuthLook.ink.withValues(alpha: 0.07),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(22, 26, 22, 26),
            child: Column(
              children: [
                PaperPlaneMark(size: 34, color: AppTheme.introTeal),
                SizedBox(height: 12),
                Text(
                  'Log in to save trips',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AuthLook.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can still generate a trip as a guest. Log in to save it to your account.',
                  textAlign: TextAlign.center,
                  style: AuthLook.subtitle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        AuthPrimaryButton(
          key: const Key('saved-login'),
          label: 'Log in',
          onPressed: onLogin,
        ),
        const SizedBox(height: 12),
        AuthSoftButton(
          key: const Key('saved-signup'),
          label: 'Create account',
          onPressed: onSignup,
        ),
      ],
    );
  }
}

class _SignedInSaved extends StatelessWidget {
  const _SignedInSaved({
    required this.session,
    required this.trips,
    required this.loading,
    required this.error,
    required this.draftPlan,
    required this.saving,
    required this.onAccount,
    required this.onPlanTrip,
    required this.onRetry,
    required this.onSaveDraft,
    required this.onOpenTrip,
  });

  final AuthSession session;
  final List<SavedTrip> trips;
  final bool loading;
  final String? error;
  final TripPlan? draftPlan;
  final bool saving;
  final VoidCallback onAccount;
  final VoidCallback onPlanTrip;
  final VoidCallback onRetry;
  final VoidCallback onSaveDraft;
  final ValueChanged<SavedTrip> onOpenTrip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Saved trips', style: AuthLook.headline),
            ),
            IconButton(
              key: const Key('saved-account'),
              onPressed: onAccount,
              icon: const Icon(Icons.account_circle_outlined, size: 30),
              color: AppTheme.introTeal,
            ),
          ],
        ),
        Text('Hi, ${session.greetingName}', style: AuthLook.subtitle),
        const SizedBox(height: 16),
        if (draftPlan != null) ...[
          _DraftCard(
            plan: draftPlan!,
            saving: saving,
            onSave: onSaveDraft,
          ),
          const SizedBox(height: 16),
        ],
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          Column(
            children: [
              Text(error!, textAlign: TextAlign.center, style: AuthLook.subtitle),
              TextButton(
                key: const Key('saved-retry'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          )
        else if (trips.isEmpty && draftPlan == null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                children: [
                  const PaperPlaneMark(size: 34, color: AppTheme.introTeal),
                  const SizedBox(height: 12),
                  const Text(
                    'No saved trips yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AuthLook.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate an itinerary, then save it to this account.',
                    textAlign: TextAlign.center,
                    style: AuthLook.subtitle,
                  ),
                  const SizedBox(height: 18),
                  AuthPrimaryButton(
                    key: const Key('saved-plan-trip'),
                    label: 'Plan a trip',
                    onPressed: onPlanTrip,
                  ),
                ],
              ),
            ),
          )
        else
          ...trips.map(
            (trip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SavedTripCard(
                trip: trip,
                onTap: () => onOpenTrip(trip),
              ),
            ),
          ),
      ],
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.plan,
    required this.saving,
    required this.onSave,
  });

  final TripPlan plan;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to save · ${_destinationName(plan.destinationId)}',
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${plan.requestedDays} requested days',
              style: AuthLook.subtitle,
            ),
            const SizedBox(height: 12),
            AuthPrimaryButton(
              key: const Key('saved-save-draft'),
              label: saving ? 'Saving…' : 'Save this trip',
              onPressed: saving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedTripCard extends StatelessWidget {
  const _SavedTripCard({required this.trip, required this.onTap});

  final SavedTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('saved-trip-${trip.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: BlendedScene(
          image: DestinationArt.photoFor(trip.destinationId),
          height: 148,
          overlay: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _destinationName(trip.destinationId),
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 24,
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
