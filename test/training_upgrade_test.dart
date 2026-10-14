import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:publicwebsite/main.dart';
import 'package:publicwebsite/data/mock_data.dart';
import 'package:publicwebsite/data/progress_store.dart';
import 'package:publicwebsite/shared/auth_prototype_store.dart';

void main() {
  final auth = AuthPrototypeStore.instance;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockCourses
      ..clear()
      ..addAll(seedCourses);
    auth.signOut();
    await loadProgress();
  });
  tearDown(() {
    auth.signOut();
    mockCourses
      ..clear()
      ..addAll(seedCourses);
  });

  test(
    'course catalogue persists PDF, quiz, prerequisites and deletion',
    () async {
      const custom = Course(
        id: 'custom',
        title: 'Custom training',
        shortDescription: 'Practice',
        instructor: 'Trainer',
        duration: '1 week',
        level: 'Beginner',
        rating: 0,
        price: 0,
        modules: ['Introduction'],
        prerequisites: ['mindfulness'],
        pdfName: 'guide.pdf',
        pdfBase64: 'JVBERi0=',
        quiz: [
          {
            'prompt': 'Ready?',
            'options': ['Yes', 'No'],
            'answer': 'Yes',
          },
        ],
      );
      await saveCourseCatalogue([...mockCourses, custom]);
      mockCourses.clear();
      await loadCourseCatalogue();
      final restored = mockCourses.firstWhere((c) => c.id == 'custom');
      expect(restored.pdfBase64, 'JVBERi0=');
      expect(restored.quiz.single['answer'], 'Yes');
      expect(restored.prerequisites, ['mindfulness']);
      await saveCourseCatalogue(
        mockCourses.where((c) => c.id != 'custom').toList(),
      );
      await loadCourseCatalogue();
      expect(mockCourses.any((c) => c.id == 'custom'), isFalse);
    },
  );
  test('prerequisites and full lessons plus passing score gate completion', () {
    auth.signIn('learner@mtalchemy.demo', 'AlchemyLearner!26');
    enrollCourse('leadership');
    expect(enrolledCourses, isNot(contains('leadership')));
    completeCourse('ei-fundamentals', score: 100);
    expect(completedCourses, isEmpty);
    completedLessons['ei-fundamentals'] = {for (var i = 0; i < 20; i++) i};
    completeCourse('ei-fundamentals', score: 40);
    expect(completedCourses, isEmpty);
    completeCourse('ei-fundamentals', score: 80);
    enrollCourse('leadership');
    expect(enrolledCourses, contains('leadership'));
  });
  test('profile names persist per account', () async {
    auth.signIn('learner@mtalchemy.demo', 'AlchemyLearner!26');
    expect(await auth.updateProfile('A Learner'), isTrue);
    auth.signIn('trainer@mtalchemy.demo', 'AlchemyTrainer!26');
    await auth.loadProfile();
    expect(auth.displayName, 'MT Alchemy Trainer');
    auth.signIn('learner@mtalchemy.demo', 'AlchemyLearner!26');
    await auth.loadProfile();
    expect(auth.displayName, 'A Learner');
  });
  for (final role in [
    ('learner', 'AlchemyLearner!26'),
    ('trainer', 'AlchemyTrainer!26'),
    ('employer', 'AlchemyEmployer!26'),
    ('admin', 'AlchemyAdmin!26'),
  ]) {
    testWidgets(
      '${role.$1} account can navigate home, learning and its profile',
      (tester) async {
        auth.signIn('${role.$1}@mtalchemy.demo', role.$2);
        await tester.pumpWidget(const MtAlchemyApp());
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        for (final route in ['/dashboard', '/hub', '/profile', '/']) {
          nav.pushNamed(route);
          await tester.pumpAndSettle();
          expect(find.text('Workspace access required'), findsNothing);
          expect(tester.takeException(), isNull);
          nav.pop();
          await tester.pumpAndSettle();
        }
      },
    );
  }
  testWidgets('Next completes lessons without a blocking snackbar', (
    tester,
  ) async {
    auth.signIn('learner@mtalchemy.demo', 'AlchemyLearner!26');
    await tester.pumpWidget(const MtAlchemyApp());
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/course-player', arguments: 'mindfulness');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(completedLessons['mindfulness'], contains(0));
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('quiz deep link requires lesson completion', (tester) async {
    auth.signIn('learner@mtalchemy.demo', 'AlchemyLearner!26');
    await tester.pumpWidget(const MtAlchemyApp());
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/quiz');
    await tester.pumpAndSettle();
    expect(
      find.text('Complete all lessons before taking the assessment.'),
      findsOneWidget,
    );
    expect(completedCourses, isEmpty);
  });
  testWidgets('admin adds a course with custom assessment', (tester) async {
    auth.signIn('admin@mtalchemy.demo', 'AlchemyAdmin!26');
    await tester.pumpWidget(const MtAlchemyApp());
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/admin/courses');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add course'));
    await tester.tap(find.text('Add course'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    for (final entry in [
      (0, 'Safety training'),
      (1, 'Workplace skills'),
      (2, '1 week'),
      (3, 'Getting started'),
      (4, 'Ask for help? | Yes | No | Yes'),
    ]) {
      await tester.ensureVisible(fields.at(entry.$1));
      await tester.enterText(fields.at(entry.$1), entry.$2);
    }
    await tester.tap(find.text('Save course'));
    await tester.pumpAndSettle();
    expect(mockCourses.last.title, 'Safety training');
    expect(mockCourses.last.quiz.single['answer'], 'Yes');
    expect(tester.takeException(), isNull);
  });
}
