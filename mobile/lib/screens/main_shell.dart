import 'package:flutter/material.dart';

import '../data/stage1_catalog.dart';
import '../models/trip_plan.dart';
import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'trip_form_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api, this.initialTab = 0});

  final TripApi api;
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab;
  String? _presetDestination;
  TripPlan? _plan;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  void _openPlan({String? destinationId}) {
    setState(() {
      _presetDestination = destinationId;
      _tab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.introCanvas,
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(
            onStartPlanning: () => _openPlan(),
            onDestinationSelected: (id) => _openPlan(destinationId: id),
          ),
          TripFormScreen(
            api: widget.api,
            presetDestinationId: _presetDestination,
            onPlanGenerated: (plan) => setState(() => _plan = plan),
          ),
          _ItineraryTab(
            plan: _plan,
            onPlanTrip: () => _openPlan(),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                  keyName: 'nav-home',
                  icon: Icons.home_outlined,
                  label: 'Home',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  keyName: 'nav-plan',
                  icon: Icons.explore_outlined,
                  label: 'Plan',
                  selected: _tab == 1,
                  onTap: () => _openPlan(),
                ),
                _NavItem(
                  keyName: 'nav-itinerary',
                  icon: Icons.map_outlined,
                  label: 'Trip',
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.introTeal : AppTheme.muted;
    return Expanded(
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.plan, required this.onPlanTrip});

  final TripPlan? plan;
  final VoidCallback onPlanTrip;

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 48, color: AppTheme.introTeal),
              const SizedBox(height: 16),
              const Text(
                'No itinerary yet',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3D45),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plan a trip first. The Backend response will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, height: 1.4),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onPlanTrip,
                style: FilledButton.styleFrom(backgroundColor: AppTheme.introTeal),
                child: const Text('Start planning'),
              ),
            ],
          ),
        ),
      );
    }

    final match = Stage1Catalog.destinations.where(
      (item) => item.id == plan!.destinationId,
    );
    final destination =
        match.isEmpty ? plan!.destinationId : match.first.name;

    return ColoredBox(
      color: AppTheme.introCanvas,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              '$destination trip',
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 30,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3D45),
              ),
            ),
            Text(
              '${plan!.requestedDays} requested days',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 16),
            for (final day in plan!.days)
              Card(
                color: Colors.white.withValues(alpha: 0.9),
                child: ListTile(
                  title: Text(
                    'Day ${day.dayNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    day.places.isEmpty
                        ? 'No places for this day.'
                        : day.places.take(3).map((place) => place.name).join(', '),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
