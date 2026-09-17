import 'dart:convert';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/trip_api_exception.dart';
import '../models/trip_options.dart';
import '../models/trip_plan.dart';
import '../models/trip_request.dart';
import '../services/mock_trip_api.dart';
import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../theme/destination_art.dart';
import '../widgets/blended_scene.dart';

enum _FlowStatus { initial, loading, success, error }

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({
    super.key,
    required this.api,
    this.presetDestinationId,
    this.onPlanGenerated,
  });

  final TripApi api;
  final String? presetDestinationId;
  final ValueChanged<TripPlan>? onPlanGenerated;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController(text: '3');
  final _pageController = PageController();

  TripOptions? _options;
  Object? _optionsError;
  bool _optionsLoading = true;

  String? _destinationId;
  final Set<String> _interestIds = {};

  _FlowStatus _status = _FlowStatus.initial;
  TripPlan? _plan;
  TripApiException? _error;
  bool _submitting = false;
  int _requestSeq = 0;
  int _step = 0;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  MockScenario _scenario = MockScenario.success;

  MockTripApi? get _mockApi {
    final api = widget.api;
    return api is MockTripApi ? api : null;
  }

  @override
  void initState() {
    super.initState();
    _destinationId = widget.presetDestinationId;
    final mock = _mockApi;
    if (mock != null) {
      _scenario = mock.scenario;
    }
    _loadOptions();
  }

  @override
  void didUpdateWidget(covariant TripFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.presetDestinationId != null &&
        widget.presetDestinationId != _destinationId) {
      setState(() => _destinationId = widget.presetDestinationId);
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _optionsLoading = true;
      _optionsError = null;
    });
    try {
      final options = await widget.api.getOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _optionsLoading = false;
        if (_destinationId != null &&
            options.destinations.every((item) => item.id != _destinationId)) {
          _destinationId = null;
        }
        _interestIds.removeWhere(
          (id) => options.interests.every((item) => item.id != id),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _optionsError = error;
        _optionsLoading = false;
      });
    }
  }

  Future<void> _onGenerate() async {
    if (_submitting) {
      return;
    }
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      if (_destinationId == null) {
        _goToStep(0);
      }
      return;
    }

    final request = TripPlanRequest(
      destinationId: _destinationId!,
      days: int.parse(_daysController.text.trim()),
      interests: _interestIds.toList(),
    );
    final seq = ++_requestSeq;

    setState(() {
      _submitting = true;
      _status = _FlowStatus.loading;
      _error = null;
    });

    try {
      final plan = await widget.api.planTrip(request);
      if (!mounted || seq != _requestSeq) {
        return;
      }
      setState(() {
        _plan = plan;
        _status = _FlowStatus.success;
        _submitting = false;
      });
      widget.onPlanGenerated?.call(plan);
    } catch (error) {
      if (!mounted || seq != _requestSeq) {
        return;
      }
      final mapped = error is TripApiException
          ? error
          : const TripApiException(
              code: TripApiException.unexpected,
              message: 'Unexpected local failure.',
            );
      setState(() {
        _error = mapped;
        _status = _FlowStatus.error;
        _submitting = false;
      });
      if (mapped.code == TripApiException.invalidDestination ||
          mapped.code == TripApiException.invalidInterest) {
        await _loadOptions();
      }
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextFromDestination() {
    if (_destinationId == null) {
      _formKey.currentState?.validate();
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }
    _goToStep(1);
  }

  VoidCallback? get _footerAction {
    if (_submitting) {
      return _step == 2 ? _onGenerate : null;
    }
    if (_step == 0) {
      return _options == null ? null : _nextFromDestination;
    }
    if (_step == 1) {
      return _nextFromDays;
    }
    if (_options == null || _options!.destinations.isEmpty || _optionsLoading) {
      return null;
    }
    return _onGenerate;
  }

  void _nextFromDays() {
    final value = int.tryParse(_daysController.text.trim());
    if (value == null || value < 1 || value > 14) {
      _formKey.currentState?.validate();
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }
    _goToStep(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Opacity(
            opacity: 0.16,
            child: Image(
              image: AssetImage('assets/intro/onboard_floral_wash.png'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
        child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate,
        child: Column(
          children: [
            if (AppConfig.useMockApi)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: _ModeChip(label: 'MOCK')),
              ),
            if (_optionsLoading) const LinearProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => setState(() => _step = value),
                children: [
                  _DestinationStep(
                    options: _options,
                    destinationId: _destinationId,
                    enabled: !_submitting && _options != null,
                    optionsError: _optionsError,
                    onRetryOptions: _loadOptions,
                    mockApi: _mockApi,
                    scenario: _scenario,
                    onScenarioChanged: (value) {
                      setState(() {
                        _scenario = value;
                        _mockApi?.scenario = value;
                      });
                    },
                    onDestinationChanged: (id) => setState(() => _destinationId = id),
                  ),
                  _DaysStep(
                    controller: _daysController,
                    enabled: !_submitting,
                    onBack: () => _goToStep(0),
                  ),
                  _InterestsStep(
                    options: _options,
                    interestIds: _interestIds,
                    enabled: !_submitting && _options != null,
                    submitting: _submitting,
                    status: _status,
                    error: _error,
                    plan: _plan,
                    onInterestToggled: (id, selected) {
                      setState(() {
                        if (selected) {
                          _interestIds.add(id);
                        } else {
                          _interestIds.remove(id);
                        }
                      });
                    },
                    onGenerate: _onGenerate,
                    onBack: () => _goToStep(1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  key: Key(_step == 2 ? 'generate-button' : _step == 1 ? 'days-next' : 'plan-next'),
                  onPressed: _footerAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.introTeal,
                    shape: const StadiumBorder(),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_step == 2 ? 'Generate' : 'Next'),
                ),
              ),
            ),
          ],
        ),
        ),
          ),
        ],
      ),
    );
  }
}

