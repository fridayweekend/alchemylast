import '../commerce/commerce_prototype_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_data.dart';

const lessonsPerCourse = 20;
final Map<String, Set<int>> completedLessons = {};
final Map<String, int> lastLesson = {};
final Set<String> completedCourses = {};
final Set<String> enrolledCourses = {};
SharedPreferences? _preferences;
String? _learner;
String? progressStorageError;

Future<void> loadProgress() async {
  try {
    _preferences = await SharedPreferences.getInstance();
    selectLearner(_learner);
  } catch (_) {
    progressStorageError =
        'Learning progress could not be loaded on this device.';
  }
}

void selectLearner(String? email) {
  _learner = email?.toLowerCase();
  completedLessons.clear();
  lastLesson.clear();
  completedCourses.clear();
  enrolledCourses.clear();
  if (_learner == null) return;
  final prefs = _preferences;
  final prefix = 'mta_${_learner}_';
  for (final e in prefs?.getStringList('${prefix}done') ?? <String>[]) {
    final i = e.indexOf(':');
    if (i < 0) continue;
    completedLessons[e.substring(0, i)] = {
      for (final n in e.substring(i + 1).split(','))
        if (int.tryParse(n) case final int value)
          if (value >= 0 && value < lessonsPerCourse) value,
    };
  }
  for (final e in prefs?.getStringList('${prefix}last') ?? <String>[]) {
    final i = e.indexOf(':');
    if (i < 0) continue;
    lastLesson[e.substring(0, i)] = (int.tryParse(e.substring(i + 1)) ?? 0)
        .clamp(0, lessonsPerCourse - 1);
  }
  completedCourses.addAll(prefs?.getStringList('${prefix}completed') ?? []);
  enrolledCourses.addAll(prefs?.getStringList('${prefix}enrolled') ?? []);
  final assigned = CommercePrototypeStore.instance.assignedCoursesFor(
    _learner!,
  );
  enrolledCourses.addAll(
    mockCourses.where((c) => assigned.contains(c.title)).map((c) => c.id),
  );
}

Future<void> saveProgress() async {
  if (_learner == null) return;
  for (final course in mockCourses.where(
    (c) => enrolledCourses.contains(c.id),
  )) {
    CommercePrototypeStore.instance.updateLearningProgress(
      _learner!,
      course.title,
      progressFor(course),
    );
  }
  final prefix = 'mta_${_learner}_';
  final done = [
    for (final e in completedLessons.entries) '${e.key}:${e.value.join(',')}',
  ];
  final last = [for (final e in lastLesson.entries) '${e.key}:${e.value}'];
  final completed = completedCourses.toList();
  final enrolled = enrolledCourses.toList();
  try {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    final results = await Future.wait([
      prefs.setStringList('${prefix}done', done),
      prefs.setStringList('${prefix}last', last),
      prefs.setStringList('${prefix}completed', completed),
      prefs.setStringList('${prefix}enrolled', enrolled),
    ]);
    progressStorageError = results.every((ok) => ok)
        ? null
        : 'Progress could not be saved on this device.';
  } catch (_) {
    progressStorageError = 'Progress could not be saved on this device.';
  }
}

void enrollCourse(String courseId) {
  enrolledCourses.add(courseId);
  saveProgress();
}

void completeCourse(String courseId, {int? score}) {
  enrolledCourses.add(courseId);
  completedCourses.add(courseId);
  if (_learner != null && score != null) {
    final course = mockCourses.firstWhere((c) => c.id == courseId);
    CommercePrototypeStore.instance.updateLearningProgress(
      _learner!,
      course.title,
      progressFor(course),
      score: score,
    );
  }
  saveProgress();
}

int progressFor(Course course) =>
    ((completedLessons[course.id]?.length ?? 0) / lessonsPerCourse * 100)
        .round();
