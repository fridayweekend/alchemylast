import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});
  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  Future<void> edit([Course? course]) async {
    await showDialog(
      context: context,
      builder: (_) => CourseEditor(course: course),
    );
    if (mounted) setState(() {});
  }

  Future<void> remove(Course course) async {
    if (mockCourses.any((c) => c.prerequisites.contains(course.id))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remove this course from other prerequisites first.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${course.title}?'),
        content: const Text(
          'This removes the course from the catalogue. Existing learning records are retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await saveCourseCatalogue(
        mockCourses.where((c) => c.id != course.id).toList(),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save changes. Please retry.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Build your learning catalogue.',
          eyebrow: 'Admin · Courses',
          subtitle:
              'Manage training, learning resources, assessments and prerequisites.',
        ),
        FilledButton.icon(
          onPressed: () => edit(),
          icon: const Icon(Icons.add),
          label: const Text('Add course'),
        ),
        const SizedBox(height: 24),
        if (mockCourses.isEmpty)
          const Text('Your catalogue is empty. Add your first course.'),
        for (final c in mockCourses)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${c.modules.length} modules · ${c.duration} · ${c.level}',
                  ),
                  Text(c.pdfName ?? 'No PDF attached'),
                  Text('${c.quiz.length} custom quiz questions'),
                  Wrap(
                    spacing: 12,
                    children: [
                      TextButton.icon(
                        onPressed: () => edit(c),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit course'),
                      ),
                      TextButton.icon(
                        onPressed: () => remove(c),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete course'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 32),
      ],
    ),
  );
}

class CourseEditor extends StatefulWidget {
  const CourseEditor({super.key, this.course});
  final Course? course;
  @override
  State<CourseEditor> createState() => _CourseEditorState();
}

class _CourseEditorState extends State<CourseEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.course?.title);
  late final description = TextEditingController(
    text: widget.course?.shortDescription,
  );
  late final duration = TextEditingController(
    text: widget.course?.duration ?? '4 weeks',
  );
  late final modules = TextEditingController(
    text: widget.course?.modules.join('\n'),
  );
  late final quiz = TextEditingController(
    text: widget.course?.quiz
        .map(
          (q) =>
              '${q['prompt']} | ${(q['options'] as List).join(' | ')} | ${q['answer']}',
        )
        .join('\n'),
  );
  late final prerequisites = {...?widget.course?.prerequisites};
  late String? pdfName = widget.course?.pdfName;
  late String? pdfData = widget.course?.pdfBase64;
  String? error;
  bool saving = false;
  @override
  void dispose() {
    for (final c in [title, description, duration, modules, quiz]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> upload() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (picked == null || !mounted) return;
      final file = picked.files.single;
      final bytes = file.bytes;
      if (bytes == null ||
          bytes.length > 3 * 1024 * 1024 ||
          bytes.length < 5 ||
          utf8.decode(bytes.take(5).toList(), allowMalformed: true) !=
              '%PDF-') {
        setState(() => error = 'Choose a valid PDF smaller than 3 MB.');
        return;
      }
      setState(() {
        pdfName = file.name;
        pdfData = base64Encode(bytes);
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => error = 'PDF upload failed. Please try again.');
      }
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final questions = <Map<String, dynamic>>[];
    for (final line
        in quiz.text.split('\n').where((l) => l.trim().isNotEmpty)) {
      final parts = line.split('|').map((s) => s.trim()).toList();
      if (parts.length != 4 ||
          parts.any((p) => p.isEmpty) ||
          !parts.sublist(1, 3).contains(parts.last) ||
          parts[1] == parts[2]) {
        setState(
          () => error =
              'Each quiz line needs: Question | Option A | Option B | Correct option (exact text).',
        );
        return;
      }
      questions.add({
        'prompt': parts[0],
        'options': parts.sublist(1, 3),
        'answer': parts[3],
      });
    }
    if (widget.course == null && questions.isEmpty) {
      setState(() => error = 'Add at least one quiz question.');
      return;
    }
    final list = modules.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (list.isEmpty || list.length > 100) {
      setState(() => error = 'Enter between 1 and 100 modules.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final c = Course(
      id:
          widget.course?.id ??
          'course-${DateTime.now().microsecondsSinceEpoch}',
      title: title.text.trim(),
      shortDescription: description.text.trim(),
      instructor: widget.course?.instructor ?? 'MT Alchemy Learning Team',
      duration: duration.text.trim(),
      level: widget.course?.level ?? 'Beginner',
      rating: widget.course?.rating ?? 0,
      price: widget.course?.price ?? 0,
      modules: list,
      prerequisites: prerequisites.toList(),
      pdfName: pdfName,
      pdfBase64: pdfData,
      quiz: questions,
    );
    try {
      await saveCourseCatalogue([
        ...mockCourses.where((item) => item.id != c.id),
        c,
      ]);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          error =
              'Could not save. Check prerequisites for circular dependencies and available device storage.';
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.course == null ? 'Add course' : 'Edit course'),
    content: SizedBox(
      width: 600,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final field in [
                (title, 'Course title'),
                (description, 'Description'),
                (duration, 'Duration'),
                (modules, 'Modules — one per line'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: field.$1,
                    maxLines: field.$1 == modules ? 5 : null,
                    decoration: InputDecoration(labelText: field.$2),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              const Text('Prerequisites'),
              for (final c in mockCourses.where(
                (c) => c.id != widget.course?.id,
              ))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.title),
                  value: prerequisites.contains(c.id),
                  onChanged: (v) => setState(() {
                    v == true
                        ? prerequisites.add(c.id)
                        : prerequisites.remove(c.id);
                  }),
                ),
              OutlinedButton.icon(
                onPressed: saving ? null : upload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF (up to 3 MB)'),
              ),
              if (pdfName != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pdfName!),
                  trailing: IconButton(
                    tooltip: 'Remove PDF',
                    onPressed: () => setState(() {
                      pdfName = null;
                      pdfData = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quiz,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Quiz questions',
                  helperText:
                      'One per line: Question | Option A | Option B | Correct option',
                  helperMaxLines: 3,
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(saving ? 'Saving…' : 'Save course'),
      ),
    ],
  );
}
