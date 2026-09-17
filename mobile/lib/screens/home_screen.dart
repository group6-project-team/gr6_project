import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/stage1_catalog.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartPlanning,
    required this.onDestinationSelected,
  });

  final VoidCallback onStartPlanning;
  final ValueChanged<String> onDestinationSelected;

  static const _images = {
    'istanbul': 'assets/intro/onboard_travel.png',
    'rome': 'assets/intro/onboard_wave_discover.png',
    'aqaba': 'assets/intro/splash_amalfi.png',
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.introCanvas,
        body: Stack(
          children: [
            const Opacity(
              opacity: 0.22,
              child: Image(
                image: AssetImage('assets/intro/login_sky.png'),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'Hi there',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3D45),
                    ),
                  ),
                  const Text(
                    'Where do you want to go?',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onStartPlanning,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.introTeal.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.introTeal),
                          SizedBox(width: 10),
                          Text(
                            'Search for a destination',
                            style: TextStyle(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Popular destinations',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A3D45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 168,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final destination in Stage1Catalog.destinations)
                          _DestinationCard(
                            id: destination.id,
                            name: destination.name,
                            image: _images[destination.id] ??
                                'assets/intro/onboard_wave_plan.png',
                            onTap: () => onDestinationSelected(destination.id),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      key: const Key('start-planning'),
                      onPressed: onStartPlanning,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.introTeal,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Start planning'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.id,
    required this.name,
    required this.image,
    required this.onTap,
  });

  final String id;
  final String name;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        key: Key('home-destination-$id'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xAA12343A)],
                ),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
