import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'support/mock_trip_api.dart';

void main() {
  testWidgets('splash fades into onboarding and skip opens the planner', (
    tester,
  ) async {
    await tester.pumpWidget(
      TripPlannerApp(
        api: MockTripApi(delay: Duration.zero),
        splashDuration: const Duration(milliseconds: 40),
      ),
    );

    expect(find.byKey(const Key('splash-screen')), findsOneWidget);
    expect(find.text('Triply'), findsWidgets);
    expect(find.textContaining("It's a story."), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpAndSettle();

    expect(find.text('Discover\nNew Places'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next-0')));
    await tester.pumpAndSettle();
    expect(find.text('Plan Your\nPerfect Trip'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Plan your trip'), findsOneWidget);
    expect(find.text('Where do you want to go?'), findsOneWidget);
    expect(find.byKey(const Key('destination-field')), findsOneWidget);
    expect(find.byKey(const Key('plan-next')), findsOneWidget);
    expect(find.text('Welcome Back!'), findsNothing);
    expect(find.byKey(const Key('login-submit')), findsNothing);
  });
}
