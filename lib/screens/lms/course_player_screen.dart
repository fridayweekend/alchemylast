import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/progress_store.dart';
import '../../theme.dart';
import '../../widgets/lms/content_viewer.dart';
import '../../widgets/lms/module_sidebar.dart';
import '../../widgets/lms/progress_bar_card.dart';

const _types = [
  LessonType.video,
  LessonType.text,
  LessonType.pdf,
  LessonType.presentation,
  LessonType.audio,
  LessonType.image,
  LessonType.externalLink,
];

/// 5 modules x 4 lessons = 20 lessons, so 13 completed = 65%.
List<PlayerLesson> _sampleLessons(List<String> titles) => [
  for (var m = 0; m < 5; m++)
    for (var l = 0; l < 4; l++)
      PlayerLesson(
        moduleIndex: m,
        moduleTitle: titles[m],
        title: 'Lesson ${m + 1}.${l + 1}',
        type: _types[(m * 4 + l) % _types.length],
        body:
            'Sample content for lesson ${m + 1}.${l + 1}. Emotional '
            'intelligence is the ability to recognise, understand and manage '
            'our own emotions, and to respond well to the emotions of others.',
      ),
];

class CoursePlayerScreen extends StatefulWidget {
  const CoursePlayerScreen({super.key, this.courseId = 'ei-fundamentals'});
  final String courseId;

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  Course get _course => mockCourses.firstWhere(
    (c) => c.id == widget.courseId,
    orElse: () => mockCourses.first,
  );
  late final _lessons = _sampleLessons(_course.modules);
  late final int _startDone = (progressFor(_course) / 100 * _lessons.length)
      .round();

  // _done is the shared in-memory store, so progress survives leaving the screen.
  late final Set<int> _done = completedLessons.putIfAbsent(
    _course.id,
    () => {for (var i = 0; i < _startDone; i++) i},
  );
  late int _current =
      lastLesson[_course.id] ??
      _startDone.clamp(0, _lessons.length - 1).toInt();

  @override
  void dispose() {
    if (completedLessons[_course.id] != _done) {
      super.dispose();
      return;
    }
    lastLesson[_course.id] = _current;
    saveProgress();
    super.dispose();
  }

  double get _progress => _done.length / _lessons.length;
  bool get _isLast => _current == _lessons.length - 1;

  void _markComplete() {
    setState(() => _done.add(_current));
    saveProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_lessons[_current].title} marked complete')),
    );
  }

  void _next() {
    if (_isLast) {
      Navigator.pushNamed(context, '/quiz', arguments: widget.courseId);
    } else {
      setState(() => _current++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final sidebar = ModuleSidebar(
      lessons: _lessons,
      currentIndex: _current,
      completed: _done,
      onSelect: (i) {
        if (!wide) {
          Navigator.pop(context); // close the drawer
        }
        setState(() => _current = i);
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(_course.title)),
      drawer: wide ? null : Drawer(child: SafeArea(child: sidebar)),
      body: Row(
        children: [
          if (wide)
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: deepBlue.withValues(alpha: .08)),
                ),
              ),
              child: sidebar,
            ),
          Expanded(child: _mainArea(wide)),
        ],
      ),
    );
  }

  Widget _mainArea(bool wide) {
    final isDone = _done.contains(_current);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: ProgressBarCard(progress: _progress),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: deepBlue.withValues(alpha: .08)),
            ),
            child: SingleChildScrollView(
              child: ContentViewer(lesson: _lessons[_current]),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: deepBlue.withValues(alpha: .08)),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _current == 0
                    ? null
                    : () => setState(() => _current--),
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              FilledButton.icon(
                onPressed: isDone ? null : _markComplete,
                icon: Icon(isDone ? Icons.check : Icons.task_alt),
                label: Text(isDone ? 'Completed' : 'Mark Complete'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _isLast ? softYellow : null,
                  foregroundColor: _isLast ? deepBlue : null,
                ),
                onPressed: _next,
                icon: Icon(_isLast ? Icons.quiz_outlined : Icons.chevron_right),
                label: Text(_isLast ? 'Take Quiz' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
