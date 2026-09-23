import 'package:flutter/material.dart';

import '../data/stage1_catalog.dart';
import '../models/auth_session.dart';
import '../models/saved_trip.dart';
import '../models/saved_trips_api_exception.dart';
import '../models/trip_plan.dart';
import '../services/auth_api.dart';
import '../services/auth_session_store.dart';
import '../services/saved_trips_api.dart';
import '../services/trip_api.dart';
import 'saved_trip_detail_screen.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/blended_scene.dart';
import 'account_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'saved_trips_screen.dart';
import 'signup_screen.dart';
import 'trip_form_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.api,
    required this.authApi,
    required this.savedTripsApi,
    required this.sessionStore,
    this.initialTab = 0,
    this.initialSession,
  });

  final TripApi api;
  final AuthApi authApi;
  final SavedTripsApi savedTripsApi;
  final AuthSessionStore sessionStore;
  final int initialTab;
  final AuthSession? initialSession;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab;
  String? _presetDestination;
  TripPlan? _plan;
  AuthSession? _session;
  List<SavedTrip> _savedTrips = const [];
  bool _savedLoading = false;
  bool _saving = false;
  String? _savedError;
  int _plannerEpoch = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _session = widget.initialSession;
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (_session != null) {
      await _loadSavedTrips();
      return;
    }
    final stored = await widget.sessionStore.read();
    if (!mounted || stored == null) {
      return;
    }
    setState(() => _session = stored);
    await _loadSavedTrips();
  }

  Future<void> _keepSession(AuthSession session) async {
    setState(() => _session = session);
    await widget.sessionStore.write(session);
    await _loadSavedTrips();
  }

  String? get _token => _session?.token;

  Future<void> _loadSavedTrips() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      setState(() {
        _savedTrips = const [];
        _savedError = null;
        _savedLoading = false;
      });
      return;
    }
    setState(() {
      _savedLoading = true;
      _savedError = null;
    });
    try {
      final trips = await widget.savedTripsApi.listTrips(token: token);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedTrips = trips;
        _savedLoading = false;
      });
    } on SavedTripsApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.code == SavedTripsApiException.unauthorized) {
        await _forceSignOut();
        return;
      }
      setState(() {
        _savedLoading = false;
        _savedError = error.userMessage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _savedLoading = false;
        _savedError = 'Could not load saved trips. Please try again.';
      });
    }
  }

  void _resetLocalWorkspace() {
    _plan = null;
    _presetDestination = null;
    _saving = false;
    _plannerEpoch += 1;
  }

  Future<void> _forceSignOut() async {
    setState(() {
      _session = null;
      _savedTrips = const [];
      _savedLoading = false;
      _savedError = null;
      _tab = 0;
      _resetLocalWorkspace();
    });
    await widget.sessionStore.clear();
  }

  Future<void> _saveCurrentPlan() async {
    final plan = _plan;
    final token = _token;
    if (plan == null) {
      return;
    }
    if (token == null || token.isEmpty) {
      await _openLogin();
      return;
    }
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.savedTripsApi.saveTrip(token: token, plan: plan);
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      await _loadSavedTrips();
      if (!mounted) {
        return;
      }
      setState(() => _tab = 3);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved to your account.')),
      );
    } on SavedTripsApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      if (error.code == SavedTripsApiException.unauthorized) {
        await _forceSignOut();
        await _openLogin();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this trip. Please try again.')),
      );
    }
  }

  Future<void> _openSavedTrip(SavedTrip trip) async {
    final token = _token;
    if (token == null) {
      return;
    }
    SavedTrip detailed = trip;
    if (trip.trip == null) {
      try {
        detailed = await widget.savedTripsApi.getTrip(token: token, id: trip.id);
      } on SavedTripsApiException catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.userMessage)),
        );
        return;
      }
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SavedTripDetailScreen(
          trip: detailed,
          onDelete: () => _deleteSavedTrip(detailed.id),
        ),
      ),
    );
  }

  Future<void> _deleteSavedTrip(String id) async {
    final token = _token;
    if (token == null) {
      return;
    }
    try {
      await widget.savedTripsApi.deleteTrip(token: token, id: id);
      await _loadSavedTrips();
    } on SavedTripsApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }

  void _openPlan({String? destinationId}) {
    setState(() {
      _presetDestination = destinationId;
      _tab = 1;
    });
  }

  Future<void> _openLogin() async {
    final session = await Navigator.of(context).push<AuthSession>(
      MaterialPageRoute(builder: (_) => LoginScreen(authApi: widget.authApi)),
    );
    if (session != null && mounted) {
      await _keepSession(session);
    }
  }

  Future<void> _openSignup() async {
    final session = await Navigator.of(context).push<AuthSession>(
      MaterialPageRoute(builder: (_) => SignupScreen(authApi: widget.authApi)),
    );
    if (session != null && mounted) {
      await _keepSession(session);
    }
  }

  Future<void> _logout() async {
    final token = _session?.token;
    setState(() {
      _session = null;
      _savedTrips = const [];
      _savedError = null;
      _tab = 0;
      _resetLocalWorkspace();
    });
    await widget.sessionStore.clear();
    if (token != null && token.isNotEmpty) {
      try {
        await widget.authApi.logout(token);
      } catch (_) {
        // Local JWT is already deleted, matching the access-token-only contract.
      }
    }
  }

  Future<void> _openAccount() async {
    if (_session == null) {
      await _openLogin();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AccountScreen(
          session: _session!,
          onLogout: _logout,
        ),
      ),
    );
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
            greetingName: _session?.greetingName,
            onAccountTap: _openAccount,
          ),
          TripFormScreen(
            key: ValueKey('planner-$_plannerEpoch'),
            api: widget.api,
            presetDestinationId: _presetDestination,
            onPlanGenerated: (plan) => setState(() => _plan = plan),
          ),
          _ItineraryTab(
            plan: _plan,
            isSignedIn: _session != null,
            onPlanTrip: () => _openPlan(),
            onSaveTrip: _saveCurrentPlan,
          ),
          SavedTripsScreen(
            session: _session,
            trips: _savedTrips,
            loading: _savedLoading,
            error: _savedError,
            draftPlan: _plan,
            saving: _saving,
            onLogin: _openLogin,
            onSignup: _openSignup,
            onAccount: _openAccount,
            onPlanTrip: () => _openPlan(),
            onRetry: _loadSavedTrips,
            onSaveDraft: _saveCurrentPlan,
            onOpenTrip: _openSavedTrip,
          ),
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

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({
    required this.plan,
    required this.isSignedIn,
    required this.onPlanTrip,
    required this.onSaveTrip,
  });

  final TripPlan? plan;
  final bool isSignedIn;
  final VoidCallback onPlanTrip;
  final VoidCallback onSaveTrip;

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
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('itinerary-save'),
            onPressed: onSaveTrip,
            child: Text(isSignedIn ? 'Save to account' : 'Log in to save'),
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
