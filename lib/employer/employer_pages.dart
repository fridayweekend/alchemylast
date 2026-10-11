import '../data/mock_data.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../commerce/commerce_prototype_store.dart';
import '../shared/file_export.dart';
import '../shared/portal_components.dart';
import '../shared/report_document.dart';
import '../theme.dart';
import '../widgets.dart';

final _store = CommercePrototypeStore.instance;

class EmployerDashboardPage extends StatelessWidget {
  const EmployerDashboardPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) {
      final assignments = _store.assignments;
      final average = assignments.isEmpty
          ? 0
          : assignments
                    .map((a) => a['progress'] as int)
                    .reduce((a, b) => a + b) ~/
                assignments.length;
      return PortalPage(
        title: 'Help your people grow.',
        eyebrow: 'Employer portal · ABC Sdn Bhd',
        children: [
          const InfoCard(
            color: deepBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('Organization workspace', light: true),
                SizedBox(height: 10),
                Text(
                  'Welcome, HR team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage employees, learning assignments and progress from one place.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ResponsiveGrid(
            children: [
              MetricCard(
                label: 'Employees',
                value: '${_store.employees.length}',
                icon: Icons.people_outline,
              ),
              MetricCard(
                label: 'Active learners',
                value: '${_store.employees.length}',
                icon: Icons.school_outlined,
              ),
              MetricCard(
                label: 'Courses assigned',
                value: '${assignments.length}',
                icon: Icons.assignment_outlined,
              ),
              MetricCard(
                label: 'Average progress',
                value: '$average%',
                icon: Icons.insights_outlined,
              ),
            ],
          ),
          const SectionTitle('Organization tools', eyebrow: 'Quick actions'),
          ResponsiveGrid(
            children: [
              PortalAction(
                title: 'Employee management',
                subtitle: 'Invite and manage people in your organization.',
                icon: Icons.groups_outlined,
                route: '/employees',
              ),
              PortalAction(
                title: 'Assign a course',
                subtitle: 'Choose a programme, audience and due date.',
                icon: Icons.assignment_add,
                route: '/assign-course',
              ),
              PortalAction(
                title: 'Learning reports',
                subtitle: 'Review progress by course and department.',
                icon: Icons.bar_chart,
                route: '/reports',
              ),
              PortalAction(
                title: 'Purchase programmes',
                subtitle: 'Browse learning materials and resources.',
                icon: Icons.storefront_outlined,
                route: '/store',
              ),
              PortalAction(
                title: 'My quote requests',
                subtitle: 'Track business pricing requests and team responses.',
                icon: Icons.request_quote_outlined,
                route: '/quote-requests',
              ),
            ],
          ),
          const SectionTitle(
            'Current assignments',
            eyebrow: 'Learning at a glance',
          ),
          if (assignments.isEmpty)
            const InfoCard(child: Text('No courses have been assigned yet.'))
          else
            for (final item in assignments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['course'] as String,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${item['team']} · Due ${item['due']}'),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (item['progress'] as int) / 100,
                        minHeight: 8,
                        color: purple,
                        backgroundColor: purple.withValues(alpha: .12),
                      ),
                      const SizedBox(height: 5),
                      Text('${item['progress']}% complete'),
                    ],
                  ),
                ),
              ),
        ],
      );
    },
  );
}

