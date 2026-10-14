import '../commerce/commerce_prototype_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_data.dart';

const lessonsPerCourse = 20;
final Map<String, Set<int>> completedLessons = {};
final Map<String, int> lastLesson = {};
final Set<String> completedCourses = {};
final Map<String, String> completionDates = {};
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
  completionDates.clear();
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
          if (value >= 0 && value < 400) value,
    };
  }
  for (final e in prefs?.getStringList('${prefix}last') ?? <String>[]) {
    final i = e.indexOf(':');
    if (i < 0) continue;
    lastLesson[e.substring(0, i)] = (int.tryParse(e.substring(i + 1)) ?? 0)
        .clamp(0, 399);
  }
  completedCourses.addAll(prefs?.getStringList('${prefix}completed') ?? []);
  for (final entry
      in prefs?.getStringList('${prefix}completion_dates') ?? <String>[]) {
    final split = entry.indexOf('|');
    if (split > 0) {
      completionDates[entry.substring(0, split)] = entry.substring(split + 1);
    }
  }
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
      prefs.setStringList(
        '${prefix}completion_dates',
        completionDates.entries.map((e) => '${e.key}|${e.value}').toList(),
      ),
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
  final course = mockCourses.where((c) => c.id == courseId).firstOrNull;
  if (course == null ||
      !course.prerequisites.every(completedCourses.contains)) {
    return;
  }
  enrolledCourses.add(courseId);
  saveProgress();
}

void completeCourse(String courseId, {int? score}) {
  final selected = mockCourses.where((c) => c.id == courseId).firstOrNull;
  if (selected == null ||
      score == null ||
      score < 60 ||
      !selected.prerequisites.every(completedCourses.contains) ||
      progressFor(selected) < 100) {
    return;
  }
  enrolledCourses.add(courseId);
  completedCourses.add(courseId);
  completionDates.putIfAbsent(courseId, () => DateTime.now().toIso8601String());
  if (_learner != null) {
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
    ((completedLessons[course.id]?.length ?? 0) /
            (course.modules.length * 4) *
            100)
        .round();
