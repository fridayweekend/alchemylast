import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/progress_store.dart';
import '../../widgets/lms/course_card.dart';
import '../../shared/auth_prototype_store.dart';

class LearnerDashboardScreen extends StatefulWidget {
  final String courseId;
  final bool enroll;

  const LearnerDashboardScreen({
    super.key,
    this.courseId = 'ei-fundamentals',
    this.enroll = false,
  });

  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
  final _profileFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController(
    text: AuthPrototypeStore.instance.displayName ?? 'Learner',
  );
  final emailController = TextEditingController(
    text: AuthPrototypeStore.instance.email ?? 'learner@example.com',
  );
  final preferencesController = TextEditingController(
    text: 'Leadership, Communication',
  );

  Course get course {
    return mockCourses.firstWhere(
      (item) => item.id == widget.courseId,
      orElse: () => mockCourses.first,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.enroll) enrollCourse(widget.courseId);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    preferencesController.dispose();
    super.dispose();
  }

  void continueCourse() {
    Navigator.pushNamed(context, '/course-player', arguments: course.id).then((
      _,
    ) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Browse learning hub',
            onPressed: () => Navigator.pushNamed(context, '/hub').then((_) {
              if (mounted) setState(() {});
            }),
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
                    color: const Color(0xFF16105B),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${nameController.text}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep learning and growing your skills.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'My Learning',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        icon: Icons.menu_book_outlined,
                        value: enrolledCourses.length.toString(),
                        label: 'Enrolled',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _statCard(
                        context,
                        icon: Icons.play_circle_outline,
                        value: enrolledCourses
                            .difference(completedCourses)
                            .length
                            .toString(),
                        label: 'In Progress',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _statCard(
                        context,
                        icon: Icons.check_circle_outline,
                        value: completedCourses.length.toString(),
                        label: 'Completed',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Continue Learning',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                if (enrolledCourses.isEmpty)
                  const Text(
                    'No courses enrolled yet. Browse the Learning Hub to get started.',
                  ),
                for (final enrolled in mockCourses.where(
                  (item) => enrolledCourses.contains(item.id),
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CourseCard(
                      course: enrolled,
                      onContinueCourse: () =>
                          Navigator.pushNamed(
                            context,
                            '/course-player',
                            arguments: enrolled.id,
                          ).then((_) {
                            if (mounted) setState(() {});
                          }),
                      onViewCourse: () =>
                          Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: enrolled.id,
                          ).then((_) {
                            if (mounted) setState(() {});
                          }),
                    ),
                  ),
                for (final id in completedCourses)
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/certificate',
                      arguments: {'courseId': id},
                    ),
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(
                      'View certificate: ${mockCourses.firstWhere((c) => c.id == id, orElse: () => mockCourses.first).title}',
                    ),
                  ),

                const SizedBox(height: 32),

                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8E5F0)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFECE9FF),
                        child: Icon(
                          Icons.workspace_premium_outlined,
                          color: Color(0xFF7655B7),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              completedCourses.isEmpty
                                  ? 'Keep Going!'
                                  : 'Course completed!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              completedCourses.isEmpty
                                  ? 'Complete your first course to unlock your first achievement.'
                                  : 'You earned your first course achievement. Your certificate is ready above.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8E5F0)),
                  ),
                  child: Form(
                    key: _profileFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: preferencesController,
                          decoration: const InputDecoration(
                            labelText: 'Learning Preferences',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            if (_profileFormKey.currentState!.validate()) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated'),
                                ),
                              );
                            }
                          },
                          child: const Text('Save Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E5F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: const Color(0xFF7655B7)),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
