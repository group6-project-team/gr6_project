import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/widgets/auth_validators.dart';

import 'support/fake_auth_api.dart';
import 'support/fake_saved_trips_api.dart';
import 'support/mock_trip_api.dart';

Future<void> _openApp(WidgetTester tester, {FakeAuthApi? authApi}) async {
  await tester.pumpWidget(
    TripPlannerApp(
      api: MockTripApi(delay: Duration.zero),
      authApi: authApi ?? FakeAuthApi(),
      savedTripsApi: FakeSavedTripsApi(),
      skipIntro: true,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('auth validators require name, email, and matching passwords', () {
    expect(AuthValidators.name(null), 'Name is required');
    expect(AuthValidators.name('   '), 'Name is required');
    expect(AuthValidators.name('Heba Rabaya'), isNull);
    expect(AuthValidators.email(null), 'Email is required');
    expect(AuthValidators.email('not-an-email'), 'Enter a valid email');
    expect(AuthValidators.email('t@gmail.com'), 'Enter a valid email');
    expect(AuthValidators.email('ab@gmail.com'), 'Enter a valid email');
    expect(AuthValidators.email('heba@test.com'), isNull);
    expect(AuthValidators.password('short'), 'Password must be at least 8 characters');
    expect(AuthValidators.password('longenough'), isNull);
    expect(
      AuthValidators.confirmPassword('a', 'b'),
      'Passwords do not match',
    );
  });

  testWidgets('saved tab asks a guest to log in', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byKey(const Key('nav-wishlist')));
    await tester.pumpAndSettle();

    expect(find.text('Log in to save trips'), findsOneWidget);
    expect(find.byKey(const Key('saved-login')), findsOneWidget);
    expect(find.byKey(const Key('saved-signup')), findsOneWidget);
  });

  testWidgets('login session opens the signed-in saved list', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byKey(const Key('nav-wishlist')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved-login')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-email')), 'heba@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'password1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Hi, heba'), findsOneWidget);
    expect(find.text('No saved trips yet'), findsOneWidget);
  });

  testWidgets('invalid login stays on the form', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login-email')), 'bad');
    await tester.enterText(find.byKey(const Key('login-password')), '123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('logout returns the guest saved state', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-email')), 'heba@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'password1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();
    expect(find.text('heba@test.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Hi there'), findsOneWidget);
    expect(find.byKey(const Key('home-account')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-wishlist')));
    await tester.pumpAndSettle();
    expect(find.text('Log in to save trips'), findsOneWidget);
  });

  testWidgets('logout clears the previous planner so the next guest starts fresh', (
    tester,
  ) async {
    await _openApp(tester);
    await tester.tap(find.byKey(const Key('nav-plan')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('destination-istanbul')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('plan-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('days-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('generate-button')));
    await tester.pumpAndSettle();
    expect(find.text('Day 1'), findsWidgets);

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-email')), 'heba@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'password1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Hi there'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-plan')));
    await tester.pumpAndSettle();
    expect(find.text('Where do you want to go?'), findsOneWidget);
    expect(find.text('Day 1'), findsNothing);
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('destination-istanbul'))).selected,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('nav-itinerary')));
    await tester.pumpAndSettle();
    expect(find.text('Start planning'), findsOneWidget);
  });
}