class EmployeeManagementPage extends StatelessWidget {
  const EmployeeManagementPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => PortalPage(
      title: 'Your people, learning together.',
      eyebrow: 'Employee management',
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _AddEmployeeDialog(),
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Invite employee'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => go(context, '/assign-course'),
              child: const Text('Assign course'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_store.employees.isEmpty)
          const InfoCard(
            child: Text(
              'No employees yet. Invite a team member to get started.',
            ),
          )
        else
          InfoCard(
            padding: 12,
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: constraints.maxWidth >= 720
                    ? [
                        const _EmployeeRow(
                          name: 'Employee',
                          department: 'Department',
                          email: 'Email',
                          status: 'Status',
                          header: true,
                        ),
                        for (final employee in _store.employees)
                          _EmployeeRow(
                            name: employee['name']!,
                            department: employee['department']!,
                            email: employee['email']!,
                            status: employee['status'] ?? 'Active',
                          ),
                      ]
                    : [
                        for (final employee in _store.employees)
                          _EmployeeCard(employee: employee),
                      ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'Invitations are recorded locally for this prototype; no email is sent. Authentication and organization membership connect during integration.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({
    required this.name,
    required this.department,
    required this.email,
    required this.status,
    this.header = false,
  });
  final String name;
  final String department;
  final String email;
  final String status;
  final bool header;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            name,
            style: TextStyle(
              fontWeight: header ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Text(department)),
        Expanded(flex: 2, child: Text(email, overflow: TextOverflow.ellipsis)),
        Expanded(child: Text(status)),
        if (!header)
          IconButton(
            tooltip: 'Remove employee',
            onPressed: () => _confirmRemoveEmployee(context, email),
            icon: const Icon(Icons.person_remove_outlined),
          )
        else
          const SizedBox(width: 48),
      ],
    ),
  );
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee});
  final Map<String, String> employee;
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFF8F6FF),
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(employee['name'] ?? ''),
        subtitle: Text(
          '${employee['department']}\n${employee['email']} · ${employee['status'] ?? 'Active'}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Remove employee',
          onPressed: () =>
              _confirmRemoveEmployee(context, employee['email'] ?? ''),
          icon: const Icon(Icons.person_remove_outlined),
        ),
      ),
    ),
  );
}

Future<void> _confirmRemoveEmployee(BuildContext context, String email) async {
  final employee = _store.employees.firstWhere(
    (item) => item['email'] == email,
    orElse: () => {'name': 'this employee'},
  );
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Remove employee?'),
      content: Text(
        'Remove ${employee['name']} and their local assignments from this demo organization?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed == true) _store.removeEmployee(email);
}

class _AddEmployeeDialog extends StatefulWidget {
  const _AddEmployeeDialog();
  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String department = 'Human Resources';
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Invite employee'),
    content: Form(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter a name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Work email'),
            validator: (v) =>
                v == null ||
                    !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
                ? 'Enter a valid work email'
                : _store.employees.any(
                    (employee) =>
                        employee['email']?.toLowerCase() ==
                        v.trim().toLowerCase(),
                  )
                ? 'This email is already in the organization'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: department,
            decoration: const InputDecoration(labelText: 'Department'),
            items: const [
              DropdownMenuItem(
                value: 'Human Resources',
                child: Text('Human Resources'),
              ),
              DropdownMenuItem(value: 'Finance', child: Text('Finance')),
              DropdownMenuItem(value: 'Management', child: Text('Management')),
              DropdownMenuItem(value: 'Sales', child: Text('Sales')),
            ],
            onChanged: (v) => setState(() => department = v ?? department),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            _store.addEmployee(
              name: _name.text.trim(),
              email: _email.text.trim(),
              department: department,
            );
            Navigator.pop(context);
          }
        },
        child: const Text('Create invitation'),
      ),
    ],
  );
}

class CourseAssignmentPage extends StatefulWidget {
  const CourseAssignmentPage({super.key});
  @override
  State<CourseAssignmentPage> createState() => _CourseAssignmentPageState();
}

