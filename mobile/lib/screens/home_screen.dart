import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/stage1_catalog.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/blended_scene.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartPlanning,
    required this.onDestinationSelected,
  });

  final VoidCallback onStartPlanning;
  final ValueChanged<String> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.introCanvas,
        body: Stack(
          children: [
            const Opacity(
              opacity: 0.28,
              child: Image(
                image: AssetImage('assets/intro/login_sky.png'),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            const Opacity(
              opacity: 0.22,
              child: Image(
                image: AssetImage(DestinationArt.floral),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  const Text(
                    'Hi there',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandInk,
                    ),
                  ),
                  const Text(
                    'Plan your perfect trip',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.brandSoft,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onStartPlanning,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.introTeal.withValues(alpha: 0.28)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.introTeal.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.introTeal),
                          SizedBox(width: 10),
                          Text(
                            'Search destinations, days, stories…',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontStyle: FontStyle.italic,
                              color: AppTheme.brandSoft,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      key: const Key('start-planning'),
                      onPressed: onStartPlanning,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.introTeal,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Start planning'),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Popular destinations',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandInk,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 248,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final destination in Stage1Catalog.destinations)
                          _DestinationCard(
                            id: destination.id,
                            name: destination.name,
                            image: DestinationArt.photoFor(destination.id),
                            onTap: () => onDestinationSelected(destination.id),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandInk,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onStartPlanning,
                    child: BlendedScene(
                      image: DestinationArt.recommend,
                      height: 196,
                      overlay: const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Istanbul at golden hour',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'History, landmarks, and a sky that turns rose.',
                              style: TextStyle(
                                color: Color(0xF0FFFFFF),
                                height: 1.35,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      padding: const EdgeInsets.only(right: 14, bottom: 6, top: 4),
      child: InkWell(
        key: Key('home-destination-$id'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: PolaroidPhoto(image: image, caption: name, width: 152),
      ),
    );
  }
}
