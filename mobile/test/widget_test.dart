import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'support/fake_auth_api.dart';
import 'support/fake_saved_trips_api.dart';
import 'support/mock_trip_api.dart';

Finder generateButton() => find.byKey(const Key('generate-button'));

Future<void> _openApp(WidgetTester tester, MockTripApi api) async {
  await tester.pumpWidget(
    TripPlannerApp(
      api: api,
      authApi: FakeAuthApi(),
      savedTripsApi: FakeSavedTripsApi(),
      skipIntro: true,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openPlanner(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-plan')));
  await tester.pumpAndSettle();
}

Future<void> _chooseIstanbul(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('destination-istanbul')));
  await tester.pump();
}

Future<void> _goToDays(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('plan-next')));
  await tester.pumpAndSettle();
}

Future<void> _goToInterests(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('days-next')));
  await tester.pumpAndSettle();
}

Future<void> _generate(WidgetTester tester, {Duration delay = Duration.zero}) async {
  await tester.tap(generateButton());
  await tester.idle();
  if (delay > Duration.zero) {
    await tester.pump(delay);
    await tester.idle();
  }
  await tester.pump();
}

void main() {
  testWidgets('invalid days cannot be submitted', (tester) async {
    final api = MockTripApi(delay: Duration.zero);
    await _openApp(tester, api);
    await _openPlanner(tester);
    await _chooseIstanbul(tester);
    await _goToDays(tester);

    await tester.enterText(find.byKey(const Key('days-field')), '15');
    await _goToInterests(tester);

    expect(find.text('Days must be between 1 and 14'), findsOneWidget);
    expect(find.text('Day 1'), findsNothing);
    expect(api.planCallCount, 0);
  });

  testWidgets('destination is required', (tester) async {
    final api = MockTripApi(delay: Duration.zero);
    await _openApp(tester, api);
    await _openPlanner(tester);
    await _goToDays(tester);

    expect(find.text('Destination is required'), findsOneWidget);
    expect(api.planCallCount, 0);
  });

  testWidgets('success shows every requested day', (tester) async {
    final api = MockTripApi(delay: Duration.zero);
    await _openApp(tester, api);
    await _openPlanner(tester);
    await _chooseIstanbul(tester);
    await _goToDays(tester);
    await tester.enterText(find.byKey(const Key('days-field')), '2');
    await _goToInterests(tester);
    await _generate(tester);

    expect(api.planCallCount, 1);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('Hagia Sophia'), findsWidgets);
  });

  testWidgets('partial result shows empty days and a coverage warning', (
    tester,
  ) async {
    final api = MockTripApi(delay: Duration.zero);
    await _openApp(tester, api);
    await _openPlanner(tester);
    await tester.tap(find.byKey(const Key('scenario-partial')));
    await tester.pump();
    await _chooseIstanbul(tester);
    await _goToDays(tester);
    await _goToInterests(tester);
    await _generate(tester);

    expect(find.text('Coverage warning'), findsOneWidget);
    expect(find.text('No places for this day.'), findsWidgets);
  });

  testWidgets('PLANNING_FAILED is retryable and keeps the form', (tester) async {
    final api = MockTripApi(
      delay: Duration.zero,
      scenario: MockScenario.planningFailed,
    );
    await _openApp(tester, api);
    await _openPlanner(tester);
    await _chooseIstanbul(tester);
    await _goToDays(tester);
    await _goToInterests(tester);
    await _generate(tester);

    expect(find.textContaining('could not create this itinerary'), findsOneWidget);
    expect(find.text('What do you love?'), findsOneWidget);

    api.scenario = MockScenario.success;
    await tester.ensureVisible(find.byKey(const Key('action-Retry')));
    await tester.tap(find.byKey(const Key('action-Retry')));
    await tester.idle();
    await tester.pump();

    expect(find.text('Day 1'), findsOneWidget);
  });

  testWidgets('loading ignores extra Generate taps', (tester) async {
    final api = MockTripApi(delay: const Duration(milliseconds: 400));
    await _openApp(tester, api);
    await _openPlanner(tester);
    await _chooseIstanbul(tester);
    await _goToDays(tester);
    await _goToInterests(tester);

    await tester.tap(generateButton());
    await tester.pump();
    await tester.tap(generateButton());
    await tester.pump();

    expect(api.planCallCount, 1);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Day 1'), findsOneWidget);
  });
}
