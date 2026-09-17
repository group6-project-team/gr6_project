import 'package:flutter/material.dart';

import '../data/stage1_catalog.dart';
import '../models/trip_plan.dart';
import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/blended_scene.dart';
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
          const _WishlistLounge(),
          const _VisualLounge(
            title: 'Travel Assistant',
            subtitle: 'Ask for ideas, packing notes, and little local secrets.',
            icon: Icons.auto_awesome,
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF8FFFDF8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.1),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                _NavItem(
                  keyName: 'nav-home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  keyName: 'nav-assistant',
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome,
                  label: 'Chat',
                  selected: _tab == 4,
                  onTap: () => setState(() => _tab = 4),
                ),
                _NavItem(
                  keyName: 'nav-plan',
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                  label: 'Plan',
                  selected: _tab == 1,
                  emphasized: true,
                  onTap: () => _openPlan(),
                ),
                _NavItem(
                  keyName: 'nav-itinerary',
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map_rounded,
                  label: 'Map',
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
                _NavItem(
                  keyName: 'nav-wishlist',
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  label: 'Saved',
                  selected: _tab == 3,
                  onTap: () => setState(() => _tab = 3),
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
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  final String keyName;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.introTeal : AppTheme.muted;
    return Expanded(
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: emphasized ? 48 : 36,
                height: emphasized ? 48 : 36,
                decoration: BoxDecoration(
                  color: emphasized
                      ? AppTheme.introTeal
                      : selected
                          ? AppTheme.introTeal.withValues(alpha: 0.12)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: emphasized ? Colors.white : color,
                  size: emphasized ? 24 : 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: emphasized && selected ? AppTheme.introTeal : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisualLounge extends StatelessWidget {
  const _VisualLounge({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Opacity(
          opacity: 0.28,
          child: Image(
            image: AssetImage('assets/intro/login_sky.png'),
            fit: BoxFit.cover,
          ),
        ),
        const Opacity(
          opacity: 0.22,
          child: Image(
            image: AssetImage('assets/intro/onboard_floral_wash.png'),
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.introTeal.withValues(alpha: 0.16),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 36, color: AppTheme.introTeal),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brandInk,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    height: 1.45,
                    color: AppTheme.brandSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WishlistLounge extends StatelessWidget {
  const _WishlistLounge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Opacity(
          opacity: 0.3,
          child: Image(
            image: AssetImage('assets/intro/login_sky.png'),
            fit: BoxFit.cover,
          ),
        ),
        const Opacity(
          opacity: 0.28,
          child: Image(
            image: AssetImage(DestinationArt.floral),
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Wishlist',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brandInk,
                  ),
                ),
                const Text(
                  'Destinations waiting for a story.',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontStyle: FontStyle.italic,
                    color: AppTheme.brandSoft,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 360,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 8,
                            top: 28,
                            child: PolaroidPhoto(
                              image: DestinationArt.rome,
                              caption: 'Rome',
                              width: 138,
                              angle: -0.12,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 8,
                            child: PolaroidPhoto(
                              image: DestinationArt.aqaba,
                              caption: 'Aqaba',
                              width: 138,
                              angle: 0.14,
                            ),
                          ),
                          PolaroidPhoto(
                            image: DestinationArt.istanbul,
                            caption: 'Istanbul',
                            width: 168,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(DestinationArt.map, fit: BoxFit.cover),
          ColoredBox(color: AppTheme.introCanvas.withValues(alpha: 0.18)),
          const Opacity(
            opacity: 0.2,
            child: Image(
              image: AssetImage(DestinationArt.floral),
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Collect moments',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandInk,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pin a destination, then generate a trip.',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontStyle: FontStyle.italic,
                        color: AppTheme.brandSoft,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: const [
                        _MapPhotoPin(
                          alignment: Alignment(-0.55, -0.35),
                          image: DestinationArt.istanbul,
                          label: 'Istanbul',
                        ),
                        _MapPhotoPin(
                          alignment: Alignment(0.15, 0.05),
                          image: DestinationArt.rome,
                          label: 'Rome',
                        ),
                        _MapPhotoPin(
                          alignment: Alignment(0.55, 0.42),
                          image: DestinationArt.aqaba,
                          label: 'Aqaba',
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: onPlanTrip,
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.introTeal),
                    child: const Text('Start planning'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final match = Stage1Catalog.destinations.where(
      (item) => item.id == plan!.destinationId,
    );
    final destination =
        match.isEmpty ? plan!.destinationId : match.first.name;

    return ColoredBox(
      color: AppTheme.introCanvas,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          BlendedScene(
            image: DestinationArt.photoFor(plan!.destinationId),
            height: 268,
            overlay: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$destination trip',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${plan!.requestedDays} requested days',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFE8F2F0),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final day in plan!.days)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
                        : day.places.take(3).map((place) => place.name).join(', '),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPhotoPin extends StatelessWidget {
  const _MapPhotoPin({
    required this.alignment,
    required this.image,
    required this.label,
  });

  final Alignment alignment;
  final String image;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ink.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandInk,
            ),
          ),
        ],
      ),
    );
  }
}
