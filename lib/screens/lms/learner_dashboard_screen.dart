import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/progress_store.dart';
import '../../widgets/lms/course_card.dart';
import '../../shared/auth_prototype_store.dart';
import '../../shared/learning_navigation.dart';
import '../../theme.dart';

class LearnerDashboardScreen extends StatefulWidget {
  const LearnerDashboardScreen({
    super.key,
    this.courseId = 'ei-fundamentals',
    this.enroll = false,
  });
  final String courseId;
  final bool enroll;
  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
  String filter = 'In progress';
  @override
  void initState() {
    super.initState();
    if (widget.enroll) enrollCourse(widget.courseId);
  }

  Future<void> open(String route, {Object? arguments}) async {
    await Navigator.pushNamed(context, route, arguments: arguments);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mine = mockCourses
        .where((c) => enrolledCourses.contains(c.id))
        .toList();
    final finished = mine
        .where((c) => completedCourses.contains(c.id))
        .toList();
    final active = mine.where((c) => !completedCourses.contains(c.id)).toList();
    final suggested = mockCourses
        .where(
          (c) =>
              !enrolledCourses.contains(c.id) &&
              c.prerequisites.every(completedCourses.contains),
        )
        .take(3)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
        actions: const [LearningNavigation()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: deepBlue,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final intro = Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR LEARNING JOURNEY',
                              style: TextStyle(
                                color: softYellow,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome, ${AuthPrototypeStore.instance.displayName ?? 'Learner'}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Small steps. Stronger skills.\nBuild your future, one course at a time.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: softYellow,
                                foregroundColor: deepBlue,
                              ),
                              onPressed: () => open('/hub'),
                              icon: const Icon(Icons.explore_outlined),
                              label: const Text('Explore courses'),
                            ),
                          ],
                        ),
                      );
                      return box.maxWidth < 700
                          ? intro
                          : Row(
                              children: [
                                Expanded(flex: 3, child: intro),
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    'assets/images/workshop_group_activity.jpeg',
                                    height: 310,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, box) => Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final stat in [
                        ('Enrolled', mine.length, Icons.menu_book_outlined),
                        (
                          'In Progress',
                          active.length,
                          Icons.play_circle_outline,
                        ),
                        ('Completed', finished.length, Icons.task_alt),
                        (
                          'Certificates',
                          finished.length,
                          Icons.workspace_premium_outlined,
                        ),
                      ])
                        SizedBox(
                          width:
                              (box.maxWidth - (box.maxWidth < 650 ? 16 : 48)) /
                              (box.maxWidth < 650 ? 2 : 4),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(stat.$3, color: purple, size: 30),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${stat.$2}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  Text(stat.$1),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'My Learning',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final label in [
                      'In progress',
                      'Completed',
                      'Certificates',
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: filter == label,
                        onSelected: (_) => setState(() => filter = label),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if ((filter == 'In progress' ? active : finished).isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            filter == 'In progress'
                                ? Icons.auto_stories
                                : Icons.workspace_premium_outlined,
                            size: 44,
                            color: purple,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            filter == 'In progress'
                                ? 'Your next chapter starts here.'
                                : 'Your achievements will appear here.',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Text(
                            'Explore a course, complete the lessons and pass its assessment.',
                          ),
                          TextButton(
                            onPressed: () => open('/hub'),
                            child: const Text('Browse learning hub'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (filter != 'Certificates')
                  grid(filter == 'In progress' ? active : finished),
                if (filter == 'Certificates')
                  for (final course in finished)
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: const Icon(
                          Icons.workspace_premium,
                          color: purple,
                          size: 40,
                        ),
                        title: Text(course.title),
                        subtitle: const Text(
                          'Training completed · Certificate available',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => open(
                          '/certificate',
                          arguments: {'courseId': course.id},
                        ),
                      ),
                    ),
                const SizedBox(height: 32),
                Text(
                  'Recommended next',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Courses you are ready to start, based on your completed prerequisites.',
                ),
                const SizedBox(height: 20),
                grid(suggested),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      AuthPrototypeStore.instance.displayName ?? 'My profile',
                    ),
                    subtitle: Text(AuthPrototypeStore.instance.email ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open('/profile'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget grid(List<Course> courses) => LayoutBuilder(
    builder: (context, box) {
      final count = box.maxWidth >= 900
          ? 3
          : box.maxWidth >= 600
          ? 2
          : 1;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final c in courses)
            SizedBox(
              width: (box.maxWidth - (count - 1) * 20) / count,
              child: CourseCard(
                course: c,
                onViewCourse: () => open('/course-detail', arguments: c.id),
                onContinueCourse: () => open('/course-player', arguments: c.id),
              ),
            ),
        ],
      );
    },
  );
}