class _CourseAssignmentPageState extends State<CourseAssignmentPage> {
  final _key = GlobalKey<FormState>();
  String course = 'Emotional Intelligence Fundamentals';
  DateTime? deadline;
  final selected = <String>{};
  @override
  Widget build(BuildContext context) => PortalPage(
    title: 'Put learning into motion.',
    eyebrow: 'Corporate course assignment',
    children: [
      InfoCard(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: course,
                decoration: const InputDecoration(labelText: 'Course'),
                isExpanded: true,
                items: [
                  for (final item in mockCourses)
                    DropdownMenuItem(
                      value: item.title,
                      child: Text(item.title),
                    ),
                ],
                onChanged: (v) => setState(() => course = v ?? course),
              ),
              const SizedBox(height: 16),
              Text(
                'Assign to employees',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final employee in _store.employees)
                    FilterChip(
                      label: Text(
                        '${employee['name']} · ${employee['department']}',
                      ),
                      selected: selected.contains(employee['email']),
                      onSelected: (value) => setState(() {
                        value
                            ? selected.add(employee['email']!)
                            : selected.remove(employee['email']!);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final chosen = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate:
                        deadline ??
                        DateTime.now().add(const Duration(days: 14)),
                  );
                  if (chosen != null) setState(() => deadline = chosen);
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  deadline == null
                      ? 'Choose a deadline'
                      : 'Due ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _assign,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Assign Course'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Employees receive an assignment notification in the final integrated application. This prototype saves the assignment on this device.',
        style: const TextStyle(color: Colors.black54),
      ),
    ],
  );
  void _assign() {
    if (!_key.currentState!.validate()) return;
    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a deadline for this assignment.')),
      );
      return;
    }
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one employee.')),
      );
      return;
    }
    final due = '${deadline!.day} ${_month(deadline!.month)} ${deadline!.year}';
    for (final email in selected) {
      final employee = _store.employees.firstWhere(
        (item) => item['email'] == email,
        orElse: () => {'department': 'Unassigned'},
      );
      _store.assignCourse(
        course: course,
        team: employee['department'] ?? 'Unassigned',
        due: due,
        employeeEmail: email,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$course assigned to ${selected.length} employee(s).'),
      ),
    );
    go(context, '/reports');
  }

  String _month(int value) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][value - 1];
}

