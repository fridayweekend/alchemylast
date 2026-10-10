import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:publicwebsite/main.dart';
import 'package:publicwebsite/shared/auth_prototype_store.dart';

void main() {
  setUp(() => AuthPrototypeStore.instance.signOut());
  tearDown(() => AuthPrototypeStore.instance.signOut());

  testWidgets('admin login opens the protected admin dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const MtAlchemyApp());
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed('/admin');
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@mtalchemy.demo',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'AlchemyAdmin!26');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Platform operations at a glance.'), findsOneWidget);
    expect(AuthPrototypeStore.instance.role, 'Admin');
  });

  testWidgets('registration creates and signs in a learner account', (
    tester,
  ) async {
    await tester.pumpWidget(const MtAlchemyApp());
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed('/register');
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    final email = 'new-${DateTime.now().microsecondsSinceEpoch}@example.test';
    const values = [
      'Test Learner',
      '',
      '0123456789',
      'Malaysia',
      'Leadership',
      'CorrectHorseBattery1',
      'CorrectHorseBattery1',
    ];
    for (var i = 0; i < values.length; i++) {
      final field = fields.at(i);
      await tester.ensureVisible(field);
      await tester.enterText(field, i == 1 ? email : values[i]);
    }
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Learner Dashboard'), findsOneWidget);
    expect(AuthPrototypeStore.instance.email, email);
    expect(AuthPrototypeStore.instance.role, 'Learner');
  });

  testWidgets('learner credentials cannot open the admin dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const MtAlchemyApp());
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed('/admin');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'learner@mtalchemy.demo',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'AlchemyLearner!26',
    );
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('This page requires a Admin account.'), findsOneWidget);
    expect(find.text('Platform operations at a glance.'), findsNothing);
    expect(AuthPrototypeStore.instance.isSignedIn, isFalse);
  });
}
