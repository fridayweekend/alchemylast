import '../../shared/learning_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme.dart';
import '../../widgets.dart'; // InfoCard
import '../../widgets/lms/course_card.dart';
import '../../widgets/lms/progress_bar_card.dart';
import '../../shared/auth_prototype_store.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  static const _stats = [
    (Icons.menu_book_outlined, '3', 'Assigned courses'),
    (Icons.groups_outlined, '24', 'Learners'),
    (Icons.rate_review_outlined, '5', 'To review'),
    (Icons.trending_up, '62%', 'Avg. progress'),
  ];

  static const _materials = [
    (
      Icons.play_circle_outline,
      'Introduction to Emotional Intelligence',
      'Video · Module 1',
    ),
    (
      Icons.picture_as_pdf_outlined,
      'Self-Awareness Workbook',
      'PDF · Module 2',
    ),
    (
      Icons.slideshow_outlined,
      'Emotional Regulation Slides',
      'Presentation · Module 3',
    ),
    (
      Icons.headphones_outlined,
      'Guided Breathing Exercise',
      'Audio · Module 3',
    ),
  ];

  static const _assessments = [
    ('EI Fundamentals: Module 2 Quiz', '3 submissions waiting'),
    ('Mindfulness at Work: Final Assessment', '2 submissions waiting'),
    ('Leadership Essentials: Module 1 Quiz', '1 submission waiting'),
  ];

  static const _learners = [
    ('Aisha Rahman', 'Emotional Intelligence Fundamentals', 0.80),
    ('Daniel Lee', 'Leadership Essentials', 0.45),
    ('Mei Ling', 'Mindfulness at Work', 1.0),
    ('Farid Hassan', 'Effective Communication', 0.25),
  ];

  void _openCourse(BuildContext context, Course course) =>
      Navigator.pushNamed(context, '/course-player', arguments: course.id);

  Future<void> _review(BuildContext context, String assessment) async {
    final prefs = await SharedPreferences.getInstance();
    var note = prefs.getString('trainer_review_$assessment') ?? '';
    if (!context.mounted) return;
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(assessment),
        content: SizedBox(
          width: 480,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sample assessment review. Feedback is saved on this device; no notification is sent.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: note,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Trainer feedback',
                  ),
                  onChanged: (value) => note = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter feedback before saving.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          const LearningNavigation(),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(dialogContext, note.trim());
              }
            },
            child: const Text('Save review'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final saved = await prefs.setString('trainer_review_$assessment', result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Review saved on this device.'
                : 'Review could not be saved.',
          ),
        ),
      );
    }
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 16),
    child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        actions: [
          const LearningNavigation(),
          IconButton(
            tooltip: 'Browse learning hub',
            onPressed: () => Navigator.pushNamed(context, '/hub'),
            icon: const Icon(Icons.explore_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              AuthPrototypeStore.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: deepBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${AuthPrototypeStore.instance.displayName ?? 'Trainer'}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your courses, materials and learner progress.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/trainer_presenting.jpeg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Sample training overview'),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 900
                        ? 4
                        : (box.maxWidth >= 500 ? 2 : 1);
                    final w = (box.maxWidth - (cols - 1) * 16) / cols;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final s in _stats)
                          SizedBox(
                            width: w,
                            child: InfoCard(
                              padding: 20,
                              child: Column(
                                children: [
                                  Icon(s.$1, size: 30, color: purple),
                                  const SizedBox(height: 10),
                                  Text(
                                    s.$2,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(s.$3),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                _heading(context, 'Assigned courses'),
                for (final course in mockCourses.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CourseCard(
                      course: course,
                      onContinueCourse: () => _openCourse(context, course),
                      onViewCourse: () => _openCourse(context, course),
                    ),
                  ),

                _heading(context, 'Learning materials'),
                InfoCard(
                  padding: 8,
                  child: Column(
                    children: [
                      for (final m in _materials)
                        ListTile(
                          leading: Icon(m.$1, color: purple),
                          title: Text(m.$2),
                          subtitle: Text(m.$3),
                        ),
                    ],
                  ),
                ),

                _heading(context, 'Assessments to review'),
                InfoCard(
                  padding: 8,
                  child: Column(
                    children: [
                      for (final a in _assessments)
                        ListTile(
                          leading: const Icon(
                            Icons.rate_review_outlined,
                            color: purple,
                          ),
                          title: Text(a.$1),
                          subtitle: Text(a.$2),
                          trailing: OutlinedButton(
                            onPressed: () => _review(context, a.$1),
                            child: const Text('Review'),
                          ),
                        ),
                    ],
                  ),
                ),

                _heading(context, 'Sample learners and progress'),
                for (final l in _learners)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProgressBarCard(
                      progress: l.$3,
                      label: '${l.$1} · ${l.$2}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
