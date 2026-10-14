import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Course {
  final String id;
  final String title;
  final String shortDescription;
  final String instructor;
  final String duration;
  final String level;
  final double rating;
  final double price;
  final List<String> modules;
  final int progress;
  final List<String> prerequisites;
  final String? pdfName;
  final String? pdfBase64;
  final List<Map<String, dynamic>> quiz;
  String get imageAsset =>
      'assets/images/${switch (id) {
        'mindfulness' || 'workplace-wellbeing' => 'impact_teachers_retreat.jpeg',
        'leadership' || 'organisational-development' => 'trainer_presenting.jpeg',
        'communication' => 'online_team_learning.jpg',
        'team-effectiveness' => 'workshop_team_creativity.jpeg',
        'personal-development' => 'impact_student_interaction.jpeg',
        _ => 'workshop_eq_facilitator.jpeg',
      }}';

  const Course({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.rating,
    required this.price,
    required this.modules,
    this.progress = 0,
    this.prerequisites = const [],
    this.pdfName,
    this.pdfBase64,
    this.quiz = const [],
  });
}

final List<Course> mockCourses = [...seedCourses];

const List<Course> seedCourses = [
  Course(
    id: 'ei-fundamentals',
    title: 'Emotional Intelligence Fundamentals',
    shortDescription:
        'Build self-awareness, emotional regulation, empathy, and stronger interpersonal skills.',
    instructor: 'MT Alchemy Learning Team',
    duration: '6 weeks',
    level: 'Beginner',
    rating: 4.8,
    price: 499.0,
    progress: 65,
    modules: [
      'Introduction to Emotional Intelligence',
      'Self-Awareness',
      'Emotional Regulation',
      'Empathy and Social Awareness',
      'Building Better Relationships',
    ],
  ),
  Course(
    id: 'mindfulness',
    title: 'Mindfulness at Work',
    shortDescription:
        'Learn practical mindfulness techniques for focus, resilience, and workplace well-being.',
    instructor: 'MT Alchemy Learning Team',
    duration: '4 weeks',
    level: 'Beginner',
    rating: 4.7,
    price: 399.0,
    modules: [
      'Introduction to Mindfulness',
      'Breathing and Attention',
      'Managing Workplace Stress',
      'Mindful Communication',
      'Building a Daily Practice',
    ],
  ),
  Course(
    id: 'leadership',
    prerequisites: ['ei-fundamentals'],
    title: 'Leadership Essentials',
    shortDescription:
        'Develop practical leadership skills for communication, decision-making, and team growth.',
    instructor: 'MT Alchemy Learning Team',
    duration: '8 weeks',
    level: 'Intermediate',
    rating: 4.9,
    price: 699.0,
    modules: [
      'Foundations of Leadership',
      'Leading Yourself',
      'Leading Teams',
      'Decision-Making',
      'Creating High-Performing Teams',
    ],
  ),
  Course(
    id: 'communication',
    title: 'Effective Communication',
    shortDescription:
        'Strengthen communication skills for clearer conversations, presentations, and professional relationships.',
    instructor: 'MT Alchemy Learning Team',
    duration: '5 weeks',
    level: 'Beginner',
    rating: 4.8,
    price: 449.0,
    modules: [
      'Foundations of Communication',
      'Active Listening',
      'Clear and Confident Speaking',
      'Difficult Conversations',
      'Professional Communication',
    ],
  ),
  Course(
    id: 'team-effectiveness',
    title: 'Team Effectiveness',
    shortDescription:
        'Learn how to build collaborative, productive, and high-performing teams.',
    instructor: 'MT Alchemy Learning Team',
    duration: '6 weeks',
    level: 'Intermediate',
    rating: 4.7,
    price: 549.0,
    modules: [
      'Understanding Team Dynamics',
      'Building Trust',
      'Collaboration and Cooperation',
      'Managing Team Conflict',
      'High-Performance Teams',
    ],
  ),
  Course(
    id: 'workplace-wellbeing',
    title: 'Workplace Well-being',
    shortDescription:
        'Explore practical approaches to creating healthier, happier, and more resilient workplaces.',
    instructor: 'MT Alchemy Learning Team',
    duration: '5 weeks',
    level: 'Beginner',
    rating: 4.6,
    price: 399.0,
    modules: [
      'Understanding Workplace Well-being',
      'Managing Stress',
      'Healthy Work Practices',
      'Resilience at Work',
      'Creating a Well-being Culture',
    ],
  ),
  Course(
    id: 'personal-development',
    title: 'Personal Development',
    shortDescription:
        'Develop self-awareness, confidence, goal-setting, and habits for continuous personal growth.',
    instructor: 'MT Alchemy Learning Team',
    duration: '6 weeks',
    level: 'Beginner',
    rating: 4.8,
    price: 429.0,
    modules: [
      'Self-Awareness',
      'Personal Goals',
      'Building Positive Habits',
      'Confidence and Growth',
      'Continuous Improvement',
    ],
  ),
  Course(
    id: 'organisational-development',
    prerequisites: ['leadership'],
    title: 'Organisational Development',
    shortDescription:
        'Understand people, culture, and change strategies that help organisations grow effectively.',
    instructor: 'MT Alchemy Learning Team',
    duration: '8 weeks',
    level: 'Advanced',
    rating: 4.9,
    price: 749.0,
    modules: [
      'Introduction to Organisational Development',
      'Organisational Culture',
      'Change Management',
      'People and Performance',
      'Building Sustainable Organisations',
    ],
  ),
];