class _DestinationStep extends StatelessWidget {
  const _DestinationStep({
    required this.options,
    required this.destinationId,
    required this.enabled,
    required this.optionsError,
    required this.onRetryOptions,
    required this.mockApi,
    required this.scenario,
    required this.onScenarioChanged,
    required this.onDestinationChanged,
  });

  final TripOptions? options;
  final String? destinationId;
  final bool enabled;
  final Object? optionsError;
  final VoidCallback onRetryOptions;
  final MockTripApi? mockApi;
  final MockScenario scenario;
  final ValueChanged<MockScenario> onScenarioChanged;
  final ValueChanged<String?> onDestinationChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (mockApi != null) ...[
          _MockScenarioCard(
            scenario: scenario,
            enabled: enabled,
            onChanged: onScenarioChanged,
          ),
          const SizedBox(height: 12),
        ],
        if (optionsError != null)
          _MessageCard(
            color: Theme.of(context).colorScheme.errorContainer,
            title: 'Could not load destinations',
            body: 'Saved-trip work is not part of this card. Retry to load options.',
            actionLabel: 'Retry options',
            onAction: onRetryOptions,
          ),
        if (options != null && options!.destinations.isEmpty)
          const _MessageCard(
            title: 'No destinations available',
            body: 'Generate stays disabled until trip-options returns destinations.',
          ),
        const Text(
          'Plan your trip',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: AppTheme.brandInk,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Where do you want to go?',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 18,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: AppTheme.brandSoft,
          ),
        ),
        const SizedBox(height: 16),
        FormField<String>(
          key: const Key('destination-field'),
          validator: (_) {
            if (destinationId == null || destinationId!.isEmpty) {
              return 'Destination is required';
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final destination
                        in options?.destinations ?? const <DestinationOption>[])
                      ChoiceChip(
                        key: Key('destination-${destination.id}'),
                        label: Text(destination.name),
                        selected: destinationId == destination.id,
                        showCheckmark: true,
                        selectedColor: AppTheme.introTeal,
                        labelStyle: TextStyle(
                          color: destinationId == destination.id
                              ? Colors.white
                              : AppTheme.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: enabled
                            ? (_) {
                                onDestinationChanged(destination.id);
                                state.didChange(destination.id);
                              }
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  child: BlendedScene(
                    key: ValueKey(destinationId ?? 'featured'),
                    image: DestinationArt.photoFor(destinationId),
                    height: 210,
                    overlay: destinationId == null
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                              child: Text(
                                _destinationName(options, destinationId),
                                style: const TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DaysStep extends StatelessWidget {
  const _DaysStep({
    required this.controller,
    required this.enabled,
    required this.onBack,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onBack;

  void _bump(int delta) {
    final current = int.tryParse(controller.text.trim()) ?? 3;
    controller.text = '${(current + delta).clamp(1, 14)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            label: const Text('Back'),
          ),
        ),
        const Text(
          'How long is your trip?',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: AppTheme.brandInk,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose 1 to 14 days.',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: AppTheme.brandSoft,
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundStepButton(
              icon: Icons.remove,
              onPressed: enabled ? () => _bump(-1) : null,
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 140,
              child: TextFormField(
                key: const Key('days-field'),
                controller: controller,
                enabled: enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 56,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.introTeal,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                validator: (raw) {
                  final value = int.tryParse(raw?.trim() ?? '');
                  if (value == null) {
                    return 'Enter a whole number';
                  }
                  if (value < 1 || value > 14) {
                    return 'Days must be between 1 and 14';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 18),
            _RoundStepButton(
              icon: Icons.add,
              onPressed: enabled ? () => _bump(1) : null,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'days',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontStyle: FontStyle.italic,
              fontSize: 18,
              color: AppTheme.brandSoft,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const BlendedScene(
          image: DestinationArt.days,
          height: 210,
        ),
      ],
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({
    required this.options,
    required this.interestIds,
    required this.enabled,
    required this.submitting,
    required this.status,
    required this.error,
    required this.plan,
    required this.onInterestToggled,
    required this.onGenerate,
    required this.onBack,
  });

  final TripOptions? options;
  final Set<String> interestIds;
  final bool enabled;
  final bool submitting;
  final _FlowStatus status;
  final TripApiException? error;
  final TripPlan? plan;
  final void Function(String id, bool selected) onInterestToggled;
  final VoidCallback onGenerate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            label: const Text('Back'),
          ),
        ),
        const Text(
          'What do you love?',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: AppTheme.brandInk,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Interests are optional. Leave them empty if you want.',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: AppTheme.brandSoft,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final interest in options?.interests ?? const <InterestOption>[])
              FilterChip(
                key: Key('interest-${interest.id}'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                avatar: Icon(
                  _interestIcon(interest.id),
                  size: 18,
                  color: _interestColor(interest.id),
                ),
                label: Text(
                  interest.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                selected: interestIds.contains(interest.id),
                selectedColor: _interestColor(interest.id).withValues(alpha: 0.18),
                onSelected: enabled
                    ? (selected) => onInterestToggled(interest.id, selected)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (status == _FlowStatus.initial) ...[
          const BlendedScene(
            image: DestinationArt.featured,
            height: 188,
          ),
          const SizedBox(height: 16),
        ],
        if (status == _FlowStatus.loading)
          const _MessageCard(
            title: 'Creating itinerary…',
            body: 'Please wait. Extra Generate taps are ignored while this is running.',
          ),
        if (status == _FlowStatus.error && error != null)
          _MessageCard(
            color: Theme.of(context).colorScheme.errorContainer,
            title: 'Could not generate this trip',
            body: error!.userMessage,
            actionLabel: 'Retry',
            onAction: submitting ? null : onGenerate,
          ),
        if (status == _FlowStatus.success && plan != null) ...[
          _ResultView(plan: plan!, showJson: true),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

IconData _interestIcon(String id) {
  switch (id) {
    case 'history':
      return Icons.account_balance_outlined;
    case 'culture':
      return Icons.theater_comedy_outlined;
    case 'food':
      return Icons.restaurant_outlined;
    case 'nature':
      return Icons.park_outlined;
    case 'adventure':
      return Icons.hiking;
    case 'art':
      return Icons.palette_outlined;
    default:
      return Icons.favorite_outline;
  }
}

Color _interestColor(String id) {
  switch (id) {
    case 'history':
      return const Color(0xFF6B5BB8);
    case 'culture':
      return const Color(0xFF2F6F6A);
    case 'food':
      return const Color(0xFFD9843A);
    case 'nature':
      return const Color(0xFF4F9A62);
    case 'adventure':
      return const Color(0xFFC45C3E);
    case 'art':
      return const Color(0xFF3F7FB5);
    default:
      return AppTheme.primary;
  }
}

String _destinationName(TripOptions? options, String? destinationId) {
  if (options == null || destinationId == null) return '';
  for (final item in options.destinations) {
    if (item.id == destinationId) return item.name;
  }
  return '';
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.introTeal,
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          shape: const CircleBorder(),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ScenarioChoice {
  const _ScenarioChoice(this.scenario, this.label);
  final MockScenario scenario;
  final String label;
}

const _scenarioChoices = [
  _ScenarioChoice(MockScenario.success, 'Success'),
  _ScenarioChoice(MockScenario.partial, 'Partial'),
  _ScenarioChoice(MockScenario.empty, 'Empty'),
  _ScenarioChoice(MockScenario.planningUnavailable, 'Unavailable'),
  _ScenarioChoice(MockScenario.planningFailed, 'Failed'),
  _ScenarioChoice(MockScenario.networkError, 'Network'),
  _ScenarioChoice(MockScenario.unexpected, 'Unknown code'),
];

class _MockScenarioCard extends StatelessWidget {
  const _MockScenarioCard({
    required this.scenario,
    required this.enabled,
    required this.onChanged,
  });

  final MockScenario scenario;
  final bool enabled;
  final ValueChanged<MockScenario> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cream.withValues(alpha: 0.72),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mock scenario',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Demo only. The real Backend will not receive this.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              key: const Key('mock-scenario-dropdown'),
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _scenarioChoices)
                  ChoiceChip(
                    key: Key('scenario-${item.scenario.name}'),
                    label: Text(item.label),
                    selected: scenario == item.scenario,
                    onSelected: enabled ? (_) => onChanged(item.scenario) : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.plan, required this.showJson});

  final TripPlan plan;
  final bool showJson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final warning in plan.warnings) ...[
          _MessageCard(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            title: 'Coverage warning',
            body: _warningText(warning),
          ),
          const SizedBox(height: 12),
        ],
        const Text(
          'Your trip itinerary',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontStyle: FontStyle.italic,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppTheme.brandInk,
          ),
        ),
        Text(
          '${plan.requestedDays} requested day${plan.requestedDays == 1 ? '' : 's'}',
          style: const TextStyle(color: AppTheme.muted),
        ),
        const SizedBox(height: 8),
        for (final day in plan.days) _DayCard(day: day),
        if (showJson) ...[
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: const Text('Response JSON'),
              children: [
                SelectableText(
                  const JsonEncoder.withIndent('  ').convert(plan.toJson()),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _warningText(PlanningWarning warning) {
    if (warning.message != null && warning.message!.trim().isNotEmpty) {
      return warning.message!;
    }
    switch (warning.code) {
      case 'PARTIAL_ITINERARY':
        return 'Some days came back empty. Empty days are shown on purpose; this is not a crash.';
      case 'NO_PLACES_AVAILABLE':
        return 'No places were returned for this request. That does not mean the destination itself has nothing to visit.';
      default:
        return 'Warning: ${warning.code}';
    }
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final DayPlan day;

  @override
  Widget build(BuildContext context) {
    final extraPlaces = day.places.length > 3;
    final visiblePlaces = day.places.take(3).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Day ${day.dayNumber}',
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontStyle: FontStyle.italic,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (visiblePlaces.isEmpty)
              Text(
                'No places for this day.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            for (final place in visiblePlaces) _PlaceTile(place: place),
            if (extraPlaces)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Contract defect: more than 3 places were returned. Extra places are not shown.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
        backgroundImage: place.imageUrl == null ? null : NetworkImage(place.imageUrl!),
        onBackgroundImageError: place.imageUrl == null ? null : (_, _) {},
        child: Icon(Icons.place_outlined, color: AppTheme.primary),
      ),
      title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (place.description != null) Text(place.description!),
          if (place.address != null) Text(place.address!),
          if (place.rating != null) Text('Rating ${place.rating}'),
          if (place.website != null) Text(place.website!),
        ],
      ),
      isThreeLine: place.description != null || place.address != null,
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    this.color,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final Color? color;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(body),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: Key('action-$actionLabel'),
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: AppTheme.cream.withValues(alpha: 0.8),
      side: const BorderSide(color: AppTheme.outline),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6),
      ),
    );
  }
}
