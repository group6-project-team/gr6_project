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

enum _FlowStatus { initial, loading, success, error }

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key, required this.api});

  final TripApi api;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController(text: '3');

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
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  MockScenario _scenario = MockScenario.success;

  MockTripApi? get _mockApi {
    final api = widget.api;
    return api is MockTripApi ? api : null;
  }

  @override
  void initState() {
    super.initState();
    final mock = _mockApi;
    if (mock != null) {
      _scenario = mock.scenario;
    }
    _loadOptions();
  }

  @override
  void dispose() {
    _daysController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.mistTop, AppTheme.mistBottom],
        ),
      ),
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Triply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted)),
            Text('Plan your trip'),
          ],
        ),
        actions: [
          if (AppConfig.useMockApi)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: _ModeChip(label: 'MOCK')),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (_mockApi != null) ...[
              _MockScenarioCard(
                scenario: _scenario,
                enabled: !_submitting,
                onChanged: (value) {
                  setState(() {
                    _scenario = value;
                    _mockApi!.scenario = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            if (_optionsLoading) const LinearProgressIndicator(),
            if (_optionsError != null)
              _MessageCard(
                color: Theme.of(context).colorScheme.errorContainer,
                title: 'Could not load destinations',
                body: 'Saved-trip work is not part of this card. Retry to load options.',
                actionLabel: 'Retry options',
                onAction: _optionsLoading ? null : _loadOptions,
              ),
            if (_options != null && _options!.destinations.isEmpty)
              _MessageCard(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                title: 'No destinations available',
                body: 'Generate stays disabled until trip-options returns destinations.',
              ),
            const SizedBox(height: 8),
            _TripInputForm(
              options: _options,
              destinationId: _destinationId,
              daysController: _daysController,
              interestIds: _interestIds,
              enabled: !_submitting && _options != null,
              onDestinationChanged: (id) => setState(() => _destinationId = id),
              onInterestToggled: (id, selected) {
                setState(() {
                  if (selected) {
                    _interestIds.add(id);
                  } else {
                    _interestIds.remove(id);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_status == _FlowStatus.loading)
              const _MessageCard(
                title: 'Creating itinerary…',
                body: 'Please wait. Extra Generate taps are ignored while this is running.',
              ),
            if (_status == _FlowStatus.error && _error != null)
              _MessageCard(
                color: Theme.of(context).colorScheme.errorContainer,
                title: 'Could not generate this trip',
                body: _error!.userMessage,
                actionLabel: 'Retry',
                onAction: _submitting ? null : _onGenerate,
              ),
            if (_status == _FlowStatus.success && _plan != null)
              _ResultView(plan: _plan!, showJson: true),
          ],
        ),
      ),
      ),
      bottomNavigationBar: ColoredBox(
        color: AppTheme.mistBottom.withValues(alpha: 0.92),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            key: const Key('generate-button'),
            onPressed: (!_submitting &&
                    _options != null &&
                    _options!.destinations.isNotEmpty &&
                    !_optionsLoading)
                ? _onGenerate
                : null,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cream),
                  )
                : const Text('Generate'),
          ),
        ),
      ),
      ),
    ),
    );
  }
}

class _TripInputForm extends StatelessWidget {
  const _TripInputForm({
    required this.options,
    required this.destinationId,
    required this.daysController,
    required this.interestIds,
    required this.enabled,
    required this.onDestinationChanged,
    required this.onInterestToggled,
  });

  final TripOptions? options;
  final String? destinationId;
  final TextEditingController daysController;
  final Set<String> interestIds;
  final bool enabled;
  final ValueChanged<String?> onDestinationChanged;
  final void Function(String id, bool selected) onInterestToggled;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.15,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      Text('Where do you want to go?', style: titleStyle),
                      const SizedBox(height: 6),
                      Text(
                        'Pick a supported destination.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                      ),
                      const SizedBox(height: 14),
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
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: destinationId == destination.id ? AppTheme.cream : AppTheme.ink,
                                fontWeight: FontWeight.w600,
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
              const SizedBox(height: 28),
              Text('How long is your trip?', style: titleStyle),
              const SizedBox(height: 6),
              Text(
                'Choose 1 to 14 days.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 320,
                  child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: enabled ? () => _bumpDays(-1) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('days-field'),
                      controller: daysController,
                      enabled: enabled,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        hintText: '1 to 14',
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
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: enabled ? () => _bumpDays(1) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text('What do you love?', style: titleStyle),
              const SizedBox(height: 6),
              Text(
                'Interests are optional. Leave them empty if you want.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final interest in options?.interests ?? const <InterestOption>[])
                    FilterChip(
                      key: Key('interest-${interest.id}'),
                      avatar: Icon(_interestIcon(interest.id), size: 16, color: _interestColor(interest.id)),
                      label: Text(interest.name),
                      selected: interestIds.contains(interest.id),
                      selectedColor: _interestColor(interest.id).withValues(alpha: 0.18),
                      onSelected: enabled
                          ? (selected) => onInterestToggled(interest.id, selected)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  void _bumpDays(int delta) {
    final current = int.tryParse(daysController.text.trim()) ?? 3;
    daysController.text = '${(current + delta).clamp(1, 14)}';
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
            Text('Mock scenario', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
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
        Text(
          'Your trip itinerary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          '${plan.requestedDays} requested day${plan.requestedDays == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
        ),
        const SizedBox(height: 8),
        for (final day in plan.days) _DayCard(day: day),
        if (showJson) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Response JSON'),
            children: [
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(plan.toJson()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
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
            Text('Day ${day.dayNumber}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (visiblePlaces.isEmpty)
              Text(
                'No places for this day.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6)),
    );
  }
}