Future<void> loadCourseCatalogue() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('mta_course_catalogue_v1');
  if (raw == null) return;
  final decoded = (jsonDecode(raw) as List).map((value) {
    final c = value as Map<String, dynamic>;
    return Course(
      id: c['id'],
      title: c['title'],
      shortDescription: c['description'],
      instructor: c['instructor'],
      duration: c['duration'],
      level: c['level'],
      rating: (c['rating'] as num).toDouble(),
      price: (c['price'] as num).toDouble(),
      modules: List<String>.from(c['modules']),
      prerequisites: List<String>.from(c['prerequisites'] ?? []),
      pdfName: c['pdfName'],
      pdfBase64: c['pdfBase64'],
      quiz: List<Map<String, dynamic>>.from(c['quiz'] ?? []),
    );
  }).toList();
  mockCourses
    ..clear()
    ..addAll(decoded);
}

Future<void> saveCourseCatalogue(List<Course> courses) async {
  final byId = {for (final course in courses) course.id: course};
  bool cycle(String id, Set<String> visiting) {
    if (!visiting.add(id)) return true;
    for (final prerequisite in byId[id]!.prerequisites) {
      if (!byId.containsKey(prerequisite) || cycle(prerequisite, {...visiting})) {
        return true;
      }
    }
    return false;
  }

  if (byId.length != courses.length ||
      courses.any((c) => c.modules.isEmpty || cycle(c.id, {}))) {
    throw ArgumentError(
      'Courses need modules and prerequisites without circular dependencies.',
    );
  }

  final prefs = await SharedPreferences.getInstance();
  final ok = await prefs.setString(
    'mta_course_catalogue_v1',
    jsonEncode(
      courses
          .map(
            (c) => {
              'id': c.id,
              'title': c.title,
              'description': c.shortDescription,
              'instructor': c.instructor,
              'duration': c.duration,
              'level': c.level,
              'rating': c.rating,
              'price': c.price,
              'modules': c.modules,
              'prerequisites': c.prerequisites,
              'pdfName': c.pdfName,
              'pdfBase64': c.pdfBase64,
              'quiz': c.quiz,
            },
          )
          .toList(),
    ),
  );
  if (!ok) throw StateError('Course changes could not be saved.');
  mockCourses
    ..clear()
    ..addAll(courses);
}