class LearningReportsPage extends StatelessWidget {
  const LearningReportsPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => PortalPage(
      title: 'See how learning is progressing.',
      eyebrow: 'Corporate learning reports',
      children: [
        ResponsiveGrid(
          children: [
            MetricCard(
              label: 'Employee enrolments',
              value: '${_store.assignments.length}',
              icon: Icons.assignment_outlined,
            ),
            MetricCard(
              label: 'Completion',
              value: '${_average()}%',
              icon: Icons.task_alt,
            ),
            MetricCard(
              label: 'Average score',
              value: '${_averageScore()}%',
              icon: Icons.grade_outlined,
            ),
            MetricCard(
              label: 'Learning hours',
              value: '${_learningHours()}',
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
        const SectionTitle(
          'Department performance',
          eyebrow: 'Progress by team',
        ),
        for (final department in [
          'Human Resources',
          'Finance',
          'Management',
          'Sales',
        ])
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(department, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _departmentProgress(department) / 100,
                  minHeight: 9,
                  color: purple,
                  backgroundColor: purple.withValues(alpha: .12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_departmentProgress(department)}% average progress · ${_store.assignments.where((a) => a['team'] == department).length} enrolments',
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const SectionTitle(
          'Individual performance',
          eyebrow: 'Learner progress and certificates',
        ),
        if (_store.employees.isEmpty)
          const InfoCard(
            child: Text('Add employees to see individual learning progress.'),
          )
        else
          for (final employee in _store.employees)
            Builder(
              builder: (context) {
                final email = employee['email']!;
                final assigned = _store.assignments
                    .where((a) => a['employee'] == email)
                    .toList();
                final progress = assigned.isEmpty
                    ? 0
                    : assigned
                              .map((a) => a['progress'] as int)
                              .reduce((a, b) => a + b) ~/
                          assigned.length;
                final certificates = assigned
                    .where((a) => (a['progress'] as int) >= 100)
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InfoCard(
                    padding: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name']!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${employee['department']} · $email'),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 8,
                          color: purple,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${assigned.length} enrolments · $progress% average · $certificates certificates',
                        ),
                        for (final item in assigned)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${item['course']} · Due ${item['due']} · ${item['progress']}%',
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showReportPreview(context),
              icon: const Icon(Icons.description_outlined),
              label: const Text('View report'),
            ),
            OutlinedButton.icon(
              onPressed: () => _copyReport(
                context,
                'CSV report copied to clipboard',
                _csvReport(),
              ),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Copy CSV'),
            ),
            OutlinedButton.icon(
              onPressed: () => _downloadCsv(context),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download CSV'),
            ),
            FilledButton.icon(
              onPressed: () => _downloadPdf(context),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Download PDF'),
            ),
          ],
        ),
      ],
    ),
  );
  int _average() {
    final values = _store.assignments.map((a) => a['progress'] as int).toList();
    return values.isEmpty ? 0 : values.reduce((a, b) => a + b) ~/ values.length;
  }

  int _averageScore() {
    final values = _store.assignments
        .map((assignment) => assignment['score'] as int? ?? 0)
        .where((score) => score > 0)
        .toList();
    return values.isEmpty ? 0 : values.reduce((a, b) => a + b) ~/ values.length;
  }

  int _learningHours() => _store.assignments.fold<int>(
    0,
    (total, assignment) => total + (assignment['hours'] as int? ?? 0),
  );

  int _departmentProgress(String department) {
    final values = _store.assignments
        .where((a) => a['team'] == department)
        .map((a) => a['progress'] as int)
        .toList();
    return values.isEmpty ? 0 : values.reduce((a, b) => a + b) ~/ values.length;
  }

  String _csvReport() {
    String escape(Object? value) =>
        '"${'${value ?? ''}'.replaceAll('"', '""')}"';
    final rows = <List<Object?>>[
      [
        'Course',
        'Department',
        'Employee name',
        'Employee email',
        'Due date',
        'Progress',
        'Score',
        'Hours',
        'Certificate',
      ],
      ..._store.assignments.map(
        (a) => [
          a['course'],
          a['team'],
          _employeeName(a['employee']),
          a['employee'],
          a['due'],
          a['progress'],
          a['score'],
          a['hours'],
          (a['progress'] as int) >= 100 ? 'Earned' : 'Not earned',
        ],
      ),
    ];
    return rows.map((row) => row.map(escape).join(',')).join('\n');
  }

  List<String> _reportLines() => [
    'MT Alchemy Corporate Learning Report',
    'Generated: ${DateTime.now().toLocal()}',
    'Enrolments: ${_store.assignments.length}',
    'Average completion: ${_average()}%',
    'Average score: ${_averageScore()}%',
    'Learning hours: ${_learningHours()}',
    'Course | Department | Employee | Email | Deadline | Progress | Score | Hours',
    ..._store.assignments.map(
      (a) =>
          '${a['course']} | ${a['team']} | ${_employeeName(a['employee'])} | ${a['employee']} | ${a['due']} | ${a['progress']}% | ${a['score']}% | ${a['hours']}',
    ),
  ];

  String _employeeName(Object? email) {
    for (final employee in _store.employees) {
      if (employee['email'] == email) return employee['name'] ?? 'Unknown';
    }
    return 'Unknown employee';
  }

  Future<void> _downloadCsv(BuildContext context) async {
    try {
      final path = await saveLocalFile(
        'mt_alchemy_learning_report.csv',
        utf8.encode(_csvReport()),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path == null
                ? 'File saving is unavailable on this platform.'
                : 'CSV saved to $path',
          ),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save CSV: $error')));
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final path = await saveLocalFile(
        'mt_alchemy_learning_report.pdf',
        createReportPdf(_reportLines()),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path == null
                ? 'File saving is unavailable on this platform.'
                : 'PDF saved to $path',
          ),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save PDF: $error')));
      }
    }
  }

  Future<void> _copyReport(
    BuildContext context,
    String title,
    String content,
  ) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }

  void _showReportPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corporate learning report'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              _csvReport().replaceAll(',', '  ·  ').replaceAll('"', ''),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _csvReport()));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copy CSV data'),
          ),
        ],
      ),
    );
  }
}
